//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./SpaceToken.sol";

/**
 *
 * @title Space
 * @author Olendolorian
 * @notice ICO Management and Administration Contract for SpaceICO
 *
 */
contract SpaceICO {
    SpaceToken spaceToken;
    uint private  ICO_TARGET = 30000 ether;
    uint constant SEED_INDIVIDUAL_LIMIT = 1500 ether;
    uint constant SEED_TOTAL_LIMIT = 15000 ether;
    uint constant GENERAL_INDIVIDUAL_LIMIT = 1000 ether;
    uint constant GENERAL_TOTAL_LIMIT = 30000 ether;
    uint constant SPC_TO_ETH_RATE = 5;
    uint private _totalFunds;
    mapping(address => bool) _allowList;
    mapping(address => uint) _investors;
    bool public isFundraising;
    address private _owner;

    event InvestmentReceived(address contributor, uint amount);
    event PhaseUpgraded();

    enum Phase {
      Seed,
      General,
      Open
    }

    Phase private _currentPhase;

    constructor() {
      _currentPhase = Phase.Seed;
      _owner = msg.sender;
      isFundraising = true;

    }

    /**
     * @dev Modifier to ensure that only certain functions can be accessed by the project creator.
     */
    modifier onlyOwner() {
      require(msg.sender == _owner, "ONLY_OWNER");
      _;
    }

    /**
     * @dev Modifier to ensure the Phase is Open.
     */
    modifier onlyOpen() {
      require(_currentPhase == Phase.Open, "PHASE_NOT_OPEN");
      _;
    }

    function icoPhase() external view returns (Phase) {
      return _currentPhase;
    }

    function buy() external payable returns (bool) {
      require(isFundraising, "FUNDRAISING_PAUSED");
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

      if(_currentPhase == Phase.Open){
        redeem();
      }
      emit InvestmentReceived(msg.sender, msg.value);
      return true;
    }

    function allowList(address _address) external onlyOwner {
      _allowList[_address] = true;
    }

    function toggleFundraising(bool _isFundraising) external onlyOwner {
      isFundraising = _isFundraising;
    }

    function advancePhaseToOpen() external onlyOwner returns (Phase){
      require(_currentPhase == Phase.General, "PHASE_NOT_GENERAL");
      _currentPhase = Phase.Open;
      emit PhaseUpgraded();
      return _currentPhase;
    }

    function advancePhaseToGeneral() external onlyOwner returns (Phase){
      require(_currentPhase == Phase.Seed, "PHASE_NOT_SEED");
      _currentPhase = Phase.General; 
      emit PhaseUpgraded();
      return _currentPhase;
    }

    function redeem() public onlyOpen returns (bool) {
      require(_investors[msg.sender] > 0, "INSUFFICIENT_BALANCE");
      uint amount = _investors[msg.sender] * SPC_TO_ETH_RATE;
      _investors[msg.sender] = 0;
      spaceToken.transfer(msg.sender, amount);
      return true;
    }

    function withdrawToPool(address to, uint amount) public onlyOpen returns (bool) {
      require(_investors[msg.sender] > 0, "INSUFFICIENT_BALANCE");
      uint tokens = _investors[msg.sender] * SPC_TO_ETH_RATE;
      uint totalInvestment = _investors[msg.sender];
      uint balanceBefore = spaceToken.balanceOf(msg.sender);
      (bool success) = spaceToken.transfer(to, balanceBefore);
      uint balanceAfter = spaceToken.balanceOf(msg.sender);
      //send to LP Token
      
    }
}
