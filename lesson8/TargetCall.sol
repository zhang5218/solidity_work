// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TargetContract{
    uint256 public value;
    address public sender;

    function setValue(uint256 _value) external payable {
        value = _value;
        sender = msg.sender;
    }

    function getValue() external  view returns (uint256){
        return value;
    }
}

contract CallerContract{
    function callSetValue(address target,uint256 newValue) external payable {
       (bool success,) = target.call{value:msg.value} (
            abi.encodeWithSignature("setValue(uint256)", newValue)
        );
        require(success,"Call failed");
    }
}