// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstateToken is ERC721, Ownable {
    uint256 private _tokenIdCounter;

    struct RealEstateAsset {
        string propertyAddress;
        string description;
        string imageURL;
        uint256 price;
        bool forSale;
        bool forRent;
        uint256 rentPrice;
        address currentRenter;
        uint256 rentalDuration; 
        uint256 rentalEndTime;  
    }

    mapping (uint256 => RealEstateAsset) private _tokenAssets;

    event TokenMinted(
        uint256 indexed tokenId,
        address indexed owner,
        string propertyAddress,
        string description,
        string imageURL,
        uint256 price,
        bool forSale,
        uint256 rentPrice
    );

    event ForSaleStateChanged(uint256 indexed tokenId, bool newForSaleState);
    event ForRentStateChanged(uint256 indexed tokenId, bool newForRentState);
    event PriceChanged(uint256 indexed tokenId, uint256 newPrice);
    event RentPriceChanged(uint256 indexed tokenId, uint256 newRentPrice);
    event RentStarted(uint256 indexed tokenId, address indexed renter, uint256 rentalDuration);
    event RentEnded(uint256 indexed tokenId, address indexed renter);

    constructor() ERC721("RealEstateToken", "RET") Ownable(msg.sender) {}

    function mint(
        address to,
        string memory propertyAddress,
        string memory description,
        string memory imageURL,
        uint256 price,
        bool forSale,
        bool forRent,
        uint256 rentPrice
    ) public onlyOwner {
        _tokenIdCounter++;

        _mint(to, _tokenIdCounter);

        RealEstateAsset memory asset = RealEstateAsset({
            propertyAddress: propertyAddress,
            description: description,
            imageURL: imageURL,
            price: price,
            forSale: forSale,
            forRent: forRent,
            rentPrice: rentPrice,
            currentRenter: address(0),
            rentalDuration: 0,
            rentalEndTime: 0
        });

        _tokenAssets[_tokenIdCounter] = asset;

        emit TokenMinted(_tokenIdCounter, to, propertyAddress, description, imageURL, price, forSale, rentPrice);
    }

    function getTokenInfo(uint256 _tokenId) external view returns (
        string memory propertyAddress,
        string memory description,
        uint256 price,
        string memory imageURL,
        bool forSale,
        bool forRent,
        uint256 rentPrice,
        address currentRenter,
        uint256 rentalDuration,
        uint256 rentalEndTime
    ) {
        RealEstateAsset storage asset = _tokenAssets[_tokenId];
        propertyAddress = asset.propertyAddress;
        description = asset.description;
        price = asset.price;
        imageURL = asset.imageURL;
        forSale = asset.forSale;
        forRent = asset.forRent;
        rentPrice = asset.rentPrice;
        currentRenter = asset.currentRenter;
        rentalDuration = asset.rentalDuration;
        rentalEndTime = asset.rentalEndTime;
    }

    function changeForSaleState(uint256 _tokenId, bool newForSaleState) external onlyOwner {
        _tokenAssets[_tokenId].forSale = newForSaleState;
        emit ForSaleStateChanged(_tokenId, newForSaleState);
    }

    function changeForRentState(uint256 _tokenId, bool newForRentState) external onlyOwner {
        _tokenAssets[_tokenId].forRent = newForRentState;
        emit ForRentStateChanged(_tokenId, newForRentState);
    }

    function changePrice(uint256 _tokenId, uint256 newPrice) external onlyOwner {
        _tokenAssets[_tokenId].price = newPrice;
        emit PriceChanged(_tokenId, newPrice);
    }

    function changeRentPrice(uint256 _tokenId, uint256 newRentPrice) external onlyOwner {
        _tokenAssets[_tokenId].rentPrice = newRentPrice;
        emit RentPriceChanged(_tokenId, newRentPrice);
    }

    function rent(uint256 _tokenId, uint256 durationInDays) external {
        require(_tokenExists(_tokenId), "Token does not exist");
        require(_tokenAssets[_tokenId].forRent, "Token is not available for rent");
        require(!_isRented(_tokenId), "Token is already rented");
        require(msg.sender != ownerOf(_tokenId), "You cannot rent your own property");
        
        uint256 rentalEndTime = block.timestamp + (durationInDays * 1 days);

        _tokenAssets[_tokenId].currentRenter = msg.sender;
        _tokenAssets[_tokenId].rentalDuration = durationInDays;
        _tokenAssets[_tokenId].rentalEndTime = rentalEndTime;

        emit RentStarted(_tokenId, msg.sender, durationInDays);
    }

    function endRent(uint256 _tokenId) external {
        require(_isRented(_tokenId), "Token is not currently rented");
        require(msg.sender == _tokenAssets[_tokenId].currentRenter, "Only the current renter can end the rent");

        _tokenAssets[_tokenId].currentRenter = address(0);
        _tokenAssets[_tokenId].rentalDuration = 0;
        _tokenAssets[_tokenId].rentalEndTime = 0;

        emit RentEnded(_tokenId, msg.sender);
    }

    function _isRented(uint256 _tokenId) internal view returns (bool) {
        return (_tokenAssets[_tokenId].currentRenter != address(0) && _tokenAssets[_tokenId].rentalEndTime > block.timestamp);
    }

    function _tokenExists(uint256 _tokenId) internal view returns (bool) {
        try this.ownerOf(_tokenId) returns (address) {
            return true;
        } catch {
            return false;
        }
    }
}
