pragma solidity >=0.4.21 <0.6.0;

interface SlaInterface
{

    function computationFees() external view returns(uint256);

    function mediatorsFees() external view returns(uint256);

}
