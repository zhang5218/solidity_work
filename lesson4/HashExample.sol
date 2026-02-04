// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HashExample{
    function generateID(address user,uint noce) public pure returns (bytes32){
        return keccak256(abi.encodePacked(user,noce));
    } 

    bytes32 public passwordHash;

    function setPassword(string memory password) public {
        passwordHash = keccak256(bytes(password));
    }

    function checkPassword(string memory password) public view returns (bool){
        return keccak256(bytes(password)) == passwordHash;
    }
    
}