// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol";

contract ETHStakingData {
    uint256 public totalStaked;
    mapping(address => uint256) public stakers;
    mapping(address => uint256) public unstakers;
    address stakeToken;
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address _implementation) {
        setImplementation(_implementation);
    }

    function setStakeToken(address _stakeToken) external {
        stakeToken = _stakeToken;
    }

    fallback() external payable {
        (bool success, bytes memory data) = getImplementation().delegatecall(msg.data);
        require(success, "Fallback delegatecall failed");
        
        // Handle return data for getRewards
        if (data.length > 0) {
            assembly {
                // Return the full returndatasize to ensure we capture the uint256
                let returndata_size := returndatasize()
                returndatacopy(0, 0, returndata_size)
                return(0, returndata_size)
            }
        }
    }


    receive() external payable {
        // Custom logic for receiving Ether can be added here
    }

    function getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function setImplementation(address _implementation) public {
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }
}