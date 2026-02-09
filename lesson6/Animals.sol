// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract Animals{
    string public species;

    constructor(string memory _species){
        species = _species;
    }
    function makeSound()public virtual returns (string memory);

    function eat() public pure returns (string memory){
        return "eating.....";
    }
    function sleeping() public virtual returns (string memory){
        return "sleeping....";
    }

}