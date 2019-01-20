pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/Roles.sol";
import "./Mediators.sol";

/**
 * @title Arbitrable
 * @dev This contract allows to start an arbitration in case of conflict
 */
contract Arbitrable is Ownable {
    
    using Roles for Roles.Role;
    
    using Mediators for Mediators.Pool;
    
    Mediators.Pool private mediators;
    
    Roles.Role private trustedThirdParties;
    
    uint256 private necessaryArbitrationFees;
    
    bool private arbitrationStarted;
    
    event LogMediatorsAdded();
    
    event LogMediatorVoted(address indexed mediatorAddress, Mediators.Decision decision);
    
    event LogTrustedThirdPartyAdded(address indexed trustedThirdPartyAddress);
    
    event LogArbitrationStarted();

    /**
     * Create the contract
     */
    constructor () internal {
        Ownable(msg.sender);
    }
    
    /**
     * @dev allows the owner to request arbitration
     * 
     */
    function startArbitration()
        public
        payable
        onlyOwner
        onlyNotStartedArbitration
    {
        //there is at least one mediator
        require (mediators.getNumberOfMediators()>0);
        //check that the user sends enough fees for mediators
        arbitrationStarted = true;
        require (msg.value==necessaryArbitrationFees);
        emit LogArbitrationStarted();
    }
    
    /**
     * @dev the mediator will call this method if he agrees with the opinion of the owner who requested the arbitration.
     * 
     */
    function accept()
        public
        onlyMediator
    {
        _setDecision(Mediators.Decision.Agree);
    }
    
    
    /**
     * @dev the mediator will call this mehtod if he does not agree with the opinion of the owner who requested the arbitration.
     * 
     */
    function refuse()
        public
        onlyMediator
    {
        _setDecision(Mediators.Decision.Disagree);
    }
    
    /**
     * @dev get Number Of Mediators
     * @return number of mediators
     */
    function getNbMediators()
        public
        view
        returns (uint)
    {
       return mediators.getNumberOfMediators();
    }
    
    /**
     * @dev Add mediator. Mediators can only be added by a trusted third party
     * @param _mediators mediators to add
     */
    function addMediators(address[] memory _mediators)
       public
       onlyTrustedThirdParty
    {
        mediators.add(_mediators);
        emit LogMediatorsAdded();
    }

    /**
     * @dev Add a trusted third party 
     * @param _addTrustedThirdPartyAddress trusted third party address 
     */
    function addTrustedThirdParty(address _addTrustedThirdPartyAddress)
       public
       onlyTrustedThirdParty
    {
        trustedThirdParties.add(_addTrustedThirdPartyAddress);
        emit LogTrustedThirdPartyAdded(_addTrustedThirdPartyAddress);
    }
    
    
    function _setDecision (Mediators.Decision _decision)
        internal
    {
        //check that there are still fees for the mediator
        require (address(this).balance >= 0);
        //check that the mediator has not already voted
        require (mediators.getDecision(msg.sender) == Mediators.Decision.Unknown);
        mediators.setDecision(msg.sender, _decision);
        msg.sender.transfer(necessaryArbitrationFees/mediators.getNumberOfMediators());
        emit LogMediatorVoted(msg.sender, _decision);
    }
    
    function _setNecessaryArbitrationFees (uint256 _necessaryArbitrationFees)
        internal
    {
        necessaryArbitrationFees=_necessaryArbitrationFees;
    }
    
    
    function _addTrustedThirdParty (address _addTrustedThirdPartyAddress)
        internal
    {
        trustedThirdParties.add(_addTrustedThirdPartyAddress);
    }
    
    
    /**
    * @dev Throws if arbitration is already started
    */
    modifier onlyNotStartedArbitration(){
         require(!arbitrationStarted);
         arbitrationStarted = true;
         _;
    }
    
    /**
    * @dev Throws if it's not a mediator
    */
    modifier onlyMediator(){
         require(mediators.has(msg.sender));
         _;
    }
    
    /**
    * @dev Throws if it's not a trusted third party
    */
    modifier onlyTrustedThirdParty(){
         require(trustedThirdParties.has(msg.sender));
         _;
    }
    
    

}
