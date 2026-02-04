// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CodeCheck{
    //检查地址是否是合约
    function isContract(address account) public view returns (bool){
        return account.code.length > 0;
    }
    //获取合约字节码
    function getCode(address account) public view returns (bytes memory){
        return account.code;
    }
    //获取代码哈希
    function getCodeHash(address account) public view returns (bytes32){
        return account.codehash;
    }

    //应用场景
    // 防止合约调用（只允许EOA）
    function onlyEOA() public view {
        require(msg.sender.code.length == 0, "Contracts not allowed");
        // 只有外部账户（EOA）代码长度为0
    }
    
    // 确保是合约地址
    function onlyContract(address target) public view {
        require(target.code.length > 0, "Not a contract");
    }
}