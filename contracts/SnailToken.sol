/**
 * Mr. Snail is quite slow,
 * other markets falling low..
 * Put some snails in your pocket,
 * take a ride on crypto rocket!
 *
 * (c) Takeshi Kodo, under the MIT License (MIT)
 */
pragma solidity ^0.5.8;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './f64.sol';


/**
 * The price of the token is computed as a ratio of the ETH deposit (reserve) to the
 * total token supply. Deposit, withdraw or transfer operations may charge interest
 * depending on the transaction rate. Interest is added to the common deposit,
 * which is then shared between all of the token holders.
 */
contract SnailToken is ERC20, ERC20Detailed {
    using f64 for int128;
    using SafeMath for uint256;
    int128 private constant MAX_PRICE = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant DONATED = 1618033988749894848204586; //16e24
    uint256 private constant CMP_PCN = 1000000000000000000; //1e18
    address private donationAddress;
    uint256 private donationDate;
    // Track the transfer rates.
    uint256 private lastTrackedDay;
    uint256 private anyLastTracking;
    mapping(address => uint256) private lastHolderTransfer;
    mapping (uint256 => uint256) private lastTotalRates;
    mapping (address => uint256) private lastHolderTrackedDay;
    mapping (address => mapping (uint256 => uint256)) private lastHolderRates;
    // Only last 25 days are considered.
    uint256 public constant NUM_OF_RATES = 25;
    uint256 public constant DAY_IN_SECONDS = 86400;
    int128 private L2;
    int128 private L;
    int128 private M;
    int128 private O;

    event InterestOnSnl(address sender, uint256 snlAmount, uint256 interest);
    event SoldSnl(address buyer, uint256 snlAmount, uint256 ethAmount);
    event BoughtSnl(address seller, uint256 snlAmount, uint256 ethAmount);


    /**
     * Describe token: name, symbol, decimals.. and mint initial supply.
     */
    constructor() ERC20Detailed("SnailToken", "SNL", 18) public {
        donationDate = now;
        donationAddress = msg.sender;
        _mint(msg.sender, DONATED);
        anyLastTracking = now;
        L2 = f64.fromUInt(16);
        L = f64.fromUInt(4);
        M = f64.fromUInt(26);
        O = f64.fromUInt(1);
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a > b) ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a < b) ? a : b;
    }

    function max(int128 a, int128 b) internal pure returns (int128) {
        return (f64.mulu(a, CMP_PCN) > f64.mulu(b, CMP_PCN)) ? a : b;
    }

    function min(int128 a, int128 b) internal pure returns (int128) {
        return (f64.mulu(a, CMP_PCN) < f64.mulu(b, CMP_PCN)) ? a : b;
    }

    /**
     * Prevent donation amount of affecting the price equilibrium.
     */
    function totalSupply() public view returns (uint256) {
        uint256 supplyOfSnl = super.totalSupply();
        if (now < donationDate + 365 days || 2 * balanceOf(donationAddress) > supplyOfSnl) {
            // Distribute donation by ignoring it in the price ratio for the next 365 days
            // and as long as the amount is not negligibly small, i.e. can effect
            // the pricing ratio more than by half.
            supplyOfSnl = supplyOfSnl.sub(balanceOf(donationAddress));
        }
        return (supplyOfSnl == 0) ? 1 : supplyOfSnl;
    }

    /**
     * Learn total ETH deposit supporting the token supply.
     */
    function getEthDeposit() public view returns (uint256) {
        uint256 depositInEth = address(this).balance;
        return (depositInEth == 0) ? 1 : depositInEth;
    }

    /**
     * Learn total rate.
     */
    function getTotalRate(uint256 day) public view returns (uint256) {
        return lastTotalRates[day];
    }

    /**
     * Learn holder's rate.
     */
    function getHolderRate(address holder, uint256 day) public view returns (uint256) {
        return lastHolderRates[holder][day];
    }

    /**
     * Return the SNL/ETH ratio for price calculation.
     *
     * Note that 1 SNL >= 1 ETH.
     *
     * @param baseAmount  unsigned 256-bit integer number
     * @param tokenAmount unsigned 256-bit integer number
     * @return signed 64.64 fixed point number (@see f64.sol)
     */
    function getTokenRatio(uint256 baseAmount, uint256 tokenAmount) internal pure returns (int128) {
        int128 ratio = f64.divu(baseAmount, tokenAmount);
        if (ratio >= MAX_PRICE) {
            return MAX_PRICE;
        } else if (ratio > int128(4 << 64)) {
            return f64.mul(f64.sqrt(ratio), int128(2 << 64));
        } else if (ratio < int128(1 << 64)) {
            return int128(1 << 64);
        }
        return ratio;
    }

    /**
     * Convert SNL to ETH at the inner exchange rate (price), w/o applied interest.
     */
    function convSnl2Eth(uint256 amountSnl) public view returns (uint256) {
        int128 price = getTokenRatio(getEthDeposit(), totalSupply());
        return f64.mulu(price, amountSnl);
    }

    /**
     * Called by a payable function (see convEth2Snl).
     */
    function _convEth2Snl(uint256 amountEth, bool payedToDeposit) internal view returns (uint256) {
        uint256 deposit = getEthDeposit();
        if (payedToDeposit) {
            deposit = (deposit > amountEth) ? deposit.sub(amountEth) : 1;
        }
        int128 revPrice = f64.inv(getTokenRatio(deposit, totalSupply()));
        return f64.mulu(revPrice, amountEth);
    }

    /**
     * Convert ETH to SNL at the inner exchange rate (price), w/o applied interest.
     */
    function convEth2Snl(uint256 amountEth) public view returns (uint256) {
        return _convEth2Snl(amountEth, false);
    }

    /**
     * Track total (global) rates as a sum of all rates.
     */
    function _trackTotalRates(uint256 _value, uint256 currentDay) internal returns (bool)  {
        require(lastTrackedDay <= currentDay, "_trackTotalRates: wrong currentDay");
        lastTotalRates[currentDay] += _value;
        if (lastTrackedDay < currentDay) { lastTrackedDay = currentDay; }
        return true;
    }

    /**
     * Very similar to the global tracking, however applied to individual holder.
     */
    function _trackHolderRates(uint256 _value, uint256 currentDay) internal returns (bool) {
        require(lastHolderTrackedDay[msg.sender] <= currentDay, "_trackHolderRates: wrong currentDay");
        lastHolderRates[msg.sender][currentDay] += _value;
        if (lastHolderTrackedDay[msg.sender] < currentDay) { lastHolderTrackedDay[msg.sender] = currentDay; }
        return true;
    }

    /**
     * Track transfer rates (volumes).
     */
    function trackSnlRates(uint256 _value, uint256 _timestamp) internal returns (bool)  {
        uint256 currentDay = _timestamp / DAY_IN_SECONDS;
        bool res = _trackTotalRates(_value, currentDay);
        res = res && _trackHolderRates(_value, currentDay);
        anyLastTracking = _timestamp;
        return res;
    }

    /**
     * Get transfer rates: total and individual (holder's).
     *
     * Ignore outdated data since last tracking. Return trivial
     * moving average over the array of rates.
     */
    function _getRates(address holder, uint256 currentDay) internal view returns (uint256, uint256) {
        uint256 totalSnlRate = 0;
        uint256 holderSnlRate = 0;
        for (uint256 i = 0; i < NUM_OF_RATES; i++) {
            totalSnlRate += lastTotalRates[currentDay - i];
            holderSnlRate += lastHolderRates[holder][currentDay - i];
        }
        totalSnlRate /= NUM_OF_RATES;
        holderSnlRate /= NUM_OF_RATES;
        require(holderSnlRate <= totalSnlRate, "getRates: individual rate exceeds total rate");
        return (totalSnlRate, holderSnlRate);
    }
    function getRates(address holder, uint256 _timestamp) public view returns (uint256, uint256) {
        uint256 currentDay = _timestamp / DAY_IN_SECONDS;
        return _getRates(holder, currentDay);
    }

    /**
     * Get interest rate based on the rate of the recent transaction volume.
     *
     * Note that any form of transfer including deposits, withdraws or p2p
     * transfer do contribute to the tracked rates equally.
     */
    function _getSnlInterest(address holder, uint256 amountSnl, uint256 _timestamp) internal view returns (int128) {
        (uint256 totalSnlRate, uint256 holderSnlRate) = getRates(holder, _timestamp);
        totalSnlRate += amountSnl;
        holderSnlRate += amountSnl;
        uint256 futureTotalSupply = totalSupply() + amountSnl;
        uint256 futureBalance = balanceOf(holder) + amountSnl;
        int128 futureBalanceRatioPct = f64.divu(futureBalance * 100, futureTotalSupply);
        int128 futureRateRatioPct = f64.divu(holderSnlRate * 100, totalSnlRate);
        int128 interest = min(f64.avg(futureRateRatioPct, futureBalanceRatioPct), M);
        int128 theta = f64.divu(balanceOf(holder) * 100, totalSupply());
        int128 lprime = f64.sqrt(f64.mul(max(min(theta, L2), O), L));
        interest = f64.sub(max(interest, lprime), lprime);
        return interest;
    }
    function getSnlInterestPct(address holder, uint256 amountSnl, uint256 _timestamp) public view returns (uint256) {
        return f64.toUInt(_getSnlInterest(holder, amountSnl, _timestamp));
    }
    function getSnlInterestPct(address holder, uint256 amountSnl) public view returns (uint256) {
        return getSnlInterestPct(holder, amountSnl, now);
    }
    function getSnlInterest(address holder, uint256 amountSnl, uint256 _timestamp) public view returns (uint256) {
        int128 interest = _getSnlInterest(holder, amountSnl, _timestamp);
        uint256 interestSnl = f64.mulu(interest, amountSnl) / 100;
        require(amountSnl > interestSnl, "getSnlInterest: interest exceeds amountSnl");
        return interestSnl;
    }
    function getSnlInterest(address holder, uint256 amountSnl) public view returns (uint256) {
        return getSnlInterest(holder, amountSnl, now);
    }

    /**
     * Same as buying token at market price plus interest.
     */
    function depositEth() public payable returns (bool)  {
        // Donation address is not allowed to affect pricing.
        require(msg.sender != donationAddress, "depositEth: donation address is sealed");
        require(msg.value > 0, "depositEth: msg.value must be above zero");
        uint256 amountSnl = _convEth2Snl(msg.value, true);
        require(amountSnl > 0, "depositEth: amountSnl must be above zero");
        uint256 ts = now;
        uint256 interest = getSnlInterest(msg.sender, amountSnl, ts);
        // Tracking happens after finding and subtracting interest.
        amountSnl = amountSnl.sub(interest);
        trackSnlRates(amountSnl, ts);
        _mint(msg.sender, amountSnl);
        emit BoughtSnl(msg.sender, amountSnl + interest, msg.value);
        emit InterestOnSnl(msg.sender, amountSnl + interest, interest);
        return true;
    }

    /**
     * Same as selling token at market price minus interest.
     */
    function withdrawEth(uint256 amountSnl) public returns (bool)  {
        require(amountSnl > 0, "withdrawEth: amountSnl must be above zero");
        require(balanceOf(msg.sender) >= amountSnl, "withdrawEth: balance is too small");
        uint256 ts = now;
        uint256 interest = getSnlInterest(msg.sender, amountSnl, ts);
        amountSnl = amountSnl.sub(interest);
        trackSnlRates(amountSnl, ts);
        uint256 amountEth = convSnl2Eth(amountSnl);
        uint256 depositInEth = address(this).balance;
        require(depositInEth > amountEth, "withdrawEth: not enough ETH");
        _burn(msg.sender, amountSnl + interest);
        emit SoldSnl(msg.sender, amountSnl + interest, amountEth);
        emit InterestOnSnl(msg.sender, amountSnl + interest, interest);
        require(msg.sender.send(amountEth), "withdrawEth: failed to send ETH");
        return true;
    }

    /**
     * Extend to track transfers.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != donationAddress, "transfer: donation address is sealed");
        uint256 ts = now;
        uint256 interest = getSnlInterest(msg.sender, _value, ts);
        _value = _value.sub(interest);
        require(_value > 0, "transfer: zero value");
        trackSnlRates(_value, ts);
        if (interest > 0) { _burn(msg.sender, interest); }
        emit InterestOnSnl(msg.sender, _value + interest, interest);
        require(super.transfer(_to, _value), "transfer: failed");
        return true;
    }

    /**
     * Extend to track transfers.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != donationAddress, "transferFrom: donation address is sealed");
        uint256 ts = now;
        uint256 interest = getSnlInterest(msg.sender, _value, ts);
        _value = _value.sub(interest);
        require(_value > 0, "transferFrom: zero value");
        trackSnlRates(_value, ts);
        if (interest > 0) { _burn(msg.sender, interest); }
        emit InterestOnSnl(msg.sender, _value + interest, interest);
        require(super.transferFrom(_from, _to, _value), "transferFrom: failed");
        return true;
    }
}
