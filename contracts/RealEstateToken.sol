// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract RealEstateToken is ERC721 {
    uint256 private _tokenIdCounter;

    struct RealEstateAsset {
        string propertyAddress;
        string description;
        string imageURL;
        uint256 price;
        bool forSale;
    }

    mapping (uint256 => RealEstateAsset) private _tokenAssets;

    constructor() ERC721("RealEstateToken", "RET") {}

    // Function to mint a new real estate token
    function mint(
        address to,
        string memory propertyAddress,
        string memory description,
        string memory imageURL,
        uint256 price,
        bool forSale
    ) public {
        // Increment the token counter
        _tokenIdCounter++;

        // Mint a new token and assign it to the specified address
        _mint(to, _tokenIdCounter);

        // Create a RealEstateAsset struct with the provided details
        RealEstateAsset memory asset = RealEstateAsset({
            propertyAddress: propertyAddress,
            description: description,
            imageURL: imageURL,
            price: price,
            forSale: forSale
        });

        // Store the asset information for the newly minted token
        _tokenAssets[_tokenIdCounter] = asset;
    }

    // Function to get all information about a specific token
    function getTokenInfo(uint256 _tokenId) external view returns (
        string memory propertyAddress,
        string memory description,
        uint256 price,
        string memory imageURL,
        bool forSale
    ) {
        // Retrieve and return information about the specified token
        RealEstateAsset storage asset = _tokenAssets[_tokenId];
        propertyAddress = asset.propertyAddress;
        description = asset.description;
        price = asset.price;
        imageURL = asset.imageURL;
        forSale = asset.forSale;
    }
}



