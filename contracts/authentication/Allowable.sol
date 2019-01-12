pragma solidity >=0.4.21 <0.6.0;

import "./PermissionsVerifier.sol";


/**
 * @title Allowable
 * @dev This contract makes it possible to check the permissions that a user possesses via a signature mechanism
 */
contract Allowable {
    
    
    // Function selectors are 4 bytes long, as documented in
    // https://solidity.readthedocs.io/en/v0.5.2/abi-spec.html#function-selector
    uint256 private constant _METHOD_ID_SIZE = 4;

    /**
    * @dev PermissionsVerifier contract address
    */
    address private _permissionVerifierContractAddress;
    
    /**
    * @dev modifier to scope access to only Authorized User
    * @param signature signature of the user to be verifed
    * // reverts
    */
    modifier onlyAuthorizedUser(bytes memory signature)
    {
        PermissionsVerifier permissionsVerifier = PermissionsVerifier(_permissionVerifierContractAddress);
        require(permissionsVerifier.isAuthorized(msg.sender, signature));
        _;
    }
    
    /**
    * @dev modifier to scope access to only Authorized User to call this specific contract
    * @param signature signature of the user to be verifed
    * // reverts
    */
    modifier onlyAuthorizedUserToCallContract(bytes memory signature)
    {
        PermissionsVerifier permissionsVerifier = PermissionsVerifier(_permissionVerifierContractAddress);
        require(permissionsVerifier.isAuthorizedToCallContract(msg.sender, address(this), signature));
        _;
    }
    
    modifier onlyAuthorizedUserToCallContractAndMethod(bytes memory signature)
    {
        bytes memory data = new bytes(_METHOD_ID_SIZE);
        for (uint i = 0; i < data.length; i++) {
            data[i] = msg.data[i];
        }
        PermissionsVerifier permissionsVerifier = PermissionsVerifier(_permissionVerifierContractAddress);
        require(permissionsVerifier.isAuthorizedToCallContractAndMethod(msg.sender, address(this), data, signature));
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
    * @dev internal function to define permission Verifier Contract Address
    * @param permissionVerifierContractAddress permission Verifier Contract Address
    */
    function _definePermissionVerifierContractAddress(address permissionVerifierContractAddress) 
        internal
        nonEmptyAddress(permissionVerifierContractAddress)
    {
            _permissionVerifierContractAddress = permissionVerifierContractAddress;
    }


}
