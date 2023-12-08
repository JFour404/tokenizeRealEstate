// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstateToken is ERC20, Ownable {
    constructor() ERC20("RealEstateToken", "RET") Ownable(msg.sender) {
        _mint(msg.sender, 1000000000000000000000); // Mint 1,000 tokens for the contract deployer
    }

    // Function to mint additional tokens, accessible only by the owner
    function mintTokens(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
