pragma solidity >=0.4.21 <0.6.0;

import "./Arbitrable.sol";


/**
 * @title SampleArbitrable
 * @dev Example of use of the Arbitrable contract
 */
contract SampleArbitrable is Arbitrable  {

    
      
    constructor (address _trustedThirdPartyAddress, uint256 _necessaryArbitrationFees) 
        public
    {
        Ownable(msg.sender);
        Arbitrable._addTrustedThirdParty(_trustedThirdPartyAddress);
        Arbitrable._setNecessaryArbitrationFees(_necessaryArbitrationFees);
    }
    

}