pragma solidity >=0.4.21 <0.6.0;

import "./SignatureBorderCrossing.sol";


/**
 * @title CustomOfficer
 * @dev This contract will query a second contract of type SignatureBorderCrossing to verify the rights that a user has. Check that a user can call a specific contract, a specific method etc.
 */
contract CustomOfficer {
    

    /**
    * @dev SignatureBorderCrossing contract address
    */
    address private signatureBorderCrossingContractAddress;

    
    /**
    * @dev modifier to scope access to only Authorized User
    * @param _signature signature of the user to be verifed
    * // reverts
    */
    modifier onlyAuthorizedUser(bytes memory _signature)
    {
        SignatureBorderCrossing signatureBorderCrossing = SignatureBorderCrossing(signatureBorderCrossingContractAddress);
        require(signatureBorderCrossing.isAuthorized(msg.sender, _signature));
        _;
    }
    
    /**
    * @dev modifier to scope access to only Authorized User to call specific contract
    * @param _signature signature of the user to be verifed
    * // reverts
    */
    modifier onlyAuthorizedUserToCallContract(bytes memory _signature)
    {
        SignatureBorderCrossing signatureBorderCrossing = SignatureBorderCrossing(signatureBorderCrossingContractAddress);
        require(signatureBorderCrossing.isAuthorizedToCallContract(msg.sender, address(this), _signature));
        _;
    }
    
    /**
    * @dev modifier to scope access to only Authorized User to call specific method of a specific contract 
    * @param _signature signature of the user to be verifed
    * // reverts
    */
    modifier onlyAuthorizedUserToCallContractAndMethod(bytes memory _signature)
    {
        SignatureBorderCrossing signatureBorderCrossing = SignatureBorderCrossing(signatureBorderCrossingContractAddress);
        require(signatureBorderCrossing.isAuthorizedToCallContractAndMethod(msg.sender, address(this), msg.sig, _signature));
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
    * @dev internal function to define permission Verifier Contract Address
    * @param _signatureBorderCrossingContractAddress permission Verifier Contract Address
    */
    function _defineSignatureBorderCrossingContractAddress(address _signatureBorderCrossingContractAddress) 
        internal
        nonEmptyAddress(_signatureBorderCrossingContractAddress)
    {
            signatureBorderCrossingContractAddress = _signatureBorderCrossingContractAddress;
    }


}
