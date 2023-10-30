// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../node_modules/hardhat/console.sol";

contract VotingContract {
    address public immutable owner;

    struct Proposal {
        string description;
        string option1; // First option
        string option2; // Second option
        uint256 voteCountOption1; // Vote count for the first option
        uint256 voteCountOption2; // Vote count for the second option
    }

    Proposal[] public proposals;
    mapping(bytes32 => uint8) public voterChoices; // Use a bytes32 key to combine proposal ID and voter's address

    mapping(address => bool) public hasVoted;

    event ProposalAdded(uint256 proposalId, string description, string option1, string option2);
    event Voted(address voter, uint256 proposalId, uint8 choice);

    
	constructor(address _owner) {
        owner = _owner; // we can use isOwner so that only the owner can add proposals
     }

    function addProposal(string memory _description, string memory _option1, string memory _option2) public {
        proposals.push(Proposal({
            description: _description,
            option1: _option1,
            option2: _option2,
            voteCountOption1: 0,
            voteCountOption2: 0
        }));

        uint256 proposalId = proposals.length - 1;
        emit ProposalAdded(proposalId, _description, _option1, _option2);
    }

    function vote(uint256 _proposalId, uint8 _choice) public {
        require(!hasVoted[msg.sender], "You have already voted.");
        require(_proposalId < proposals.length, "Invalid proposal ID.");
        require(_choice == 1 || _choice == 2, "Invalid choice. Use 1 for the first option and 2 for the second option.");

		// mapping with unique keys for gas efficiency
        bytes32 key = keccak256(abi.encodePacked(_proposalId, msg.sender));
        voterChoices[key] = _choice;

        Proposal storage proposal = proposals[_proposalId];
        if (_choice == 1) {
            proposal.voteCountOption1 += 1;
        } else {
            proposal.voteCountOption2 += 1;
        }

        hasVoted[msg.sender] = true;
        emit Voted(msg.sender, _proposalId, _choice);
    }

    function getProposalCount() public view returns (uint256) {
        return proposals.length;
    }

    function getOptionVoteCount(uint256 _proposalId, uint8 _option) public view returns (uint256) {
        require(_proposalId < proposals.length, "Invalid proposal ID.");
        require(_option == 1 || _option == 2, "Invalid option. Use 1 for the first option and 2 for the second option.");
        Proposal storage proposal = proposals[_proposalId];
        if (_option == 1) {
            return proposal.voteCountOption1;
        } else {
            return proposal.voteCountOption2;
        }
    }

    function getVoterChoice(uint256 _proposalId, address _voter) public view returns (uint8) {
        bytes32 key = keccak256(abi.encodePacked(_proposalId, _voter));
        return voterChoices[key];
    }
}
