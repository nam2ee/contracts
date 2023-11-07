pragma solidity ^0.8.19;
//SPDX-License-Identifier: MIT
import "./ReleasableSimpleCoin.sol";
import "./Ownable.sol";
import "./SimpleCrowdSale.sol";

contract CrowdSale is Ownable, ICrowdSale{
    uint256 public start;
    uint256 public deadline;
    uint256 public price; // 가격: wei단위
    uint256 public goal; // 목표 단위: wei
    mapping(address => uint256) public investments; //투자 단위: 이더
    uint256 public totalInvestments; //투자 총액 단위: 이더
    uint256 public totalRefundments; //환불 총액 단위: 이더
    bool public Isfinalized;
    bool public IsRefund;
    ReleasableSimpleCoin public token;

    constructor(uint256 _start, uint256 _deadline, uint256 _wetokenprice, uint256 _ethgoal) public{
        require(start >= block.timestamp);
        require(deadline >= start);
        require(_wetokenprice > 0);
        require(_ethgoal > 0);
        
        start = _start;
        deadline = _deadline;
        price = _wetokenprice;
        goal = _ethgoal*1000000000000000000;

        token = new ReleasableSimpleCoin(32121);
        owner = msg.sender;
        Isfinalized = false;
        IsRefund = false;
    }



    function invest() public payable{
        require(isValidinvestment(msg.value));
        address investor = msg.sender;
        uint256 value = msg.value;

        investments[investor] += value;
        totalInvestments += value;

        emit LogInvestment(investor, value);
    }
    function finalize() onlyOwner public{
        if (Isfinalized){
            revert();
        }

        bool isCrowdsaleComplete = block.timestamp >= deadline;
        bool isCrowdsaleGoalReached = totalInvestments >= goal*1000000000000000000;

        if(isCrowdsaleComplete){
            if(isCrowdsaleGoalReached){
               token.release(); // 완료되면, token을 사용할 수 있도록
            }
            else{
                IsRefund = true; // 미충족 시 환불
            }
            Isfinalized = true;
        }
    }


    function refund() external{
        if(!IsRefund){
            revert();
        }
        address investor = msg.sender;
        uint256 value = investments[investor];
        if(value == 0){
            revert();
        }
        totalRefundments += value;
        investments[investor] = 0;
        emit LogRefund(investor, value);

        if(!payable(investor).send(value)){
            revert();
        }
    }

    function isValidinvestment(uint256 _value) public view  returns(bool){
        bool nonZero = _value != 0;
        bool withinPeriod = block.timestamp >= start && block.timestamp <= deadline;
        return nonZero && withinPeriod;
    }

    function calculateNumberOfTokens(uint256 _investment) public view returns (uint256){
        return _investment / price;
    }

    function assigningTokens(address _investor, uint256 _value) internal{
        uint256 numberOfTokens = calculateNumberOfTokens(_value);
        token.mint(_investor, numberOfTokens);
    }

    
}
