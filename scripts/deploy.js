// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const [owner, acc1, acc2] = await ethers.getSigners();

  const lockedAmount = hre.ethers.utils.parseEther("0.001");

  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy([acc1.address], 'ipfs://bafybeif2urrld55ikv7cel2yns3qoctirfhl6iso3c7syv7a27o4ms7utu/');

  await nft.deployed();

  console.log(
    `NFT deployed to ${nft.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
