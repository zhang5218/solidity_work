// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AddressSources{
    //用户账户地址
    address user = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    //合约地址
    address contractAddress = address(this);
    //全局变量(调用者地址)
    address owner = msg.sender;
    //计算出地址
    address predicted = address(uint160(uint(keccak256(bytes("123")))));

}