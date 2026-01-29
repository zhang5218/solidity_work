// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ParameterValidation{
    modifier validAddress(address _addr){
        require(_addr != address(0),"Invalid address");
        _;
    }

    modifier minValue(uint256 _minValue){
        require(msg.value >= _minValue,"Insufficient value");
        _;
    }

    modifier inRange(uint256 _value,uint256 _min,uint256 _max){
        require(_value>=_min && _value<=_max,"Value out of range");
        _;
    }

    function transfer(address to,uint256 amount)public validAddress(to){

    }

    function deposit() public payable minValue(0.1 ether){

    }

    function setValue(uint256 _value) public inRange(_value,1,100){

    }
}