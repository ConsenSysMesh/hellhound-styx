pragma solidity >=0.4.21 <0.6.0;

import "./SignatureBorderCrossing.sol";
import "zos-lib/contracts/Initializable.sol";

/**
 * @title Immersion
 * @dev Contract verifying that a user is enroled and has the necessary permissions to use hellhound
 */
contract Immersion is Initializable, SignatureBorderCrossing  {

 
    function initialize () 
        public 
        initializer
    {
        Ownable._transferOwnership(msg.sender);
    }
}
