pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Sla {

  using SafeMath for uint256;

  uint256 public computationFees;

  uint256 public mediatorsFees;

  uint256 public computationTime;

  constructor(
        uint256 _computationTime, 
        uint256 _computationFees,
        uint256 _mediatorsFees
  )
    public
    nonZeroUint256(_computationTime)
    nonZeroUint256(_computationFees)
    nonZeroUint256(_mediatorsFees)
  {
      computationTime = _computationTime;
      computationFees = _computationFees;
      mediatorsFees = _mediatorsFees;
  }


  /**
  * @dev Throws if zero
  */
  modifier nonZeroUint256(uint256 _value){
    require(_value != uint256(0));
    _;
  }


}
