// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenWihtMintBurn{
    string public name = "My Token";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address =>mapping(address => uint)) public allowance;

    address public owner;

    event Transfer(address indexed from ,address indexed to ,uint value);
    event Approval(address indexed owner,address indexed spender,uint value);

    constructor(uint _initialSupply){
        totalSupply = _initialSupply * 10 **decimals;
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"only owner");
        _;
    }
    function transfer(address to ,uint amount)public returns (bool) {
        require(to != address(0),"invalid address");
        require(balanceOf[msg.sender] >= amount,"Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);

        return true;
    }
    function approve(address spender,uint amount) public returns (bool){
        require(spender != address(0),"Zero address");
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(address from ,address to,uint amount) public returns (bool){
        require(from != address(0),"From Zero");
        require(to != address(0),"To Zero");
        require(balanceOf[from]>=amount,"Insufficient balance");
        require(allowance[from][msg.sender] >= amount,"Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to ,uint amount) public onlyOwner{
        require(to != address(0),"To Zero");
        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);

    }

    function burn(uint amount) public {
        require(balanceOf[msg.sender] >= amount,"Insufficient balance");
        totalSupply -= amount;
        balanceOf[msg.sender] -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

}