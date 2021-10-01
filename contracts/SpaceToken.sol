//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 *
 * @title Hekaya
 * @author Olendolorian
 * @notice SpaceToken contract for issuance of Space Tokens
 *
 */
contract SpaceToken is ERC20 {
  
  uint private _initialSupply = 500000;
  bool private _applyTax;
  bool private _isTrading;
  address private _owner;
  address payable private _treasury;

  constructor(address payable treasury_) ERC20("Space Token", "SPC") {
    _applyTax = false;
    _isTrading = false;
    _owner = msg.sender;
    _treasury = treasury_;
    _mint(msg.sender, _initialSupply * (10 ** decimals()));
  }

  /**
    * @dev Modifier to ensure that only certain functions can be accessed by the project creator.
    */
  modifier onlyOwner() {
    require(msg.sender == _owner, "Only Owner");
    _;
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    if (_applyTax) {
      uint taxAmount = (amount / 100) * 2;
      amount -= taxAmount;
      _transfer(msg.sender, _treasury, taxAmount);
    }
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function setTax(bool shouldApplyTax) public onlyOwner returns (bool) {
    _applyTax = shouldApplyTax;
    return _applyTax;
  }

  function taxStatus() public view onlyOwner returns (bool) {
    return _applyTax;
  }

  function treasury() public view returns (address) {
    return _treasury;
  }

}
