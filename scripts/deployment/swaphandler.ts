import { ethers } from "hardhat";
    //     swaprouter    -> 0xE592427A0AEce92De3Edee1F18E0157C05861564
    //      WETH         -> 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
    //     WDARC         -> 0xFbAf1f87EfAdF0fb2f591C6D88404A1B673604De
    //      USDC(UNI)    -> 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984
async function main() {
  
  const SwapHandler = await ethers.getContractFactory("SwapHandler");
  const swapHandler = await SwapHandler.deploy(
    "0xE592427A0AEce92De3Edee1F18E0157C05861564",
    "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6",
    "0xFbAf1f87EfAdF0fb2f591C6D88404A1B673604De",
    "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984"
    );

  await swapHandler.deployed()
  console.log(swapHandler)
  console.log(swapHandler.address)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
