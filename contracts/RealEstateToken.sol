// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstateToken {
    struct RealEstateAsset {
        string propertyAddress;
        string description;
        uint256 currentValue;
        // Add any other relevant details here
    }

    // Token count to generate unique token IDs
    uint256 private tokenCount;

    // Mapping to associate token IDs with real estate assets
    mapping(uint256 => RealEstateAsset) public tokenToAsset;

    // Mapping to track token ownership
    mapping(address => uint256[]) public ownership;

    // Event for token creation
    event TokenCreated(
        uint256 indexed tokenId,
        address indexed owner,
        string propertyAddress,
        string description
    );

    // Event for token ownership transfer
    event TokenOwnershipTransferred(uint256 indexed tokenId, address indexed owner);

    // Token Creation Function
    function createToken(
        string memory _propertyAddress,
        string memory _description,
        uint256 _currentValue
    ) public {
        // Input validation
        require(bytes(_propertyAddress).length > 0, "Property address must be provided");
        require(bytes(_description).length > 0, "Description must be provided");
        require(_currentValue > 0, "Current value must be greater than zero");

        // Increment token count
        tokenCount++;

        // Create a new RealEstateAsset
        RealEstateAsset memory newAsset = RealEstateAsset(_propertyAddress, _description, _currentValue);

        // Link token to its associated real estate asset
        linkTokenToAsset(tokenCount, newAsset);

        // Mint the new token
        ownership[msg.sender].push(tokenCount);

        // Emit the token creation event
        emit TokenCreated(tokenCount, msg.sender, _propertyAddress, _description);

        // Emit the token ownership event
        emit TokenOwnershipTransferred(tokenCount, msg.sender);
    }

    // Private function to link token to its associated real estate asset
    function linkTokenToAsset(uint256 _tokenId, RealEstateAsset memory _asset) private {
        tokenToAsset[_tokenId] = _asset;
    }

    // Function to get all token IDs owned by a specific address
    function getTokenIdsByOwner(address _owner) external view returns (uint256[] memory) {
        return ownership[_owner];
    }
}

