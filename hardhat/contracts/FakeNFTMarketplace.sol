// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract FakeNFTMarketplace {
    mapping(uint256 => address) public tokens;

    uint256 nftPrice = 0.1 ether;

     function purchase(uint256 _tokenID) external payable {
        require(msg.value == nftPrice, "This NFT costs 0.1 ether");
        tokens[_tokenID] = msg.sender;
     }

     function getPrice() external view returns (uint256) {
        return nftPrice;  
     }

     function available(uint256 _tokenID) external view returns(bool) {
        if (tokens[_tokenID] == address(0)){
            return true;
        }
        return false;
     }
}