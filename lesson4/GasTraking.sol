// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasTracking{
    function expensiveOperation() public view returns (uint gasUsed){
        uint gasBefore = gasleft();
        uint sum = 0;
        for(uint i = 0;i<100;i++){
            sum += i;
        }
        gasUsed = gasBefore - gasleft();
        return gasUsed;
    }
    
}