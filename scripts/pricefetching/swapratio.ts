
require("dotenv").config({ path: __dirname + '/.env' });
import { abi as UniswapV3FactoryABI } from '@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json';
import { abi as IUniswapV3Pool } from '@uniswap/v3-core/artifacts/contracts/interfaces/IUniswapV3Pool.sol/IUniswapV3Pool.json';
import { ethers } from "hardhat";

async function main() {

    // console.log(IUniswapV3PoolABI)
    // console.log("asd")
    const factory = await ethers.getContractAt(UniswapV3FactoryABI, "0x1F98431c8aD98523631AE4a59f267346ea31F984");
    // console.log("asd")
    console.log(factory.functions)

    const poolAddress = await factory.getPool(
        "0xFbAf1f87EfAdF0fb2f591C6D88404A1B673604De", // WDARC address
        "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984", // USDC address ( UNI in testnet )
        3000
    );

    console.log(poolAddress)

    const tokenAmount = 0.001;
    const pool = await ethers.getContractAt(IUniswapV3Pool, poolAddress);

    console.log(pool.functions)
    console.log(await pool.token1())


    const t = await pool.slot0();
    const {sqrtPriceX96} = t;
    console.log(t)
    /* WDARC IN */
    const price_in = (2 ** 192 / sqrtPriceX96 ** 2)
    const min_receive_in = (tokenAmount * price_in) * 0.99 * 0.997 // 0.99 is 1 - slippage
    console.log("1 WDARC : ",price_in, " UNI")
    console.log(tokenAmount, "WDARC :", min_receive_in, " UNI, Slippage : 1 %")


    /* WDARC OUT */ 
  
    const price_out = (sqrtPriceX96 ** 2 / 2 ** 192)
    const min_receive_out = (tokenAmount * price_out) * 0.99 * 0.997 // 0.99 is 1 - slippage
    console.log("1 UNI : ", price_out, " WDARC")
    console.log(tokenAmount, " UNI : ", min_receive_out, " WDARC, , Slippage : 1 %")
}

  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  