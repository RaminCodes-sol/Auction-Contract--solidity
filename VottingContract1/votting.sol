// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract VottingContract {
    address public ownerAddress;
    uint8 public idCounter;


    enum Status {
        preStart,
        start,
        end
    }

    struct CandidaStruct {
        string name;
        uint8 id;
        uint256 votesRecieved;
    }

    struct VoterStruct {
        string name;
        bool alreadyVoted;
        uint8 candidaID;
    }
    
    Status public electionStatus;
    CandidaStruct [] public candidas;
    mapping(address => VoterStruct) public voters;


    constructor () {
        ownerAddress = msg.sender;
        electionStatus = Status.preStart;
    }


    modifier Owner {
        require(ownerAddress == msg.sender, "Only owner can call this function!");
        _;
    }

    function changeStatus (uint8 _id) public Owner {
        if (_id == 1) {
            electionStatus = Status.start;
        } else if (_id == 2) {
            electionStatus = Status.end;
        }
    }

    function addCandida (string memory _name) public Owner {
        require(electionStatus == Status.preStart, "Election Status should be in preStart!");
        candidas.push(CandidaStruct(_name, idCounter, 0));
        idCounter ++;
    }

    function vote (string memory _name, uint8 _candidaId) public {
        require(electionStatus == Status.start, "Election Status should be in start!");
        require(voters[msg.sender].alreadyVoted == false, "You have already voted!");

        voters[msg.sender] = VoterStruct(_name, true, _candidaId);
        candidas[_candidaId].votesRecieved += 1;
    }
    
    function winner () public view Owner returns(uint8, string memory, uint) {
        require (electionStatus == Status.end, "Election Status should be in end!");
        uint256 maximum = 0;
        uint8 winnerIndex;
        for (uint8 i = 0; i < candidas.length; i++) {
            if (candidas[i].votesRecieved > maximum) {
                maximum = candidas[i].votesRecieved;
                winnerIndex = i;
            }
        }
        return (winnerIndex, candidas[winnerIndex].name, candidas[winnerIndex].votesRecieved);
    }
       
}


