// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyArray{
    uint[] public numbers;

    constructor(){
        numbers = [1,2,3,4,5];
    }

    function removeOrderd(uint index) public{
        require(index<numbers.length,"Index out of bounds");
        for(uint i= index;i<numbers.length-1;i++){
            numbers[i] = numbers[i+1];
        }
        numbers.pop();
    }

    function removeUnOrderd(uint index) public{
        require(index < numbers.length,"Index out of bounds");
        numbers[index] = numbers[numbers.length-1];
        numbers.pop();
    }
}