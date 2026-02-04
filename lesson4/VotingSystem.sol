// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem{
    struct Proposal{
        string description;
        uint voteCount;
        uint deadline;
        bool exists;
    }
    address public owner;
    uint public proposalCount;
    mapping(uint => Proposal) public proposals;
    mapping(uint => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint indexed proposalId,string description,uint deadline);
    event Voted(uint indexed proposalId,address indexed owner);

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"Only owner can call");
        _;
    }
    function createProposal(string memory description,uint durationDays) public onlyOwner{
        require(bytes(description).length>0,"Empyt description");
        require(durationDays >= 1 && durationDays <= 30,"Ivalid duration");
        uint proposalId = proposalCount++;
        uint deadline = block.timestamp + (durationDays * 1 days);
        proposals[proposalId] = Proposal({
            description: description,
            voteCount:0,
            deadline: deadline,
            exists: true
        });
        emit ProposalCreated(proposalId,description,deadline);
    }
    function vote(uint proposalId) public {
        require(proposals[proposalId].exists,"Proposal does not exists");
        require(block.timestamp<=proposals[proposalId].deadline,"Voting has ended");
        require(!hasVoted[proposalId][msg.sender],"Already voted");

        hasVoted[proposalId][msg.sender] = true;
        proposals[proposalId].voteCount++;
        emit Voted(proposalId, msg.sender);
    }

    function getWinner() public view returns (uint winnerProposalId){
        uint maxVotes = 0;
        for(uint i = 0;i<proposalCount;i++){
            if(proposals[i].voteCount > maxVotes){
                maxVotes = proposals[i].voteCount;
                winnerProposalId = i;
            }
        }
        return winnerProposalId;
    }

    function getProposalInfo(uint proposalId) public view returns (
        string memory description,uint voteCount,uint deadline,bool hasEnd
    ){
        require(proposals[proposalId].exists,"Proposal does not exists");
        Proposal memory p = proposals[proposalId];
        return (p.description,p.voteCount,p.deadline,block.timestamp>p.deadline);
    }
}