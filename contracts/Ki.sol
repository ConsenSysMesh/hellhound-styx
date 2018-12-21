pragma solidity >=0.4.21 <0.6.0;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "./SlaInterface.sol";

contract Ki is Ownable {

  using SafeMath for uint256;
  using Address for address;
  using Roles for Roles.Role;

  Roles.Role private nodes;

  Roles.Role private mediators;

  address public slaContractAddress;

  bytes32 public computationId;

  uint256 public computationFees;

  uint256 public mediatorsFees;

  event LogComputeStarted (address indexed ownerAddress);

  event LogDisputeStarted (address indexed ownerAddress, address indexed disputeContractAddress);
  
  event LogNodeAdded (address indexed nodeAddress);

  constructor(bytes32 _computationId, address _slaContractAddress)
    public
    nonZeroBytes32(_computationId)
    nonEmptyAddress(_slaContractAddress)
    isContract(_slaContractAddress)
  {
      Ownable._transferOwnership(msg.sender);
      computationId = _computationId;
      slaContractAddress = _slaContractAddress;
  }

  function compute()
   public
   payable
   onlyOwner
  {
    SlaInterface sla = SlaInterface(slaContractAddress);
    require(sla.computationFees()<=msg.value);
    emit LogComputeStarted(msg.sender);
  }
  
  function addNode(address _nodeAddress)
   public
   nonEmptyAddress(_nodeAddress)
   //TODO only bank
  {
    nodes.add(_nodeAddress);
    emit LogNodeAdded(_nodeAddress);
    
  }

  function startDispute()
   public
   payable
   onlyOwner
  {
    SlaInterface sla = SlaInterface(slaContractAddress);
    require(sla.mediatorsFees()<=msg.value);
    emit LogDisputeStarted(msg.sender, address(0)); //TODO add dispute contract address
  }

  /**
  * @dev Throws if zero
  */
  modifier nonZeroBytes32(bytes32 _value){
      require(_value != bytes32(0));
      _;
  }
  
  /**
  * @dev Throws if address is empty
  */
  modifier nonEmptyAddress(address value){
    require(value != address(0));
    _;
  }

  /**
  * @dev Throws if it is not a contract
  */
  modifier isContract(address _slaContractAddress){
    require(_slaContractAddress.isContract());
    _;
  }


}
