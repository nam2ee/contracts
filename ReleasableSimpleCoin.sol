pragma solidity ^0.8.19;
//SPDX-License-Identifier: MIT
import "./SimpleCoin.sol";

contract ReleasableSimpleCoin is SimpleCoin{
    bool public released = false;

    modifier isReleased(){
        require(released);
        _;
    }

    constructor(uint initialSupply) SimpleCoin(initialSupply) public{

    }

    function release() public{
        released = true;
    }


    function transfer(address _to, uint _amount) override isReleased public {
        super.transfer(_to, _amount);
    }

    function transferfrom( address _from, address _to , uint _amount ) override isReleased public returns (bool success) {
        super.transferfrom(_from, _to, _amount);
    }


}