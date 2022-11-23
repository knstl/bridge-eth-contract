// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@uniswap/v3-periphery/contracts/interfaces/external/IWETH9.sol";

interface IERC20withBurn is IERC20 {
    function burn(uint256 amount) external;
}