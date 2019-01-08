pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";
/**
 * @title AuthenticationVerifier
 * @dev This contract is used to check the permissions of a user
 */
 
contract PermissionsVerifier is Ownable  {

  // Function selectors are 4 bytes long, as documented in
  // https://solidity.readthedocs.io/en/v0.5.2/abi-spec.html#function-selector
  uint256 private constant _METHOD_ID_SIZE = 4;

  using ECDSA for bytes32;

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
  * @dev Verifies if message was signed by owner to authenticate user.
  * @param user Address of user
  * @param signature signature to be verifed
  * @return validity of the token
  */
  function isAuthorized(address user,bytes memory signature)
      public
      nonEmptyAddress(user)
      view
      returns (bool)
  {
        bytes32 hash = keccak256(abi.encodePacked(address(this), user));
        return _isValidSignature(hash, signature);

  }
  
  /**
  * @dev Verifies if message was signed by owner to give access to user for a specific contract.
  * @param user Address of user
  * @param contractDestination Address of contract to call 
  * @param signature signature to be verifed
  * @return validity of the token
  */
  function isAuthorizedToCallContract(address user, address contractDestination, bytes memory signature)
      public
      nonEmptyAddress(user)
      view
      returns (bool)
  {
        bytes32 hash = keccak256(abi.encodePacked(address(this), contractDestination , user));
        return _isValidSignature(hash, signature);
  }
 
  /**
  * @dev Verifies if message was signed by owner to give access to user for a specific contract and method.
  * @param user Address of user
  * @param contractDestination Address of contract to call
  * @param contractMethodId the contract method to call
  * @param signature signature to be verifed
  * @return validity of the token
  */
  function isAuthorizedToCallContractAndMethod(address user, address contractDestination, bytes4 contractMethodId,  bytes memory signature)
      public 
      nonEmptyAddress(user)
      view 
      returns (bool)
  {
        bytes memory data = new bytes(_METHOD_ID_SIZE);
        for (uint i = 0; i < data.length; i++) {
            data[i] = msg.data[i];
        }
        bytes32 hash = keccak256(abi.encodePacked(address(this), user, contractDestination, contractMethodId, data));
        return _isValidSignature(hash, signature);
  }
 

  /**
  * @dev Throws if address is empty
  */
  modifier nonEmptyAddress(address value)
  {
        require(value != address(0));
        _;
  }
  
  
  /**
  * @dev internal function to check the signature 
  * @param hash to verify
  * @param signature 
  * @return bool
  */
  function _isValidSignature(bytes32 hash, bytes memory signature) 
      internal
      view 
      returns (bool)
  {
        address signer = hash
            .toEthSignedMessageHash()
            .recover(signature);
        return signer != address(0) && owner() == signer;
  }
}
