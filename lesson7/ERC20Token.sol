// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ERC20Token{
    string public name = "MyToken";
    string public symbol = "MT";
    uint8 public decimal = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to,uint256 value);

    event Approval(address indexed owner,address indexed spender,uint256 value);

    constructor(uint256 _initialSupply){
        totalSupply = _initialSupply * 10**decimal;
        balanceOf[msg.sender] = totalSupply;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to,uint256 amount) public returns (bool){
        require(to != address(0),"Invalid address");
        require(balanceOf[msg.sender]>=amount,"Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender,uint256 amount) public returns (bool){
        require(spender != address(0),"Invalid address");
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from ,address to,uint256 amount) public returns (bool){
        require(from != address(0),"Invalid sender");
        require(to != address(0),"Invalid recipient");
        require(balanceOf[from] >= amount,"Insufficient balance");
        require(allowance[from][msg.sender] >= amount,"Insufficient allowance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to,uint256 amount) public {
        require(to != address(0),"Invalid address");
        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    function burn(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount,"Insufficient balance");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }
}