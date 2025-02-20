;; Recycling Verification Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_INVALID_AMOUNT (err u400))

;; Data Maps
(define-map recycling-records
  { user: principal }
  {
    total-recycled: uint,
    last-verification: uint
  }
)

(define-map verifiers { address: principal } { active: bool })

;; Public Functions
(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (map-set verifiers { address: verifier } { active: true }))
  )
)

(define-public (remove-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (map-set verifiers { address: verifier } { active: false }))
  )
)

(define-public (verify-recycling (user principal) (amount uint))
  (let
    ((current-record (default-to { total-recycled: u0, last-verification: u0 } (map-get? recycling-records { user: user })))
     (is-verifier (default-to { active: false } (map-get? verifiers { address: tx-sender }))))
    (asserts! (get active is-verifier) ERR_NOT_AUTHORIZED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (ok (map-set recycling-records
      { user: user }
      {
        total-recycled: (+ (get total-recycled current-record) amount),
        last-verification: block-height
      }
    ))
  )
)

;; Read-only Functions
(define-read-only (get-recycling-record (user principal))
  (default-to { total-recycled: u0, last-verification: u0 } (map-get? recycling-records { user: user }))
)

(define-read-only (is-active-verifier (address principal))
  (get active (default-to { active: false } (map-get? verifiers { address: address })))
)

