// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol";

contract ETHStakingData {
    uint256 totalStaked;
    mapping(address => uint256) public stakers;
    mapping(address => uint256) public unstakers;
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address _implementation) {
        setImplementation(_implementation);
    }

    fallback() external {
        
        (bool success, ) = getImplementation().delegatecall(msg.data);

        if (!success) {
            revert();
        }
    }

    function getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function setImplementation(address _implementation) public {
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }
}