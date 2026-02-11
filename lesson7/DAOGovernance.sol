// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DAOGovernance{
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        string decription,
        uint256 startTime,
        uint256 endTime
    );
    event Voted(
        uint256 indexed proposalId,
        address indexed voter,
        bool indexed support,
        uint256 votes,
        string reason
    );
    event ProposalExecuted(
        uint256 indexed proposalId,
        bool indexed  passed,
        uint256 forVotes,
        uint256 againstVotes,
        uint256 executionTime
    );
    event ProposalCanceled(
        uint256 indexed propoalId,
        address indexed canceler,
        string reason
    );

    event VotingPowerChanged(
        address indexed voter,
        uint256 oldPower,
        uint256 newPower,
        uint256 timestamp
    );
    struct Proposal{
        address proposer;
        string description;
        uint256 forVotes;
        uint256 againtsVotes;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        bool passed;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public votingPower;

    uint256 public proposalCount;
    uint256 public constant VOTING_PERIOD = 3 days;
    uint256 public constant QUORUM = 100;

    function createProposal(string memory description) public returns (uint256){
        require(votingPower[msg.sender] > 0,"No voting power");
        uint256 proposalId = proposalCount++;
        Proposal storage proposal = proposals[proposalId];
        proposal.proposer = msg.sender;
        proposal.description = description;
        proposal.startTime = block.timestamp;
        proposal.endTime = block.timestamp + VOTING_PERIOD;

        emit ProposalCreated(proposalId, msg.sender, description, proposal.startTime, proposal.endTime);
        return proposalId;

    }

    function vote(uint256 proposalId,bool support,string memory reason) public {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp>=proposal.startTime,"Voting not started");
        require(block.timestamp<=proposal.endTime,"Voting ended");
        require(!proposal.hasVoted[msg.sender],"Already Voted");
        require(votingPower[msg.sender]>0,"No voting powere");

        uint256 votes = votingPower[msg.sender];
        proposal.hasVoted[msg.sender] = true;
        if(support){
            proposal.forVotes += votes;
        }else{
            proposal.againtsVotes += votes;
        }
        emit Voted(proposalId, msg.sender, support, votes, reason);
    }

    function executeProposal(uint256 proposalId) public{
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp>proposal.endTime,"Voting not ended");
        require(!proposal.executed,"Proposal has executed");
        require(proposal.forVotes + proposal.againtsVotes >= QUORUM,"quorum not reached");
        proposal.executed = true;

        proposal.passed= proposal.forVotes > proposal.againtsVotes;
        emit ProposalExecuted(proposalId, proposal.passed, proposal.forVotes, proposal.againtsVotes, block.timestamp);
        if(proposal.passed){
            //do something
        }
    }

    function cancelProposal(uint256 proposalId,string memory reason) public {
        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer,"Not proposal");
        require(!proposal.executed,"Already executed");
        require(block.timestamp<=proposal.endTime,"Voting ended");
        proposal.executed = true;
        proposal.passed = false;
        emit ProposalCanceled(proposalId, msg.sender, reason);
    }


}