// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSign{
    //提交提案
    event SubmitTransaction(address indexed owner,uint indexed txIndex,address to ,uint value,bytes data);
    //确认提案
    event ConfirmTransaction(address indexed owner,uint indexed txIndex);
    //撤回提案
    event RevokeConfirmation(address indexed owner,uint indexed txIndex);
    //执行提案
    event ExecuteTransaction(address indexed owner,uint indexed txIndex);
    //所有者列表
    address[] public owners;
    //是否是所有者
    mapping(address => bool) public isOwner;
    //执行交易需要的确认数
    uint public required;

    struct Transaction{
        address to ;//接收者地址
        uint value;//转账金额
        bytes data;//数据
        bool executed;//是否已经执行
        uint numConfirmations;//确认数
    }
    //提案列表
    Transaction[] public transactions;
    //记录交易是否被特定所有者确认
    mapping(uint => mapping(address => bool)) public isConfirmed;

    modifier onlyOwner(){
        require(isOwner[msg.sender],"Not owner");
        _;
    }
    //检查交易是否存在
    modifier txExists(uint _txIndex){
        require(_txIndex < transactions.length,"Transactions not exists");
        _;
    }
    //检查交易未执行
    modifier noExecuted(uint _txIndex){
        require(!transactions[_txIndex].executed,"Transactions already executed");
        _;
    }
    modifier noConfirmed(uint _txIndex){
        require(!isConfirmed[_txIndex][msg.sender],"Transactions already confirmed");
        _;
    }

    constructor(address[] memory _owners,uint _required){
        require(_owners.length>0,"Owners required");
        require(_required>0 && _required<=_owners.length,"Invalid reqired number");
        uint _length = _owners.length;
        for(uint i = 0;i<_length;i++){
            address owner = _owners[i];
            require(owner != address(0),"Invalid owner");
            require(!isOwner[owner],"Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }
    receive() external payable { }
    //提交交易提案
    function submitTransaction(address _to,uint _value,bytes memory _data) public onlyOwner{
        uint txIndex = transactions.length;
        transactions.push(Transaction({
            to:_to,
            value:_value,
            data:_data,
            executed:false,
            numConfirmations:0
        }));
        emit SubmitTransaction(msg.sender,txIndex,_to,_value,_data);
    }

    function confirmTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) noExecuted(_txIndex) noConfirmed(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) noExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.numConfirmations >= required ,"Cannot execute: not enough confirmations");
        transaction.executed = true;
        (bool success,) = transaction.to.call{value:transaction.value}(transaction.data);
        require(success,"Transaction failed");
        emit ExecuteTransaction(msg.sender, _txIndex);
    }
}