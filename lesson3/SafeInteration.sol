// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SafeInteration {
    uint[] public data;
    uint public constant max_array_size = 100;

    function safePush(uint value) public {
        require(data.length<max_array_size,"Array is full");
        data.push(value);
    }

    function sumRange(uint start,uint end)public view returns (uint){
        require(start<end,"Invalid range");
        require(end<data.length,"End out of bounds");
        require(end-start<50,"Range too large");
        
        uint total = 0;
        for(uint i = start;i<end;i++){
            total += data[i];
        }
        return total;
    }
    
}
