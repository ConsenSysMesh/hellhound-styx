pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "../sla/SlaInterface.sol";
import "zos-lib/contracts/Initializable.sol";
import "../arbitration/Arbitrable.sol";

contract Ki is Initializable, Arbitrable {

  using SafeMath for uint256;
  using Address for address;
  using Roles for Roles.Role;

  Roles.Role private nodes;

  SlaInterface private slaContract;

  bytes32 private computationId;

  uint256 private computationFees;

  event LogComputeStarted (address indexed ownerAddress);
  
  event LogNodeAdded (address indexed nodeAddress);


  function initialize (bytes32 _computationId, address _slaContractAddress, address _trustedThirdPartyAddress) 
    public 
    initializer
  {
    computationId = _computationId;
    slaContract = SlaInterface(_slaContractAddress);
    Ownable._transferOwnership(msg.sender);
    Arbitrable._addTrustedThirdParty(_trustedThirdPartyAddress);
    Arbitrable._setNecessaryArbitrationFees(slaContract.mediatorsFees());
  }
  
  function compute()
   public
   payable
   onlyOwner
  {
    require(slaContract.computationFees()<=msg.value);
    emit LogComputeStarted(msg.sender);
  }
  
  function addNode(address _nodeAddress)
   public
   nonEmptyAddress(_nodeAddress)
  {
    nodes.add(_nodeAddress);
    emit LogNodeAdded(_nodeAddress);
    
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
  modifier nonEmptyAddress(address _value){
    require(_value != address(0));
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
