/**
 * Testable/debuggable version of SnailToken.sol.
 *
 * (c) Takeshi Kodo, under the MIT License (MIT)
 */
pragma solidity ^0.5.8;

import './dhelper.sol';
import './SnailToken.sol';


contract TestableSnailToken is SnailToken {
    // FIXME: TEST/DEBUG ONLY
    // BEGIN LOG
    event Log(string message);
    event LogUint(uint message);
    function log(string memory message) public {
        emit Log(message);
    }
    function logUint(uint message) public {
        emit LogUint(message);
    }
    // END LOG

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
}