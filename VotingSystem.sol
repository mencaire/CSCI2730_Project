// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VotingNFT.sol";

/**
 * @title VotingSystem
 * @dev Decentralized voting system that uses NFTs to prevent Sybil attacks
 * Each voter must own a VotingNFT to cast a vote, and each NFT can only be used once
 */
contract VotingSystem {
    // Reference to the VotingNFT contract
    VotingNFT public votingNFT;
    
    // Struct to represent a voting proposal
    struct Proposal {
        string title;
        string description;
        uint256 deadline;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
        address creator;
    }
    
    // Array of all proposals
    Proposal[] public proposals;
    
    // Mapping from proposal ID to voter address to whether they voted
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    
    // Mapping from proposal ID to token ID to track which NFTs were used
    mapping(uint256 => mapping(uint256 => bool)) public nftUsedInProposal;
    
    // Event emitted when a new proposal is created
    event ProposalCreated(
        uint256 indexed proposalId,
        string title,
        address indexed creator,
        uint256 deadline
    );
    
    // Event emitted when someone votes
    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        bool support,
        uint256 tokenId
    );
    
    // Event emitted when a proposal is executed
    event ProposalExecuted(uint256 indexed proposalId, bool result);
    
    /**
     * @dev Constructor
     * @param _votingNFT Address of the VotingNFT contract
     */
    constructor(address _votingNFT) {
        require(_votingNFT != address(0), "Invalid NFT contract address");
        votingNFT = VotingNFT(_votingNFT);
    }
    
    /**
     * @dev Create a new voting proposal
     * @param title Title of the proposal
     * @param description Description of the proposal
     * @param duration Duration in seconds until the proposal deadline
     * @return proposalId The ID of the newly created proposal
     */
    function createProposal(
        string memory title,
        string memory description,
        uint256 duration
    ) public returns (uint256) {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(duration > 0, "Duration must be greater than 0");
        
        uint256 deadline = block.timestamp + duration;
        
        Proposal memory newProposal = Proposal({
            title: title,
            description: description,
            deadline: deadline,
            yesVotes: 0,
            noVotes: 0,
            executed: false,
            creator: msg.sender
        });
        
        proposals.push(newProposal);
        uint256 proposalId = proposals.length - 1;
        
        emit ProposalCreated(proposalId, title, msg.sender, deadline);
        return proposalId;
    }
    
    /**
     * @dev Cast a vote on a proposal
     * @param proposalId The ID of the proposal to vote on
     * @param support True for yes, false for no
     */
    function vote(uint256 proposalId, bool support) public {
        require(proposalId < proposals.length, "Proposal does not exist");
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Voting deadline has passed");
        require(!proposal.executed, "Proposal has already been executed");
        require(!hasVoted[proposalId][msg.sender], "You have already voted on this proposal");
        
        // Check if the voter owns a VotingNFT
        require(votingNFT.hasVotingNFT(msg.sender), "You must own a VotingNFT to vote");
        
        // Get the token ID owned by the voter
        uint256 tokenId = votingNFT.getTokenIdByOwner(msg.sender);
        require(tokenId != type(uint256).max, "No NFT found for this address");
        
        // Check if this NFT has been used for this proposal
        require(!nftUsedInProposal[proposalId][tokenId], "This NFT has already been used for this proposal");
        
        // Mark the NFT as used for this proposal
        nftUsedInProposal[proposalId][tokenId] = true;
        
        // Mark the voter as having voted
        hasVoted[proposalId][msg.sender] = true;
        
        // Record the vote
        if (support) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }
        
        emit VoteCast(proposalId, msg.sender, support, tokenId);
    }
    
    /**
     * @dev Execute a proposal after voting deadline
     * @param proposalId The ID of the proposal to execute
     */
    function executeProposal(uint256 proposalId) public {
        require(proposalId < proposals.length, "Proposal does not exist");
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Voting deadline has not passed");
        require(!proposal.executed, "Proposal has already been executed");
        
        proposal.executed = true;
        bool result = proposal.yesVotes > proposal.noVotes;
        
        emit ProposalExecuted(proposalId, result);
    }
    
    /**
     * @dev Get the total number of proposals
     * @return Number of proposals
     */
    function getProposalCount() public view returns (uint256) {
        return proposals.length;
    }
    
    /**
     * @dev Get details of a specific proposal
     * @param proposalId The ID of the proposal
     * @return title Title of the proposal
     * @return description Description of the proposal
     * @return deadline Deadline timestamp
     * @return yesVotes Number of yes votes
     * @return noVotes Number of no votes
     * @return executed Whether the proposal has been executed
     * @return creator Address of the proposal creator
     */
    function getProposal(uint256 proposalId) public view returns (
        string memory title,
        string memory description,
        uint256 deadline,
        uint256 yesVotes,
        uint256 noVotes,
        bool executed,
        address creator
    ) {
        require(proposalId < proposals.length, "Proposal does not exist");
        Proposal memory proposal = proposals[proposalId];
        return (
            proposal.title,
            proposal.description,
            proposal.deadline,
            proposal.yesVotes,
            proposal.noVotes,
            proposal.executed,
            proposal.creator
        );
    }
    
    /**
     * @dev Check if a voter can vote on a proposal
     * @param proposalId The ID of the proposal
     * @param voter Address of the voter
     * @return eligible True if the voter can vote
     * @return reason Reason why they cannot vote (if applicable)
     */
    function canVote(uint256 proposalId, address voter) public view returns (bool eligible, string memory reason) {
        if (proposalId >= proposals.length) {
            return (false, "Proposal does not exist");
        }
        
        Proposal memory proposal = proposals[proposalId];
        
        if (block.timestamp >= proposal.deadline) {
            return (false, "Voting deadline has passed");
        }
        
        if (proposal.executed) {
            return (false, "Proposal has already been executed");
        }
        
        if (hasVoted[proposalId][voter]) {
            return (false, "You have already voted on this proposal");
        }
        
        if (!votingNFT.hasVotingNFT(voter)) {
            return (false, "You must own a VotingNFT to vote");
        }
        
        uint256 tokenId = votingNFT.getTokenIdByOwner(voter);
        if (tokenId == type(uint256).max) {
            return (false, "No NFT found for this address");
        }
        
        if (nftUsedInProposal[proposalId][tokenId]) {
            return (false, "This NFT has already been used for this proposal");
        }
        
        return (true, "");
    }
    
    /**
     * @dev Get voting statistics for a proposal
     * @param proposalId The ID of the proposal
     * @return totalVotes Total number of votes cast
     * @return yesPercentage Percentage of yes votes
     * @return noPercentage Percentage of no votes
     */
    function getVotingStats(uint256 proposalId) public view returns (
        uint256 totalVotes,
        uint256 yesPercentage,
        uint256 noPercentage
    ) {
        require(proposalId < proposals.length, "Proposal does not exist");
        Proposal memory proposal = proposals[proposalId];
        
        totalVotes = proposal.yesVotes + proposal.noVotes;
        
        if (totalVotes > 0) {
            yesPercentage = (proposal.yesVotes * 100) / totalVotes;
            noPercentage = (proposal.noVotes * 100) / totalVotes;
        }
        
        return (totalVotes, yesPercentage, noPercentage);
    }
}

