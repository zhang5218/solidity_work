// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoleMangement{
    enum Role{None,User,Admin,Owner}

    mapping(address => Role) public roles;

    address public owner;

    event RoleAssigned(address indexed  user,Role role);
    event RoleRevoked(address indexed user);

    constructor(){
        owner = msg.sender;
        roles[msg.sender] = Role.Owner;
        emit RoleAssigned(msg.sender,Role.Owner);
    }

    modifier onlyOwner(){
        require(roles[msg.sender] == Role.Owner,"only owner can call");
        _;
    }
    modifier onlyAdmin(){
        require(roles[msg.sender] == Role.Admin,"Not Admin");
        _;
    }
    function addAdmin(address user) public onlyOwner{
        require(user != address(0),"Invalid adress");
        require(roles[user] != Role.Owner,"can not change role");
        roles[user] = Role.Admin;
        emit RoleAssigned(user, Role.Admin);
    }
    function addUser(address user) public onlyAdmin{
        roles[user] = Role.User;
    }
    function getRole(address user) public view returns (Role) {

    }
}