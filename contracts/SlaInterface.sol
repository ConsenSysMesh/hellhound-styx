pragma solidity >=0.4.21 <0.6.0;

contract SlaInterface
{

    function computationFees() public view returns(uint256);

    function mediatorsFees() public view returns(uint256);

}
