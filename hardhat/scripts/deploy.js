const hre = require("hardhat");

async function sleep(ms){
  return new Promise((resolve) => setTimeout(resolve,ms));
}

async function main(){
  const nftContract = await hre.ethers.deployContract("CryptoDevsNFT");
  await nftContract.waitForDeployment();
  console.log("CryptoDevsNFT deployed to:", nftContract.target);

  const fakeNFTMarketplaceContract = await hre.ethers.deployContract("FakeNFTMarketplace");
  await fakeNFTMarketplaceContract.waitForDeployment();
  console.log("FakeNFTMarketplace deployed to:",fakeNFTMarketplaceContract.target);

  const amount = hre.ethers.parseEther("1");
  const daoContract = await hre.ethers.deployContract("CryptoDevsDAO", [
    fakeNFTMarketplaceContract.target,
    nftContract.target
  ], {value: amount,});
  await daoContract.waitForDeployment();
  console.log("CryptoDevsDAO deployed to:", daoContract.target);

  await sleep(30*1000);

  // Verify the NFT Contract
  await hre.run("verify:verify", {
    address: nftContract.target,
    constructorArguments: [],
  });

  // Verify the Fake Marketplace Contract
  await hre.run("verify:verify", {
    address: fakeNFTMarketplaceContract.target,
    constructorArguments: [],
  });

  // Verify the DAO Contract
  await hre.run("verify:verify", {
    address: daoContract.target,
    constructorArguments: [
      fakeNFTMarketplaceContract.target,
      nftContract.target,
    ],
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});