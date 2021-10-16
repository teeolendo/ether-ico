//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/utils/math/Math.sol';
import "./SpaceToken.sol";

contract SpacePool is ERC20 {

  uint public constant MINIMUM_LIQUIDITY = 10**3;
  bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

  SpaceToken spaceToken;
  
  uint private reserve0;           // uses single storage slot, accessible via getReserves
  uint private reserve1;           // uses single storage slot, accessible via getReserves
  uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

  uint public contractBalance;
  uint public price0CumulativeLast;
  uint public price1CumulativeLast;
  uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event
  mapping(address => uint) private _investors;
  uint private unlocked = 1;

  constructor(address payable treasury_) ERC20("Space Liquidity Token", "SLT") { }
  
  modifier lock() {
    require(unlocked == 1, 'SpacePool: LOCKED');
    unlocked = 0;
    _;
    unlocked = 1;
  }

  function getReserves() public view returns (uint _reserve0, uint _reserve1, uint32 _blockTimestampLast) {
    _reserve0 = reserve0;
    _reserve1 = reserve1;
    _blockTimestampLast = blockTimestampLast;
  }

  function _safeTransfer(address token, address to, uint value) private {
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), 'SpacePool: TRANSFER_FAILED');
  }

  event Mint(address indexed sender, uint amount0, uint amount1);
  event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
  event Swap(
    address indexed sender,
    uint amount0In,
    uint amount1In,
    uint spcTokenOut,
    uint ethOut,
    address indexed to
  );
  event Sync(uint reserve0, uint reserve1);


  // update reserves and, on the first call per block, price accumulators
  function _update(uint balance0, uint balance1, uint _reserve0, uint _reserve1) private {
    require(balance0 <= uint(0) && balance1 <= uint(0), 'SpacePool: OVERFLOW');
    uint32 blockTimestamp = uint32(block.timestamp % 2**32);
    uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
    if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
        // * never overflows, and + overflow is desired
        price0CumulativeLast += (_reserve1 / _reserve0) * timeElapsed;
        price1CumulativeLast += (_reserve0 / _reserve1) * timeElapsed;
    }
    reserve0 = uint(balance0);
    reserve1 = uint(balance1);
    blockTimestampLast = blockTimestamp;
    emit Sync(reserve0, reserve1);
  }

  // this low-level function should be called from a contract which performs important safety checks
  function mint(address to) external payable lock returns (uint liquidity) {
    (uint _reserve0, uint _reserve1,) = getReserves(); // gas savings
    uint balance0 = spaceToken.balanceOf(address(this));
    uint balance1 = contractBalance;
    uint amount0 = balance0 - _reserve0;
    uint amount1 = balance1 - _reserve1;

    uint _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
    if (_totalSupply == 0) {
        liquidity = _sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
        _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
    } else {
        liquidity = Math.min(amount0 * _totalSupply / _reserve0, amount1 * _totalSupply / _reserve1);
    }
    require(liquidity > 0, 'SpacePool: INSUFFICIENT_LIQUIDITY_MINTED');
    _mint(to, liquidity);
    contractBalance -= amount1;
    _investors[msg.sender] += amount1;
    _update(balance0, balance1, _reserve0, _reserve1);
    emit Mint(msg.sender, amount0, amount1);
  }

  // this low-level function should be called from a contract which performs important safety checks
  function burn(address to) external lock returns (uint amount0, uint amount1) {
    (uint _reserve0, uint _reserve1,) = getReserves(); // gas savings
    address _spaceToken = address(spaceToken);                              // gas savings
    uint balance0 = spaceToken.balanceOf(address(this));
    uint balance1 = contractBalance;
    uint liquidity = balanceOf(address(this));

    uint _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
    amount0 = liquidity * balance0 / _totalSupply; // using balances ensures pro-rata distribution
    amount1 = liquidity * balance1 / _totalSupply; // using balances ensures pro-rata distribution
    require(amount0 > 0 && amount1 > 0, 'SpacePool: INSUFFICIENT_LIQUIDITY_BURNED');
    _burn(address(this), liquidity);
    _safeTransfer(_spaceToken, to, amount0);
    contractBalance -= amount1;
    _investors[msg.sender] -= amount1;
    balance0 = spaceToken.balanceOf(address(this));
    balance1 = contractBalance;

    _update(balance0, balance1, _reserve0, _reserve1);
    emit Burn(msg.sender, amount0, amount1, to);
  }

  // this low-level function should be called from a contract which performs important safety checks
  function swap(uint spcTokenOut, uint ethOut, address to, bytes calldata data) external lock {
    require(spcTokenOut > 0 || ethOut > 0, 'SpacePool: INSUFFICIENT_OUTPUT_AMOUNT');
    (uint _reserve0, uint _reserve1,) = getReserves(); // gas savings
    require(spcTokenOut < _reserve0 && ethOut < _reserve1, 'SpacePool: INSUFFICIENT_LIQUIDITY');

    uint balance0;
    uint balance1;
    { // scope for _token{0,1}, avoids stack too deep errors
      address _spaceToken = address(spaceToken);
      require(to != _spaceToken, 'SpacePool: INVALID_TO');
      if (spcTokenOut > 0) _safeTransfer(_spaceToken, to, spcTokenOut); // optimistically transfer tokens
      if (ethOut > 0) {
          contractBalance -= ethOut;
          (bool sent, bytes memory data) = to.call{value: ethOut}("");
          require(sent, "Failed to send Ether");
      }
      balance0 = spaceToken.balanceOf(address(this));
      balance1 = contractBalance;
    }
    uint amount0In = balance0 > _reserve0 - spcTokenOut ? balance0 - (_reserve0 - spcTokenOut) : 0;
    uint amount1In = balance1 > _reserve1 - ethOut ? balance1 - (_reserve1 - ethOut) : 0;
    require(amount0In > 0 || amount1In > 0, 'SpacePool: INSUFFICIENT_INPUT_AMOUNT');
    { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
    uint balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
    uint balance1Adjusted = (balance0 * 1000) - (amount0In * 3);
    require(balance0Adjusted * balance1Adjusted >= uint(_reserve0) * _reserve1 * 1000**2, 'SpacePool: K');
    }

    _update(balance0, balance1, _reserve0, _reserve1);
    emit Swap(msg.sender, amount0In, amount1In, spcTokenOut, ethOut, to);
  }


  /**
    * @dev Square root calcuation using the Babylonian Method 
    */
  function _sqrt(uint x) private pure returns (uint y) {
    uint z = (x + 1) / 2;
    y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }
}
}
