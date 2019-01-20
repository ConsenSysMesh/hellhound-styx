pragma solidity >=0.4.21 <0.6.0;

import "./CustomOfficer.sol";


/**
 * @title SampleCustomOfficer
 * @dev Example of use of the CustomOfficer contract
 */
contract SampleCustomOfficer is CustomOfficer  {

  address public lastCaller;
  
    
      
    constructor (address _signatureBorderCrossingContractAddress) 
    public
    {
        CustomOfficer._defineSignatureBorderCrossingContractAddress(_signatureBorderCrossingContractAddress);
    }
    
    
  /**
  * @dev check The caller  address
  * @param _signature signature of the user to be verifed
  */
  function checkUserAddress(bytes memory _signature)
    public
    onlyAuthorizedUser(_signature)
  {
      lastCaller = msg.sender;
  }

  /**
  * @dev Check the caller and contract addresses 
  * @param _signature signature of the user to be verifed
  */
  function checkUserAndContractAddresses(bytes memory _signature)
    public
    onlyAuthorizedUserToCallContract(_signature)
  {
      lastCaller = msg.sender;
  }

  /**
  * @dev Check the caller and contract addresses and the method ID
  * @param _signature signature of the user to be verifed
  */
  function checkUserAndContractAddressesAndMethodId(bytes memory _signature)
    public
    onlyAuthorizedUserToCallContractAndMethod(_signature)
  {
      lastCaller = msg.sender;
  }
  
}