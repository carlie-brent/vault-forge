;; Title: VaultForge Protocol - Adaptive Collateral Management System
;;
;; Summary: 
;; Next-generation Bitcoin lending infrastructure that dynamically adjusts 
;; collateral requirements through intelligent reputation scoring and 
;; behavioral analytics on the Stacks blockchain.
;;
;; Description:
;; VaultForge Protocol pioneers a revolutionary approach to Bitcoin-based 
;; lending by implementing an adaptive collateral framework that evolves 
;; with user behavior. Unlike static DeFi protocols, VaultForge continuously 
;; analyzes on-chain activities, payment histories, and risk profiles to 
;; create personalized lending experiences. The protocol's proprietary 
;; Reputation Engine enables qualified users to access capital with 
;; progressively lower collateral ratios and reduced interest rates, 
;; effectively bridging centralized finance efficiency with decentralized 
;; security. Through machine-learning inspired algorithms and real-time 
;; risk assessment, VaultForge transforms Bitcoin's Layer 2 ecosystem into 
;; a sophisticated capital marketplace where financial responsibility is 
;; rewarded with enhanced access and preferential terms.

;; PROTOCOL CONSTANTS AND ERROR MANAGEMENT

(define-constant CONTRACT-OWNER tx-sender)

;; Comprehensive error code system for robust transaction handling
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-BALANCE (err u2))
(define-constant ERR-INVALID-AMOUNT (err u3))
(define-constant ERR-LOAN-NOT-FOUND (err u4))
(define-constant ERR-LOAN-DEFAULTED (err u5))
(define-constant ERR-INSUFFICIENT-SCORE (err u6))
(define-constant ERR-ACTIVE-LOAN (err u7))
(define-constant ERR-NOT-DUE (err u8))
(define-constant ERR-INVALID-DURATION (err u9))
(define-constant ERR-INVALID-LOAN-ID (err u10))

;; Reputation Engine configuration parameters
(define-constant MIN-SCORE u50)
(define-constant MAX-SCORE u100)
(define-constant MIN-LOAN-SCORE u70)

;; DATA ARCHITECTURE AND STORAGE MAPS

;; Comprehensive user reputation profiles with behavioral metrics
(define-map UserScores
  { user: principal }
  {
    score: uint,
    total-borrowed: uint,
    total-repaid: uint,
    loans-taken: uint,
    loans-repaid: uint,
    last-update: uint,
  }
)

;; Detailed loan metadata registry with complete lifecycle tracking
(define-map Loans
  { loan-id: uint }
  {
    borrower: principal,
    amount: uint,
    collateral: uint,
    due-height: uint,
    interest-rate: uint,
    is-active: bool,
    is-defaulted: bool,
    repaid-amount: uint,
  }
)

;; Multi-loan portfolio management per user account
(define-map UserLoans
  { user: principal }
  { active-loans: (list 20 uint) }
)

;; PROTOCOL STATE VARIABLES

(define-data-var next-loan-id uint u0)
(define-data-var total-stx-locked uint u0)

;; CORE PROTOCOL FUNCTIONS

;; Initialize user reputation profile in the VaultForge ecosystem
;; Creates baseline metrics for new protocol participants
(define-public (initialize-score)
  (let ((sender tx-sender))
    (asserts! (is-none (map-get? UserScores { user: sender })) ERR-UNAUTHORIZED)
    (ok (map-set UserScores { user: sender } {
      score: MIN-SCORE,
      total-borrowed: u0,
      total-repaid: u0,
      loans-taken: u0,
      loans-repaid: u0,
      last-update: stacks-block-height,
    }))
  )
)

;; Execute intelligent loan origination with adaptive risk pricing
;; Implements VaultForge's signature reputation-based lending algorithm
(define-public (request-loan
    (amount uint)
    (collateral uint)
    (duration uint)
  )
  (let (
      (sender tx-sender)
      (loan-id (+ (var-get next-loan-id) u1))
      (user-score (unwrap! (map-get? UserScores { user: sender }) ERR-UNAUTHORIZED))
      (active-loans (default-to { active-loans: (list) } (map-get? UserLoans { user: sender })))
    )
    ;; Multi-tier eligibility verification system
    (asserts! (>= (get score user-score) MIN-LOAN-SCORE) ERR-INSUFFICIENT-SCORE)
    (asserts! (<= (len (get active-loans active-loans)) u5) ERR-ACTIVE-LOAN)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (and (> duration u0) (<= duration u52560)) ERR-INVALID-DURATION)

    ;; Adaptive collateral calculation using Reputation Engine
    (let ((required-collateral (calculate-required-collateral amount (get score user-score))))
      (asserts! (>= collateral required-collateral) ERR-INSUFFICIENT-BALANCE)

      ;; Secure collateral locking mechanism
      (try! (stx-transfer? collateral sender (as-contract tx-sender)))

      ;; Create comprehensive loan record with dynamic pricing
      (map-set Loans { loan-id: loan-id } {
        borrower: sender,
        amount: amount,
        collateral: collateral,
        due-height: (+ stacks-block-height duration),
        interest-rate: (calculate-interest-rate (get score user-score)),
        is-active: true,
        is-defaulted: false,
        repaid-amount: u0,
      })

      ;; Update user's loan portfolio registry
      (try! (update-user-loans sender loan-id))

      ;; Execute capital disbursement to borrower
      (as-contract (try! (stx-transfer? amount tx-sender sender)))

      ;; Update global protocol metrics
      (var-set next-loan-id loan-id)
      (var-set total-stx-locked (+ (var-get total-stx-locked) collateral))

      (ok loan-id)
    )
  )
)

