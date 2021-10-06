// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  
  const SpaceICO = await hre.ethers.getContractFactory("SpaceICO");
  const spaceICO = await SpaceICO.deploy();

  const SpaceTokenContract = await hre.ethers.getContractFactory("SpaceToken")
  const spaceToken = await SpaceTokenContract.deploy('0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199')
  
  await spaceICO.deployed();
  await spaceToken.deployed();

  console.log("Space ICO deployed to:", spaceICO.address);
  console.log("Space Token deployed to:", spaceToken.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
