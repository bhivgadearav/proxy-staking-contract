// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface StakeTokenContract is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

event TokenStaked (
    address indexed by,
    uint256 amount
);

event TokenUnstaked (
    address indexed by,
    uint256 amount
);

contract ERC20StakingLogic {
    uint256 public totalStaked;
    mapping(address => uint256) public stakers;
    mapping(address => uint256) public redeemers;
    address validToken;
    address stakeToken;

    function stake(IERC20 _tokenAddress, uint256 _amount) public {
        require(_tokenAddress == validToken, "You can only stake valid tokens.");
        require(_tokenAddress.allowance(msg.sender, address(this)) >= _amount, "You need to allow contract to spend your tokens in order to stake");
        require(_amount > 0, "Amount must be greater than 0.");
        _tokenAddress.transferFrom(msg.sender, address(this), _amount);
        stakers[msg.sender] += _amount;
        totalStaked += _amount;
        emit TokenStaked(msg.sender, _amount);
    }

    function unstake(IERC20 _tokenAddress, , uint256 _amount) public {
        require(stakers[msg.sender] > 0, "You haven't staked any tokens.");
        require(stakers[msg.sender] >= _amount, "You haven't staked enough tokens.");
        stakers[msg.sender] -= _amount;
        _tokenAddress.transfer(msg.sender, _amount);
        emit TokenUnstaked(msg.sender, _amount);
    }

    function getRewards() public view returns (uint256) {
        require(redeemers[msg.sender] == 0, "You don't have any rewards to redeem.");
        return stakers[msg.sender];
    }

    function redeemRewards() public {}

    function stakedBalance() public view returns (uint256) {
        return stakers[msg.sender];
    }
}

