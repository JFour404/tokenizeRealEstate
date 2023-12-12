// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin library for access control
import "@openzeppelin/contracts/access/Ownable.sol";

// Real Estate Token Contract
contract RealEstateToken is Ownable(msg.sender) {

    // Real Estate Asset Struct
    struct RealEstateAsset {
        string propertyAddress;
        string description;
        uint256 currentValue;
        // Token metadata
        string imageURL;
        // Add any other relevant details here
        address[] owners; // List of owners for the token
        uint256[] percentages; // List of ownership percentages
    }

    // Token count starts from 1
    uint256 private tokenCount = 0;

    // Mapping to associate token IDs with real estate assets
    mapping(uint256 => RealEstateAsset) public tokenToAsset;

    // Mapping to track token ownership
    mapping(address => mapping(uint256 => bool)) public ownership;

    // Event for token creation
    event TokenCreated(
        uint256 indexed tokenId,
        address indexed owner,
        string propertyAddress,
        string description,
        string imageURL
    );

    // Event for token ownership transfer
    event TokenOwnershipTransferred(uint256 indexed tokenId, address indexed from, address indexed to);

    // Event for additional information about token transfer
    event TokenSent(uint256 indexed tokenId, address indexed from, address indexed to);
    event TokenReceived(uint256 indexed tokenId, address indexed from, address indexed to);

    // Modifier: Only Token Owner
    modifier onlyTokenOwner(uint256 _tokenId) {
        require(ownership[msg.sender][_tokenId], "Only the token owner can perform this action");
        _;
    }

    // Modifier: Valid Recipient
    modifier validRecipient(address _to) {
        require(_to != address(0), "Invalid recipient address");
        _;
    }

    // Modifier: Reentrancy Guard
    modifier reentrancyGuard(uint256 _tokenId) {
        require(!ownership[msg.sender][_tokenId], "ReentrancyGuard: No tokens to transfer");
        _;
    }

    // Token Creation Function with Partial Ownership
    function createToken(
        string memory _propertyAddress,
        string memory _description,
        uint256 _currentValue,
        string memory _imageURL,
        address[] memory _owners,
        uint256[] memory _percentages
    ) public onlyOwner {
        // Input validation
        require(bytes(_propertyAddress).length > 0, "Property address must be provided");
        require(bytes(_description).length > 0, "Description must be provided");
        require(_currentValue > 0, "Current value must be greater than zero");
        require(_owners.length > 0, "At least one owner must be provided");
        require(_owners.length == _percentages.length, "Owners and percentages arrays must have the same length");

        uint256 totalPercentage;

        // Calculate total percentage and validate
        for (uint256 i = 0; i < _owners.length; i++) {
            require(_percentages[i] > 0 && _percentages[i] <= 100, "Percentage must be between 1 and 100");
            totalPercentage += _percentages[i];
        }

        require(totalPercentage == 100, "Total ownership percentage must be 100");

        // Increment token count starting from 1
        tokenCount++;

        // Create a new RealEstateAsset with metadata and initial owners
        RealEstateAsset memory newAsset = RealEstateAsset(
            _propertyAddress,
            _description,
            _currentValue,
            _imageURL,
            _owners,
            _percentages
        );

        // Set ownership information within the RealEstateAsset struct
        for (uint256 i = 0; i < _owners.length; i++) {
            ownership[_owners[i]][tokenCount] = true;
        }

        // Link token to its associated real estate asset
        linkTokenToAsset(tokenCount, newAsset);

        // Emit the token creation event
        emit TokenCreated(tokenCount, owner(), _propertyAddress, _description, _imageURL);
    }

    // Transfer Token Function with Reentrancy Protection
    function transferToken(address _to, uint256 _tokenId, uint256 _percentage) public onlyTokenOwner(_tokenId) validRecipient(_to) reentrancyGuard(_tokenId) {
        // Validate the specified percentage
        require(_percentage > 0 && _percentage <= 100, "Invalid transfer percentage");

        // Get the current ownership information
        address[] storage currentOwners = tokenToAsset[_tokenId].owners;
        uint256[] storage currentPercentages = tokenToAsset[_tokenId].percentages;

        // Find the index of the sender in the current owners list
        uint256 senderIndex = findOwnerIndex(msg.sender, currentOwners);

        // Ensure that the sender owns at least the specified percentage
        require(currentPercentages[senderIndex] >= _percentage, "Not enough ownership to transfer");

        // Calculate the new ownership percentage for the sender
        currentPercentages[senderIndex] -= _percentage;

        // Update ownership information for the recipient
        if (updateOwnership(_tokenId, _to, _percentage, currentOwners, currentPercentages)) {
            // Emit the updated token ownership event
            emit TokenOwnershipTransferred(_tokenId, msg.sender, _to);

            // Emit additional events for more detailed transfer information
            emit TokenSent(_tokenId, msg.sender, _to); // Removed the transferred percentage from the event
            emit TokenReceived(_tokenId, msg.sender, _to); // Removed the received percentage from the event
        }
    }




    // Function to find the index of an owner in the owners array
    function findOwnerIndex(address _owner, address[] memory _owners) internal pure returns (uint256) {
        for (uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == _owner) {
                return i;
            }
        }
        revert("Owner not found");
    }

    // Function to update ownership information for the recipient
    function updateOwnership(
        uint256 _tokenId,
        address _recipient,
        uint256 _percentage,
        address[] storage _owners,
        uint256[] storage _percentages
    ) internal returns (bool) {
        // Check if the recipient already owns a part of the token
        uint256 recipientIndex = findOwnerIndex(_recipient, _owners);

        // Update ownership information for the recipient
        if (recipientIndex < _owners.length) {
            _percentages[recipientIndex] += _percentage;
        } else {
            _owners.push(_recipient);
            _percentages.push(_percentage);
        }

        // Update the ownership information in the tokenToAsset mapping
        tokenToAsset[_tokenId].owners = _owners;
        tokenToAsset[_tokenId].percentages = _percentages;

        return true;
    }

    // Function to get all token IDs owned by a specific address
    function getTokenIdsByOwner(address _owner) external view returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](tokenCount);
        uint256 count = 0;

        for (uint256 i = 1; i <= tokenCount; i++) {
            if (ownership[_owner][i]) {
                tokenIds[count] = i;
                count++;
            }
        }

        return tokenIds;
    }

    // Private function to link token to its associated real estate asset
    function linkTokenToAsset(uint256 _tokenId, RealEstateAsset memory _asset) private {
        tokenToAsset[_tokenId] = _asset;
    }

    function getTokenCount() public view returns (uint256) {
        return tokenCount;
    }

        // Function to get all information about a specific token
    function getTokenInfo(uint256 _tokenId) external view returns (
        string memory propertyAddress,
        string memory description,
        uint256 currentValue,
        string memory imageURL,
        address[] memory owner,
        uint256[] memory share
    ) {
        RealEstateAsset storage asset = tokenToAsset[_tokenId];
        propertyAddress = asset.propertyAddress;
        description = asset.description;
        currentValue = asset.currentValue;
        imageURL = asset.imageURL;
        owner = asset.owners;
        share = asset.percentages;
    }
}