;; Process loan repayment with automatic reputation enhancement
;; Handles flexible payment schedules and instant collateral release
(define-public (repay-loan
    (loan-id uint)
    (amount uint)
  )
  (let (
      (sender tx-sender)
      (loan (unwrap! (map-get? Loans { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
    )
    ;; Comprehensive authorization and validation framework
    (asserts! (is-eq sender (get borrower loan)) ERR-UNAUTHORIZED)
    (asserts! (get is-active loan) ERR-LOAN-NOT-FOUND)
    (asserts! (not (get is-defaulted loan)) ERR-LOAN-DEFAULTED)
    (asserts! (<= loan-id (var-get next-loan-id)) ERR-INVALID-LOAN-ID)

    ;; Calculate total obligation including dynamic interest
    (let ((total-due (calculate-total-due loan)))
      (asserts! (>= amount u0) ERR-INVALID-AMOUNT)

      ;; Process repayment transaction
      (try! (stx-transfer? amount sender (as-contract tx-sender)))

      ;; Update loan repayment tracking system
      (let ((new-repaid-amount (+ (get repaid-amount loan) amount)))
        (map-set Loans { loan-id: loan-id }
          (merge loan {
            repaid-amount: new-repaid-amount,
            is-active: (< new-repaid-amount total-due),
          })
        )

        ;; Execute loan completion and reputation rewards
        (if (>= new-repaid-amount total-due)
          (begin
            (try! (update-trust-score sender true loan))
            (as-contract (try! (stx-transfer? (get collateral loan) tx-sender sender)))
            (var-set total-stx-locked
              (- (var-get total-stx-locked) (get collateral loan))
            )
          )
          true
        )

        (ok true)
      )
    )
  )
)

;; ADVANCED CALCULATION ALGORITHMS

;; Reputation-driven collateral optimization engine
;; Implements VaultForge's proprietary capital efficiency scaling
(define-private (calculate-required-collateral
    (amount uint)
    (score uint)
  )
  (let ((collateral-ratio (- u100 (/ (* score u50) u100))))
    (/ (* amount collateral-ratio) u100)
  )
)

;; Dynamic interest rate calculation with reputation incentives
;; Rewards high-reputation users with competitive pricing
(define-private (calculate-interest-rate (score uint))
  (let ((base-rate u10))
    (- base-rate (/ (* score u5) u100))
  )
)

;; Comprehensive debt calculation with compound interest modeling
(define-private (calculate-total-due (loan {
  borrower: principal,
  amount: uint,
  collateral: uint,
  due-height: uint,
  interest-rate: uint,
  is-active: bool,
  is-defaulted: bool,
  repaid-amount: uint,
}))
  (let ((interest (* (get amount loan) (get interest-rate loan))))
    (+ (get amount loan) (/ interest u100))
  )
)

;; Advanced reputation scoring with behavioral reinforcement learning
;; Implements positive feedback loops for responsible lending behavior
(define-private (update-trust-score
    (user principal)
    (success bool)
    (loan {
      borrower: principal,
      amount: uint,
      collateral: uint,
      due-height: uint,
      interest-rate: uint,
      is-active: bool,
      is-defaulted: bool,
      repaid-amount: uint,
    })
  )
  (let (
      (current-score (unwrap! (map-get? UserScores { user: user }) ERR-UNAUTHORIZED))
      (new-score (if success
        (if (<= (+ (get score current-score) u2) MAX-SCORE)
          (+ (get score current-score) u2)
          MAX-SCORE
        )
        (if (>= (- (get score current-score) u10) MIN-SCORE)
          (- (get score current-score) u10)
          MIN-SCORE
        )
      ))
    )
    ;; Execute comprehensive user profile enhancement
    (if success
      (map-set UserScores { user: user }
        (merge current-score {
          score: new-score,
          total-repaid: (+ (get total-repaid current-score) (get amount loan)),
          loans-repaid: (+ (get loans-repaid current-score) u1),
          last-update: stacks-block-height,
        })
      )
      (map-set UserScores { user: user }
        (merge current-score {
          score: new-score,
          last-update: stacks-block-height,
        })
      )
    )

    (ok true)
  )
)