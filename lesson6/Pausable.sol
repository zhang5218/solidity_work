// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Pausable{
    bool public paused;

    event Paused(address account);
    event Unpaused(address account);

    modifier WhenNotPaused(){
        require(!paused,"Contract is paused");
        _;
    }
    modifier WhenPaused(){
        require(paused,"Constract is not paused");
        _;
    }
    function _pause() internal WhenNotPaused{
        paused = true;
        emit Paused(msg.sender);
    }
    function _unpause() internal WhenNotPaused{
        paused = false;
        emit Unpaused(msg.sender);
    }
    
}