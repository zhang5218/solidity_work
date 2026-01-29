// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PaymentContract{
    address public owner;
    bool public paused = false;
    mapping(address => uint256) balances;

    uint256 public constant MIN_DEPOSIT = 0.01 ether;

    event Deposit(address indexed user,uint256 amount);
    event Withdrawal(address indexed user,uint256 amount);
    event Paused(address indexed by);
    event Unpaused(address indexed by);

    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner,"Not the owner");
        _;
    }
    modifier whenNotPaused(){
        require(!paused,"constract is paused");
        _;
    }
    modifier whenPaused(){
        require(paused,"contract is not paused");
        _;
    }
    modifier minValue(uint256 amount){
        require(msg.value >= amount,"Insufficient value");
        _;
    }
    function deposit() public payable whenNotPaused minValue(MIN_DEPOSIT){
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender,msg.value);
    }
    function withdraw(uint256 amount) public payable whenNotPaused{
        require(balances[msg.sender] >= amount,"Insufficient balance");
        balances[msg.sender] -= amount;
        //payable(msg.sender).transfer(amount);
        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success,"call failed");
        emit Withdrawal(msg.sender, amount);
    }

    function getBalance() public view returns (uint256){
        return balances[msg.sender];
    }
    function getContractBalance() public view returns (uint256){
        return address(this).balance;
    }
    function pause() public onlyOwner whenNotPaused{
        paused = true;
        emit Paused(msg.sender);
    }
    function unpause() public onlyOwner whenPaused{
        paused = false;
        emit Unpaused(msg.sender);
    }
    receive() external payable { deposit();}

}