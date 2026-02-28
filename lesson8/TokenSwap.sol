// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender,uint256) external returns (bool);
    function transferfrom(address from,address to,uint256 amount) external returns (bool);
}

contract TokenSwap{
    // 声明两个代币接口变量
    IERC20 public tokenA;
    IERC20 public tokenB;
    event Swap(address indexed user,uint256 amountA,uint256 amountB);
    // 构造函数：初始化两个代币合约地址
    constructor(address _tokenA,address _tokenB){
        // 将地址转换为接口类型，这样就可以调用接口中定义的方法
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function swap(uint256 amountA) external {
         // 步骤1：从用户账户转移tokenA到本合约
        // transferFrom需要用户先调用approve授权本合约使用其代币
        // 如果转账失败，require会回滚整个交易
        require(tokenA.transferfrom(msg.sender,address(this),amountA),"TokenA transfer failed");
         // 步骤2：计算可交换的tokenB数量（简化示例，1:1兑换）
        uint256 amountB = amountA;
        // 步骤3：从本合约向用户转移tokenB
        // 如果转账失败，require会回滚整个交易
        require(tokenB.transfer(msg.sender, amountB),"TokenB transfer failed");

        emit Swap(msg.sender, amountA, amountB);

    }

    function getBalances() external view returns (uint256 amountA,uint256 amountB){
        amountA = tokenA.balanceOf(address(this));
        amountB = tokenB.balanceOf(address(this));
    }
}