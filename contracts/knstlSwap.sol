// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interface/IERC20withBurn.sol";
    //     swaprouter    -> 0xE592427A0AEce92De3Edee1F18E0157C05861564
    //      WETH         -> 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
    //     WDARC         -> 0xFbAf1f87EfAdF0fb2f591C6D88404A1B673604De
    //      USDC(UNI)    -> 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984


contract SwapHandler is Ownable {
    ISwapRouter public immutable swapRouter;
    IWETH9 public immutable WETH9; 
    uint24 public constant poolFee = 3000;
    IERC20withBurn public immutable WDARC;
    address public immutable USDC;
    mapping(string => address) public tokenContractAddress;

    constructor(
        ISwapRouter _swapRouter,
        IWETH9 _IWETH9,
        IERC20withBurn _WDARC,
        address _USDC
    ) {
        WETH9 = _IWETH9;
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
                path: abi.encodePacked(address(WDARC), poolFee, USDC, poolFee, address(WETH9)),
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0
            });
        // swap from DARC -> WETH
        amountOut = swapRouter.exactInput(params);
        // unwrap WETH 
        WETH9.withdraw(amountOut);
        // send ETH
        payable(msg.sender).transfer(amountOut);
        //== WETH9.transfer(msg.sender, amountOut);
    }

    function swapETHtoDARC() public payable returns (uint256 amountOut) {
        WETH9.deposit{value: msg.value}();
        WETH9.approve(address(swapRouter), msg.value);
        // TransferHelper.safeApprove(address(WETH9), 
        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams({
                path: abi.encodePacked(address(WETH9), poolFee, USDC, poolFee, address(WDARC)),
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