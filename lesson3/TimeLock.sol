// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLock{
    uint256 public lockTime;
    modifier afterTime(uint256 _time){
        require(block.timestamp>=_time,"Too early");
        _;
    }
    modifier beforeTime(uint256 _time){
        require(block.timestamp<_time,"Too late");
        _;
    }
    constructor(){
        lockTime = block.timestamp + 1 days;
    }
    function executeAfterLock()public afterTime(lockTime){
    }
    function executeBeforeLock() public beforeTime(lockTime){
        
    }
}