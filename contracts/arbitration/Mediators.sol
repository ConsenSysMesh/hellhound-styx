pragma solidity >=0.4.21 <0.6.0;



/**
 * @title Roles
 * @dev Library for managing mediators for arbitration
 */
library Mediators {
    
    enum Decision {NOT_FOUND, AGREE, DISAGREE, UNKNWON}
    
    struct Pool {
        address[] mediators;
        mapping (address => Decision) decisions ;
    }
    
    
    /**
     * @dev adds a mediator to the pool
     */
    function add(Pool storage pool, address[] memory mediators) internal {
        //there is at least one mediator to add
        require(mediators.length > 0);
        //there is no mediator in the pool
        require(pool.mediators.length == 0);
        //init all mediators
        for (uint i=0; i<mediators.length; i++) {
            pool.mediators.push(mediators[i]);
            pool.decisions[mediators[i]] = Decision.UNKNWON;   
        }
    }

    /**
     * @dev check if a pool has this mediator
     * @return bool
     */
    function has(Pool storage pool, address mediator) internal view returns (bool) {
        require(mediator != address(0));
        return pool.decisions[mediator] != Decision.NOT_FOUND;
    }
    
    /**
     * @dev update the decision of a mediator
     * @return bool
     */
    function setDecision(Pool storage pool, address mediator, Decision decision) internal {
        require(mediator != address(0));
        pool.decisions[mediator] = decision;
    }
    
    /**
     * @dev get number of mediators
     * @return bool
     */
    function getNumberOfMediators(Pool storage pool) internal view returns (uint) {
        return pool.mediators.length;
    }
    
    /**
     * @dev retrieve the address of a mediator
     * @param index index of the mediator in the pool
     * @return address
     */
    function getMediator(Pool storage pool, uint index) internal view returns (address) {
        return pool.mediators[index];
    }
    
    /**
     * @dev get decision of a mediator 
     * @return bool
     */
    function getDecision(Pool storage pool, address mediator) internal view returns (Decision) {
        require(mediator != address(0));
        return pool.decisions[mediator];
    }
    
    /**
     * @dev check if all mediators voted
     * @return bool
     */
    function isArbitrationCompleted(Pool storage pool) internal view returns (bool) {
        for (uint i=0; i<pool.mediators.length; i++) {
            if(pool.decisions[pool.mediators[i]] == Decision.UNKNWON){
                return false;
            }
        }
        return true;
    }
    
}