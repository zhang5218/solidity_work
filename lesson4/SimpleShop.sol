// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleShop{
    address public immutable OWNER;
    uint public constant ITEM_PRICE = 0.1 ether;
    mapping(address => uint) public purchases;

    event ItemPurchased(address indexed buyer,uint quantity,uint totalPaid);
    event WithDrawal(address indexed owner,uint amount);

    constructor(){
        OWNER = msg.sender;
    }
    
    modifier onlyOwner(){
        require(msg.sender == OWNER,"Not the owner");
        _;
    }

    function buyItem(uint quantity) public payable {
        require(quantity > 0,"Quantity must be greater than zero");
        uint totalCost = ITEM_PRICE * quantity;
        require(msg.value == totalCost,"Incorrect payment");
        purchases[msg.sender] += quantity;

        emit ItemPurchased(msg.sender, quantity, totalCost);
    }

    function getPruchases(address buyer) public view returns (uint){
        return purchases[buyer];
    }
    
    function withdraw() public onlyOwner{
        uint balance  = address(this).balance;
        require(balance > 0 ,"No balance to withdraw");
        (bool success,) = OWNER.call{value:balance}("");
        require(success,"withdraw failed");
        emit WithDrawal(OWNER, balance);
    }

}