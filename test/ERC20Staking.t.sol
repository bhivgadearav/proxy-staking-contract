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

    function setUp() public {
        stakingLogicContract = new ERC20StakingLogic();
        stakingDataContract = new ERC20StakingData(address(stakingLogicContract));
        stakeTokenContract = new StakeToken(address(user), address(stakingDataContract));
    }

    function testStake() public {
        vm.deal(user, 10 ether);
        vm.startPrank(user);

        customTokenContract = new CustomToken();
        stakingDataContract.setValidToken(address(customTokenContract));

        customTokenContract.mint(address(user), 1000);

        customTokenContract.approve(address(stakingDataContract), 900);

        (bool success, ) = address(stakingDataContract).call(abi.encodeWithSignature("stake(address,uint256)", address(customTokenContract), 900));
        assertTrue(success);

        (uint256 amount, ) = stakingDataContract.stakers(user);
        assertEq(amount, 900);

        vm.stopPrank();
    }

    function testUnstake() public {
        vm.deal(user, 10 ether);
        vm.startPrank(user);

        customTokenContract = new CustomToken();
        stakingDataContract.setValidToken(address(customTokenContract));

        customTokenContract.mint(address(user), 1000);

        customTokenContract.approve(address(stakingDataContract), 900);

        (bool success, ) = address(stakingDataContract).call(abi.encodeWithSignature("stake(address,uint256)", address(customTokenContract), 900));
        assertTrue(success);

        (uint256 amount, ) = stakingDataContract.stakers(user);
        assertEq(amount, 900);

        (success, ) = address(stakingDataContract).call(abi.encodeWithSignature("unstake(uint256)", 800));
        assertTrue(success);

        (amount, ) = stakingDataContract.stakers(user);
        assertEq(amount, 100);

        uint256 balance = IERC20(customTokenContract).balanceOf(user);
        assertEq(balance, 900);

        vm.stopPrank();
    }
}