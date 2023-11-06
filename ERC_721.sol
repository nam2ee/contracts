pragma solidity ^0.4.20;

interface ERC721 /* is ERC165 */ {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) public view returns (uint256);
    function ownerOf(uint256 _tokenId) public  view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public  ;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId)  public  ;
    function transferFrom(address _from, address _to, uint256 _tokenId) public  ;
    function approve(address _approved, uint256 _tokenId) public  ;
    function setApprovalForAll(address _operator, bool _approved) public ;
    function getApproved(uint256 _tokenId) public view returns (address);
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);
}

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}

contract ERC721Implementation is ERC721{
    mapping(uint256 => address) tokenOwner; //디폴트: 스토리지
    mapping(address => uint256) ownedTokensCount;//디폴트: 스토리지
    mapping(uint256 => address) tokenApprovals;//디폴트: 스토리지
    mapping(address => mapping(address => bool)) operatorApprovals;//디폴트: 스토리지

    function mint(address _to , uint _tokenid) public{ //_to와 _tokenid는 디폴트: 메모리
        tokenOwner[_tokenid] = _to; 
        ownedTokensCount[_to]++;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return ownedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public  view returns (address){
        return tokenOwner[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public{
        address owner = ownerOf(_tokenId);
        address approval = getApproved(_tokenId);
        require(msg.sender == owner || msg.sender == approval || isApprovedForAll(owner,msg.sender) ); //소유자 계정이어야하므로 remix에서 니껄로 바꿔줘야한다!
        require(_from != address(0) && _to != address(0)); 
        tokenOwner[_tokenId] = _to;
        ownedTokensCount[_to]++;
        ownedTokensCount[_from]--;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId){
        transferFrom(_from, _to, _tokenId);
        if(isContract(_to)){
            bytes4 returnValue = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "");
            require(returnValue == 0x150b7a02); // ERC721TokenReceiver의 식별자 값인 0x150b7a02와 같아야한다.
                                                // 해당 magic value가 나오면, 신뢰를 암묵적으로 하는 것이다. 
                                                // 만일 receipt기능을 구현을 하지 않는다면, 신뢰를 잃고 비즈니스는 나락 가겠지 뭐
        }
    }

    function safeTransferFrom(address _from, address  _to, uint256 _tokenId, bytes _data){
        address _operator = msg.sender;
        transferFrom(_from, _to, _tokenId);
        if(isContract(_to)){
            bytes4 returnValue = ERC721TokenReceiver(_to).onERC721Received(_operator, _to, _tokenId, _data);
            require(returnValue == 0x150b7a02);
        }

    }

    function isContract(address _addr) internal view returns (bool){
        uint size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }


    function approve(address _approved, uint256 _tokenId) public{
        address owner = ownerOf(_tokenId);
        require(_approved != address(0) && owner != _approved && msg.sender == owner);
        tokenApprovals[_tokenId] = _approved;
    }

    function getApproved( uint256 _tokenId) public view returns (address){
        return tokenApprovals[_tokenId];
    }

    function setApprovalForAll( address _operator,bool _approved){ //가진 모든 토큰에 대해 승인을 해준다!
        require(_operator != msg.sender);
        operatorApprovals[msg.sender][_operator] = _approved;

    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        return operatorApprovals[_owner][_operator];
    }



}


contract Auction is ERC721TokenReceiver{
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")); //결과는 ERC721TokenReceiver의 식별자 값인 0x150b7a02
    }
}