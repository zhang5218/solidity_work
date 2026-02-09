// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lesson6/Animals.sol";

contract Cat is Animals{
    constructor() Animals("Cat"){}

    function makeSound()public pure override returns (string memory){
        return "Meow";
    }
}