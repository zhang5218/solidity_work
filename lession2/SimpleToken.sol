// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleToken{
    string public name = "My Token";
    string public symbol = "MIT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public owner;
    
    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from,address indexed to,uint256 value);

    constructor(uint256 _initialSupply){
        owner = msg.sender;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply; 
    }

    function transfer(address _to,uint256 _value) public returns (bool){
        require(_to != address(0),"Cannot transfer to zero address");
        require(balanceOf[msg.sender]>=_value,"Insufficient balance");
        balanceOf[msg.sender] = _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function getBalance(address _owner)public view  returns (uint256){
        return balanceOf[_owner];
    }

    function mint(address _to,uint256 _value) public{
        require(msg.sender == owner,"only owner can mint");
        require(_to != address(0), "Cannot mint to zero address");
        totalSupply += _value;
        balanceOf[_to] += _value;
        emit Transfer(address(0), _to, _value);
    }
}