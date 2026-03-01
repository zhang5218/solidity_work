// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter{
    uint256 public count;
    address public owner;

    constructor(address _owner){
        owner = _owner;
        count = 0;
    }
    function increment() external {
        require(msg.sender == owner,"Not owner");
        count++;
    }
}
contract CounterFactory{
    address[] public counters;

    event CounterCreated(address indexed counterAddress,address owner);

    function creatCounter() external returns (address){
        Counter counter = new Counter(msg.sender);
        address counterAddress = address(counter);

        counters.push(counterAddress);

        emit CounterCreated(counterAddress,msg.sender);

        return counterAddress;
    }
    function getCounterCount() external view returns (uint256){
        return counters.length;
    }

    function getCounter(uint256 index) external view returns (address){
        require(index < counters.length,"Index out of bounds");
        return counters[index];
    }
}

contract CounterFactoryV2{
    event CounterCreated(address indexed counterAddress,bytes32 salt);
    
    /**
     * @notice 使用new创建（地址不可预测）
     */
    function createWithNew() external returns (address){
        Counter counter = new Counter(msg.sender);
        return address(counter);
    }
     /**
     * @notice 使用create2创建（地址可预测）
     * @param salt 用于计算地址的盐值
     * @return 新创建的计数器合约地址
     */
    function createWithCreate2(bytes32 salt) external returns (address){
        Counter counter = new Counter{salt: salt}(msg.sender);
        address counterAddress = address(counter);

        emit CounterCreated(counterAddress, salt);

        return counterAddress;
    }
     
    /**
     * @notice 预计算create2地址
     * @param salt 盐值
     * @param deployer 部署者地址（通常是本合约地址）
     * @return 预计算的合约地址
     */
    function computeAddress(bytes32 salt,address deployer) external view returns (address){
        // 获取合约的创建字节码
        // type(Counter).creationCode 获取Counter合约的字节码
        // abi.encode(msg.sender) 编码构造函数参数
        bytes memory bytecode = abi.encodePacked(type(Counter).creationCode,abi.encode(msg.sender));
        // 计算create2地址
        // 公式：keccak256(0xff + deployer + salt + keccak256(bytecode))
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff),deployer,salt,keccak256(bytecode)));
        // 将哈希转换为地址（取后20字节）
        return address(uint160(uint256(hash)));
        // create2地址 = keccak256(
        //         0xff +                    // 固定前缀
        //         factory地址 +             // 创建者地址
        //         salt +                    // 盐值（32字节）
        //         keccak256(bytecode)       // 合约字节码的哈希
        // )
    }

}