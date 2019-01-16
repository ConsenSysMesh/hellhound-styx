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
    
    Mediators.Pool private _mediators;
    
    Roles.Role private _trustedThirdParties;
    
    uint256 private _necessaryArbitrationFees;
    
    event LogMediatorsAdded();
    
    event LogMediatorVoted(address indexed mediatorAddress, Mediators.Decision decision);
    
    event LogTrustedThirdPartyAdded(address indexed trustedThirdPartyAddress);
    
    event LogArbitrationStarted();

    /**
     * Create the contract
     * @param trustedThirdParty the address of a trusted third party. This address will be able to choose the mediators
     * @param necessaryArbitrationFees the number of fees that will be required to start an arbitration (wei)
     */
    constructor (address trustedThirdParty, uint256 necessaryArbitrationFees) public {
        Ownable._transferOwnership(msg.sender);
         _trustedThirdParties.add(trustedThirdParty);
        _necessaryArbitrationFees=necessaryArbitrationFees;
    }
    
    /**
     * @dev allows the owner to request arbitration
     * 
     */
    function startArbitration()
        public
        payable
        onlyOwner
    {
        //there is at least one mediator
        require (_mediators.getNumberOfMediators()>0);
        //check that the user sends enough fees for mediators
        require (msg.value==_necessaryArbitrationFees);
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
    
    
    function _setDecision (Mediators.Decision decision)
        internal
    {
        //check that there are still fees for the mediator
        require (address(this).balance >= 0);
        //check that the mediator has not already voted
        require (_mediators.getDecision(msg.sender) == Mediators.Decision.Unknown);
        _mediators.setDecision(msg.sender, decision);
        msg.sender.transfer(_necessaryArbitrationFees/_mediators.getNumberOfMediators());
        emit LogMediatorVoted(msg.sender, decision);
    }
    
    /**
     * @dev Add mediator. Mediators can only be added by a trusted third party
     * @param mediators mediators to add
     */
    function addMediators(address[] memory mediators)
       public
       onlyTrustedThirdParty
    {
        _mediators.add(mediators);
        emit LogMediatorsAdded();
    }

    /**
     * @dev Add a trusted third party 
     * @param trustedThirdParty trusted third party address 
     */
    function addTrustedThirdParty(address trustedThirdParty)
       public
       onlyTrustedThirdParty
    {
        _trustedThirdParties.add(trustedThirdParty);
        emit LogTrustedThirdPartyAdded(trustedThirdParty);
    }
    
    /**
    * @dev Throws if it's not a mediator
    */
    modifier onlyMediator(){
         require(_mediators.has(msg.sender));
         _;
    }
    
    /**
    * @dev Throws if it's not a trusted third party
    */
    modifier onlyTrustedThirdParty(){
         require(_trustedThirdParties.has(msg.sender));
         _;
    }
    
    

}
