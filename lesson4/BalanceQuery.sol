// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BalanceQuery{
    function getBalance(address account) public view returns(uint){
        return account.balance;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function getMyBalance() public view returns(uint){
        return msg.sender.balance;
    }
    function hasEnougthBalance(address account,uint required)public view returns (bool){
        return account.balance>required;
    }
    
}