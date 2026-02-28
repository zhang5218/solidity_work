// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract TokenWithCustomErrors{
    error InsufficientBalance(address account,uint256 available,uint256 required);
    error InsufficientAllowance(address owner,address spender,uint256 available,uint256 required);
    error InvalidRecipient(address recipient);
    error InvalidAmount(uint256 amount);
    error Unauthorized(address caller);
    error TransferPaused();
    error ExceedsMaxSupply(uint256 requested,uint256 maxSupply);
    error ArrayLengthMismatch(uint256 length1,uint256 length2);

    string public name = "CustomeError Token";
    string public symbol = "CET";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public constant MAX_SUPPLY = 1000000*10**18;

    address public owner;
    bool public paused;

    mapping(address =>uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from,address indexed to,uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    event Pause();
    event Unpuase();

    modifier onlyOwner(){
        if(msg.sender != owner){
            revert Unauthorized(msg.sender);
        }
        _;
    }
    modifier whenNotPaused(){
        if(paused){
            revert TransferPaused();
        }
        _;
    }

    function transfer(address to,uint256 amount) public whenNotPaused returns (bool){
        if(to == address(0)){
            revert InvalidRecipient(to);
        }
        if(amount == 0){
            revert InvalidAmount(amount);
        }
        if(balanceOf[msg.sender] < amount){
            revert InsufficientBalance(msg.sender,balanceOf[msg.sender],amount);
        }
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    function approve(address spender,uint256 amount) public returns (bool){
        if(spender == address(0)){
            revert InvalidRecipient(spender);
        }
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public whenNotPaused returns (bool){
        if(to == address(0)) revert InvalidRecipient(to);
        if(amount == 0) revert InvalidAmount(amount);
        if(balanceOf[from]<amount) revert InsufficientBalance(from,balanceOf[from],amount);
        if(allowance[from][msg.sender]<amount){
            revert InsufficientAllowance(from,msg.sender,allowance[from][msg.sender],amount);
        }
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function batchTransfer(address[] memory recipients,uint256[] memory amounts) public whenNotPaused returns (bool){
        if(recipients.length != amounts.length){
            revert ArrayLengthMismatch(recipients.length,amounts.length);
        }
        uint256 totalAmount = 0;
        for(uint256 i = 0;i<amounts.length;i++){
            totalAmount += amounts[i];
        }
        if(balanceOf[msg.sender]<totalAmount){
            revert InsufficientBalance(msg.sender,balanceOf[msg.sender],totalAmount);
        }
        for(uint256 i = 0;i<recipients.length;i++){
            if(recipients[i] == address(0)){
                revert InvalidRecipient(recipients[i]);
            }
            balanceOf[msg.sender] -= amounts[i];
            balanceOf[recipients[i]] += amounts[i];
            emit Transfer(msg.sender, recipients[i], amounts[i]);
        }
        return true;
    }
    function mint(address to,uint256 amount) public onlyOwner{
        if(to == address(0)) revert InvalidRecipient(to);
        if(totalSupply + amount > MAX_SUPPLY){
            revert ExceedsMaxSupply(totalSupply + amount,MAX_SUPPLY);
        }
        _mint(to, amount);
    }
    function burn(uint256 amount) public {
        if(balanceOf[msg.sender]<amount){
            revert InsufficientBalance(msg.sender,balanceOf[msg.sender],amount);
        }
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
    function pause() public onlyOwner{
        paused = true;
        emit Pause();
    }
    function unpause()public onlyOwner{
        paused = false;
        emit Unpuase();
    }





    function _mint(address to,uint256 amount) private{
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

}