// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lesson6/Animals.sol";

contract Dog is Animals{
    constructor() Animals("Dog") {}

    function makeSound() public pure override returns (string memory){
        return "woof  woof";
    }
}