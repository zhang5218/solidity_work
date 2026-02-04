// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlockHash{
    //只能获取最近256个块的哈希
    //更早的块返回bytes32(0)
    function getRecentBlockHash(uint blockNumber) public view returns (bytes32){
        require(blockNumber<block.number,"Block not yet mined");
        require(block.number-blockNumber<=256,"Block too old");
        return blockhash(blockNumber);
    }

}