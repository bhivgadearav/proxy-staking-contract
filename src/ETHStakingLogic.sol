// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

event ETHStaked (
    address by,
    uint256 amount
);

event ETHRestaked (
    address by,
    uint256 amount
);

event ETHUnstaked (
    address by,
    uint256 amount
);

contract ETHStakingLogic {
    uint256 totalStaked;
    mapping(address => uint256) public stakers;
    mapping(address => uint256) public unstakers;

    function stake() payable public {
        require(msg.value > 0, "Amount must be greater than 0.");
        if (unstakers[msg.sender] > 0) {
            unstakers[msg.sender] = 0;
            totalStaked += msg.value;
            emit ETHRestaked(msg.sender, msg.value);
        }
        else {
            stakers[msg.sender] += msg.value;
            totalStaked += msg.value;
            emit ETHStaked(msg.sender, msg.value);
        }
    }

    function unstake() public {
        require(stakers[msg.sender] > 0, "You haven't staked any ETH.");
        if (unstakers[msg.sender] > 0) {
            require(unstakers[msg.sender] < block.timestamp, "You need to wait longer before you can unstake");
            uint256 amount = stakers[msg.sender];
            stakers[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
            unstakers[msg.sender] = 0;
        }
        else {
            unstakers[msg.sender] = block.timestamp + 21 days;
            totalStaked -= stakers[msg.sender];
            emit ETHUnstaked(msg.sender, stakers[msg.sender]);
        }
    }
}
