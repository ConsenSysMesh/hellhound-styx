pragma solidity >=0.4.21 <0.6.0;

import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../authentication/CustomOfficer.sol";

/**
 * @title Retention
 * @dev Contract that allows users to stack ethers
 */
contract Retention is Initializable, CustomOfficer, Ownable  {

  using SafeMath for uint256;

  /**
   * @dev A registry of staked ethers (wei)
   */
  mapping(address => uint256) private stakingRegistry;


  event LogDeposited(address indexed depositor, uint256 weiAmount);

  event LogWithdrawn(address indexed withdrawer, uint256 weiAmount);


  function initialize (address _signatureBorderCrossingContractAddress) 
    public 
    initializer
  {
    Ownable._transferOwnership(msg.sender);
    CustomOfficer._defineSignatureBorderCrossingContractAddress(_signatureBorderCrossingContractAddress);
  }


  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param _newOwner address of the new owner
  */
  function transferOwnership(address _newOwner)
   public
   nonEmptyAddress(_newOwner)
   onlyOwner
  {
    Ownable.transferOwnership(_newOwner);
  }

  /**
  * @dev This method allows to stake ethers
  * @param _signature signature of the user to be verifed
  */
  function stake(bytes memory _signature)
    public
    onlyAuthorizedUserToCallContractAndMethod(_signature)
    payable
  {
    uint256 amount = msg.value;
    stakingRegistry[msg.sender] = stakingRegistry[msg.sender].add(amount);
    emit LogDeposited(msg.sender, amount);
  }

  /**
  * @dev Withdraw balance for a staker.
  * @param _signature signature of the user to be verifed
  */
  function withdraw(bytes memory _signature)
    public
    onlyAuthorizedUserToCallContractAndMethod(_signature)
  {
    uint256 amount = stakingRegistry[msg.sender];
    stakingRegistry[msg.sender] = 0;
    assert(amount > 0);
    msg.sender.transfer(amount);
    emit LogWithdrawn(msg.sender, amount);
  }


  
}
