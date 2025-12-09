# Sybil-Resistant Decentralized Voting System

A blockchain-based voting system that uses Non-Fungible Tokens (NFTs) to prevent Sybil attacks, ensuring that each voter can only cast one vote per proposal.

## Author
PENG, MINQI ; SID: 1155191548

## Abstract

This project implements a decentralized voting system on the Ethereum blockchain that addresses the Sybil attack problem through the use of ERC721 NFTs as proof of voting eligibility. The system ensures one vote per eligible participant by requiring ownership of a unique, non-transferable NFT token. Each NFT can only be used once per proposal, maintaining the integrity of the voting process.

## Project Overview

The system consists of two main smart contracts:

1. **VotingNFT Contract**: An ERC721 NFT contract that serves as proof of voting eligibility. Each eligible voter receives exactly one NFT, which cannot be transferred to prevent vote selling and maintain Sybil resistance.

2. **VotingSystem Contract**: The main voting contract that manages proposals and processes votes. It verifies NFT ownership before allowing votes and tracks voting history to prevent duplicate voting.

## Project Structure

```
Project/
├── VotingNFT.sol          # ERC721 NFT contract for voting eligibility
├── VotingSystem.sol       # Main voting system contract
├── index.html            # Web frontend interface
├── ARCHITECTURE.md       # System architecture documentation
└── README.md             # This file
```

## Prerequisites

### Required Software

