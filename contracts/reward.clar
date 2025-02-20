;; Reward Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_INSUFFICIENT_BALANCE (err u402))

;; Fungible Token Definition
(define-fungible-token eco-token u1000000000)

;; Data Maps
(define-map authorized-contracts { contract-address: principal } { authorized: bool })

;; Public Functions
(define-public (authorize-contract (contract-address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (map-set authorized-contracts { contract-address: contract-address } { authorized: true }))
  )
)

(define-public (revoke-contract-authorization (contract-address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (map-set authorized-contracts { contract-address: contract-address } { authorized: false }))
  )
)

(define-public (mint-tokens (recipient principal) (amount uint))
  (let
    ((is-authorized (default-to { authorized: false } (map-get? authorized-contracts { contract-address: tx-sender }))))
    (asserts! (get authorized is-authorized) ERR_NOT_AUTHORIZED)
    (ft-mint? eco-token amount recipient)
  )
)

(define-public (transfer-tokens (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_NOT_AUTHORIZED)
    (ft-transfer? eco-token amount sender recipient)
  )
)

;; Read-only Functions
(define-read-only (get-balance (user principal))
  (ft-get-balance eco-token user)
)

(define-read-only (is-contract-authorized (contract-address principal))
  (get authorized (default-to { authorized: false } (map-get? authorized-contracts { contract-address: contract-address })))
)

