const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  
  describe("NFT", function () {

    let uri = 'ipfs://bafybeif2urrld55ikv7cel2yns3qoctirfhl6iso3c7syv7a27o4ms7utu/'

    async function deployNftFixture() {
      const [owner, acc1, acc2] = await ethers.getSigners();
      const NFT = await hre.ethers.getContractFactory("NFT");
      const nft = await NFT.deploy([acc1.address], uri);
      await nft.deployed();
      return { nft, owner, acc1, acc2 };
    }

    it("Should return right uri", async function () {
      const {nft, owner, acc1, acc2} = await loadFixture(deployNftFixture);
      await expect(await nft.tokenURI(1)).to.equal(uri + '1.json');
      await expect(await nft.tokenURI(2)).to.equal(uri + '2.json');
      await expect(await nft.tokenURI(14)).to.equal(uri + '14.json');
    });

    it("Should return right WL users", async function () {
      const {nft, owner, acc1, acc2} = await loadFixture(deployNftFixture);
      await expect(await nft.isWhitelisted(acc1.address)).to.equal(true);
      await expect(await nft.isWhitelisted(acc2.address)).to.equal(false);
    });

    it("Should return right balance", async function () {
      const {nft, owner, acc1, acc2} = await loadFixture(deployNftFixture);
      await expect(await nft.balanceOf(owner.address)).to.equal(15);
      await expect(await nft.balanceOf(acc1.address)).to.equal(0);
    });

    it("Should mint new nft", async function () {
      const {nft, owner, acc1, acc2} = await loadFixture(deployNftFixture);
      await nft.connect(acc1).safeMintWL()
      await expect(await nft.balanceOf(acc1.address)).to.equal(1);
      await nft.connect(acc1).safeMintWL()
      await expect(await nft.balanceOf(acc1.address)).to.equal(2);
    });

    it("Should mass mint nft", async function () {
      const {nft, owner, acc1, acc2} = await loadFixture(deployNftFixture);
      await nft.connect(acc1).mint(2);
      expect(await nft.balanceOf(acc1.address)).to.equal(2);
    });

    it("Should revert, if address not from WL", async function () {
      const {nft, owner, acc1, acc2} = await loadFixture(deployNftFixture);
      await expect(nft.connect(acc2).mint(2)).to.be.revertedWith("user is not whitelisted");
    });
  });
  