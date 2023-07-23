// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "hardhat/console.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "@balancer-labs/v2-interfaces/contracts/vault/IVault.sol";
import "@balancer-labs/v2-interfaces/contracts/vault/IFlashLoanRecipient.sol";

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
     * @notice deposits USDC into margin account. The amount is supplied as collateral on Aave V3.
     * @dev make sure to approve the transfer of USDC from user to this contract
     * @param amount the amount of USDC to be transferred
     */
    function depositIntoMarginAccount(uint256 amount) public {
        console.log("Entered deposit() Function...");

        // Instantiate Aave V3 Pool
        iPoolAddress = i_poolAddressesProvider.getPool();
        aavePool = IPool(iPoolAddress);
        console.log("Pool instantiated with address: ");
        console.log(address(aavePool));

        // Transfer USDC to contract
        i_usdc.transferFrom(msg.sender, address(this), amount);
        console.log("Amount Transferred...");

        // Approve Pool contract to spend USDC
        i_usdc.approve(iPoolAddress, amount);
        console.log("Amount Approved...");

        // Supply all USDC to Aave V3 on behalf of user
        aavePool.supply(address(i_usdc), amount, msg.sender, 0);
        console.log("Supplied to Aave...");
    }

    /**
     * @notice withdraws USDC into margin account. The amount is withdrawn from Aave V3 supplies.
     * @dev Aave will allow the withdraw only if new HF > 1 else tx will revert
     * @dev make sure to appove the transfer aUSDC from user to this contract
     * @param amount the amount of USDC to be withdrawn
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
        console.log("Flashloan request received...");

        // Parse data
        IERC20 token = tokens[0];
        uint256 amount = amounts[0];
        (address tokenAddress, address userAddress, uint8 direction, uint256 profit) = abi.decode(
            userData,
            (address, address, uint8, uint256)
        );

        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        console.log("This contract now holds token balance of: ");
        console.log(tokenBalance);

        uint256 usdcBalance = i_usdc.balanceOf(address(this));
        console.log("This contract now holds USDC of: ");
        console.log(usdcBalance);

        // Perform intended action
        if (direction == 0) {
            console.log("Open long position request received...");
            openLongPosition(amount, tokenAddress, userAddress);
        } else if (direction == 1) {
            console.log("Open short position request received...");
            openShortPosition(amount, tokenAddress, userAddress);
        } else if (direction == 2) {
            console.log("Close long position request received...");
            closeLongPosition(amount, tokenAddress, userAddress, profit);
        } else if (direction == 3) {
            console.log("Close short position request received...");
            closeShortPosition(amount, tokenAddress, userAddress, profit);
        }

        // Repay flashloan
        token.transfer(address(i_vault), amount);
        console.log("Flashloan has been repayed...");
    }

    /**
     * @notice requests flashloan from Balancer. USDC if long, requested asset if short
     * @dev make sure to do the necessary checks to calculate if the position can be opened else Aave will revert the tx
     * @dev make sure to approve credit delegation of vTokens of USDC (if long) or the requested asset (if short) from user to this contract address
     * @param amount size of position denoted in USDC (if long) or denoted in requested asset (if short)
     * @param tokenAddress contract address of the asset
     * @param direction 0 = long, 1 = short
     */
    function requestOpen(uint256 amount, address tokenAddress, uint8 direction) public {
        console.log("Entered function requestOpen()...");
        address userAddress = msg.sender;

        // Setup flashloan request
        IERC20[] memory tokens = new IERC20[](1);
        uint256[] memory amounts = new uint256[](1);
        bytes memory userData = abi.encode(tokenAddress, userAddress, direction, 0);

        direction == 0 ? tokens[0] = i_usdc : tokens[0] = IERC20(tokenAddress);
        amounts[0] = amount;
        console.log("Flashloan has been setup...");

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
        console.log("Swaprouter approved for ", amount);

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
        console.log("Swapped ", amount, "for USDC ", quotedAmountBase);

        // Approve Aave Pool contract to spend token
        IERC20 token = IERC20(address(i_usdc));
        token.approve(iPoolAddress, quotedAmountBase);
        console.log("Approved Aave for USDC ", quotedAmountBase);

        // Supply USDC on Aave V3
        aavePool.supply(address(i_usdc), quotedAmountBase, userAddress, 0);
        console.log("Supplied on Aave: USDC ", quotedAmountBase);

        // Borrow requested asset on Aave v3
        aavePool.borrow(tokenAddress, amount, 2, 0, userAddress);
        console.log("Borrowing on Aave: ", amount);
    }

    /**
     * @notice requests flashloan from Balancer. Requested asset if long, USDC if short
     * @dev make sure to do the necessary checks to calculate if the position can be closed else Aave will revert the tx
     * @dev if closing long, make sure to approve the transfer of close size of tokens and aTokens of the requested asset from user to this contract address
     * @dev if closing short, make sure to approve the transfer of close size of USDC and aUSDC from user to this contract address
     * @param repay if closing long, size of position minus profit (denoted in requested asset). If closing short, size of borrow (denoted in USDC)
     * @param tokenAddress contract address of the asset
     * @param direction 2 = closing long, 3 = closing short
     * @param profit amount of profit booked. If closing long, denoted in requested asset. If closing short, denoted in USDC. 0 if profit <= 0
     */
    function requestClose(
        uint256 repay,
        address tokenAddress,
        uint8 direction,
        uint256 profit
    ) public {
        console.log("Entered function requestClose()...");
        address userAddress = msg.sender;
        IERC20[] memory tokens = new IERC20[](1);
        uint256[] memory amounts = new uint256[](1);
        bytes memory userData = abi.encode(tokenAddress, userAddress, direction, profit);

        direction == 2 ? tokens[0] = IERC20(tokenAddress) : tokens[0] = i_usdc;
        amounts[0] = repay;

        console.log("Requesting flashloan...");
        i_vault.flashLoan(this, tokens, amounts, userData);
    }

    function closeLongPosition(
        uint256 repay,
        address tokenAddress,
        address userAddress,
        uint256 profit
    ) private {
        console.log("Entered closeLongPosition()...");
        uint256 totalPosition = repay + profit;
        uint256 tcb;
        uint256 tdb;

        console.log("Total Position: ");
        console.log(totalPosition);

        // Approve Uni V3 router to spend requested asset
        IERC20 token = IERC20(tokenAddress);
        token.approve(address(i_swapRouter), totalPosition);
        console.log("Uni V3 approved...");

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
        console.log("Swap successful...");
        console.log(quotedAmountBase);

        // Approve Aave Pool contract to spend USDC
        i_usdc.approve(iPoolAddress, quotedAmountBase);
        console.log("Aave approved for: ");
        console.log(quotedAmountBase);

        // Check Aave
        (tcb, tdb, , , , ) = aavePool.getUserAccountData(userAddress);
        console.log("Current TCB: ");
        console.log(tcb);
        console.log("Current TDB: ");
        console.log(tdb);

        // Repay quotedAmountBase (USDC) debt on Aave V3
        aavePool.repay(address(i_usdc), quotedAmountBase, 2, userAddress);
        console.log("Repaid debt on Aave");

        // Check Aave
        (tcb, tdb, , , , ) = aavePool.getUserAccountData(userAddress);
        console.log("Current TCB: ");
        console.log(tcb);
        console.log("Current TDB: ");
        console.log(tdb);

        // Transfer aTokens of requested asset to contract
        IERC20 aToken = IERC20(tokenAddressToATokenAddress[tokenAddress]);
        console.log("User aToken balance: ");
        console.log(aToken.balanceOf(userAddress));
        aToken.transferFrom(userAddress, address(this), totalPosition);
        console.log("Received aTokens from user");
        console.log("Balance of aTokens: ");
        console.log(aToken.balanceOf(address(this)));

        // Withdraw requested asset on Aave V3
        aavePool.withdraw(tokenAddress, aToken.balanceOf(address(this)), userAddress);
        console.log("Withdrew tokens from Aave");

        // Check Aave
        (tcb, tdb, , , , ) = aavePool.getUserAccountData(userAddress);
        console.log("Current TCB: ");
        console.log(tcb);
        console.log("Current TDB: ");
        console.log(tdb);

        // Transfer newly withdrawn tokens of requested asset to contract
        token.transferFrom(userAddress, address(this), totalPosition);
        console.log("Received tokens from user");
        console.log("Balance of token: ");
        console.log(token.balanceOf(address(this)));

        if (profit > 0) {
            console.log("This trade is profitable...");

            // Swap profit for USDC
            console.log("Amount to swap on Uni V3: ");
            console.log(profit);
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
            console.log("Swapped profit on Uniswap");
            console.log(quotedAmountBase);

            // Approve Aave Pool contract to spend USDC
            i_usdc.approve(iPoolAddress, quotedAmountBase);
            console.log("Aave approved for: ");
            console.log(quotedAmountBase);

            // Supply profit in USDC back into Aave V3
            aavePool.supply(address(i_usdc), quotedAmountBase, userAddress, 0);
            console.log("Profit supplied back to Aave: ");
        }
    }

    function closeShortPosition(
        uint256 repay,
        address tokenAddress,
        address userAddress,
        uint256 profit
    ) private {
        console.log("Entered closeShortPosition()...");
        uint256 totalPosition = repay + profit;
        uint256 tcb;
        uint256 tdb;

        console.log("Total Position: ");
        console.log(totalPosition);

        // Approve Uni V3 router to spend USDC
        i_usdc.approve(address(i_swapRouter), totalPosition);
        console.log("Uni V3 approved...");

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
        console.log("Swap successful...");
        console.log(quotedAmountBase);

        // Approve Aave Pool contract to spend requested asset
        IERC20 token = IERC20(tokenAddress);
        token.approve(iPoolAddress, quotedAmountBase);
        console.log("Aave approved for: ");
        console.log(quotedAmountBase);

        // Check Aave
        (tcb, tdb, , , , ) = aavePool.getUserAccountData(userAddress);
        console.log("Current TCB: ");
        console.log(tcb);
        console.log("Current TDB: ");
        console.log(tdb);

        // Repay quotedAmountBase (requested asset) debt on Aave V3
        aavePool.repay(tokenAddress, quotedAmountBase, 2, userAddress);
        console.log("Repaid debt on Aave");

        // Check Aave
        (tcb, tdb, , , , ) = aavePool.getUserAccountData(userAddress);
        console.log("Current TCB: ");
        console.log(tcb);
        console.log("Current TDB: ");
        console.log(tdb);

        // Transfer aTokens of USDC to contract
        IERC20 aToken = IERC20(tokenAddressToATokenAddress[address(i_usdc)]);
        console.log("User aToken balance: ");
        console.log(aToken.balanceOf(userAddress));
        aToken.transferFrom(userAddress, address(this), totalPosition);
        console.log("Received aTokens from user");
        console.log("Balance of aTokens: ");
        console.log(aToken.balanceOf(address(this)));

        // Withdraw USDC on Aave V3
        aavePool.withdraw(address(i_usdc), aToken.balanceOf(address(this)), userAddress);
        console.log("Withdrew USDC from Aave");

        // Check Aave
        (tcb, tdb, , , , ) = aavePool.getUserAccountData(userAddress);
        console.log("Current TCB: ");
        console.log(tcb);
        console.log("Current TDB: ");
        console.log(tdb);

        // Transfer newly withdrawn USDC tokens to contract
        i_usdc.transferFrom(userAddress, address(this), totalPosition);
        console.log("Received USDC from user");
        console.log("Balance of USDC: ");
        console.log(i_usdc.balanceOf(address(this)));

        if (profit > 0) {
            console.log("This trade is profitable...");

            // Approve Aave Pool contract to spend USDC
            i_usdc.approve(iPoolAddress, profit);
            console.log("Aave approved for: ");
            console.log(profit);

            // Supply profit in USDC back into Aave V3
            aavePool.supply(address(i_usdc), profit, userAddress, 0);
            console.log("Profit supplied back to Aave: ");
        }
    }

    receive() external payable {}

    fallback() external payable {}
}
