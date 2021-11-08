//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./SpaceToken.sol";
import "./SpacePool.sol";

/*
 *
 * @title SpaceRouter
 * @author Tony Olendo
 * @notice This is the primary router to facilite Space Token and Ether exchanges
 * @dev This contract allows for the removal and addition of liquidity to the Space Token Liquidity Pool Contract
 *
 */

contract SpaceRouter {
    
  SpaceToken spaceToken;
  SpacePool spacePool;
  mapping(address => uint) private refundableEther;

  event LiquidityAdded(address lpTokenHolder, uint lpTokens);
  event LiquidityRemoved(address lpTokenHolder, uint lpTokens);
  event SwapEth(address swapHolder, uint amount, uint issuedAmount);
  event SwapSPToken(address swapHolder, uint amount, uint issuedAmount);

  /*
   * @notice Initializes the contracts with Space Token and Space Token Liquidity Pool contract.
   * @param _spaceToken SpaceToken Address
   * @param _spacePool SpacePool Address
   */
  constructor(SpaceToken _spaceToken, SpacePool _spacePool) {
    spaceToken = _spaceToken;
    spacePool = _spacePool;
  }

  /* 
    * 
    * @dev Adds liquidity by accepting a desired amount of Ether vs Space Token
    * @param amountTokenDesired Desired SpaceToken Amount
    * @param amountTokenMin Minimum Desired Token Amount
    * @param amountEthMin Minimum Deposited Token Amount
    * @param to Desired Liquidity Pool Token Holder 
    *
    */
  function addLiquidity(
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to
  ) external virtual payable
    returns (
      uint amountToken,
      uint amountETH,
      uint liquidity
    ){
    (amountToken, amountETH) = _addLiquidity(
      amountTokenDesired,
      msg.value,
      amountTokenMin,
      amountETHMin
    );
    spaceToken.transfer(msg.sender, amountToken);
    spacePool.deposit{value: amountETH}();
    liquidity = spacePool.mint(to);
    // refund dust eth, if any
    if (msg.value > amountETH) refundableEther[msg.sender] += (msg.value - amountETH);
  }

  /*
    * @notice Refunds dust Eth to LP Token Holders
    */
  function refundMyEther() external returns (bool sent) {
    require(refundableEther[msg.sender] > 0, "NO_REFUNDS_FOR_ADDRESS");
    uint refund = refundableEther[msg.sender];
    refundableEther[msg.sender] = 0;
    (sent,) = payable(msg.sender).call{value: refund}("");
    require(sent, "Failed to send Ether");
  }

  /*
    * @notice Show token holder dust ether balance.
    */
  function refundable() external view returns (uint) {
    return refundableEther[msg.sender];
  }

  /*
    * 
    * @dev Removes liquidity by accepting a desired amount of Ether vs Space Token
    * @param amountTokenDesired Desired SpaceToken Amount
    * @param amountTokenMin Minimum Desired Token Amount
    * @param amountEthMin Minimum Deposited Token Amount
    * @param to Desired Liquidity Pool Token Holder 
    *
    */
  function removeLiquidity(
      uint amount1Min,
      uint amount2Min,
      address to
  ) public  returns (uint amount0, uint amount1) {
    (amount0, amount1) = spacePool.burn(to);
    require(amount0 >= amount1Min, 'INSUFFICIENT_A_AMOUNT');
    require(amount1 >= amount2Min, 'INSUFFICIENT_B_AMOUNT');
  }

  /*
    * 
    * @dev Processes LP Token addition
    * @param amountTokenDesired Desired SpaceToken Amount
    * @param amountTokenMin Minimum Desired Token Amount
    * @param amountEthMin Minimum Deposited Token Amount
    * @param to Desired Liquidity Pool Token Holder 
    *
    */
  function _addLiquidity(
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin
  ) internal virtual 
    returns (uint amountA, uint amountB) {
    (uint reserveA, uint reserveB,) = spacePool.getReserves();
    if (reserveA == 0 && reserveB == 0) {
      (amountA, amountB) = (amountADesired, amountBDesired);
    } 
    else {
      uint amountBOptimal = _quote(amountADesired, reserveA, reserveB);
      if (amountBOptimal <= amountBDesired) {
        require(amountBOptimal >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
        (amountA, amountB) = (amountADesired, amountBOptimal);
      } else {
        uint amountAOptimal = _quote(amountBDesired, reserveB, reserveA);
        assert(amountAOptimal <= amountADesired);
        require(amountAOptimal >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
        (amountA, amountB) = (amountAOptimal, amountBDesired);
      }
    }
  }

  
  
  function swap(uint spaceTokenToSwap, address recipient) internal virtual returns (uint, uint) {
		uint reserveTokenOut;
		uint reserveTokenIn;
		uint tokenInAfterFee;
		uint tokenOutAmount;
		if (spaceTokenToSwap > 0) {
			reserveTokenIn = spaceToken.balanceOf(address(this));
			reserveTokenOut = address(this).balance;
			tokenInAfterFee = (spaceTokenToSwap * 99) / 100;
			tokenOutAmount = reserveTokenOut - (reserveTokenIn * reserveTokenOut) / (reserveTokenIn + tokenInAfterFee);

      spaceToken.transferFrom(recipient, address(this), spaceTokenToSwap);
      (bool sent, ) = recipient.call{value: tokenOutAmount}("");
      require(sent, "SPACEROUTER:: ETHER_SWAP_TRANSFER_FAIL");
      emit SwapSPToken(recipient, spaceTokenToSwap, tokenOutAmount);
		} else {
			reserveTokenIn = address(this).balance;
			reserveTokenOut = spaceToken.balanceOf(address(this));
			tokenInAfterFee = (msg.value * 99) / 100;
			tokenOutAmount = reserveTokenOut - (reserveTokenIn * reserveTokenOut) / (reserveTokenIn + tokenInAfterFee);
			spaceToken.transfer(recipient, tokenOutAmount);
			emit SwapEth(recipient, msg.value, tokenOutAmount);
			(bool sent, ) = recipient.call{value: msg.value}("");
		}
		return (tokenInAfterFee, tokenOutAmount);
  }

  // **** LIBRARY FUNCTIONS ****
  function _quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
    require(amountA > 0, 'SpaceRouter: INSUFFICIENT_AMOUNT');
    require(reserveA > 0 && reserveB > 0, 'SpaceRouter: INSUFFICIENT_LIQUIDITY');
    amountB = (amountA * reserveB) / reserveA;
  }
}