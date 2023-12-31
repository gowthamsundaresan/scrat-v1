// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "@balancer-labs/v2-interfaces/contracts/vault/IVault.sol";
import "@balancer-labs/v2-interfaces/contracts/vault/IFlashLoanRecipient.sol";

/**
 * @title Cross Margin Trading contract
 * @author Gowtham Sundaresan
 * @notice The contract that Scrat Finance users interact with when use the margin trading product.
 * Users can:
 *     # Deposit funds into their margin account
 *     # Open long & short positions
 *     # Close long & short positions
 *     # Withdraw funds from their margin account
 * @dev The contract interfaces with Aave as the margin account provider, Balancer for flashloans and Uniswap V3 for swaps.
 */

contract CrossMarginTrading is IFlashLoanRecipient {
    // Token Addresses
    address private constant usdcTokenAddress = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address private constant wmaticTokenAddress = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address private constant wethTokenAddress = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address private constant wbtcTokenAddress = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address private constant stMaticTokenAddress = 0x3A58a54C066FdC0f2D55FC9C89F0415C92eBf3C4;
    address private constant linkTokenAddress = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;

    // Other DeFi Addresses
    address private constant iUniswapV3PoolAddress = 0xA374094527e1673A86dE625aa59517c5dE346d32;
    address private constant iSwapRouterAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address private constant iQuoterAddress = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
    address private constant iPoolAddressesProviderAddress =
        0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;
    address private constant iVaultAddress = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    // Immutables
    ISwapRouter public immutable i_swapRouter;
    IQuoter private immutable i_quoter;
    IPoolAddressesProvider private immutable i_poolAddressesProvider;
    IVault private immutable i_vault;
    IERC20 private i_usdc;

    // Init
    address private iPoolAddress;
    mapping(address => address) private tokenAddressToATokenAddress;
    IPool private aavePool;

    constructor() {
        i_swapRouter = ISwapRouter(iSwapRouterAddress);
        i_quoter = IQuoter(iQuoterAddress);
        i_poolAddressesProvider = IPoolAddressesProvider(iPoolAddressesProviderAddress);
        i_vault = IVault(iVaultAddress);
        i_usdc = IERC20(usdcTokenAddress);

        // aToken address mapping init
        tokenAddressToATokenAddress[usdcTokenAddress] = 0x625E7708f30cA75bfd92586e17077590C60eb4cD;
        tokenAddressToATokenAddress[
            wmaticTokenAddress
        ] = 0x6d80113e533a2C0fe82EaBD35f1875DcEA89Ea97;
        tokenAddressToATokenAddress[wethTokenAddress] = 0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8;
        tokenAddressToATokenAddress[wbtcTokenAddress] = 0x078f358208685046a11C85e8ad32895DED33A249;
        tokenAddressToATokenAddress[
            stMaticTokenAddress
        ] = 0xEA1132120ddcDDA2F119e99Fa7A27a0d036F7Ac9;
        tokenAddressToATokenAddress[linkTokenAddress] = 0x191c10Aa4AF7C30e871E70C95dB0E4eb77237530;
    }

    /**
     * @notice Deposits USDC into margin account. The amount is supplied as collateral on Aave V3.
     * @dev Make sure to approve the transfer of USDC from user to this contract.
     * @param amount The amount of USDC to be transferred.
     */
    function depositIntoMarginAccount(uint256 amount) public {
        // Instantiate Aave V3 Pool
        iPoolAddress = i_poolAddressesProvider.getPool();
        aavePool = IPool(iPoolAddress);

        // Transfer USDC to contract
        i_usdc.transferFrom(msg.sender, address(this), amount);

        // Approve Pool contract to spend USDC
        i_usdc.approve(iPoolAddress, amount);

        // Supply all USDC to Aave V3 on behalf of user
        aavePool.supply(address(i_usdc), amount, msg.sender, 0);
    }

    /**
     * @notice Withdraws USDC into margin account. The amount is withdrawn from Aave V3 supplies.
     * @dev Aave will allow the withdraw only if new HF > 1 else tx will revert.
     * @dev Make sure to appove the transfer aUSDC from user to this contract.
     * @param amount The amount of USDC to be withdrawn.
     */
    function withdrawFromMarginAccount(uint256 amount) public {
        // Instantiate Aave V3 Pool and USDC aToken
        iPoolAddress = i_poolAddressesProvider.getPool();
        aavePool = IPool(iPoolAddress);
        IERC20 aToken = IERC20(tokenAddressToATokenAddress[address(i_usdc)]);

        // Transfer USDC aTokens to contract
        aToken.transferFrom(msg.sender, address(this), amount);

        // Approve contract to spend USDC aTokens
        aToken.approve(address(aavePool), amount);

        // Withdraw amount of USDC from Aave V3
        aavePool.withdraw(address(i_usdc), amount, msg.sender);
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory /* feeAmounts */,
        bytes memory userData
    ) external override {
        // Parse data
        IERC20 token = tokens[0];
        uint256 amount = amounts[0];
        (address tokenAddress, address userAddress, uint8 direction, uint256 profit) = abi.decode(
            userData,
            (address, address, uint8, uint256)
        );

        // Route to desired action
        if (direction == 0) {
            openLongPosition(amount, tokenAddress, userAddress);
        } else if (direction == 1) {
            openShortPosition(amount, tokenAddress, userAddress);
        } else if (direction == 2) {
            closeLongPosition(amount, tokenAddress, userAddress, profit);
        } else if (direction == 3) {
            closeShortPosition(amount, tokenAddress, userAddress, profit);
        }

        // Repay flashloan
        token.transfer(address(i_vault), amount);
    }

    /**
     * @notice Requests flashloan from Balancer. USDC if long, requested asset if short.
     * @dev Make sure to do the necessary checks to calculate if the position can be opened else Aave will revert the tx.
     * @dev Make sure to approve credit delegation of vTokens of USDC (if long) or the requested asset (if short) from user to this contract address.
     * @param amount Size of position denoted in USDC (if long) or denoted in requested asset (if short).
     * @param tokenAddress Contract address of a supported asset.
     * @param direction 0 = long, 1 = short
     */
    function requestOpen(uint256 amount, address tokenAddress, uint8 direction) public {
        address userAddress = msg.sender;

        // Setup flashloan request
        IERC20[] memory tokens = new IERC20[](1);
        uint256[] memory amounts = new uint256[](1);
        bytes memory userData = abi.encode(tokenAddress, userAddress, direction, 0);

        direction == 0 ? tokens[0] = i_usdc : tokens[0] = IERC20(tokenAddress);
        amounts[0] = amount;

        // Request flashloan
        i_vault.flashLoan(this, tokens, amounts, userData);
    }

    function openLongPosition(uint256 amount, address tokenAddress, address userAddress) private {
        // Approve Uni V3 router to spend USDC
        i_usdc.approve(address(i_swapRouter), amount);

        // Swap USDC for requested asset on Uni V3
        ISwapRouter.ExactInputSingleParams memory inputParams = ISwapRouter.ExactInputSingleParams(
            address(i_usdc),
            tokenAddress,
            3000,
            address(this),
            block.timestamp + 60 * 10,
            amount,
            0,
            0
        );
        uint256 quotedAmountBase = i_quoter.quoteExactInputSingle(
            address(i_usdc),
            tokenAddress,
            3000,
            amount,
            0
        );
        i_swapRouter.exactInputSingle(inputParams);

        // Approve Aave Pool contract to spend token
        IERC20 token = IERC20(tokenAddress);
        token.approve(iPoolAddress, quotedAmountBase);

        // Supply requested asset on Aave V3
        aavePool.supply(tokenAddress, quotedAmountBase, userAddress, 0);

        // Borrow USDC on Aave v3
        aavePool.borrow(address(i_usdc), amount, 2, 0, userAddress);
    }

    function openShortPosition(uint256 amount, address tokenAddress, address userAddress) private {
        // Approve Uni V3 router to spend USDC
        IERC20(tokenAddress).approve(address(i_swapRouter), amount);

        // Swap requested asset for USDC on Uni V3
        ISwapRouter.ExactInputSingleParams memory inputParams = ISwapRouter.ExactInputSingleParams(
            tokenAddress,
            address(i_usdc),
            3000,
            address(this),
            block.timestamp + 60 * 10,
            amount,
            0,
            0
        );
        uint256 quotedAmountBase = i_quoter.quoteExactInputSingle(
            tokenAddress,
            address(i_usdc),
            3000,
            amount,
            0
        );
        i_swapRouter.exactInputSingle(inputParams);

        // Approve Aave Pool contract to spend token
        IERC20 token = IERC20(address(i_usdc));
        token.approve(iPoolAddress, quotedAmountBase);

        // Supply USDC on Aave V3
        aavePool.supply(address(i_usdc), quotedAmountBase, userAddress, 0);

        // Borrow requested asset on Aave v3
        aavePool.borrow(tokenAddress, amount, 2, 0, userAddress);
    }

    /**
     * @notice Requests flashloan from Balancer. Requested asset if long, USDC if short.
     * @dev Make sure to do the necessary checks to calculate if the position can be closed else Aave will revert the tx.
     * @dev If closing long, make sure to approve the transfer of close size of tokens and aTokens of the requested asset from user to this contract address.
     * @dev If closing short, make sure to approve the transfer of close size of USDC and aUSDC from user to this contract address.
     * @param repay If closing long, size of position minus profit (denoted in requested asset). If closing short, size of borrow (denoted in USDC).
     * @param tokenAddress Contract address of the asset.
     * @param direction 2 = closing long, 3 = closing short.
     * @param profit Amount of profit booked. If closing long, denoted in requested asset. If closing short, denoted in USDC. 0 if profit <= 0.
     */
    function requestClose(
        uint256 repay,
        address tokenAddress,
        uint8 direction,
        uint256 profit
    ) public {
        address userAddress = msg.sender;
        IERC20[] memory tokens = new IERC20[](1);
        uint256[] memory amounts = new uint256[](1);
        bytes memory userData = abi.encode(tokenAddress, userAddress, direction, profit);

        direction == 2 ? tokens[0] = IERC20(tokenAddress) : tokens[0] = i_usdc;
        amounts[0] = repay;

        i_vault.flashLoan(this, tokens, amounts, userData);
    }

    function closeLongPosition(
        uint256 repay,
        address tokenAddress,
        address userAddress,
        uint256 profit
    ) private {
        uint256 totalPosition = repay + profit;

        // Approve Uni V3 router to spend requested asset
        IERC20 token = IERC20(tokenAddress);
        token.approve(address(i_swapRouter), totalPosition);

        // Swap requested asset for USDC on Uni V3
        ISwapRouter.ExactInputSingleParams memory inputParams = ISwapRouter.ExactInputSingleParams(
            tokenAddress,
            address(i_usdc),
            3000,
            address(this),
            block.timestamp + 60 * 10,
            repay,
            0,
            0
        );
        uint256 quotedAmountBase = i_quoter.quoteExactInputSingle(
            tokenAddress,
            address(i_usdc),
            3000,
            repay,
            0
        );
        i_swapRouter.exactInputSingle(inputParams);

        // Approve Aave Pool contract to spend USDC
        i_usdc.approve(iPoolAddress, quotedAmountBase);

        // Repay quotedAmountBase (USDC) debt on Aave V3
        aavePool.repay(address(i_usdc), quotedAmountBase, 2, userAddress);

        // Transfer aTokens of requested asset to contract
        IERC20 aToken = IERC20(tokenAddressToATokenAddress[tokenAddress]);
        aToken.transferFrom(userAddress, address(this), totalPosition);

        // Withdraw requested asset on Aave V3
        aavePool.withdraw(tokenAddress, aToken.balanceOf(address(this)), userAddress);

        // Transfer newly withdrawn tokens of requested asset to contract
        token.transferFrom(userAddress, address(this), totalPosition);

        if (profit > 0) {
            // Swap profit for USDC
            inputParams = ISwapRouter.ExactInputSingleParams(
                tokenAddress,
                address(i_usdc),
                3000,
                address(this),
                block.timestamp + 60 * 10,
                profit,
                0,
                0
            );
            quotedAmountBase = i_quoter.quoteExactInputSingle(
                tokenAddress,
                address(i_usdc),
                3000,
                profit,
                0
            );
            i_swapRouter.exactInputSingle(inputParams);

            // Approve Aave Pool contract to spend USDC
            i_usdc.approve(iPoolAddress, quotedAmountBase);

            // Supply profit in USDC back into Aave V3
            aavePool.supply(address(i_usdc), quotedAmountBase, userAddress, 0);
        }
    }

    function closeShortPosition(
        uint256 repay,
        address tokenAddress,
        address userAddress,
        uint256 profit
    ) private {
        uint256 totalPosition = repay + profit;

        // Approve Uni V3 router to spend USDC
        i_usdc.approve(address(i_swapRouter), totalPosition);

        // Swap requested asset for USDC on Uni V3
        ISwapRouter.ExactInputSingleParams memory inputParams = ISwapRouter.ExactInputSingleParams(
            address(i_usdc),
            tokenAddress,
            3000,
            address(this),
            block.timestamp + 60 * 10,
            repay,
            0,
            0
        );
        uint256 quotedAmountBase = i_quoter.quoteExactInputSingle(
            address(i_usdc),
            tokenAddress,
            3000,
            repay,
            0
        );
        i_swapRouter.exactInputSingle(inputParams);

        // Approve Aave Pool contract to spend requested asset
        IERC20 token = IERC20(tokenAddress);
        token.approve(iPoolAddress, quotedAmountBase);

        // Repay quotedAmountBase (requested asset) debt on Aave V3
        aavePool.repay(tokenAddress, quotedAmountBase, 2, userAddress);

        // Transfer aTokens of USDC to contract
        IERC20 aToken = IERC20(tokenAddressToATokenAddress[address(i_usdc)]);
        aToken.transferFrom(userAddress, address(this), totalPosition);

        // Withdraw USDC on Aave V3
        aavePool.withdraw(address(i_usdc), aToken.balanceOf(address(this)), userAddress);

        // Transfer newly withdrawn USDC tokens to contract
        i_usdc.transferFrom(userAddress, address(this), totalPosition);

        if (profit > 0) {
            // Approve Aave Pool contract to spend USDC
            i_usdc.approve(iPoolAddress, profit);

            // Supply profit in USDC back into Aave V3
            aavePool.supply(address(i_usdc), profit, userAddress, 0);
        }
    }

    receive() external payable {}

    fallback() external payable {}
}
