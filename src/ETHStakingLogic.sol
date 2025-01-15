// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface StakeTokenContract is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

event ETHStaked (
    address by,
    uint256 amount
);

event ETHUnstaked (
    address by,
    uint256 amount
);

contract ETHStakingLogic {
    uint256 public totalStaked;
    mapping(address => uint256) public stakers;
    mapping(address => uint256) public unstakers;
    address stakeToken;

    function stake(address _sender, uint256 _value) payable public {
        require(_value > 0, "Amount must be greater than 0.");
        if (unstakers[_sender] > 0) {
            unstakers[_sender] = 0;
            totalStaked += _value;
        }
        else {
            stakers[_sender] += _value;
            totalStaked += _value;
        }
        if (StakeTokenContract(stakeToken).balanceOf(address(this)) >= _value) {
            StakeTokenContract(stakeToken).transfer(_sender, _value);
        } 
        else {
            StakeTokenContract(stakeToken).mint(_sender, _value);
        }
        emit ETHStaked(_sender, _value);
    }

    function unstake() public {
        require(stakers[msg.sender] > 0, "You haven't staked any ETH.");
        require(StakeTokenContract(stakeToken).allowance(msg.sender, address(this)) >= stakers[msg.sender], "You need to allow contract to spend your stake tokens in order to unstake");
        if (unstakers[msg.sender] == 0) {
            unstakers[msg.sender] = block.timestamp + 21 * 1 days;
            emit ETHUnstaked(msg.sender, stakers[msg.sender]);
        } else {
            require(block.timestamp >= unstakers[msg.sender], "You need to wait longer before you can unstake");
            uint256 amount = stakers[msg.sender];
            stakers[msg.sender] = 0;
            unstakers[msg.sender] = 0;
            totalStaked -= amount;
            StakeTokenContract(stakeToken).transferFrom(msg.sender, address(this), amount);
            payable(msg.sender).transfer(amount);
        }
    }

    receive() external payable {
        stake(msg.sender, msg.value);
    }
}

