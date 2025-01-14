// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ETHStakingLogic {
    mapping(address => uint256) public stakers;
    mapping(address => uint256) public unstakers;

    function stake() payable public {
        require(msg.value > 0, "Amount must be greater than 0.");
        stakers[msg.sender] += msg.value;
    }

    function unstake() public {
        require(stakers[msg.sender] > 0, "You haven't staked any ETH.");
        if (unstakers[msg.sender] > 0) {
            require(unstakers[msg.sender] < block.timestamp, "You need to wait longer before you can unstake");
            uint256 amount = stakers[msg.sender];
            stakers[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
        else {
            unstakers[msg.sender] = block.timestamp + 21 days;
        }
    }
}
