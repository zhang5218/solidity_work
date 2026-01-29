// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArrayPlusMapping{
    address[] public userList;
    mapping(address => bool) public isUser;
    mapping(address => uint256) public userIndex;

    uint public constant max_user = 1000;

    function addUser(address user) public {
        require(!isUser[user],"User already exists");
        require(userList.length<max_user,"User list is full");
        userList.push(user);
        isUser[user] = true;
        userIndex[user] = userList.length-1;
    }

    function checkUser(address user) public view returns (bool){
        return isUser[user];
    }

    function getAllUsers() public view returns (address[] memory){
        return userList;
    }

    function getUserCount() public view returns (uint){
        return userList.length;
    }

    function deleteUser(address user) public{
        require(isUser[user],"User does not exists");
        uint lastIndex = userList.length-1;
        uint index = userIndex[user];
        if(index != lastIndex){
            address lastUser = userList[lastIndex];
            userList[index] = lastUser;
            userIndex[lastUser] = index;
        }
        userList.pop();
        delete isUser[user];
        delete userIndex[user];
    }
}