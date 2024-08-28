// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./contracts/utils/ReentrancyGuard.sol";
import "./contracts/interfaces/Interfaces.sol";
import "./contracts/core/ContractErrors.sol";
import "./contracts/utils/Ownable.sol";
import "./contracts/utils/Math.sol";

/**
 * @title Fold Contract
 * @dev The Fold contract allows users to perform token swaps using the IDonkeRouter, IYakaRouter and IDragonRouter interfaces.
 * It provides functions for approving tokens, executing swaps, and handling token transfers.
 * The contract also includes reentrancy guard, contract error handling, and ownership functionality.
 */
contract Seiyan is ReentrancyGuard, ContractErrors, Ownable {
    using Math for uint;
    event SwapExecuted(
        address indexed user,
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOut,
        uint swapType
    );
    event PathsExecuted(
        address indexed user,
        Params.SwapParam[] swapParams,
        uint minTotalAmountOut,
        uint finalTokenAmount
    );

    IDragonRouter dragonRouter;
    address public dragonRouterAddress =
        0xa4cF2F53D1195aDDdE9e4D3aCa54f556895712f2;
    IYakaRouter yakaRouter;
    address public yakaRouterAddress =
        0x9f3B1c6b0CDDfE7ADAdd7aadf72273b38eFF0ebC;
    IDonkeRouter donkeRouter;
    address public donkeRouterAddress =
        0x9f3B1c6b0CDDfE7ADAdd7aadf72273b38eFF0ebC;

    //CHANGE
    address public fee_address = 0xa2a9dd657D44e46E2d1843B8784eFc3dE3Cf3A57;
    IWETH public weth;
    address public wethAddress = 0xE30feDd158A2e3b13e9badaeABaFc5516e95e8C7;
    uint public feePercentage = 3;

    constructor() ReentrancyGuard() Ownable(msg.sender) {
        dragonRouter = IDragonRouter(dragonRouterAddress);
        yakaRouter = IYakaRouter(yakaRouterAddress);
        donkeRouter = IDonkeRouter(donkeRouterAddress);
        weth = IWETH(wethAddress);
    }

    /**
     * @notice Sets the maximum allowances for the specified tokens to the syncRouter,horizonrouter and dragonRouter addresses.
     * @dev Only the contract owner can call this function.
     * @param tokens Array of token addresses.
     */
    function maxApprovals(address[] calldata tokens) external onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            if (!token.approve(donkeRouterAddress, type(uint96).max))
                revert ApprovalFailedError(tokens[i], donkeRouterAddress);
            if (!token.approve(dragonRouterAddress, type(uint96).max))
                revert ApprovalFailedError(tokens[i], dragonRouterAddress);
            if (!token.approve(yakaRouterAddress, type(uint96).max))
                revert ApprovalFailedError(tokens[i], yakaRouterAddress);
        }
    }

    /**
     * @notice Revokes the allowances for the specified tokens from the syncRouter,horizonrouter and dragonRouter addresses.
     * @dev Only the contract owner can call this function.
     * @param tokens Array of token addresses.
     */
    function revokeApprovals(address[] calldata tokens) external onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            if (!token.approve(donkeRouterAddress, 0))
                revert RevokeApprovalFailedError(tokens[i], donkeRouterAddress);
            if (!token.approve(dragonRouterAddress, 0))
                revert RevokeApprovalFailedError(
                    tokens[i],
                    dragonRouterAddress
                );
            if (!token.approve(yakaRouterAddress, 0))
                revert RevokeApprovalFailedError(tokens[i], yakaRouterAddress);
        }
    }

    /**
     * @notice Sets the fee percentage for a particular operation.
     * @dev Only the contract owner can call this function.
     * @param _feePercentage The new fee percentage to be set.
     */
    function setFeePercentage(uint _feePercentage) external onlyOwner {
        feePercentage = _feePercentage;
    }

    /**
     * @notice Sets the new fee address where fees will be sent to.
     * @dev Only the contract owner can call this function.
     * @param _newFeeAddress The new fee address to be set.
     */
    function setFeeAddress(address _newFeeAddress) external onlyOwner {
        require(_newFeeAddress != address(0), "Invalid address");
        fee_address = _newFeeAddress;
    }

    /**
     * @notice Withdraws a specific ERC20 token from the contract to the specified address.
     * @dev Only the contract owner can call this function.
     * @param _token The address of the ERC20 token to be withdrawn.
     * @param _to The address that will receive the tokens.
     */
    function withdrawTokens(address _token, address _to) external onlyOwner {
        require(_to != address(0), "Invalid address");

        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));

        require(token.transfer(_to, balance), "Transfer failed");
    }

    /**
     * @notice Withdraws the entire Ether balance from the contract to the specified address.
     * @dev Only the contract owner can call this function.
     * @param _to The address that will receive the Ether.
     */
    function withdrawEther(address payable _to) external onlyOwner {
        require(_to != address(0), "Invalid address");

        uint256 balance = address(this).balance;

        (bool success, ) = _to.call{value: balance}("");
        require(success, "Transfer failed");
    }

    /**
     * @notice Executes a token swap using the specified tokenIn, tokenOut, amountIn, and amountOutMin.
     * @dev Internal function used by executeSwaps.
     * @param tokenIn Address of the input token.
     * @param tokenOut Address of the output token.
     * @param amountIn Amount of input token to swap.
     * @return A struct containing the address of the output token and the amount of output tokens received.
     */
    function dragonSwap(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) internal returns (IPool.TokenAmount memory) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        uint deadline = block.timestamp + 20 minutes;
        uint[] memory amounts = dragonRouter.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            deadline
        );

        IPool.TokenAmount memory tokenOutAmount;
        tokenOutAmount.token = tokenOut;
        tokenOutAmount.amount = amounts[amounts.length - 1];
        emit SwapExecuted(
            msg.sender,
            tokenIn,
            tokenOut,
            amountIn,
            amounts[amounts.length - 1],
            1
        );
        return tokenOutAmount;
    }

    /**
     * @notice Executes a token swap using the specified tokenIn, tokenOut, amountIn, and amountOutMin.
     * @dev Internal function used by executeSwaps.
     * @param tokenIn Address of the input token.
     * @param tokenOut Address of the output token.
     * @param amountIn Amount of input token to swap.
     * @return A struct containing the address of the output token and the amount of output tokens received.
     */
    function yakaSwap(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) internal returns (IPool.TokenAmount memory) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        uint deadline = block.timestamp + 20 minutes;
        uint[] memory amounts = yakaRouter.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            deadline
        );
        IPool.TokenAmount memory tokenOutAmount;
        tokenOutAmount.token = tokenOut;
        tokenOutAmount.amount = amounts[amounts.length - 1];
        emit SwapExecuted(
            msg.sender,
            tokenIn,
            tokenOut,
            amountIn,
            amounts[amounts.length - 1],
            2
        );
        return tokenOutAmount;
    }

    /**
     * @notice Executes a token swap using the specified tokenIn, tokenOut, amountIn, and amountOutMin.
     * @dev Internal function used by executeSwaps.
     * @param tokenIn Address of the input token.
     * @param tokenOut Address of the output token.
     * @param amountIn Amount of input token to swap.
     * @return A struct containing the address of the output token and the amount of output tokens received.
     */
    function donkeSwap(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) internal returns (IPool.TokenAmount memory) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        uint deadline = block.timestamp + 20 minutes;
        uint[] memory amounts = dragonRouter.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            deadline
        );

        IPool.TokenAmount memory tokenOutAmount;
        tokenOutAmount.token = tokenOut;
        tokenOutAmount.amount = amounts[amounts.length - 1];
        emit SwapExecuted(
            msg.sender,
            tokenIn,
            tokenOut,
            amountIn,
            amounts[amounts.length - 1],
            3
        );
        return tokenOutAmount;
    }

    /**
     * @notice Executes a series of swap operations based on the provided swapParams.
     * @dev This function performs chained swaps using syncswap, horizondex and dragonSwap functions.
     * @param swapParams Array of SwapParam structures containing swap details.
     * @param minTotalAmountOut Minimum total amount of output token expected.
     */
    function executeSwaps(
        Params.SwapParam[] memory swapParams,
        uint minTotalAmountOut,
        bool conveth
    ) external payable nonReentrant returns (uint) {
        address tokenG = swapParams[0].tokenIn;
        IERC20 token = IERC20(tokenG);
        uint256 amountIn = swapParams[0].amountIn;
        if (msg.value > 0) {
            weth.deposit{value: msg.value}();
            amountIn = msg.value*10**12;
        } else {
            if (!token.transferFrom(msg.sender, address(this), amountIn))
                revert TransferFromFailedError(
                    msg.sender,
                    address(this),
                    amountIn
                );
        }
        address finalTokenAddress;
        uint finalTokenAmount;
        for (uint i = 0; i < swapParams.length; i++) {
            Params.SwapParam memory param = swapParams[i];
            if (param.swapType == 1) {
                IPool.TokenAmount memory result = dragonSwap(
                    param.tokenIn,
                    param.tokenOut,
                    amountIn
                );
                finalTokenAddress = result.token;
                finalTokenAmount = result.amount;
            } else if (param.swapType == 2) {
                IPool.TokenAmount memory result = yakaSwap(
                    param.tokenIn,
                    param.tokenOut,
                    amountIn
                );
                finalTokenAddress = result.token;
                finalTokenAmount = result.amount;
            } else if (param.swapType == 3) {
                IPool.TokenAmount memory result = donkeSwap(
                    param.tokenIn,
                    param.tokenOut,
                    amountIn
                );
                finalTokenAddress = result.token;
                finalTokenAmount = result.amount;
            } else {
                revert("Invalid swap type");
            }
            amountIn = finalTokenAmount;
        }
        if (finalTokenAmount < minTotalAmountOut)
            revert AmountLessThanMinRequiredError(
                finalTokenAmount,
                minTotalAmountOut
            );
        IERC20 finalToken = IERC20(finalTokenAddress);
        uint fee = (finalTokenAmount * feePercentage) / 1000;
        uint amountToTransfer = finalTokenAmount - fee;
        if (!finalToken.transfer(fee_address, fee))
            revert TransferFailedError(finalTokenAddress, fee_address, fee);
        if (conveth && finalTokenAddress == wethAddress) {
            weth.withdraw(amountToTransfer);
            (bool success, ) = msg.sender.call{value: amountToTransfer}("");
            if (!success) {
                revert TransferFailedError(
                    address(0),
                    msg.sender,
                    amountToTransfer
                );
            }
            emit PathsExecuted(
                msg.sender,
                swapParams,
                minTotalAmountOut,
                finalTokenAmount
            );
            return amountToTransfer;
        } else {
            if (!finalToken.transfer(msg.sender, amountToTransfer)) {
                revert TransferFailedError(
                    finalTokenAddress,
                    msg.sender,
                    amountToTransfer
                );
            }
            emit PathsExecuted(
                msg.sender,
                swapParams,
                minTotalAmountOut,
                finalTokenAmount
            );
            return amountToTransfer;
        }
    }

    receive() external payable {}
}
