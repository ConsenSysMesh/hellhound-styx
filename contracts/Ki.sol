pragma solidity >=0.4.21 <0.6.0;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";

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

  constructor(bytes32 _computationId, address _slaContractAddress)
    public
    nonZeroBytes32(_computationId)
    isValidContract(_slaContractAddress)
  {
      Ownable._transferOwnership(msg.sender);
      idComputation = _idComputation;
      slaContractAddress = _slaContractAddress;
  }

  function compute()
   public
   payable
   onlyOwner
  {
    Sla sla = new Sla(slaContractAddress);
    require(sla.getCmputationFees()<=msg.value)
    emit LogComputeStarted(msg.sender);
  }

  function startDispute()
   public
   payable
   onlyOwner
  {
    Sla sla = new Sla(slaContractAddress);
    require(sla.getMediatorsFees()<=msg.value)
    emit LogDisputeStarted(msg.sender);
  }

  /**
  * @dev Throws if zero
  */
  modifier nonZeroBytes32(bytes32 _value){
      require(_value != bytes32(0));
      _;
  }

  /**
  * @dev Throws if address is empty or is not a contract
  */
  modifier isValidContract(address _slaContractAddress){
    require(_slaContractAddress != address(0) && _slaContractAddress.isContract());
    _;
  }


}
