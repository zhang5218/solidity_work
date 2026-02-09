// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lesson6/Ownable.sol";
import "lesson6/Pausable.sol";

contract MyContract is Ownable,Pausable{
    uint256 public value;

    function setValue(uint256 _value) public onlyOwner WhenNotPaused{
        value = _value;
    }

    function pause() public onlyOwner{
        _pause();
    }
    
    function unpause() public onlyOwner{
        _unpause();
    }
}