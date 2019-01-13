pragma solidity >=0.4.21 <0.6.0;

import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../authentication/Safe.sol";

/**
 * @title Retention
 * @dev Contract that allows users to stack ethers
 */
contract Retention is Initializable, Safe, Ownable  {

  using SafeMath for uint256;

  /**
   * @dev A registry of staked ethers
   */
  mapping(address => uint256) private _stakingRegistry;


  event LogDeposited(address indexed depositor, uint256 weiAmount);

  event LogWithdrawn(address indexed withdrawer, uint256 weiAmount);


  function initialize (address permissionVerifierContractAddress) 
    public 
    initializer
  {
    Ownable._transferOwnership(msg.sender);
    Safe._definePermissionVerifierContractAddress(permissionVerifierContractAddress);
  }


  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param newOwner address of the new owner
  */
  function transferOwnership(address newOwner)
   public
   nonEmptyAddress(newOwner)
   onlyOwner
  {
    Ownable.transferOwnership(newOwner);
  }

  /**
  * @dev This method allows to stake ethers
  * @param signature signature of the user to be verifed
  */
  function stake(bytes memory signature)
    public
    onlyAuthorizedUser(signature)
    payable
  {
    uint256 amount = msg.value;
    _stakingRegistry[msg.sender] = _stakingRegistry[msg.sender].add(amount);
    emit LogDeposited(msg.sender, amount);
  }

  /**
  * @dev Withdraw balance for a staker.
  * @param signature signature of the user to be verifed
  */
  function withdraw(bytes memory signature)
    public
    onlyAuthorizedUser(signature)
  {
    uint256 amount = _stakingRegistry[msg.sender];
    _stakingRegistry[msg.sender] = 0;
    assert(amount > 0);
    msg.sender.transfer(amount);
    emit LogWithdrawn(msg.sender, amount);
  }


  
}
