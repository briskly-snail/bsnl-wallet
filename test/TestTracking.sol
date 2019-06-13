/**
 * Test tracking function in TestableSnailToken.sol.
 *
 * (c) Takeshi Kodo, under the MIT License (MIT)
 *

The following must be a part of the main contract:

    // FIXME: TEST/DEBUG ONLY
    // BEGIN TRACK
        function trackTotalRates(uint256 _value, uint256 _timestamp) public returns (bool)  {
        uint256 currentDay = _timestamp / DAY_IN_SECONDS;
        return _trackTotalRates(_value, currentDay);
    }
    function trackHolderRates(uint256 _value, uint256 _timestamp) public returns (bool) {
        uint256 currentDay = _timestamp / DAY_IN_SECONDS;
        return _trackHolderRates(_value, currentDay);
    }
    // END TRACK

 */
pragma solidity ^0.5.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/dhelper.sol";
import "../contracts/TestableSnailToken.sol";


contract TestTracking {
    uint private constant DAY_IN_SECONDS = 86400;
    uint private constant E18 = 1000000000000000000; //1e18
    uint private constant N = 25; // number of rates tracked
    uint private ts = now;

    function _ff(uint num_of_days) private {
        ts += DAY_IN_SECONDS * num_of_days + 1;
    }

    function _getCurrTs() public view returns (uint) {
        return ts;
    }

    function _getCurrDay() public view returns (uint) {
        return ts / DAY_IN_SECONDS;
    }

    function testIncrementalTracking() public {
        TestableSnailToken snail = TestableSnailToken(DeployedAddresses.TestableSnailToken());
        address holder = address(this);
        uint amount = E18;
        uint expected;
        uint totalSnlRate;
        uint holderSnlRate;

        // Test total rate tracking of the first 2 txs on the same day.
        _ff(26);
        snail.trackTotalRates(amount, ts);
        snail.trackTotalRates(amount, ts);
        snail.trackHolderRates(amount, ts);
        snail.trackHolderRates(amount, ts);
        // .. assert
        expected = (amount * 2) / 25;
        (totalSnlRate, holderSnlRate) = snail.getRates(holder, ts);
        Assert.equal(totalSnlRate, expected, "Wrong totalSnlRate ..of the first 2 txs on the same day");
        Assert.equal(holderSnlRate, expected, "Wrong holderSnlRate ..of the first 2 txs on the same day");

        // ..of the first 2 txs plus one on the next day.
        _ff(1);
        snail.trackTotalRates(amount, ts);
        snail.trackHolderRates(amount, ts);
        // .. assert
        expected = (amount * 3) / 25;
        (totalSnlRate, holderSnlRate) = snail.getRates(holder, ts);
        Assert.equal(totalSnlRate, expected, "Wrong totalSnlRate ..of the first 2 txs plus one on the next day.");
        Assert.equal(holderSnlRate, expected, "Wrong holderSnlRate ..of the first 2 txs plus one on the next day.");
    }

    function testCompleteCover() public {
        TestableSnailToken snail = TestableSnailToken(DeployedAddresses.TestableSnailToken());
        address holder = address(this);
        uint expected;
        uint totalSnlRate;
        uint holderSnlRate;

        uint[26] memory a;
        for(uint i = 1; i < 27; i++) {
            // 2, 4, 8, 16, 32, 64.. sum(a) := 67108862
            a[i - 1] = E18 * (1 << i);
        }

        // .. clean up previous history
        _ff(2 * 26);
        (totalSnlRate, holderSnlRate) = snail.getRates(holder, ts);
        Assert.equal(totalSnlRate, 0, "Fast forward for x*26 days does not work.");
        Assert.equal(holderSnlRate, 0, "Fast forward for x*26 days does not work.");

        // Cover test over unique sums
        uint unique_sum = 0;
        for(uint i = 1; i < 27; i++) {
            unique_sum += a[i - 1];
            snail.trackTotalRates(a[i - 1], ts);
            snail.trackHolderRates(a[i - 1], ts);
            (totalSnlRate, holderSnlRate) = snail.getRates(holder, ts);
            if (i == 26) {unique_sum -= a[0];}
            expected = unique_sum / 25;
            Assert.equal(totalSnlRate, expected,
                dhelper.strConcat("Cover test for totalSnlRate failed at step: ", dhelper.uint2str(i)));
            Assert.equal(holderSnlRate, expected,
                dhelper.strConcat("Cover test for holderSnlRate failed at step: ", dhelper.uint2str(i)));
            _ff(1);
        }
        expected = 134217724 * E18;
        Assert.equal(unique_sum, expected, "Unmatched final sum.");
    }

    function testTrackingCoolDown() public {
        TestableSnailToken snail = TestableSnailToken(DeployedAddresses.TestableSnailToken());
        address holder = address(this);
        uint amount = E18;
        uint totalSnlRate;
        uint holderSnlRate;

        // .. clean up previous history
        _ff(4 * 26);
        (totalSnlRate, holderSnlRate) = snail.getRates(holder, ts);
        Assert.equal(totalSnlRate, 0, "Fast forward for x*26 days does not work.");
        Assert.equal(holderSnlRate, 0, "Fast forward for x*26 days does not work.");

        // Test total rate tracking of the first 2 txs on the same day.
        snail.trackTotalRates(amount, ts);
        snail.trackHolderRates(amount, ts);
        // ..fast forward 25 days
        _ff(25);
        (totalSnlRate, holderSnlRate) = snail.getRates(holder, ts);
        Assert.equal(totalSnlRate, 0, "Cool down failed");
        Assert.equal(holderSnlRate, 0, "Cool down failed");

        snail.trackTotalRates(amount, ts);
        snail.trackHolderRates(amount, ts);
        (totalSnlRate, holderSnlRate) = snail.getRates(holder, ts);
        Assert.equal(totalSnlRate, amount / 25, "Wrong totalSnlRate ..after cool down");
        Assert.equal(holderSnlRate, amount / 25, "Wrong holderSnlRate ..after cool down");
        _ff(1);
        snail.trackTotalRates(amount, ts);
        snail.trackHolderRates(amount, ts);
        (totalSnlRate, holderSnlRate) = snail.getRates(holder, ts);
        Assert.equal(totalSnlRate, (amount * 2) / 25, "Wrong totalSnlRate ..after cool down and 1 day");
        Assert.equal(holderSnlRate, (amount * 2) / 25, "Wrong holderSnlRate ..after cool down and 1 day");
    }
}