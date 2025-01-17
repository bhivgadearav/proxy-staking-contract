// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface StakeTokenContract is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

event ERC20TokenStaked (
    address indexed by,
    uint256 amount
);

event ERC20TokenUnstaked (
    address indexed by,
    uint256 amount
);

contract ERC20StakingLogic {
    uint256 public totalStaked;
    mapping(address => uint256) public stakers;
    mapping(address => uint256) public unstakers;
    address stakeToken;

    function stake(IERC20 _tokenAddress, uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0.");
        require(_tokenAddress.allowance(msg.sender, address(this)) >= _amount, "You need to allow contract to spend your stake tokens in order to unstake");
        stakers[msg.sender] += _amount;
        totalStaked += _amount;
        _tokenAddress.transferFrom(msg.sender, address(this), _amount);
        if (StakeTokenContract(stakeToken).balanceOf(address(this)) >= _amount) {
            StakeTokenContract(stakeToken).transfer(msg.sender, _amount);
        } 
        else {
            StakeTokenContract(stakeToken).mint(msg.sender, _amount);
        }
        emit ERC20TokenStaked(msg.sender, _amount);
    }

    function unstake(IERC20 _tokenAddress) public {
        require(stakers[msg.sender] > 0, "You haven't staked any ETH.");
        require(StakeTokenContract(stakeToken).allowance(msg.sender, address(this)) >= stakers[msg.sender], "You need to allow contract to spend your stake tokens in order to unstake");
        if (unstakers[msg.sender] == 0) {
            unstakers[msg.sender] = block.timestamp + 21 * 1 days;
            emit ERC20TokenUnstaked(msg.sender, stakers[msg.sender]);
        } else {
            require(block.timestamp >= unstakers[msg.sender], "You need to wait longer before you can unstake");
            uint256 amount = stakers[msg.sender];
            stakers[msg.sender] = 0;
            unstakers[msg.sender] = 0;
            totalStaked -= amount;
            StakeTokenContract(stakeToken).transferFrom(msg.sender, address(this), amount);
            _tokenAddress.transfer(msg.sender, amount);
        }
    }
}

