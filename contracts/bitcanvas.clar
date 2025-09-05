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

;; User Activity Tracking
(define-map user-statistics
  { user: principal }
  {
    tokens-created: uint,
    tokens-owned: uint,
    total-volume-traded: uint,
    rewards-earned: uint,
  }
)

;; PRIVATE UTILITY FUNCTION

;; Safe arithmetic operations to prevent overflow
(define-private (safe-add
    (a uint)
    (b uint)
  )
  (let ((result (+ a b)))
    (asserts! (>= result a) ERR_ARITHMETIC_OVERFLOW)
    (ok result)
  )
)

(define-private (safe-multiply
    (a uint)
    (b uint)
  )
  (let ((result (* a b)))
    (asserts! (or (is-eq a u0) (is-eq result (/ result a)))
      ERR_ARITHMETIC_OVERFLOW
    )
    (ok result)
  )
)

;; Input validation functions
(define-private (is-valid-uri (uri (string-ascii 256)))
  (let ((uri-length (len uri)))
    (and
      (> uri-length u0)
      (<= uri-length MAX_URI_LENGTH)
      (not (is-eq uri ""))
    )
  )
)

(define-private (is-valid-recipient (recipient principal))
  (and
    (not (is-eq recipient (as-contract tx-sender)))
    (not (is-eq recipient tx-sender))
  )
)

;; Fixed calculate-protocol-fee function
(define-private (calculate-protocol-fee (amount uint))
  (ok (/ (try! (safe-multiply amount (var-get current-protocol-fee)))
         BASIS_POINTS_SCALE))
)

;; CORE NFT FUNCTIONALIT

;; Mint new NFT with Bitcoin collateral backing
(define-public (mint-artwork
    (metadata-uri (string-ascii 256))
    (bitcoin-collateral uint)
  )
  (let (
      (new-token-id (+ (var-get total-supply) u1))
      (required-collateral (/
        (try! (safe-multiply bitcoin-collateral (var-get min-collateral-requirement)))
        u100
      ))
      (creator-balance (stx-get-balance tx-sender))
    )
    ;; Comprehensive input validation
    (asserts! (is-valid-uri metadata-uri) ERR_INVALID_URI)
    (asserts! (> bitcoin-collateral u0) ERR_INSUFFICIENT_COLLATERAL)
    (asserts! (>= creator-balance required-collateral) ERR_INSUFFICIENT_BALANCE)

    ;; Secure collateral transfer to contract
    (try! (stx-transfer? required-collateral tx-sender (as-contract tx-sender)))

    ;; Register new NFT in registry
    (map-set nft-registry { token-id: new-token-id } {
      owner: tx-sender,
      creator: tx-sender,
      metadata-uri: metadata-uri,
      bitcoin-collateral: bitcoin-collateral,
      is-actively-staked: false,
      stake-initiated-block: u0,
      total-fractional-shares: u1000000, ;; 1M shares for precision
      creation-timestamp: stacks-block-height,
    })

    ;; Initialize creator's full ownership
    (map-set fractional-shares {
      token-id: new-token-id,
      shareholder: tx-sender,
    } {
      share-count: u1000000,
      acquisition-timestamp: stacks-block-height,
    })

    ;; Update global state
    (var-set total-supply new-token-id)

    ;; Update creator statistics
    (update-user-statistics tx-sender u1 u1 u0 u0)

    (ok new-token-id)
  )
)

;; Transfer NFT ownership (only if not staked)
(define-public (transfer-artwork
    (token-id uint)
    (recipient principal)
  )
  (let (
      (artwork-data (unwrap! (map-get? nft-registry { token-id: token-id }) ERR_INVALID_TOKEN))
      (sender-shares (unwrap!
        (map-get? fractional-shares {
          token-id: token-id,
          shareholder: tx-sender,
        })
        ERR_NOT_TOKEN_OWNER
      ))
    )
    ;; Validate transfer conditions
    (asserts! (is-valid-recipient recipient) ERR_INVALID_RECIPIENT)
    (asserts! (is-eq tx-sender (get owner artwork-data)) ERR_NOT_TOKEN_OWNER)
    (asserts! (not (get is-actively-staked artwork-data)) ERR_ALREADY_STAKED)
    (asserts! (is-eq (get share-count sender-shares) u1000000)
      ERR_NOT_TOKEN_OWNER
    )
    ;; Must own 100%

    ;; Execute ownership transfer
    (map-set nft-registry { token-id: token-id }
      (merge artwork-data { owner: recipient })
    )

    ;; Transfer fractional shares
    (map-delete fractional-shares {
      token-id: token-id,
      shareholder: tx-sender,
    })
    (map-set fractional-shares {
      token-id: token-id,
      shareholder: recipient,
    } {
      share-count: u1000000,
      acquisition-timestamp: stacks-block-height,
    })

    ;; Update user statistics
    (update-user-statistics tx-sender u0 u0 u0 u0)
    ;; Decrease owned count
    (update-user-statistics recipient u0 u1 u0 u0)
    ;; Increase owned count

    (ok true)
  )
)

;; MARKETPLACE FUNCTIONALIT

;; List NFT for sale on the marketplace
(define-public (create-listing
    (token-id uint)
    (asking-price uint)
  )
  (let ((artwork-data (unwrap! (map-get? nft-registry { token-id: token-id }) ERR_INVALID_TOKEN)))
    ;; Validate listing conditions
    (asserts! (> asking-price u0) ERR_INVALID_PRICE)
    (asserts! (is-eq tx-sender (get owner artwork-data)) ERR_NOT_TOKEN_OWNER)
    (asserts! (not (get is-actively-staked artwork-data)) ERR_ALREADY_STAKED)

    ;; Create marketplace listing
    (map-set active-listings { token-id: token-id } {
      asking-price: asking-price,
      seller: tx-sender,
      is-active: true,
      listing-timestamp: stacks-block-height,
    })

    (ok true)
  )
)

;; Execute NFT purchase from marketplace
(define-public (execute-purchase (token-id uint))
  (let (
      (listing-data (unwrap! (map-get? active-listings { token-id: token-id })
        ERR_LISTING_NOT_FOUND
      ))
      (artwork-data (unwrap! (map-get? nft-registry { token-id: token-id }) ERR_INVALID_TOKEN))
      (sale-price (get asking-price listing-data))
      (seller (get seller listing-data))
      (protocol-fee (try! (calculate-protocol-fee sale-price)))
      (seller-proceeds (- sale-price protocol-fee))
    )
    ;; Validate purchase conditions
    (asserts! (get is-active listing-data) ERR_MARKETPLACE_INACTIVE)
    (asserts! (not (is-eq tx-sender seller)) ERR_SELF_TRANSFER)
    (asserts! (>= (stx-get-balance tx-sender) sale-price)
      ERR_INSUFFICIENT_BALANCE
    )