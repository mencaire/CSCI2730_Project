// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title VotingNFT
 * @dev ERC721 NFT contract that serves as proof of voting eligibility
 * Each NFT represents one voting right, preventing Sybil attacks
 */
contract VotingNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIdCounter;
    
    // Mapping to track if an address has already received an NFT
    mapping(address => bool) private _hasReceivedNFT;
    
    // Mapping to track if an NFT has been used for voting
    mapping(uint256 => bool) private _usedForVoting;
    
    // Base URI for token metadata
    string private _baseTokenURI;
    
    // Maximum number of NFTs that can be minted
    uint256 public maxSupply;
    
    // Event emitted when a new voting NFT is minted
    event VotingNFTMinted(address indexed to, uint256 indexed tokenId);
    
    /**
     * @dev Constructor
     * @param name Name of the NFT collection
     * @param symbol Symbol of the NFT collection
     * @param _maxSupply Maximum number of NFTs that can be minted
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply
    ) ERC721(name, symbol) Ownable(msg.sender) {
        maxSupply = _maxSupply;
    }
    
    /**
     * @dev Mint a voting NFT to an eligible address
     * @param to Address to receive the NFT
     * @return tokenId The ID of the newly minted NFT
     */
    function mintVotingNFT(address to) public onlyOwner returns (uint256) {
        require(!_hasReceivedNFT[to], "Address already has a voting NFT");
        require(_tokenIdCounter.current() < maxSupply, "Maximum supply reached");
        require(to != address(0), "Cannot mint to zero address");
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        
        _hasReceivedNFT[to] = true;
        _safeMint(to, tokenId);
        
        emit VotingNFTMinted(to, tokenId);
        return tokenId;
    }
    
    /**
     * @dev Batch mint NFTs to multiple addresses
     * @param recipients Array of addresses to receive NFTs
     */
    function batchMintVotingNFT(address[] memory recipients) public onlyOwner {
        for (uint256 i = 0; i < recipients.length; i++) {
            if (!_hasReceivedNFT[recipients[i]] && _tokenIdCounter.current() < maxSupply) {
                mintVotingNFT(recipients[i]);
            }
        }
    }
    
    /**
     * @dev Check if an address has received a voting NFT
     * @param account Address to check
     * @return True if the address has received an NFT
     */
    function hasVotingNFT(address account) public view returns (bool) {
        return balanceOf(account) > 0;
    }
    
    /**
     * @dev Check if an NFT has been used for voting
     * @param tokenId The NFT token ID to check
     * @return True if the NFT has been used for voting
     */
    function isUsedForVoting(uint256 tokenId) public view returns (bool) {
        return _usedForVoting[tokenId];
    }
    
    /**
     * @dev Mark an NFT as used for voting (only callable by voting contract or token owner)
     * @param tokenId The NFT token ID to mark as used
     */
    function markAsUsed(uint256 tokenId) external {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        require(msg.sender == owner() || _ownerOf(tokenId) == msg.sender, 
                "Not authorized to mark NFT as used");
        require(!_usedForVoting[tokenId], "NFT already used for voting");
        
        _usedForVoting[tokenId] = true;
    }
    
    /**
     * @dev Get the token ID owned by an address (if any)
     * @param owner Address to check
     * @return tokenId The token ID owned by the address, or max uint256 if none
     */
    function getTokenIdByOwner(address owner) public view returns (uint256) {
        uint256 balance = balanceOf(owner);
        if (balance == 0) {
            return type(uint256).max;
        }
        
        // Find the token ID owned by this address
        uint256 currentSupply = _tokenIdCounter.current();
        for (uint256 i = 0; i < currentSupply; i++) {
            if (_ownerOf(i) == owner) {
                return i;
            }
        }
        return type(uint256).max;
    }
    
    /**
     * @dev Get total number of minted NFTs
     * @return Current token count
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }
    
    /**
     * @dev Set the base URI for token metadata
     * @param baseURI The base URI string
     */
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }
    
    /**
     * @dev Override base URI
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
    
    /**
     * @dev Prevent transfers of voting NFTs to maintain Sybil resistance
     * Override approve functions to prevent authorization, which prevents transfers
     * Note: Must remain public (not view) to match parent contract signature
     */
    function approve(address /* to */, uint256 /* tokenId */) public override {
        // No-op state write to prevent view warning (revert prevents execution)
        maxSupply = maxSupply;
        revert("Voting NFTs are non-transferable");
    }
    
    function setApprovalForAll(address /* operator */, bool /* approved */) public override {
        // No-op state write to prevent view warning (revert prevents execution)
        maxSupply = maxSupply;
        revert("Voting NFTs are non-transferable");
    }
}

