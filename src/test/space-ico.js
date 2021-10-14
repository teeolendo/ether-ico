const { expect } = require("chai")
const { ethers } = require("hardhat")
const web3 = require("Web3")

describe("Space ICO - Base", () => {

  let space
  let spaceContract
  let owner
  let investor1, investor2, investor3

  const SEED_INDIVIDUAL_LIMIT = '1500'
  const SEED_INDIVIDUAL_LIMIT_PLUS1 = '1501'
  const SEED_PHASE = 0
  const GENERAL_PHASE = 1
  const OPEN_PHASE = 2


  beforeEach( async () => {
    [owner, investor1, investor2, investor3] = await ethers.getSigners()
    spaceContract = await ethers.getContractFactory("SpaceICO")
    space = await spaceContract.connect(owner).deploy()
    await space.deployed()
  })

  describe("Deployment", () => {
    it("should be in Seed Phase", async function () {
      const phase = await space.icoPhase()
      await expect(phase).to.equal(SEED_PHASE)
    })

    it("fundraising should be allowed", async function () {
      const status = await space.isFundraising()
      await expect(status).to.equal(true)
    })
  })
  describe("Pause Fundraising", () => {
    it("should be", async function () {
      const phase = await space.icoPhase()
      await expect(phase).to.equal(SEED_PHASE)
    })
  })

  describe("Seed Phase", () => {
    it("should not allow pleb to add to allowList", async function () {
      const trx = space.connect(investor1).allowList(investor2.address)
      await expect(trx).to.be.revertedWith('ONLY_OWNER')
    })

    it("should allow owner to add to allowList", async function () {
      const trx = space.connect(owner).allowList(investor1.address)
      await expect(trx).to.not.be.revertedWith('ONLY_OWNER')
    })

    it("should not allow contribution before address is allowListed", async function () {
      const trx = space.buy({value: web3.utils.toWei(SEED_INDIVIDUAL_LIMIT)})
      await expect(trx).to.be.revertedWith('ADDRESS_NOT_ON_ALLOWLIST')
    })
    
    it("should allow regular contribution Seed Phase", async function () {
      await space.connect(owner).allowList(investor1.address)
      const trx = space.connect(investor1).buy({value: web3.utils.toWei(SEED_INDIVIDUAL_LIMIT)})
      await expect(trx).to.emit(space, 'InvestmentReceived')
    })

    it("should not allow contribution to exceed individual max for Seed Phase", async function () {
      await space.connect(owner).allowList(investor1.address)
      const trx = space.connect(investor1).buy({value: web3.utils.toWei(SEED_INDIVIDUAL_LIMIT_PLUS1)})
      await expect(trx).to.be.revertedWith('INDIVIDUAL_LIMIT_EXCEEDED')
    })

    it("should not allow contribution to exceed total max for Seed Phase", async function () { 
      let accounts = await ethers.getSigners()
      for (let i = 0; i < 10; i++) {
        await space.connect(owner).allowList(accounts[i].address)
        await space.connect(accounts[i]).buy({value: web3.utils.toWei(SEED_INDIVIDUAL_LIMIT)})
      }
      const trx = space.connect(investor2).buy({value: web3.utils.toWei(SEED_INDIVIDUAL_LIMIT)})
      await expect(trx).to.be.revertedWith('CONTRIBUTION_EXCEEDS_LIMIT')
    })
  })

  describe("Phases", () => {
    it("should not allow pleb to advance", async function () {
      await expect(space.connect(investor1).advancePhaseToGeneral()).to.be.revertedWith('ONLY_OWNER')
    })
    it("should only allow owner to advance", async function () {
      await expect(space.connect(owner).advancePhaseToGeneral()).to.not.be.revertedWith('ONLY_OWNER')
    })
    it("should emit phases upgrade event", async function () {
      await expect(space.connect(owner).advancePhaseToGeneral()).to.emit(space, 'PhaseUpgraded')
    })
    it("should advance from seed to general", async function () {
      await space.connect(owner).advancePhaseToGeneral()
      const phase = await space.icoPhase()
      await expect(phase).to.equal(GENERAL_PHASE)
    })
    it("should advance from seed to open", async function () {
      await space.connect(owner).advancePhaseToGeneral()
      await space.connect(owner).advancePhaseToOpen()
      await expect(space.icoPhase()).to.equal(OPEN_PHASE)
    })
    it("should not advance past open", async function () {
      await space.connect(owner).advancePhaseToGeneral()
      await space.connect(owner).advancePhaseToOpen()
      await expect(space.connect(owner).advancePhaseToOpen()).to.be.revertedWith('PHASE_NOT_GENERAL')
    })
  })
})

