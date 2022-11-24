import { ethers } from "hardhat";

async function main() {
  
  const WDARC = await ethers.getContractFactory("WrappedDARC");
  const wDARC = await WDARC.deploy();

  await wDARC.deployed()
  console.log(wDARC)
  console.log(wDARC.address)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
