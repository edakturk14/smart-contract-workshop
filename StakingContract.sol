// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../node_modules/hardhat/console.sol";

contract StakingContract {
    uint256 public totalStaked;
    uint256 public requiredStakeInEther; // The required stake in Wei
    address[] public stakers;
    address public winner;
    bool public stakingOpen = true;

    mapping(address => uint256) public stakedAmount;
    bool public winnerHasWithdrawn;

    event Staked(address indexed staker, uint256 amount);
    event Withdrawn(address indexed staker, uint256 amount);
    event WinnerSelected(address indexed winner, uint256 prize);

    constructor(uint256 _requiredStakeInEther) {
        requiredStakeInEther = 0.1 ether;
    }

    function stake() external payable {
        // msg.value is in wei!! 
        require(stakingOpen, "Staking is closed.");
        require(msg.value >= requiredStakeInEther, "Staked amount must be greater than or equal to the required stake.");
        
        totalStaked += msg.value;
        
        if (stakedAmount[msg.sender] == 0) {
            stakers.push(msg.sender);
        }
        
        stakedAmount[msg.sender] += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    function closeStaking() external {
        stakingOpen = false;
    }

    function selectWinner() external {
        require(!stakingOpen, "Staking is still open.");
        require(stakers.length > 0, "No stakers available.");

        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % stakers.length;
        winner = stakers[randomIndex];
        winnerHasWithdrawn = false;
        emit WinnerSelected(winner, address(this).balance);
    }

    function getStakerCount() external view returns (uint256) {
        return stakers.length;
    }

    function readWinner() external view returns (address) {
        return winner;
    }

    function withdrawPrize() external {
        require(msg.sender == winner, "Only the winner can withdraw the prize.");
        require(!winnerHasWithdrawn, "Prize has already been withdrawn.");
        require(!stakingOpen, "Staking is still open.");
        winnerHasWithdrawn = true;
        payable(winner).transfer(address(this).balance);
    }
}
