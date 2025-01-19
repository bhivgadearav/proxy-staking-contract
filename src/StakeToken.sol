// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StakeToken is ERC20 {
    address public stakingContract;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyStakingContract() {
        require(msg.sender == stakingContract, "Only staking contract can call this function");
        _;
    }

    constructor(address _owner, address _stakingContract) ERC20("Staked ETH", "sETH") {
        require(_owner != address(0), "Owner cannot be zero address");
        owner = _owner;
        stakingContract = _stakingContract;
    }

    function mint(address to, uint256 amount) external onlyStakingContract {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyStakingContract {
        _burn(from, amount);
    }

    function changeStakingContract(address _newStakingContract) external onlyOwner {
        stakingContract = _newStakingContract;
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}