1. **MetaMask Browser Extension**
   - Install from [metamask.io](https://metamask.io/)
   - Create or import a wallet
   - Obtain test ETH from a faucet for testnet deployment

2. **Remix IDE**
   - Access at [remix.ethereum.org](https://remix.ethereum.org/)
   - Web-based IDE, no installation required

3. **Test Network Access**
   - Recommended: Sepolia or Goerli testnet
   - Test ETH faucets:
     - [Sepolia Faucet](https://sepoliafaucet.com/)
     - [Alchemy Faucet](https://www.alchemy.com/faucets/ethereum-sepolia)

### Dependencies

The contracts utilize OpenZeppelin libraries, which are automatically fetched by Remix IDE:

```solidity
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
```

## Deployment Instructions

### Step 1: Setup Remix IDE

1. Navigate to [remix.ethereum.org](https://remix.ethereum.org/)
2. Create a new workspace or use the default workspace

### Step 2: Create Contract Files

1. In the File Explorer, create a new file named `VotingNFT.sol` in the `contracts` folder
2. Copy and paste the complete contents of `VotingNFT.sol` from this project
3. Create another file named `VotingSystem.sol` in the `contracts` folder
4. Copy and paste the complete contents of `VotingSystem.sol` from this project

### Step 3: Compile Contracts

1. Navigate to the "Solidity Compiler" tab
2. Select compiler version `0.8.20` or higher
3. Enable "Auto compile" if available
4. Verify both contracts compile without errors
5. Remix will automatically fetch OpenZeppelin dependencies during compilation

### Step 4: Deploy VotingNFT Contract

1. Navigate to the "Deploy & Run Transactions" tab
2. Select "Injected Provider - MetaMask" as the environment
3. Ensure MetaMask is connected to a testnet (Sepolia or Goerli)
4. Select "VotingNFT" from the contract dropdown
5. Enter constructor parameters:
   - `_name`: "Voting Eligibility Token"
   - `_symbol`: "VET"
   - `_maxSupply`: 1000 (or your desired maximum number of NFTs)
6. Click "Deploy"
7. Confirm the transaction in MetaMask
8. **Copy and save the deployed contract address** for the next step

### Step 5: Deploy VotingSystem Contract

1. In the "Deploy & Run Transactions" tab
2. Select "VotingSystem" from the contract dropdown
3. Enter the **VotingNFT contract address** from Step 4 as the constructor parameter
4. Click "Deploy"
5. Confirm the transaction in MetaMask
6. **Copy and save the deployed VotingSystem contract address**

## Usage Guide

### Minting Voting NFTs

Only the contract owner (the deployer account) can mint NFTs. To mint a voting NFT:

1. In Remix, locate your deployed VotingNFT contract
2. Expand the contract to view available functions
3. Find the `mintVotingNFT` function
4. Enter the recipient address (can be your own address or another eligible voter)
5. Click "transact"
6. Confirm the transaction in MetaMask

**Important**: Each address can only receive one NFT to prevent Sybil attacks. The contract enforces this restriction.

**Batch Minting**: The contract also provides a `batchMintVotingNFT` function that accepts an array of addresses to mint multiple NFTs in a single transaction, which is more gas-efficient.

### Creating Proposals

**Using Remix IDE:**

1. Locate your deployed VotingSystem contract
2. Find the `createProposal` function
3. Enter the following parameters:
   - `title`: Proposal title (string)
   - `description`: Detailed proposal description (string)
   - `duration`: Voting duration in seconds (e.g., 604800 for 7 days)
4. Click "transact"
5. Confirm the transaction in MetaMask

**Using Web Interface:**

1. Open `index.html` in a browser (preferably using a local server)
2. Connect your MetaMask wallet
3. Enter both contract addresses
4. Click "Connect Contracts"
5. Fill in the proposal form and click "Create Proposal"

### Voting on Proposals

**Prerequisites**: You must own a VotingNFT to cast a vote.

**Using Remix IDE:**

1. Under the VotingSystem contract, find the `vote` function
2. Enter:
   - `proposalId`: The ID of the proposal (0 for the first proposal)
   - `support`: `true` for yes, `false` for no
3. Click "transact"
4. Confirm in MetaMask

**Using Web Interface:**

1. Click "Refresh Proposals" to load all proposals
2. Locate the proposal you wish to vote on
3. Click "Vote Yes" or "Vote No"
4. Confirm the transaction in MetaMask

### Executing Proposals

After the voting deadline has passed:

1. Find the `executeProposal` function in the VotingSystem contract
2. Enter the `proposalId`
3. Click "transact"
4. The proposal results will be finalized

## Web Interface Usage

### Setup

1. **Start a Local Server** (recommended):
   ```bash
   # Using Python 3
   python3 -m http.server 8000
   
   # Using Node.js
   npx http-server -p 8000
   ```

2. **Access the Interface**:
   - Navigate to `http://localhost:8000` in your browser
   - Note: Opening `index.html` directly using `file://` protocol may cause MetaMask detection issues

### Connecting to Contracts

1. Click "Connect MetaMask Wallet" to connect your wallet
2. Enter the VotingNFT contract address
3. Enter the VotingSystem contract address
4. Click "Connect Contracts"
5. Verify the connection is successful

### Available Functions

- **Check NFT Status**: Verify if your address owns a voting NFT
- **Mint NFT**: Mint a voting NFT to an eligible address (owner only)
- **Create Proposal**: Create a new voting proposal
- **View Proposals**: Display all active and past proposals
- **Vote**: Cast votes on active proposals
- **Execute Proposal**: Finalize proposals after the deadline

## Security Features

### Sybil Attack Prevention

1. **One NFT Per Address**: The contract tracks which addresses have received NFTs and prevents duplicate minting
2. **Non-Transferable NFTs**: NFTs cannot be transferred between addresses, preventing vote selling and maintaining identity binding
3. **One Vote Per NFT Per Proposal**: Each NFT can only be used once per proposal, tracked through the `nftUsedInProposal` mapping

### Access Control

1. **Owner-Controlled Minting**: Only the contract owner can mint NFTs, ensuring controlled distribution
2. **NFT Ownership Verification**: Votes require proof of NFT ownership before being accepted
3. **Deadline Enforcement**: Proposals can only be executed after the voting deadline has passed

### Transparency

1. **On-Chain Record**: All votes are recorded on the blockchain and are publicly verifiable
2. **Immutable History**: Once recorded, voting data cannot be altered
3. **Decentralized Operation**: No centralized authority controls the voting process

## Contract Functions Reference

### VotingNFT Contract

| Function | Description | Access |
|----------|-------------|--------|
| `mintVotingNFT(address to)` | Mint an NFT to an eligible address | Owner only |
| `batchMintVotingNFT(address[] recipients)` | Batch mint NFTs to multiple addresses | Owner only |
| `hasVotingNFT(address account)` | Check if an address owns an NFT | Public |
| `getTokenIdByOwner(address owner)` | Get the token ID owned by an address | Public |
| `totalSupply()` | Get total number of minted NFTs | Public |
| `isUsedForVoting(uint256 tokenId)` | Check if an NFT has been used for voting | Public |

### VotingSystem Contract

| Function | Description | Access |
|----------|-------------|--------|
| `createProposal(string title, string description, uint256 duration)` | Create a new voting proposal | Public |
| `vote(uint256 proposalId, bool support)` | Cast a vote on a proposal | Public (requires NFT) |
| `executeProposal(uint256 proposalId)` | Execute a proposal after deadline | Public |
| `getProposal(uint256 proposalId)` | Get detailed proposal information | Public |
| `getProposalCount()` | Get total number of proposals | Public |
| `canVote(uint256 proposalId, address voter)` | Check if a voter can vote on a proposal | Public |
| `hasVoted(uint256 proposalId, address voter)` | Check if a voter has already voted | Public |
| `getVotingStats(uint256 proposalId)` | Get voting statistics for a proposal | Public |

## Testing

### Recommended Test Scenarios

1. **NFT Minting**:
   - Deploy contracts
   - Mint an NFT to your address
   - Verify NFT ownership using `hasVotingNFT`
   - Attempt to mint a second NFT to the same address (should fail)

2. **Proposal Creation**:
   - Create a proposal with a short duration (e.g., 1 hour for testing)
   - Verify the proposal appears in the list
   - Check proposal details using `getProposal`

3. **Voting**:
   - Vote on a proposal using your NFT
   - Attempt to vote again on the same proposal (should fail)
   - Verify vote counts are updated correctly

4. **Proposal Execution**:
   - Wait for the deadline to pass
   - Execute the proposal
   - Verify the execution status

## Important Considerations

### Gas Costs

- Contract deployment requires gas fees
- Each transaction (mint, vote, create proposal) consumes gas
- Ensure sufficient test ETH balance for all operations
- Batch minting is more gas-efficient than individual mints

### Network Selection

- Always use testnets (Sepolia or Goerli) for development and testing
- Never deploy to mainnet without thorough security auditing
- Keep private keys and seed phrases secure

### Contract Addresses

- Save deployed contract addresses in a secure location
- Contract addresses are required for all interactions
- Verify addresses are correct before use

### NFT Transfer Restrictions

- NFTs are intentionally non-transferable to maintain Sybil resistance
- This design prevents vote selling and ensures one vote per identity
- Revocation would require implementing a burn function

## Troubleshooting

### MetaMask Not Detected

- Ensure MetaMask extension is installed and enabled
- Refresh the page
- Use a local server instead of opening the file directly
- Check browser console for detailed error messages

### Insufficient Funds

- Obtain test ETH from a faucet
- Verify you are on the correct test network
- Check your account balance in MetaMask

### Contract Connection Failed

- Verify contract addresses are correct (42 characters, starting with 0x)
- Ensure contracts are deployed on the same network as MetaMask
- Check that the network matches (e.g., both on Sepolia)
- Use the "Refresh Network" button to update network information

### Already Voted Error

- Each address can only vote once per proposal
- This is by design to prevent Sybil attacks
- Verify you haven't already voted using `hasVoted`

### No Voting NFT Error

- You must own a VotingNFT to vote
- Only the contract owner can mint NFTs
- Request the owner to mint an NFT for your address

## Limitations and Future Work

### Current Limitations

1. Manual NFT distribution requires owner intervention
2. No NFT revocation mechanism
3. Simple majority voting (yes/no only)
4. No delegation system

### Potential Enhancements

- Automated eligibility verification for NFT distribution
- NFT burning functionality for revocation
- Weighted voting based on NFT attributes
- Proposal categorization and filtering
- Delegation system for vote representation
- Time-locked proposals
- Multi-choice voting options
- Enhanced frontend with modern frameworks

## License

This project is developed for educational purposes as part of the CSCI2730 Blockchain course.

## References

- OpenZeppelin Contracts: [https://docs.openzeppelin.com/contracts](https://docs.openzeppelin.com/contracts)
- Ethereum Documentation: [https://ethereum.org/en/developers/docs](https://ethereum.org/en/developers/docs)
- Remix IDE: [https://remix.ethereum.org](https://remix.ethereum.org)
- Portions of this project were developed with the assistance of AI tools, including ChatGPT ([https://openai.com/gpt-4](https://openai.com/gpt-4)) and GitHub Copilot ([https://github.com/features/copilot](https://github.com/features/copilot)).
