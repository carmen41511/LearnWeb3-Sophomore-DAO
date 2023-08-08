// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IFakeNFTMarketplace {

    function getPrice() external view returns (uint256);
    function available(uint256 _tokenID) external view returns(bool);
    function purchase(uint256 _tokenID) external payable;
 
}

interface ICryptoDevsNFT{
    // returns the number of NFTs owned by the given address
    function balanceOf(address owner) external view returns (uint256);

    // returns a tokenID at given index for owner
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

}

contract CryptoDevsDAO is Ownable{
    struct Proposal {
        uint256 nftTokenID;
        uint256 deadline;
        uint256 yayVotes;
        uint256 nayVotes;
        bool executed;
        mapping(uint256 => bool) voters;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public numProposals;

    IFakeNFTMarketplace nftMarketplace;
    ICryptoDevsNFT cryptoDevsNFT;

    constructor(address _nftMarketplace, address _cryptoDevsNFT) payable {
        nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
        cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
    }

    modifier nftHolderOnly(){
        require(cryptoDevsNFT.balanceOf(msg.sender)>0,"NOT_A_DAO_MEMBER");
        _;
    }


    function createProposal(uint256 _nftTokenID) external nftHolderOnly returns (uint256) {
        require(nftMarketplace.available(_nftTokenID), "NFT_NOT_FOR_SALE");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenID = _nftTokenID;
        proposal.deadline = block.timestamp + 5 minutes;

        numProposals++;

        return numProposals - 1;
    }

    modifier activeProposalOnly(uint256 proposalIndex) {
    require(
        proposals[proposalIndex].deadline > block.timestamp,
        "DEADLINE_EXCEEDED"
    );
    _;
}

// Create an enum named Vote containing possible options for a vote
    enum Vote {
        YAY,
        NAY
    }

    function voteOnProposal(uint256 proposalIndex, Vote vote) 
    external 
    nftHolderOnly 
    activeProposalOnly(proposalIndex){
        
        Proposal storage proposal = proposals[proposalIndex];

        uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
        uint256 numVotes = 0;

        for (uint256 i = 0; i < voterNFTBalance; i ++){
            uint256 tokenID = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            if (proposal.voters[tokenID] == false) {
                numVotes++;
                proposal.voters[tokenID] = true;
            }
        }
        require(numVotes > 0, "ALREADY_VOTED");

        if (vote == Vote.YAY){
            proposal.yayVotes += numVotes;
        } else{
            proposal.nayVotes += numVotes;
        }
    }

    modifier inactiveProposalOnly(uint256 proposalIndex){
        require(proposals[proposalIndex].deadline <= block.timestamp, "DEADLINE_NOT_EXCEEDED");
        require(proposals[proposalIndex].executed == false, "PROPOSAL_ALREADY_EXECUTED");
        _;
    }

    function executedProposal(uint256 proposalIndex)
    external
    nftHolderOnly
    inactiveProposalOnly(proposalIndex){

        Proposal storage proposal = proposals[proposalIndex];

        if (proposal.yayVotes > proposal.nayVotes){
            uint256 nftPrice = nftMarketplace.getPrice();
            require(address(this).balance >= nftPrice, "NOT_ENOUGH_FUNDS");
            nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenID);
        }
        proposal.executed = true;
    }

    function withdrawEther() external onlyOwner{
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw, contract balance empty");
        (bool sent, ) = payable(owner()).call{value: amount}("");
        require(sent, "FAILED_TO_WITHDRAW_ETHER");
    }

    receive() external payable{}
    fallback() external payable{}
}





