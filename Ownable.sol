pragma solidity ^0.8.19;
//SPDX-License-Identifier: MIT

contract Ownable{
    address public owner;
    constructor() public{
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
}
