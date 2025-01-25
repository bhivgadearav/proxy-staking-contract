// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../src/ERC20StakingData.sol";
import "../src/ERC20StakingLogic.sol";
import "../src/StakeToken.sol";
import "../src/CustomToken.sol";

contract ETHStakingTest is Test {
    ERC20StakingData stakingDataContract;
    ERC20StakingLogic stakingLogicContract;
    StakeToken stakeTokenContract;
    CustomToken customTokenContract;
    
    address user = makeAddr("user");
}