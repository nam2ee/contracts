pragma solidity ^0.8.19;

//SPDX-License-Identifier: MIT

contract SimpleCoin{
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => bool) public frozen;

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

    event freezeAccount(address indexed target, bool indexed frozen);

    address public owner;

    constructor(uint initialSupply) public {
        owner = msg.sender;
        mint(owner, initialSupply);
    }



    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    modifier authorOnly( address _authorizedAccount) {
        require(msg.sender == _authorizedAccount);
        _;
    }


    function transfer(address _to, uint _amount) public {
        require(balances[msg.sender] >= _amount);          // 잔액 확인
        require(balances[_to] + _amount >= balances[_to]); // 오버플로우 방지
        balances [msg.sender] -= _amount;
        balances [_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
    }

    function authorize(address _authorized, address _authowner  , uint _allowance) public
    authorOnly(_authowner) returns (bool success) {
        allowance[_authowner][_authorized] = _allowance;
        return true;
    }

    function transferfrom( address _from, address _to , uint _amount ) public returns (bool success) {
        require(_to != address(0x0));                              // 기본값 주소로 보내지 못하도록
        require(balances[_from]>= _amount);                 // 출금자의 잔액이 충분한지
        require(balances[_to] + _amount >= balances[_to]); // 오버플로우 방지
        require(allowance[_from][msg.sender] >= _amount); // 1. 허용여부 2. 허용 금액
        balances[_from] -= _amount;
        balances[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;

        emit Transfer(_from, _to, _amount);

        return true;
    }


    function mint(address _recipent, uint _amount) public  ownerOnly {
        balances[_recipent] += _amount;
        emit Transfer(owner, _recipent, _amount);
    }

    function frozenAccount(address _target, bool _frozen) public  ownerOnly {
        require(_target != address(0x0));
        frozen[_target] = _frozen;
        emit freezeAccount(_target, _frozen);
    }


}

