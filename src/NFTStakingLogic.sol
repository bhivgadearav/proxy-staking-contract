// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

interface StakeNFTContract is IERC721 {
    function mint(address to, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
}

event NFTStaked (
    address indexed by,
    uint256 indexed tokenId
);

event NFTUnstaked (
    address indexed by,
    uint256 indexed tokenId
);

contract NFTStakingLogic {
    mapping(address => uint256[]) public stakedNFTs;
    address public nftContract;

    function stakeNFT(uint256 tokenId) external {
        require(StakeNFTContract(nftContract).ownerOf(tokenId) == msg.sender, "You must own the NFT to stake it.");
        StakeNFTContract(nftContract).transferFrom(msg.sender, address(this), tokenId);
        stakedNFTs[msg.sender].push(tokenId);
        emit NFTStaked(msg.sender, tokenId);
    }

    function unstakeNFT(uint256 tokenId) external {
        require(isStakedBySender(msg.sender, tokenId), "You haven't staked this NFT.");
        removeStakedNFT(msg.sender, tokenId);
        StakeNFTContract(nftContract).transferFrom(address(this), msg.sender, tokenId);
        emit NFTUnstaked(msg.sender, tokenId);
    }

    function isStakedBySender(address sender, uint256 tokenId) internal view returns (bool) {
        uint256[] memory stakedTokens = stakedNFTs[sender];
        for (uint256 i = 0; i < stakedTokens.length; i++) {
            if (stakedTokens[i] == tokenId) {
                return true;
            }
        }
        return false;
    }

    function removeStakedNFT(address sender, uint256 tokenId) internal {
        uint256[] storage stakedTokens = stakedNFTs[sender];
        for (uint256 i = 0; i < stakedTokens.length; i++) {
            if (stakedTokens[i] == tokenId) {
                stakedTokens[i] = stakedTokens[stakedTokens.length - 1];
                stakedTokens.pop();
                break;
            }
        }
    }
}