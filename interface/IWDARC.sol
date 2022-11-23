// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title Interface for WDARC
interface IWDARC is IERC20 {
    /// @notice Burn WDARC of amount user designated
    function burn(uint256) external;
}
