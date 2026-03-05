// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721,ERC721URIStorage,Ownable{
    uint256 private _tokenIdCounter;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public mintPrice = 0.01 ether;

    event NFTMinted(address indexed minter,uint256 indexed tokenId,string uri);

    constructor() ERC721("MyNFT","MNFT") Ownable(msg.sender){}
    /**
     * @dev 重写tokenURI函数
     * @param tokenId Token ID
     * @return 元数据URI
     * @notice 需要重写以解决多重继承的冲突
     */
    function tokenURI(uint256 tokenId) public view override(ERC721,ERC721URIStorage) returns (string memory){
        return super.tokenURI(tokenId);
    }
    /**
     * @dev 检查接口支持
     * @param interfaceId 接口ID
     * @return 是否支持该接口
     * @notice 实现ERC165标准，支持接口查询
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721,ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
     /**
     * @dev 铸造NFT
     * @param uri NFT的元数据URI（通常是IPFS链接）
     * @return 新创建的Token ID
     * @notice 需要支付mintPrice的ETH才能铸造
     */
    function mint(string memory uri) public payable returns (uint256){
        require(_tokenIdCounter<MAX_SUPPLY,"Max supply reached");
        require(msg.value >= mintPrice,"Insufficient payment");
        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;
        _safeMint(msg.sender, newTokenId);

        _setTokenURI(newTokenId,uri);

        emit NFTMinted(msg.sender,newTokenId,uri);

        return newTokenId;
    }
    function totalSupply()public view returns (uint256){
        return _tokenIdCounter;
    }
    function withdraw() public onlyOwner{
       uint256 balance = address(this).balance;
       require(balance > 0,"No balance to withdraw"); 
       (bool success,) = payable(owner()).call{value:balance}("");
       require(success,"withdraw failed");
    }

    function setMintPrice(uint256 newPrice) public onlyOwner{
        mintPrice = newPrice;
    }
}