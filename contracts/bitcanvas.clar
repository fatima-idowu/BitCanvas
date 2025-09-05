;; Title: BitCanvas - Digital Art Ownership & Investment Platform
;;
;; Summary: A revolutionary Bitcoin-secured NFT marketplace enabling fractional 
;;          ownership, yield-generating staking, and collateralized minting on 
;;          the Stacks blockchain.
;;
;; Description: BitCanvas transforms digital art ownership by combining the security 
;;              of Bitcoin with the programmability of smart contracts. Artists can 
;;              mint NFTs with Bitcoin collateral, collectors can own fractions of 
;;              valuable pieces, and stakeholders earn sustainable yields through 
;;              our innovative staking mechanism. Built on Stacks, BitCanvas brings 
;;              DeFi primitives to the NFT space while maintaining Bitcoin's 
;;              uncompromising security guarantees.

;; CONSTANTS & ERROR CODE

(define-constant CONTRACT_OWNER tx-sender)

;; Error Constants - Organized by Category
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))
(define-constant ERR_INVALID_TOKEN (err u103))
(define-constant ERR_LISTING_NOT_FOUND (err u104))
(define-constant ERR_INVALID_PRICE (err u105))
(define-constant ERR_INSUFFICIENT_COLLATERAL (err u106))
(define-constant ERR_ALREADY_STAKED (err u107))
(define-constant ERR_NOT_STAKED (err u108))
(define-constant ERR_INVALID_PERCENTAGE (err u109))
(define-constant ERR_INVALID_URI (err u110))
(define-constant ERR_INVALID_RECIPIENT (err u111))
(define-constant ERR_ARITHMETIC_OVERFLOW (err u112))
(define-constant ERR_MARKETPLACE_INACTIVE (err u113))
(define-constant ERR_SELF_TRANSFER (err u114))

;; Protocol Configuration Constants
(define-constant MIN_COLLATERAL_RATIO u150) ;; 150% minimum collateral ratio
(define-constant PROTOCOL_FEE_BASIS_POINTS u25) ;; 0.25% protocol fee
(define-constant YIELD_RATE_BASIS_POINTS u500) ;; 5% annual yield rate
(define-constant BLOCKS_PER_YEAR u52560) ;; Approximate Stacks blocks per year
(define-constant MAX_URI_LENGTH u256) ;; Maximum URI length
(define-constant BASIS_POINTS_SCALE u10000) ;; Scale for basis points calculations

;; STATE VARIABLE

(define-data-var total-supply uint u0)
(define-data-var total-staked-tokens uint u0)
(define-data-var protocol-treasury uint u0)

;; Dynamic protocol parameters (owner-configurable)
(define-data-var current-yield-rate uint YIELD_RATE_BASIS_POINTS)
(define-data-var current-protocol-fee uint PROTOCOL_FEE_BASIS_POINTS)
(define-data-var min-collateral-requirement uint MIN_COLLATERAL_RATIO)

;; DATA STRUCTURE

;; Core NFT Metadata & State
(define-map nft-registry
  { token-id: uint }
  {
    owner: principal,
    creator: principal,
    metadata-uri: (string-ascii 256),
    bitcoin-collateral: uint,
    is-actively-staked: bool,
    stake-initiated-block: uint,
    total-fractional-shares: uint,
    creation-timestamp: uint,
  }
)

;; Marketplace Listings
(define-map active-listings
  { token-id: uint }
  {
    asking-price: uint,
    seller: principal,
    is-active: bool,
    listing-timestamp: uint,
  }
)

;; Fractional Ownership Tracking
(define-map fractional-shares
  {
    token-id: uint,
    shareholder: principal,
  }
  {
    share-count: uint,
    acquisition-timestamp: uint,
  }
)

;; Staking Rewards System
(define-map staking-positions
  { token-id: uint }
  {
    accumulated-rewards: uint,
    last-reward-claim: uint,
    total-blocks-staked: uint,
  }
)