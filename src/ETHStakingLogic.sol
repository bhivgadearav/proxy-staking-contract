// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./ETHStakingData.sol";

interface StakeTokenContract is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

event ETHStaked (
    address indexed by,
    uint256 amount
);

event ETHUnstaked (
    address indexed by,
    uint256 amount
);

// see if this contract passes the tests he wrote in the solution

contract ETHStakingLogic {
    uint256 public totalStaked;
    uint256 public dailyReward = 1;
    uint256 public rewardMultiplierPerETH = 1;
    mapping(address => StakeDetails) public stakers;
    mapping (address => uint256) public rewards;
    mapping(address => uint256) public rewardClaims;
    address stakeToken;

    modifier onlyStaker {
        require(stakers[msg.sender].lastUpdate > 0, "You are not a staker.");
        _;
    }

    function stake() payable public {
        require(rewardClaims[msg.sender] == 0, "You have to wait before you can stake again.");
        require(msg.value > 0, "Amount must be greater than 0.");
        calculateAndSetRewards(msg.sender);
        stakers[msg.sender].amount += msg.value;
        stakers[msg.sender].lastUpdate = block.timestamp;
        totalStaked += msg.value;
        emit ETHStaked(msg.sender, msg.value);
    }

    function unstake(uint256 _amount) public onlyStaker {
        require(stakers[msg.sender].amount >= _amount, "You haven't staked enough ETH.");
        calculateAndSetRewards(msg.sender);
        stakers[msg.sender].amount -= _amount;
        stakers[msg.sender].lastUpdate = block.timestamp;
        payable(msg.sender).transfer(_amount);
        emit ETHUnstaked(msg.sender, _amount);
    }

    function redeemRewards() public onlyStaker {
        if (rewardClaims[msg.sender] == 0) {
            calculateAndSetRewards(msg.sender);
            stakers[msg.sender].amount = 0;
            stakers[msg.sender].lastUpdate = block.timestamp;
            rewardClaims[msg.sender] = block.timestamp + 21 * 1 days;
        } 
        else {
            require(block.timestamp >= rewardClaims[msg.sender], "You need to wait longer before you can redeem.");
            uint256 amount = rewards[msg.sender];
            sendTokens(msg.sender, amount);
            rewards[msg.sender] = 0;
        }
    }

    function sendTokens(address _to, uint256 _amount) internal {
        if (StakeTokenContract(stakeToken).balanceOf(address(this)) >= _amount) {
            StakeTokenContract(stakeToken).transfer(_to, _amount);
        } 
        else {
            StakeTokenContract(stakeToken).mint(_to, _amount);
        }
    }

    function getRewards() public onlyStaker returns (uint256) {
        if (rewardClaims[msg.sender] == 0) {
            calculateAndSetRewards(msg.sender);
            stakers[msg.sender].lastUpdate = block.timestamp;
            return rewards[msg.sender];
        }
        else {
            return rewards[msg.sender];
        }
    }

    function stakedBalance() public view onlyStaker returns (uint256) {
        return stakers[msg.sender].amount;
    }

    function calculateAndSetRewards(address _user) internal {
        uint256 timeDiff = block.timestamp - stakers[_user].lastUpdate;
        rewards[_user] = (timeDiff * dailyReward * stakers[_user].amount) / (1 days * 1 ether);
    }
}

