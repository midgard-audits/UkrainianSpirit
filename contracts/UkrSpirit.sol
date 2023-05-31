// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact alex@cfc.io if you like to use code

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

/// @custom:security-contact alex@openbisea.io
contract UkrSpirit is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using SafeMath for uint256;

    // moto:
    uint8 public constant TYPE_HELP = 0;
    uint8 public constant TYPE_UNITY = 1;
    uint8 public constant TYPE_WILL = 2;
    uint8 public constant TYPE_LOVE = 3;
    uint8 public constant TYPE_PEACE = 4;

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => uint8) typeForId;

    mapping(uint256 => uint8) imageNumberForId;

    mapping(uint8 => mapping(uint8 => uint256)) counterForTypeForImageNumber;

    mapping(uint8 => mapping(uint8 => uint256)) limitForTypeForImageNumber;

    mapping(uint8 => uint256) priceForType;

    mapping(uint8 => uint256) imagesQuantityPerType;


    address public charityReceiver;
    address public team;
    string public baseURI;

    bool public privateSale = true;

    uint256 public totalSales;

    constructor(address _team, address _charityReceiver) ERC721("UkrSpirit", "UKRSPRT") {
        charityReceiver = _charityReceiver;
        team = _team;

        baseURI = "ipfs://QmbQVDxwB7yfoYiS7BmfbKGHFzdqcE3MvmZLGCaYe7Wsxt/";
        uint256 [] memory percents = new uint256 [](2);
        percents[0] = 85;
        percents[1] = 15;
        address [] memory addresses = new address [](2);
        addresses[0] = 0x4f476c35F1d823C24c476DB1eEcb97DB3A6A49a1;
        addresses[1] = 0x9917A225d8e40Ed471598Ec1CF5470B0406eEE85;

        setDistributionAddresses(addresses,percents);

        priceForType[TYPE_HELP] = 500000000000000000;
        priceForType[TYPE_UNITY] = 700000000000000000;
        priceForType[TYPE_WILL] = 100000000000000000;
        priceForType[TYPE_LOVE] = 200000000000000000;
        priceForType[TYPE_PEACE] = 300000000000000000;

        imagesQuantityPerType[TYPE_HELP] = 15;
        for(uint8 x=0;x<imagesQuantityPerType[TYPE_HELP];x++) {
            limitForTypeForImageNumber[TYPE_HELP][x] = 777;
        }

        imagesQuantityPerType[TYPE_UNITY] = 11;
        for(uint8 x=0;x<imagesQuantityPerType[TYPE_UNITY];x++) {
            limitForTypeForImageNumber[TYPE_UNITY][x] = 155;
        }

        imagesQuantityPerType[TYPE_WILL] = 7;
        for(uint8 x=0;x<imagesQuantityPerType[TYPE_WILL];x++) {
            limitForTypeForImageNumber[TYPE_WILL][x] = 31;
        }

        imagesQuantityPerType[TYPE_LOVE] = 4;
        for(uint8 x=0;x<imagesQuantityPerType[TYPE_LOVE];x++) {
            limitForTypeForImageNumber[TYPE_LOVE][x] = 6;
        }

        imagesQuantityPerType[TYPE_PEACE] = 2;
        for(uint8 x=0;x<imagesQuantityPerType[TYPE_PEACE];x++) {
            limitForTypeForImageNumber[TYPE_PEACE][x] = 1;
        }
        /* 0,08	777
            0,4	99
            4	55
            40	12
            80	3*/
    }


    function setPrivateSale(bool _privateSale) public onlyOwner {
        privateSale = _privateSale;
    }

    function setBaseUri(string memory uri) public onlyOwner {
        baseURI = uri;
    }


    function setLimitForType(uint256 limit, uint8 typeNft, uint8 imageNumber) public onlyOwner {
        limitForTypeForImageNumber[typeNft][imageNumber] = limit;
    }

    function setPriceForType(uint256 price, uint8 typeNft) public onlyOwner {
        priceForType[typeNft] = price;
    }

    function setImagesQuantityPerType(uint256 imagesQuantity, uint8 typeNft) public onlyOwner {
        imagesQuantityPerType[typeNft] = imagesQuantity;
    }

    function setCharityReceiver(address _charityReceiver) public onlyOwner {
        charityReceiver = _charityReceiver;
    }

    function setTeam(address _team) public onlyOwner {
        team = _team;
    }

    struct ItemFullData {
        string nftURI;
        uint256 price;
        uint256 typeNFT;
        uint256 imageNumber;
    }

    function getDirFor(uint8 typesIndex) public view returns (string memory) {
        string memory dirName;
        if (typesIndex == TYPE_HELP) dirName = "help";
        if (typesIndex == TYPE_LOVE) dirName = "love";
        if (typesIndex == TYPE_PEACE) dirName = "peace";
        if (typesIndex == TYPE_UNITY) dirName = "unity";
        if (typesIndex == TYPE_WILL) dirName = "will";
        return dirName;
    }

    function getAllItems() public view returns (ItemFullData[] memory) {
        uint256 itemsCount;
        for(uint8 typesIndex=0;typesIndex<5;typesIndex++) {
            for(uint8 imagesIndex=0;imagesIndex<imagesQuantityPerType[typesIndex];imagesIndex++) {
                itemsCount++;
            }
        }
        ItemFullData[] memory allItems = new ItemFullData[](itemsCount);

        uint256 itemsFullDataCount;
        for(uint8 typesIndex=0;typesIndex<5;typesIndex++) {
            for(uint8 imagesIndex=0;imagesIndex<imagesQuantityPerType[typesIndex];imagesIndex++) {
                allItems[itemsFullDataCount] = ItemFullData({
                    nftURI: string(abi.encodePacked(baseURI, getDirFor(typesIndex),"/" ,Strings.toString(imagesIndex) ,".json")),
                    price: priceForType[typesIndex],
                    typeNFT: typesIndex,
                    imageNumber: imagesIndex
                });
                itemsFullDataCount++;
            }
        }

        return allItems;
    }

    function getCharityReceiver() public view returns (address) {
        return charityReceiver;
    }

    function getTeam() public view returns (address) {
        return team;
    }

    function getPriceForType(uint8 typeNft) public view returns (uint256) {
        return priceForType[typeNft];
    }

    function getImagesQuantityPerType(uint8 typeNft) public view returns (uint256) {
        return imagesQuantityPerType[typeNft];
    }

    function getCounterForType(uint8 typeNft, uint8 imageNumber) public view returns (uint256) {
        return counterForTypeForImageNumber[typeNft][imageNumber];
    }

    function getLimitForType(uint8 typeNft, uint8 imageNumber) public view returns (uint256) {
        return limitForTypeForImageNumber[typeNft][imageNumber];
    }

    function getTypeForId(uint256 tokenId) public view returns (uint8) {
        return typeForId[tokenId];
    }

    function getImageNumberForId(uint256 tokenId) public view returns (uint8) {
        return imageNumberForId[tokenId];
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _safeMintType(address to, string memory uri, uint8 typeNft, uint8 imageNumber, bool needURI) private {
        uint256 counter = counterForTypeForImageNumber[typeNft][imageNumber];
        counterForTypeForImageNumber[typeNft][imageNumber] = counter + 1;
        require(limitForTypeForImageNumber[typeNft][imageNumber] > 0 && counter + 1 < limitForTypeForImageNumber[typeNft][imageNumber], "UkrSpirit: counter reach end of limit");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        if (needURI) _setTokenURI(tokenId, uri);
        typeForId[tokenId] = typeNft;
        imageNumberForId[tokenId] = imageNumber;
    }

    function safeMintType(address to, string memory uri, uint8 typeNft, uint8 imageNumber) public onlyOwner {
        _safeMintType(to, uri, typeNft, imageNumber, true);
    }

    function safeMintTypeBatch(address[] memory to, uint8[]memory typesNft,uint8[] memory imageNumbers, uint256 count, string[] memory tokenUris) public onlyOwner {
        for(uint256 x=0;x<count;x++) {
            _safeMintType(to[x], tokenUris[x], typesNft[x], imageNumbers[x], false);
        }
    }

    function priceForTypeFinal(uint8 typeNft) public view returns(uint256){
        if (privateSale) return priceForType[typeNft].mul(70).div(100);
        return priceForType[typeNft];
    }

    event Purchase(address indexed from, uint256 value, uint8 typeNft, uint8 finalTypeNft, uint8 imageNumber);

    mapping(address => uint256) distributionPercent;
    mapping(uint256 => address) distributionAddresses;
    uint256 public distributionAddressesCount;

    function setDistributionAddresses(address [] memory _distributionAddresses, uint256 [] memory _percents) public onlyOwner {
        for(uint256 x=0;x<_distributionAddresses.length;x++) {
            distributionPercent[_distributionAddresses[x]] = _percents[x];
            distributionAddresses[x] = _distributionAddresses[x];
        }
        distributionAddressesCount = _distributionAddresses.length;
    }


    function purchase (uint8 typeNft, uint8 imageNumber) payable public {
        if (privateSale) require(msg.value >= 300000000000000000, "UkrSpirit: minimal 0.3 amount for private sale");
        require(msg.value >= priceForTypeFinal(typeNft), "UkrSpirit: wrong value to send");
        for(uint256 x=0;x<distributionAddressesCount;x++) {
            payable(distributionAddresses[x]).transfer(msg.value.mul(distributionPercent[distributionAddresses[x]]).div(100));
        }
        _safeMintType(msg.sender, "", typeNft, imageNumber, false);
        totalSales = totalSales + msg.value;
        emit Purchase(msg.sender, msg.value,typeNft, typeNft, imageNumber);
    }

    function purchaseBatch(uint8[] memory typesNft, uint8 [] memory imageNumbers, uint256 count) payable public {
        if (privateSale) require(msg.value >= 300000000000000000, "UkrSpirit: minimal 0.3 amount for private sale");

        uint256 totalValueToPay;
        for(uint256 x=0;x<count;x++) {
            totalValueToPay = totalValueToPay + priceForTypeFinal(typesNft[x]);
        }
        require(msg.value >= totalValueToPay, "UkrSpirit: wrong value to send");
        for(uint256 y=0;y<count;y++) {
            _safeMintType(msg.sender, "", typesNft[y], imageNumbers[y], false);
            emit Purchase(msg.sender, priceForTypeFinal(typesNft[y]), typesNft[y], typesNft[y], imageNumbers[y]);
        }
        for(uint256 x=0;x<distributionAddressesCount;x++) {
            payable(distributionAddresses[x]).transfer(msg.value.mul(distributionPercent[distributionAddresses[x]]).div(100));
        }
        totalSales = totalSales + msg.value;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override(ERC721, ERC721Enumerable)
    {
        if (privateSale) require(from == address(0x0), "UkrSpirit: you can't transfer NFT till private sale finished");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        bytes memory tempEmptyStringTest = bytes(super.tokenURI(tokenId));
        if (tempEmptyStringTest.length == 0) {
            string memory imageNumber = Strings.toString(imageNumberForId[tokenId]);
            return string(abi.encodePacked(baseURI, getDirFor(typeForId[tokenId]),"/" ,imageNumber ,".json"));
        }
        else return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
