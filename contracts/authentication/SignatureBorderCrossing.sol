pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";

/**
 * @title SignatureBorderCrossing
 * @dev This contract will check the rights that a user has via a signature mechanism. Check that a user can call a specific contract, a specific method etc.
 */
contract SignatureBorderCrossing is Ownable  {

    using ECDSA for bytes32;

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner address of the new owner
    */
    function transferOwnership(address _newOwner)
        public
        nonEmptyAddress(_newOwner)
        onlyOwner
    {
            Ownable(_newOwner);
    }
  
  
    /**
    * @dev Verifies if message was signed by owner to authenticate user.
    * @param _user Address of user
    * @param _signature signature to be verifed
    * @return validity of the token
    */
    function isAuthorized(address _user,bytes memory _signature)
        public
        nonEmptyAddress(_user)
        view
        returns (bool)
    {
            bytes32 hash = keccak256(abi.encodePacked(address(this), _user));
            return _isValidSignature(hash, _signature);
    }
 
	
    /**
    * @dev Verifies if message was signed by owner to give access to user for a specific contract.
    * @param _user Address of user
    * @param _customOfficer Address of contract to call 
    * @param _signature signature to be verifed
    * @return validity of the token
    */
    function isAuthorizedToCallContract(address _user, address _customOfficer, bytes memory _signature)
        public
        nonEmptyAddress(_user)
        view
        returns (bool)
    {
            bytes32 hash = keccak256(abi.encodePacked(address(this), _user, _customOfficer));
            return _isValidSignature(hash, _signature);
    }
 
    /**
    * @dev Verifies if message was signed by owner to give access to user for a specific contract and method.
    * @param _user Address of user
    * @param _customOfficer Address of contract to call
    * @param _customOfficerMethodId the contract method to call
    * @param _signature signature to be verifed
    * @return validity of the token
    */
    function isAuthorizedToCallContractAndMethod(address _user, address _customOfficer, bytes4 _customOfficerMethodId,  bytes memory _signature)
        public 
        nonEmptyAddress(_user)
        view 
        returns (bool)
    {
            bytes32 hash = keccak256(abi.encodePacked(address(this), _user, _customOfficer, _customOfficerMethodId));
            return _isValidSignature(hash, _signature);
    }
 

    /**
    * @dev Throws if address is empty
    */
    modifier nonEmptyAddress(address _value)
    {
        require(_value != address(0));
        _;
    }
  
  
    /**
    * @dev internal function to check the signature 
    * @param _hash to verify
    * @param _signature 
    * @return bool
    */
    function _isValidSignature(bytes32 _hash, bytes memory _signature) 
        internal
        view 
        returns (bool)
    {
            address signer = _hash
                .toEthSignedMessageHash()
                .recover(_signature);
            return signer != address(0) && owner() == signer;
    }
}
