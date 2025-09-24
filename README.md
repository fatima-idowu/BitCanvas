# BitCanvas - Digital Art Ownership & Investment Platform

A revolutionary Bitcoin-secured NFT marketplace enabling fractional ownership, yield-generating staking, and collateralized minting on the Stacks blockchain.

## Overview

BitCanvas transforms digital art ownership by combining the security of Bitcoin with the programmability of smart contracts. Artists can mint NFTs with Bitcoin collateral, collectors can own fractions of valuable pieces, and stakeholders earn sustainable yields through our innovative staking mechanism. Built on Stacks, BitCanvas brings DeFi primitives to the NFT space while maintaining Bitcoin's uncompromising security guarantees.

## Features

### 🎨 **Collateralized NFT Minting**

- Artists mint NFTs backed by STX collateral (150% minimum ratio)
- Immutable provenance and creator attribution
- Flexible metadata URI support (up to 256 characters)

### 💰 **Marketplace Integration**

- Seamless listing and trading functionality
- Built-in protocol fees (0.25% default)
- Anti-self-trading protection
- Automatic treasury management

### 📊 **Fractional Ownership**

- Precision-based share system (1M shares per NFT)
- Transferable fractional positions
- Complete ownership tracking and analytics

### 🎯 **Yield Generation**

- Stake NFTs to earn yield on collateral value
- 5% annual yield rate (configurable)
- Block-by-block reward calculation
- Claim rewards anytime without unstaking

### 📈 **Analytics & Statistics**

- Comprehensive user profiles
- Global protocol metrics
- Individual token performance tracking
- Historical transaction data

## Technical Architecture

### Core Components

#### Data Structures

```clarity
;; NFT Registry - Core metadata and state
nft-registry: { token-id } -> { owner, creator, metadata-uri, ... }

;; Marketplace - Active listings
active-listings: { token-id } -> { asking-price, seller, is-active, ... }

;; Fractional Shares - Ownership tracking
fractional-shares: { token-id, shareholder } -> { share-count, ... }

;; Staking System - Yield generation
staking-positions: { token-id } -> { accumulated-rewards, ... }
```

#### Security Features

- **Arithmetic Overflow Protection**: Safe math operations with overflow detection
- **Input Validation**: Comprehensive validation for all user inputs
- **Access Control**: Owner-only administrative functions
- **Transfer Guards**: Prevents staked NFT transfers

## Contract Functions

### Public Functions

#### NFT Management

- `mint-artwork(metadata-uri, bitcoin-collateral)` - Mint new NFT with collateral
- `transfer-artwork(token-id, recipient)` - Transfer full NFT ownership

#### Marketplace

- `create-listing(token-id, asking-price)` - List NFT for sale
- `execute-purchase(token-id)` - Purchase listed NFT
- `cancel-listing(token-id)` - Cancel active listing

#### Fractional Ownership

- `transfer-fractional-shares(token-id, recipient, share-amount)` - Transfer shares

#### Staking System

- `initiate-staking(token-id)` - Begin earning yield
- `claim-staking-rewards(token-id)` - Claim accumulated rewards
- `terminate-staking(token-id)` - Stop staking and claim final rewards

#### Administration

- `update-protocol-parameters(yield-rate, fee-rate, collateral-ratio)` - Owner only

### Read-Only Functions

- `get-artwork-details(token-id)` - NFT metadata and state
- `get-marketplace-listing(token-id)` - Active listing information
- `get-fractional-position(token-id, shareholder)` - Share ownership
- `get-staking-position(token-id)` - Staking rewards data
- `get-user-profile(user)` - User statistics
- `get-protocol-metrics()` - Global protocol data
- `calculate-pending-rewards(token-id)` - Pending reward calculation

## Error Handling

The contract implements comprehensive error handling with descriptive error codes:

```clarity
ERR_UNAUTHORIZED (u100)           - Access denied
ERR_NOT_TOKEN_OWNER (u101)        - Not token owner
ERR_INSUFFICIENT_BALANCE (u102)   - Insufficient funds
ERR_INVALID_TOKEN (u103)          - Token doesn't exist
ERR_LISTING_NOT_FOUND (u104)      - No active listing
ERR_INVALID_PRICE (u105)          - Invalid price value
ERR_INSUFFICIENT_COLLATERAL (u106) - Collateral too low
ERR_ALREADY_STAKED (u107)         - Token already staked
ERR_NOT_STAKED (u108)             - Token not staked
ERR_INVALID_PERCENTAGE (u109)     - Invalid percentage
ERR_INVALID_URI (u110)            - Invalid metadata URI
ERR_INVALID_RECIPIENT (u111)      - Invalid recipient
ERR_ARITHMETIC_OVERFLOW (u112)    - Math overflow
ERR_MARKETPLACE_INACTIVE (u113)   - Listing inactive
ERR_SELF_TRANSFER (u114)          - Cannot transfer to self
```

## Usage Examples

### Minting an NFT

```clarity
;; Mint artwork with metadata URI and 1000 STX collateral
(contract-call? .bitcanvas mint-artwork 
  "https://ipfs.io/ipfs/QmHash123..." 
  u1000000000) ;; 1000 STX in microSTX
```

### Staking for Yield

```clarity
;; Start earning yield on token #1
(contract-call? .bitcanvas initiate-staking u1)

;; Claim accumulated rewards
(contract-call? .bitcanvas claim-staking-rewards u1)
```

### Fractional Trading

```clarity
;; Transfer 10% ownership (100,000 shares) to another user
(contract-call? .bitcanvas transfer-fractional-shares 
  u1 
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 
  u100000)
```

## Protocol Parameters

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| Min Collateral Ratio | 150% | Minimum STX backing required |
| Protocol Fee | 0.25% | Marketplace transaction fee |
| Yield Rate | 5% annually | Staking reward rate |
| Max URI Length | 256 chars | Metadata URI limit |
| Shares per NFT | 1,000,000 | Fractional precision |

## Development & Testing

### Prerequisites

- Clarinet CLI
- Stacks blockchain knowledge
- Node.js for testing scripts

### Testing

```bash
# Run contract tests
clarinet test

# Check contract syntax
clarinet check

# Generate documentation
clarinet docs
```

### Deployment

```bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet (requires setup)
clarinet deploy --mainnet
```

## Security Considerations

1. **Collateral Management**: All STX collateral is held securely by the contract
2. **Overflow Protection**: Safe arithmetic prevents integer overflow attacks
3. **Access Controls**: Critical functions restricted to appropriate parties
4. **Input Validation**: All user inputs thoroughly validated
5. **State Consistency**: Atomic operations maintain data integrity

## Roadmap

- [ ] Multi-signature admin controls
- [ ] Dutch auction marketplace
- [ ] Cross-chain bridge integration
- [ ] Enhanced analytics dashboard
- [ ] Mobile SDK development

## Contributing

We welcome contributions to BitCanvas! Please read our contributing guidelines and submit pull requests for review.

## License

MIT License - see LICENSE file for details.

---

Built with ❤️ on Bitcoin via Stacks blockchain.
