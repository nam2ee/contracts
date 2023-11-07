pragma solidity ^0.8.19;
//SPDX-License-Identifier: MIT

interface ICrowdSale{
    function invest() external payable;
    function finalize() external;
    function refund() external;
    function isValidinvestment( uint256 _value  ) external view  returns (bool);
    //function assigningTokens(address _investor, uint256 _value) external;
    function calculateNumberOfTokens(uint256 _investment) external view returns (uint256);
    event LogInvestment(address indexed investor, uint256 value);
    event LogRefund(address indexed investor, uint256 value);
    event LogFinalize(uint256 totalInvestments);

}