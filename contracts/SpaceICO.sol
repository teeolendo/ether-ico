//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 *
 * @title Space
 * @author Olendolorian
 * @notice ICO Management and Administration Contract for SpaceICO
 *
 */
contract SpaceICO {
    uint256 private _ICO_TARGET = 30000 ether;
    mapping(address => uint256) _investors;
    uint SEED_INDIVIDUAL_LIMIT = 1500 ether;
    uint SEED_TOTAL_LIMIT = 15000 ether;
    uint GENERAL_INDIVIDUAL_LIMIT = 1000 ether;
    uint GENERAL_TOTAL_LIMIT = 30000 ether;
    uint256 private _totalFunds;
    mapping(address => bool) _allowList;
    address private _owner;

    event InvestmentReceived(address contributor, uint amount);
    event PhaseUpgraded();

    enum Phase {
      Seed,
      General,
      Open
    }

    Phase _currentPhase;

    constructor() {
      _currentPhase = Phase.Seed;
      _owner = msg.sender;
    }

    /**
     * @dev Modifier to ensure that only certain functions can be accessed by the project creator.
     */
    modifier onlyOwner() {
      require(msg.sender == _owner, "ONLY_OWNER");
      _;
    }

    function icoPhase() public view returns (Phase) {
      return _currentPhase;
    }

    function buy() public payable returns (bool) {
      if (_currentPhase == Phase.Seed) {
        require(_allowList[msg.sender], "ADDRESS_NOT_ON_ALLOWLIST");
        require(msg.value <= SEED_INDIVIDUAL_LIMIT, "INDIVIDUAL_LIMIT_EXCEEDED");
        require(msg.value <= (SEED_TOTAL_LIMIT - _totalFunds), "CONTRIBUTION_EXCEEDS_LIMIT");
      }
      if (_currentPhase == Phase.General) {
        require(msg.value <= GENERAL_INDIVIDUAL_LIMIT, "INDIVIDUAL_LIMIT_EXCEEDED");
        require(msg.value <= (GENERAL_TOTAL_LIMIT - _totalFunds), "CONTRIBUTION_EXCEEDS_LIMIT");
      }

      _totalFunds += msg.value;
      _investors[msg.sender] += msg.value;
      emit InvestmentReceived(msg.sender, msg.value);
      // console.log("TOTAL_CONT", _totalFunds);
      // console.log("LIMIT", (SEED_TOTAL_LIMIT <= _totalFunds));
      // console.log("TO LIMIT", (SEED_TOTAL_LIMIT - _totalFunds));
      // console.log("allowlist", _allowList[msg.sender]);
      return true;
    }

    function allowList(address _address) public onlyOwner {
      _allowList[_address] = true;
    }

    function advancePhase() public onlyOwner returns (Phase){
      require(_currentPhase != Phase.Open, "MAX_PHASE");
      _currentPhase = Phase(uint(_currentPhase) + 1); 
      emit PhaseUpgraded();
      return _currentPhase;
    }

    function balanceOf(address _address) public view returns (uint) {
      return _investors[_address];
    }
}
