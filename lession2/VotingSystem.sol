// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem{
    enum Vote{
        Yes,
        No,
        Abstain
    }

    mapping(address=> Vote) public votes;
    mapping(address=> bool) public hasVoted;

    uint public yesCount;
    uint public noCount;
    uint public abstainCount;

    event Voted(address indexed voter,Vote vote);

    function vote(Vote _vote) public {
        require(!hasVoted[msg.sender],"Already voted");
        votes[msg.sender] = _vote;
        hasVoted[msg.sender] = true;
        if(_vote == Vote.Yes){
            yesCount++;
        }else if(_vote == Vote.No){
            noCount++;
        }else{
            abstainCount++;
        }
        emit Voted(msg.sender,_vote);
    }

    function getResult() public view returns (uint,uint,uint){
        return (yesCount,noCount,abstainCount);
    }

    function getMyVote() public view returns (Vote){
        require(hasVoted[msg.sender],"You haven't voted");
        return votes[msg.sender];
    }

}