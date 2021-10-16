//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./SpaceToken.sol";
import "./SpacePool.sol";

contract SpaceRouter {
    
  SpaceToken spaceToken;
  SpacePool spacePool;
  mapping(address => uint) private refundableEther;

  // **** ADD LIQUIDITY ****
  function _addLiquidity(
      uint amountADesired,
      uint amountBDesired,
      uint amountAMin,
      uint amountBMin
  ) internal virtual returns (uint amountA, uint amountB) {
      (uint reserveA, uint reserveB) = spacePool.getReserves();
      if (reserveA == 0 && reserveB == 0) {
          (amountA, amountB) = (amountADesired, amountBDesired);
      } else {
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
    
    function addLiquidity(
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to
    ) external virtual payable returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _addLiquidity(
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        spaceToken.transfer(msg.sender, amountToken);
        liquidity = spacePool.mint(to)({value: msg.value});
        // refund dust eth, if any
        if (msg.value > amountETH) refundableEther[msg.sender] += (msg.value - amountETH);
    }

    function refundMyEther() external returns (bool sent) {
      require(refundableEther[msg.sender] > 0, "NO_REFUNDS_FOR_ADDRESS");
      uint refund = refundableEther[msg.sender];
      refundableEther[msg.sender] = 0;
      (sent,) = payable(msg.sender).call{value: refund}("");
      require(sent, "Failed to send Ether");
      return sent;
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        uint liquidity,
        uint amount1Min,
        uint amount2Min,
        address to
    ) public  returns (uint amount0, uint amount1) {
      (amount0, amount1) = spacePool.burn(to);
      require(amount0 >= amount1Min, 'INSUFFICIENT_A_AMOUNT');
      require(amount1 >= amount2Min, 'INSUFFICIENT_B_AMOUNT');
      (bool sent,) = payable(to).call{value: amount1}("");
      require(sent, "Failed to send Ether");
    }

    // **** LIBRARY FUNCTIONS ****
    function _quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'SpaceRouter: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'SpaceRouter: INSUFFICIENT_LIQUIDITY');
        amountB = (amountA * reserveB) / reserveA;
    }
}