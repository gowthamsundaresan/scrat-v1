# scrat-v1

Scrat Protocol Smart Contract. 

The contract interfaces with Aave as the margin account provider, Balancer for flashloans and Uniswap V3 for swaps.

# Features
1. Deposit funds into margin account, which is the Aave accoutn linked the the user's wallet
2. Open long & short positions
3. Close long & short positions
4. Withdraw funds from the margin account

# Functions
depositIntoMarginAccount (uint256 amount)
  @notice Deposits USDC into margin account. The amount is supplied as collateral on Aave V3.
  @dev Make sure to approve the transfer of USDC from user to this contract.
  @param amount The amount of USDC to be transferred.

withdrawFromMarginAccount(uint256 amount)
  @notice Withdraws USDC into margin account. The amount is withdrawn from Aave V3 supplies.
  @dev Aave will allow the withdraw only if new HF > 1 else tx will revert.
  @dev Make sure to appove the transfer aUSDC from user to this contract.
  @param amount The amount of USDC to be withdrawn.

requestOpen(uint256 amount, address tokenAddress, uint8 direction)
  @notice Opens long or short position by: 
    1. Initiating a flashloan from Balancer
    2. Swapping to the asset if long or USDC if short
    3. Supplying to Aave
    4. Borrowing against collateral (borrow USDC if long, asset if short)
    5. Repaying flashloan with borrowed amount
  @dev Make sure to do the necessary checks to calculate if the position can be opened else Aave will revert the tx.
  @dev Make sure to approve credit delegation of vTokens of USDC (if long) or the requested asset (if short) from user to this contract address.
  @param amount Size of position denoted in USDC (if long) or denoted in requested asset (if short).
  @param tokenAddress Contract address of a supported asset.
  @param direction 0 = long, 1 = short

requestClose(uint256 repay, address tokenAddress, uint8 direction, uint256 profit)
  @notice  Closes long or short position by: 
    1. Initiating a flashloan from Balancer
    2. Swapping to USDC if long or the asset if short
    3. Supplying to Aave
    4. Withdrawing collateral from opening the position (withdraw asset if long, USDC if short)
    5. Repaying flashloan with the withdrawn amount
    6. Booking profit if any
  @dev Make sure to do the necessary checks to calculate if the position can be closed else Aave will revert the tx.
  @dev If closing long, make sure to approve the transfer of close size of tokens and aTokens of the requested asset from user to this contract address.
  @dev If closing short, make sure to approve the transfer of close size of USDC and aUSDC from user to this contract address.
  @param repay If closing long, size of position minus profit (denoted in requested asset). If closing short, size of borrow (denoted in USDC).
  @param tokenAddress Contract address of the asset.
  @param direction 2 = closing long, 3 = closing short.
  @param profit Amount of profit booked. If closing long, denoted in requested asset. If closing short, denoted in USDC. 0 if profit <= 0.
    