describe("Space ICO - General", () => {
  describe("General Phase", () => {

    let space
    let spaceContract
    let owner
    let investor1, investor2, investor3
  
    const GENERAL_INDIVIDUAL_LIMIT = '1000'
    const GENERAL_INDIVIDUAL_LIMIT_PLUS1 = '1501'
    const GENERAL_PHASE = 1
    
    beforeEach( async () => {
      [owner, investor1, investor2, investor3] = await ethers.getSigners()
      spaceContract = await ethers.getContractFactory("SpaceICO")
      space = await spaceContract.connect(owner).deploy()
      await space.deployed()
      await space.connect(owner).advancePhaseToGeneral()
    })
    
    it("should confirm Phase is General", async function () {
      const phase = await space.icoPhase()
      await expect(phase).to.equal(GENERAL_PHASE)
    })
    
    it("should allow regular contribution General Phase", async function () {
      const trx = space.connect(investor1).buy({value: web3.utils.toWei(GENERAL_INDIVIDUAL_LIMIT)})
      await expect(trx).to.emit(space, 'InvestmentReceived')
    })

    it("should not enforce allowList for general", async function () {
      const trx = space.connect(investor1).buy({value: web3.utils.toWei(GENERAL_INDIVIDUAL_LIMIT)})
      await expect(trx).to.not.be.revertedWith('ADDRESS_NOT_ON_ALLOWLIST')
    })
  
    it("should not allow contribution to exceed individual max for General Phase", async function () {
      await space.connect(owner).allowList(investor1.address)
      const trx = space.connect(investor1).buy({value: web3.utils.toWei(GENERAL_INDIVIDUAL_LIMIT_PLUS1)})
      await expect(trx).to.be.revertedWith('INDIVIDUAL_LIMIT_EXCEEDED')
    })
  
    it("should not allow contribution to exceed total max for General Phase", async function () { 
      let accounts = await ethers.getSigners()
      for (let i = 0; i < 19; i++) {
        await space.connect(accounts[i]).buy({value: web3.utils.toWei(GENERAL_INDIVIDUAL_LIMIT)})
      }
      for (let i = 0; i < 11; i++) {
        await space.connect(accounts[i]).buy({value: web3.utils.toWei(GENERAL_INDIVIDUAL_LIMIT)})
      }
      const trx = space.connect(investor2).buy({value: web3.utils.toWei(GENERAL_INDIVIDUAL_LIMIT)})
      await expect(trx).to.be.revertedWith('CONTRIBUTION_EXCEEDS_LIMIT')
    })
  })
})

describe("Space ICO - General", () => {
  describe("Open Phase", () => {

    let space
    let spaceContract
    let owner
    let investor1, investor2, investor3
  
    const SEED_INDIVIDUAL_LIMIT_PLUS1 = '1501'
    const OPEN_PHASE = 2
    
    beforeEach( async () => {
      [owner, investor1, investor2, investor3] = await ethers.getSigners()
      spaceContract = await ethers.getContractFactory("SpaceICO")
      space = await spaceContract.connect(owner).deploy()
      await space.deployed()
      await space.connect(owner).advancePhaseToGeneral()
      await space.connect(owner).advancePhaseToOpen()
    })
    
    it("should confirm Phase is Open", async function () {
      const phase = await space.icoPhase()
      await expect(phase).to.equal(OPEN_PHASE)
    })
    
    it("should allow regular contribution Open Phase", async function () {
      const trx = space.connect(investor3).buy({value: web3.utils.toWei(SEED_INDIVIDUAL_LIMIT_PLUS1)})
      await expect(trx).to.emit(space, 'InvestmentReceived')
    })
  })
})

describe("Space ICO - General", () => {
  describe("Mint Coins", () => {

    let space
    let spaceContract
    let owner
    let investor1, investor2, investor3
  
    const SEED_INDIVIDUAL_LIMIT_PLUS1 = '1501'
    const OPEN_PHASE = 2
    
    beforeEach( async () => {
      [owner, investor1, investor2, investor3] = await ethers.getSigners()
      spaceContract = await ethers.getContractFactory("SpaceICO")
      space = await spaceContract.connect(owner).deploy()
      await space.deployed()
      await space.connect(owner).advancePhaseToGeneral()
      await space.connect(owner).advancePhaseToOpen()
      spaceContract = await ethers.getContractFactory("SpaceToken")
      space = await spaceContract.connect(owner).deploy()
      await space.deployed()
    })
    
    it("should confirm Phase is Open", async function () {
      const phase = await space.icoPhase()
      await expect(phase).to.equal(OPEN_PHASE)
    })
    
    it("should allow regular contribution Open Phase", async function () {
      const trx = space.connect(investor1).buy({value: web3.utils.toWei(SEED_INDIVIDUAL_LIMIT_PLUS1)})
      await expect(trx).to.emit(space, 'InvestmentReceived')
    })
  })
})

