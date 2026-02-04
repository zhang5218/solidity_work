// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReentrcyGuard{
    bool private locked;
    
    modifier noRenentrant(){
        require(!locked,"Reentrant call");
        locked = true;
        _;
        locked = false;
    }
    
}