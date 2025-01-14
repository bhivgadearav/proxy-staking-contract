// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ETHStakingData.sol";
import "../src/ETHStakingLogic.sol";

contract ETHStakingTest is Test {
    ETHStakingData stakingData;
    ETHStakingLogic stakingLogic;

    address user = makeAddr("user");

    function setUp() public {
        stakingLogic = new ETHStakingLogic();
        stakingData = new ETHStakingData(address(stakingLogic));
    }

    function testStake() public {
        vm.deal(user, 1 ether);
        vm.startPrank(user);

        (bool success, ) = address(stakingData).call{value: 1 ether}(abi.encodeWithSignature("stake()"));
        assertTrue(success);

        uint256 stakedAmount = stakingData.stakers(user);
        assertEq(stakedAmount, 1 ether);

        vm.stopPrank();
    }

    function testUnstake() public {
        vm.deal(user, 1 ether);
        vm.startPrank(user);

        (bool success, ) = address(stakingData).call{value: 1 ether}(abi.encodeWithSignature("stake()"));
        assertTrue(success);

        (success, ) = address(stakingData).call(abi.encodeWithSignature("unstake()"));
        assertTrue(success);

        uint256 unstakeTimestamp = stakingData.unstakers(user);
        assertTrue(unstakeTimestamp > 0);

        vm.warp(block.timestamp + 22 days);

        (success, ) = address(stakingData).call(abi.encodeWithSignature("unstake()"));
        assertTrue(success);

        uint256 stakedAmount = stakingData.stakers(user);
        assertEq(stakedAmount, 0);

        vm.stopPrank();
    }

    function testRestake() public {
        vm.deal(address(stakingData), 1 ether);
        vm.deal(user, 2 ether);  
        vm.startPrank(user);
        
        (bool success, ) = address(stakingData).call{value: 1 ether}(abi.encodeWithSignature("stake()"));
        assertTrue(success);
        
        (success, ) = address(stakingData).call(abi.encodeWithSignature("unstake()"));
        assertTrue(success);
        
        vm.warp(block.timestamp + 22 days);
        
        vm.deal(user, 1 ether);
        (success, ) = address(stakingData).call{value: 1 ether}(abi.encodeWithSignature("stake()"));
        assertTrue(success);
        
        uint256 stakedAmount = stakingData.stakers(user); 
        assertEq(stakedAmount, 1 ether);
        
        vm.stopPrank();
    }
}