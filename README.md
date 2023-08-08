# Build an NFT-powered fully on-chain DAO to invest in NFT collections as a group

This project is to build a fully on-chain DAO to invest in NFT collections as a group.

Members of the DAO can:

- Create proposals to purchase an NFT from a fake NFT marketplace
- Vote yes or no on active proposals
- Each NFT held counts as one vote
- If majority votes yes by deadline, NFT is purchased automatically

## Smart Contracts
The project consists of 3 smart contracts:

- CryptoDevsNFT.sol - An ERC-721 NFT contract to represent DAO membership
- FakeNFTMarketplace.sol - A fake NFT marketplace to simulate purchasing NFTs
- CryptoDevsDAO.sol - The main DAO contract with proposal/voting logic

## Frontend
A lightweight Next.js app to interact with the smart contracts and allow:

- Viewing active proposals
- Creating new proposals
- Voting on proposals
- Executing passed proposals

## Deployment
The contracts were deployed to the Sepolia testnet and verified on Etherscan.io.

The Next.js app was deployed to Vercel and is accessible online.

## Usage
1. Connect your MetaMask wallet
2. Hold at least 1 CryptoDevs NFT for membership
3. Create a proposal to purchase a specific NFT ID from the fake marketplace
4. Vote yes or no on active proposals - each NFT you hold counts as 1 vote
5. After the deadline, execute proposals that passed
