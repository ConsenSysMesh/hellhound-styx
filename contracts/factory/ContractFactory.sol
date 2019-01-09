pragma solidity ^0.5.0;

import "../Sla.sol";


/**
 * @title ContractFactory
 * @dev This contract is factory allowing to create other contracts
 */
contract ContractFactory {

 
    
    function deployCode(bytes memory code) 
        public
        returns (address deployedAddress) 
    {
        uint result;
        assembly {
            deployedAddress := create(0, add(code, 0x20), mload(code))
            result := gt(extcodesize(deployedAddress), 0)
        }
        require(result==1);
    }


    
}
