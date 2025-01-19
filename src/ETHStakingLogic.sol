// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

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

// problems - user is not able to stake again and then unstake after claiming rewards
// logic is reliant on value redeemers mapping too much, restricting flexiibility

// solution - make a struct to store the staker's data and then use a mapping to store the struct
// then add tests for claimRewards, getRewards and redeemRewards

contract ETHStakingLogic {
    uint256 public totalStaked;
    mapping(address => uint256) public stakers;
    mapping(address => uint256) public redeemers;
    address stakeToken;

    function stake() payable public {
        require(msg.value > 0, "Amount must be greater than 0.");
        stakers[msg.sender] += msg.value;
        totalStaked += msg.value;
        emit ETHStaked(msg.sender, msg.value);
    }

    function unstake(uint256 _value) public {
        require(stakers[msg.sender] >= _value, "You haven't staked enough ETH.");
        stakers[msg.sender] -= _value;
        payable(msg.sender).transfer(_value);
        emit ETHUnstaked(msg.sender, stakers[msg.sender]);
    }

    function redeemRewards() public {
        require(stakers[msg.sender] > 0, "You haven't staked any ETH.");
        if (redeemers[msg.sender] == 0) {
            redeemers[msg.sender] = block.timestamp + 21 * 1 days;
        } 
        else {
            require(block.timestamp >= redeemers[msg.sender], "You need to wait longer before you can unstake");
            uint256 amount = stakers[msg.sender];
            if (StakeTokenContract(stakeToken).balanceOf(address(this)) >= amount) {
                StakeTokenContract(stakeToken).transfer(msg.sender, amount);
            } 
            else {
                StakeTokenContract(stakeToken).mint(msg.sender, amount);
            }
        }
    }

    function getRewards() public view returns (uint256) {
        require(redeemers[msg.sender] == 0, "You don't have any rewards to redeem.");
        return stakers[msg.sender];
    }
}

