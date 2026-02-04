// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdvancedCrowdFunding{
    enum State {Fundrasing,Successful,Failed,PaidOut}
    State public currentState = State.Fundrasing;
    address public immutable CREATOR;
    uint public immutable GOAL;
    uint public immutable DEADLINE;
    uint public immutable MINIMUM_CONTRIBUTION  = 0.01 ether;

    uint public totalFunded;
    uint public contributorCount;

    mapping(address => uint) public contributions;
    address[] public contributors;

    event StateChanged(State indexed oldState, State indexed newState,uint timestamp);
    event Contribution(address indexed contributor,uint amount,uint totalFunded);
    event FundWithdraw(address indexed creator,uint amount);
    event Refunded(address indexed conributor,uint amount);

    modifier inState(State expected){
        require(currentState == expected,"Invalid State");
        _;
    }

    modifier onlyCreator(){
        require(msg.sender == CREATOR,"only creator");
        _;
    }

    constructor(uint goalAmount,uint durationDays){
        require(goalAmount > 0 ,"Invalid goalAmount");
        require(durationDays >=1 && durationDays <= 90 ,"durationDays:1-90");
        CREATOR = msg.sender;
        GOAL = goalAmount;
        DEADLINE = block.timestamp + (durationDays * 1 days);
    }

    function contribute() public payable inState(State.Fundrasing){
        require(block.timestamp < DEADLINE,"Fundraising ended");
        require(msg.value >= MINIMUM_CONTRIBUTION,"Below minium");
        if(contributions[msg.sender] == 0){
            contributors.push(msg.sender);
            contributorCount++;
        }
        contributions[msg.sender] += msg.value;
        totalFunded += msg.value;

        emit Contribution(msg.sender,msg.value,totalFunded);

        if(totalFunded >= GOAL){
            State oldState = currentState;
            currentState = State.Successful;
            emit StateChanged(oldState,currentState,block.timestamp);
        }
    }
    function CheckGoalReached()public inState(State.Fundrasing){
        require(block.timestamp > DEADLINE,"Still active");
        State oldState = currentState;
        State newState ;
        if(totalFunded >= GOAL){
            newState = State.Successful;
        }else{
            newState = State.Failed;
        }
        currentState = newState;
        emit StateChanged(oldState,newState,block.timestamp);
    }
    function withdrawFunds() public onlyCreator inState(State.Successful){
        currentState = State.PaidOut;
        uint amount = address(this).balance;
        (bool success,) = CREATOR.call{value: amount}("");
        require(success,"Transfer failed");
        emit FundWithdraw(CREATOR, amount);
    }
    function refund()public inState(State.Failed){
        uint amount = contributions[msg.sender];
        require(amount > 0 ,"No contribute");
        contributions[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success,"Refund failed");
        emit Refunded(msg.sender, amount);
    }
}