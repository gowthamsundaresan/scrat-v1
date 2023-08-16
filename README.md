# Scrat Protocol Smart Contract. 

The contract interfaces with Aave as the margin account provider, Balancer for flashloans and Uniswap V3 for swaps.

# Features
1. Deposit funds into margin account, which is the Aave account linked the the user's wallet
2. Open long & short positions
3. Close long & short positions
4. Withdraw funds from the margin account

# Functions
`depositIntoMarginAccount (uint256 amount)` <br>
Deposits USDC into margin account. The amount is supplied as collateral on Aave V3. <br> <br>
&nbsp; &nbsp; &nbsp; &nbsp; @dev Make sure to approve the transfer of USDC from user to this contract. <br>
&nbsp; &nbsp; &nbsp; &nbsp; @param `amount` The amount of USDC to be transferred. <br> <br>

`withdrawFromMarginAccount(uint256 amount)` <br>
Withdraws USDC into margin account. The amount is withdrawn from Aave V3 supplies. <br> <br>
&nbsp; &nbsp; &nbsp; &nbsp; @dev Aave will allow the withdraw only if new HF > 1 else tx will revert. <br>
&nbsp; &nbsp; &nbsp; &nbsp; @dev Make sure to appove the transfer aUSDC from user to this contract. <br>
&nbsp; &nbsp; &nbsp; &nbsp; @param `amount` The amount of USDC to be withdrawn. <br> <br>

`requestOpen(uint256 amount, address tokenAddress, uint8 direction)` <br>
Opens long or short position by: <br>
1. Initiating a flashloan from Balancer <br>
2. Swapping to the asset if long or USDC if short <br>
3. Supplying to Aave <br>
4. Borrowing against collateral (borrow USDC if long, asset if short) <br>
5. Repaying flashloan with borrowed amount <br> <br>
@dev Make sure to do the necessary checks to calculate if the position can be opened else Aave will revert the tx. <br>
@dev Make sure to approve credit delegation of vTokens of USDC (if long) or the requested asset (if short) from user to this contract. <br>
@param `amount` Size of position denoted in USDC (if long) or denoted in requested asset (if short). <br>
@param `tokenAddress` Contract address of a supported asset. <br>
@param `direction` 0 = long, 1 = short. <br> <br>

`requestClose(uint256 repay, address tokenAddress, uint8 direction, uint256 profit)` <br>
Closes long or short position by: <br>
1. Initiating a flashloan from Balancer <br>
2. Swapping to USDC if long or the asset if short <br>
3. Supplying to Aave <br>
4. Withdrawing collateral from opening the position (withdraw asset if long, USDC if short) <br>
5. Repaying flashloan with the withdrawn amount <br>
6. Booking profit if any <br> <br>
@dev Make sure to do the necessary checks to calculate if the position can be closed else Aave will revert the tx. <br>
@dev If closing long, make sure to approve the transfer of close size of tokens and aTokens of the requested asset from user to this contract. <br>
@dev If closing short, make sure to approve the transfer of close size of USDC and aUSDC from user to this contract address. <br>
@param `repay` If closing long, size of position minus profit (denoted in requested asset). If closing short, size of borrow (denoted in USDC). <br>
@param `tokenAddress` Contract address of the asset. <br>
@param `direction` 2 = closing long, 3 = closing short. <br>
@param `profit` Amount of profit booked. If closing long, denoted in requested asset. If closing short, denoted in USDC. 0 if profit <= 0. <br>
    


