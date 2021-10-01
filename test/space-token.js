const { expect } = require("chai")
const { ethers } = require("hardhat")
const web3 = require("Web3")

describe("spaceToken", () => {

  let spaceToken
  let SpaceTokenContract
  let owner, treasury, account1, account2
  const TOTAL_SUPPLY = '500000'
  const TOKEN_TRANSFER_AMOUNT = 10000;
  const TREASURY_BALANCE_AFTER_TAX = 200;
  const TRANSFREE_BALANCE_AFTER_TAX = 9800;
  
  beforeEach( async () => {
    [owner, treasury, account1, account2] = await ethers.getSigners()
    SpaceTokenContract = await ethers.getContractFactory("SpaceToken")
    spaceToken = await SpaceTokenContract.deploy(treasury.address)
    await spaceToken.deployed()
  })

  describe("Deployment", () => {
    it("should set token supply to belong to owner", async function () {
      const balance = await spaceToken.balanceOf(owner.address)
      expect(balance).to.equal(web3.utils.toWei(TOTAL_SUPPLY))
    })
  
    it("should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await spaceToken.balanceOf(owner.address)
      expect(await spaceToken.totalSupply()).to.equal(ownerBalance)
    })
    
    it("should set token name should be Space Token", async function () {
      expect(await spaceToken.name()).to.equal("Space Token")
    })

    it("should set Token symbol should be SPC", async function () {
      expect(await spaceToken.symbol()).to.equal("SPC")
    })
    
    it("should match treasury account", async function () {
      expect(await spaceToken.treasury()).to.equal(treasury.address)
    })

    it("should set tax status to false", async function () {
      expect(await spaceToken.taxStatus()).to.equal(false)
    })
  })

  describe("Transfers", () => {
    it("should allow the owner to set Tax Status", async () => {
      await spaceToken.setTax(true)
      expect(await spaceToken.taxStatus()).to.equal(true)
    })

    it("should allow Transfer funds with no tax", async () => {
      await spaceToken.setTax(false)
      await spaceToken.connect(owner).transfer(account1.address, TOKEN_TRANSFER_AMOUNT)
      const account1Balance = await spaceToken.balanceOf(account1.address)
      expect(account1Balance).to.equal(TOKEN_TRANSFER_AMOUNT)
    })

    it("should allow Transfer funds with tax", async () => {
      await spaceToken.setTax(true)
      await spaceToken.connect(owner).transfer(account1.address, TOKEN_TRANSFER_AMOUNT)
      const account1Balance = await spaceToken.balanceOf(account1.address)
      expect(account1Balance).to.equal(TRANSFREE_BALANCE_AFTER_TAX)
    })

    it("should fund treasury when tax is applied", async () => {
      await spaceToken.setTax(true)
      await spaceToken.connect(owner).transfer(account1.address, TOKEN_TRANSFER_AMOUNT)
      const treasuryBalance = await spaceToken.balanceOf(treasury.address)
      expect(treasuryBalance).to.equal(TREASURY_BALANCE_AFTER_TAX)
    }) 
  })


})