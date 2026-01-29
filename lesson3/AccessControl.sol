// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl{
    address public owner;
    mapping(address => bool) public admins;

    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner,"Not the owner");
        _;
    }
    modifier onlyAdmin(){
        require(admins[msg.sender],"Not the admin");
        _;
    }
    modifier onlyAuthorized(){
        require(msg.sender == owner || admins[msg.sender],"Not authorzied");
        _;
    }

}