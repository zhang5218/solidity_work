// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TargetContract{
    uint256 public value = 100;

    function getValue() external view returns (uint256){
        return value;
    }

    function setValue(uint256 _value) external {
        value = _value;
    }
}

contract StaticCallDemo{
    function safeGetValue(address target) external view returns (uint256){
        (bool success,bytes memory returnData) = 
        target.staticcall(abi.encodeWithSignature("getValue()"));
        require(success,"staticcall failed");
        uint256 value = abi.decode(returnData, (uint256));
        return value;
    }
    function unSafeSetValue(address target,uint256 newValue) external {
        (bool success,) = target.staticcall(abi.encodeWithSignature("setValue(uint256", newValue));
         // success会是false，因为staticcall不允许修改状态
        require(success,"staticcall failed: cannot modify state");
    }
}