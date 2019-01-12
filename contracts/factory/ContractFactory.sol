pragma solidity ^0.5.0;

import "../Sla.sol";


/**
 * @title ContractFactory
 * @dev This contract is factory allowing to create other contracts
 */
contract ContractFactory {
    
   
    
    function deployByteCode(bytes memory code) 
        public
        returns (address deployedAddress) 
    {
        //bytes memory code = getBytecode(address(this));
        uint result;
        assembly {
            deployedAddress := create(0, add(code, 0x20), mload(code))
            result := gt(extcodesize(deployedAddress), 0)
        }
        require(result==1);
    }


    function getBytecode(address addr) 
        public
        view
        returns (bytes memory code) {
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(addr)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(addr, add(code, 0x20), 0, size)
        }
    }
    
}
