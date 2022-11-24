
import { ethers } from "hardhat";
require("dotenv").config({ path: __dirname + '/.env' });



async function main() {

  const SwapHandler = await ethers.getContractFactory("SwapHandler");
  const swapHandler = await SwapHandler.attach(
    "0x3faf95a83a1191ce70f82d0c7aad52e66db4d289" // deployed address
  );

  /* check constructor */

  const assert = (value1: unknown, value2: unknown) => {
    if ( value1 !== value2) throw new Error("Assertion Failed")
  }

  const swapRouter_address = await swapHandler.swapRouter();
  console.log(swapRouter_address);
  // const WETH_address = await swapHandler.WETH();  
  // console.log(WETH_address);
  // const WDARC_address = await swapHandler.WDARC();
  // console.log(WDARC_address);
  // const USDC_address = await swapHandler.USDC();
  // console.log(USDC_address);
  assert(
    "0xE592427A0AEce92De3Edee1F18E0157C05861564",
    swapRouter_address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
