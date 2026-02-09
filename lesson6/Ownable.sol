// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable{
    address public owner;

    event OwnerShipTransferred(address indexed previousOwner,address indexed newOwner);

    constructor(){
        owner = msg.sender;
        emit OwnerShipTransferred(address(0), msg.sender);
    }
    modifier onlyOwner(){
        require(msg.sender == owner,"Only owner");
        _;
    }
    function transferOwnership(address newOwner)public onlyOwner{
        require(newOwner != address(0),"Invalid address");
        owner = newOwner;
        emit OwnerShipTransferred(owner, newOwner);
    }
}