// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";


interface IERC2981 is IERC165 {
    function royaltyInfo(uint256 tokenId,uint256 salePrice) external view returns (address receiver,uint256 royaltyAmount);
}

/**
 * @title NFTMarketplace
 * @dev 完整的NFT交易市场合约，支持上架、购买、版税和拍卖功能
 * @notice 使用ReentrancyGuard防止重入攻击
 */
contract NFTMarketplace is ReentrancyGuard{
    //挂单结构体
    struct Listing{
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }
    //拍卖结构体
    struct Auction{
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 startPrice;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool active;
    }
    //挂单映射
    mapping(uint256 => Listing) public listings;

    uint256 public listingCounter;
    
    //拍卖映射
    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCounter;
    //待退款映射（用与拍卖）
    mapping(uint256 => mapping(address => uint256)) public pendingReturns;
    //平台手续费（基点，10000 = 100%）
    uint256 public platfromFee = 250;
    //手续费接收地址
    address public feeRecipient;
    
    //nft 上架事件
    event NFTListed(
        uint256 indexed listingId,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 price
    );
    //nft 下架事件
    event NFTDelisted(uint256 indexed listingId);

    //价格更新事件
    event PriceUpdated(uint256 indexed listingId,uint256 newPrice);

    //nft出售事件
    event NFTSold(uint256 indexed listingId,address indexed buyer,address indexed seller,uint256 price);

    //拍卖创建事件
    event AuctionCreaed(uint256 indexed auctionId,address indexed seller,address indexed nftContract,uint256 tokenId,uint256 startPrice,uint256 endTime);

    //出价事件
    event BidPlaced(uint256 indexed auctionId,address indexed winner,uint256 finalPrice);

    //拍卖结束事件
    event AuctionEnded(uint256 auctionId,address winner,uint256 finalPrice);

    constructor(address _feeRecipient){
        require(_feeRecipient != address(0),"Invalid fee recipient");
        feeRecipient = _feeRecipient;
    }

    //上架NFT
    function listNFT(address nftContract,uint256 tokenId,uint256 price) external returns (uint256){
        require(price>0,"price must be greater than 0");
        require(nftContract != address(0),"Invalid NFT contract");
        IERC721 nft = IERC721(nftContract);
        //验证所有权
        require(nft.ownerOf(tokenId) == msg.sender,"Not the owner");
        //验证授权
        require(nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),"Marketplace not approved");
        //创建挂单
        listingCounter++;
        listings[listingCounter] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            active: true
        });
        emit NFTListed(listingCounter, msg.sender, nftContract, tokenId, price);

        return listingCounter;
    }
    //下架NFT
    function delistNFT(uint256 listingId) external {
        Listing storage listing = listings[listingId];
        require(listing.active,"Listing not active");
        require(listing.seller == msg.sender,"Not the seller");
        listing.active = false;

        emit NFTDelisted(listingId);
    }
    //更新挂单价格
    function updatePrice(uint256 listingId,uint256 newPrice) external {
        require(newPrice > 0,"Price must be greater than 0");
        Listing storage listing = listings[listingId];
        require(listing.active,"Listing not active");
        require(listing.seller == msg.sender,"Not the seller");
        listing.price = newPrice;
        emit PriceUpdated(listingId, newPrice);
    }
    //购买NFT
    function buyNFT(uint256 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];
        require(msg.sender != listing.seller,"Cannot buy your own NFT");
        require(listing.active,"NFT not active");
        require(msg.value >= listing.price,"Insufficient payment");
        //CEI原则，先更新状态
        listing.active = false;
        //手续费
        uint256 fee = (listing.price * platfromFee) / 10000;
        //获取版税信息
        (address royaltyReceiver,uint256 royaltyAmount) = _getRoyaltyInfo(
            listing.nftContract,
            listing.tokenId,
            listing.price
        );
        //计算卖家收益
        uint256 sellerAmount = listing.price - fee - royaltyAmount;

        //转移NFT
        IERC721(listing.nftContract).safeTransferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );

        //资金分配：版税>平台手续费>卖家收益
        if(royaltyAmount>0 && royaltyReceiver != address(0)){
            (bool success,) = royaltyReceiver.call{value:royaltyAmount}("");
            require(success,"Royalty transfer failed");
        }
        (bool successFee,) = feeRecipient.call{value:fee}("");
        require(successFee,"Fee transfer failed");
        (bool successSeller,) = listing.seller.call{value:sellerAmount}("");
        require(successSeller,"Transfer to seller failed");
        // 退还多余资金
        if(msg.value>listing.price){
            (bool successRefund ,) = msg.sender.call{value:msg.value - listing.price}("");
            require(successRefund,"Refund falid");
        }
        emit NFTSold(listingId, msg.sender, listing.seller, listing.price);
    }
    //创建拍卖
    function createAuction(address nftContract,uint256 tokenId,uint256 startPrice,uint256 durationHours) external returns(uint256){
        require(startPrice>0,"start price must greater than 0");
        require(durationHours>1,"duration must be at leatest 1 hour");
        require(nftContract != address(0),"Invalid NFT contract");
        IERC721 nft = IERC721(nftContract);
        //验证所有权
        require(nft.ownerOf(tokenId) == msg.sender,"Not the owner");

        //验证授权
        require(
            nft.getApproved(tokenId) == address(this) ||
            nft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );
        auctionCounter++;
        auctions[auctionCounter] = Auction({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            startPrice: startPrice,
            highestBid: 0,
            highestBidder: address(0),
            endTime: block.timestamp + (durationHours * 1 hours),
            active: true
        });
        emit AuctionCreaed(auctionCounter, msg.sender, nftContract, tokenId, startPrice, auctions[auctionCounter].endTime);

        return auctionCounter;
    }
    //出价
    //需要支付足够的ETH，出价必须高于当前最高出价的5%
    function priceBid(uint256 auctionId) external payable {
        Auction storage auction = auctions[auctionId];
        require(auction.active,"Auction not active");
        require(block.timestamp < auction.endTime,"Auction ended");
        require(msg.sender != auction.seller,"Seller cannot bid");
        uint256 minBid;
        if(auction.highestBid == 0){
            minBid = auction.highestBid;
        }else{
            minBid = auction.highestBid +(auction.highestBid *5 /100);
        }

        require(msg.value >= minBid,"Bid too low");

        // 如果有之前的出价者，记录他们的待退款金额
        if(auction.highestBidder != address(0)){
            pendingReturns[auctionId][auction.highestBidder] += auction.highestBid;
        }
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;

        emit BidPlaced(auctionId, msg.sender, msg.value);
    }
    //提取出价退款
    function withdrawBid(uint256 auctionId) external {
        uint256 amount = pendingReturns[auctionId][msg.sender];
        require(amount > 0,"No pending return");
        pendingReturns[auctionId][msg.sender] = 0;
        (bool success,) = msg.sender.call{value:amount}("");
        require(success,"Transfer faild");
    }

    //结束拍卖
    function endAuction(uint256 auctionId) external nonReentrant{
        Auction storage auction = auctions[auctionId];
        require(auction.active,"Auction is not active");
        require(block.timestamp >= auction.endTime,"Auction not end");

        auction.active = false;

        if(auction.highestBidder != address(0)){
            //有人出价进行结算
            uint256 fee = (auction.highestBid * platfromFee) / 10000;
            (address royaltyReceiver,uint256 royaltyAmount) = _getRoyaltyInfo(auction.nftContract, auction.tokenId, auction.highestBid);

            uint256 sellerAmount = auction.highestBid - fee - royaltyAmount;

            //NFT 转移
            IERC721(auction.nftContract).safeTransferFrom(auction.seller,auction.highestBidder,auction.tokenId);

            if(royaltyAmount > 0 && royaltyReceiver != address(0)){
                (bool successRoyalty,) = royaltyReceiver.call{value:royaltyAmount}("");
                require(successRoyalty,"Royalty transfer failed");
            }
            (bool successSeller,) = auction.seller.call{value:sellerAmount}("");
            require(successSeller,"Transfer to seller failed");

            (bool successFee,) = feeRecipient.call{value:fee}("");
            require(successFee,"Transfer fee failed");
            emit AuctionEnded(auctionId, auction.highestBidder, auction.highestBid);
        }else{
            emit AuctionEnded(auctionId,address(0),0);
        }
    }


    function _getRoyaltyInfo(address nftContract,uint256 tokenId,uint256 salePrice) internal view returns (address receiver,uint256 royaltyAmount){
        // 检查NFT合约是否支持ERC2981
        if(IERC165(nftContract).supportsInterface(type(IERC2981).interfaceId)){
            (receiver,royaltyAmount) = IERC2981(nftContract).royaltyInfo(tokenId,salePrice);
        }else{
            receiver = address(0);
            royaltyAmount = 0;
        }
    }

    function getListing(uint256 listingId) external view returns(
        address seller,
        address nftContranct,
        uint256 tokenId,
        uint256 price,
        bool active
    ){
        Listing memory listing = listings[listingId];
        return(listing.seller,listing.nftContract,listing.tokenId,listing.price,listing.active);
    }
    function getAuction(uint256 auctionId) external view returns(
        address seller,
        address nftContract,
        uint256 tokenId,
        uint256 startPrice,
        uint256 highestBid,
        address highestBidder,
        uint256 endTime,
        bool active
    ){
        Auction memory auction = auctions[auctionId];
        return (
            auction.seller,
            auction.nftContract,
            auction.tokenId,
            auction.startPrice,
            auction.highestBid,
            auction.highestBidder,
            auction.endTime,
            auction.active
        );
    }
}