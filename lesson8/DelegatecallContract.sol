// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogicContract{
    uint256 public value;
    address public owner;

    function setValue(uint256 _value) external {
        value = _value;
        owner = msg.sender;
    }
    function getValue() external view returns (uint256){
        return value;
    }
}

contract ProxyContract{
    address public implementation;
    uint256 public value;
    address public owner;

    event Upgraded(address indexed newImplementation);

    constructor(address _implementation){
        implementation = _implementation;
        owner = msg.sender;
    }
    // fallback函数：将所有调用转发到逻辑合约
    fallback() external payable {
        address impl = implementation;
        require(impl != address(0),"Implementation not set");
        (bool success, bytes memory returnData) = impl.delegatecall(msg.data);
        if(!success){
            assembly{
                returndatacopy(0,0,returndatasize())
                revert(0,returndatasize())
            }
        }
        assembly{
            return(add(returnData,0x20),mload(returnData))
        }
    }
    function upgrade(address newImplementation) external {
        require(msg.sender  == owner,"Not owner");
        implementation = newImplementation;
        emit Upgraded(newImplementation);
    }

   // delegatecall的执行流程：

    // 用户调用 ProxyContract.setValue(100)
    //     ↓
    // ProxyContract的fallback函数被触发（因为Proxy没有setValue函数）
    //     ↓
    // delegatecall到 LogicContract.setValue(100)
    //     ↓
    // LogicContract的代码在ProxyContract的上下文中执行
    //     ↓
    // 修改的是ProxyContract的value和owner（不是LogicContract的）
    //     ↓
    // msg.sender仍然是原始用户（不是ProxyContract）




    receive() external payable { }
}