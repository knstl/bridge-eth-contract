// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IWDARC.sol";
import "../interface/IWETH.sol";

contract SwapHandler is Ownable {
    ISwapRouter public immutable swapRouter;
    IWETH public immutable WETH; 
    IWDARC public immutable WDARC;
    uint24 public constant poolFee = 3000;
    address public immutable USDC;
    mapping(string => address) public tokenContractAddress;

    constructor(
        ISwapRouter _swapRouter,
        IWETH _IWETH,
        IWDARC _WDARC,
        address _USDC
    ) {
        WETH = _IWETH;
        swapRouter = _swapRouter;
        WDARC = _WDARC;
        USDC = _USDC;
    }

    receive() external payable  {}
    
    function addTokenContractAddress(
        string memory symbol, 
        address tokenAddress
        ) public onlyOwner returns (address) {
        tokenContractAddress[symbol] = tokenAddress;
        return tokenContractAddress[symbol];
    }

    function swapDARCtoETH(uint256 amountIn) public payable returns (uint256 amountOut) {
        WDARC.transferFrom(msg.sender, address(this), amountIn);
        WDARC.approve(address(swapRouter), amountIn);
        
        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams({
                path: abi.encodePacked(address(WDARC), poolFee, USDC, poolFee, address(WETH)),
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0
            });
        // swap from DARC -> WETH
        amountOut = swapRouter.exactInput(params);
        // unwrap WETH 
        WETH.withdraw(amountOut);
        // send ETH
        payable(msg.sender).transfer(amountOut);
    }

    function swapETHtoDARC() public payable returns (uint256 amountOut) {
        WETH.deposit{value: msg.value}();
        WETH.approve(address(swapRouter), msg.value);
        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams({
                path: abi.encodePacked(address(WETH), poolFee, USDC, poolFee, address(WDARC)),
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: msg.value,
                amountOutMinimum: 0
            });
        amountOut = swapRouter.exactInput(params);
        WDARC.burn(amountOut);
    }

    function swapDARCtoERC20(
        uint256 amountIn, 
        string memory token_symbol
    ) public returns (uint256 amountOut) {
        // TransferHelper.safeTransferFrom(address(WDARC, msg.sender, address(this), amountIn);
        // TransferHelper.safeApprove(WDARC, address(swapRouter), amountIn);
        WDARC.transferFrom(msg.sender, address(this), amountIn);
        WDARC.approve(address(swapRouter), amountIn);
        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams({
                path: abi.encodePacked(address(WDARC), poolFee, USDC, poolFee, tokenContractAddress[token_symbol]),
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0
            });
        // swap from DARC -> WETH
        amountOut = swapRouter.exactInput(params);
        
        TransferHelper.safeTransfer(
            tokenContractAddress[token_symbol],
            msg.sender,
            amountOut
        );
    }

    function swapERC20toDARC(
        uint256 amountIn, 
        string memory token_symbol
    ) public returns (uint256 amountOut) {
        IERC20(tokenContractAddress[token_symbol]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenContractAddress[token_symbol]).approve(address(swapRouter), amountIn);
        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams({
                path: abi.encodePacked(tokenContractAddress[token_symbol], poolFee, USDC, poolFee, address(WDARC)),
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0
            });
        amountOut = swapRouter.exactInput(params);
        WDARC.burn(amountOut);
    }
}