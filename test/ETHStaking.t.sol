// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ETHStakingData.sol";
import "../src/ETHStakingLogic.sol";
import "../src/StakeToken.sol";

contract ETHStakingTest is Test {
    ETHStakingData stakingData;
    ETHStakingLogic stakingLogic;
    StakeToken stakeToken;

    address user = makeAddr("user");

    function setUp() public {
        stakingLogic = new ETHStakingLogic();
        stakingData = new ETHStakingData(address(stakingLogic));
        stakeToken = new StakeToken(address(user), address(stakingData));
        stakingData.setStakeToken(address(stakeToken));
    }

    function testStake() public {
        vm.deal(user, 10 ether);
        vm.startPrank(user);

        (bool success, ) = address(stakingData).call{value: 1 ether}(abi.encodeWithSignature("stake()"));
        assertTrue(success);

        uint256 stakedAmount = stakingData.stakers(user);
        assertEq(stakedAmount, 1 ether);

        vm.stopPrank();
    }

    function testUnstake() public {
        vm.deal(user, 10 ether);
        vm.startPrank(user);

        (bool success, ) = address(stakingData).call{value: 1 ether}(abi.encodeWithSignature("stake()"));
        assertTrue(success);

        uint256 stakedAmount = stakingData.stakers(user);
        assertEq(stakedAmount, 1 ether);

        (success, ) = address(stakingData).call(abi.encodeWithSignature("unstake(uint256)", 1 ether));
        assertTrue(success);

        stakedAmount = stakingData.stakers(user);
        assertEq(stakedAmount, 0);

        vm.stopPrank();
    }

    function testGetRewards() public {
        bool success;
        bytes memory data;

        vm.deal(user, 10 ether);
        vm.startPrank(user);

        // Stake ETH
        (success, ) = address(stakingData).call{value: 1 ether}(abi.encodeWithSignature("stake()"));
        assertTrue(success);

        uint256 stakedAmount = stakingData.stakers(user);
        assertEq(stakedAmount, 1 ether);

        // Get rewards and verify return data
        (success, data) = address(stakingData).call(abi.encodeWithSignature("getRewards()"));
        assertTrue(success);
        assertTrue(data.length == 32, "Return data should be 32 bytes (uint256)");

        uint256 rewards = abi.decode(data, (uint256));
        assertEq(rewards, 1 ether);

        vm.stopPrank();
    }

    function testRedeemRewards() public {
        vm.deal(user, 10 ether);
        vm.startPrank(user);

        (bool success, ) = address(stakingData).call{value: 1 ether}(abi.encodeWithSignature("stake()"));
        assertTrue(success);

        uint256 stakedAmount = stakingData.stakers(user);
        assertEq(stakedAmount, 1 ether);

        (success, ) = address(stakingData).call(abi.encodeWithSignature("redeemRewards()"));
        assertTrue(success);

        vm.warp(block.timestamp + 22 days);

        (success, ) = address(stakingData).call(abi.encodeWithSignature("redeemRewards()"));
        assertTrue(success);

        uint256 userTokenBalance = stakeToken.balanceOf(user);
        assertEq(userTokenBalance, 1 ether);

        vm.stopPrank();
    }
}