;; Waste Tracking Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_INVALID_AMOUNT (err u400))

;; Data Maps
(define-map waste-records
  { user: principal }
  {
    total-waste: uint,
    last-update: uint
  }
)

;; Public Functions
(define-public (record-waste (amount uint))
  (let
    ((current-record (default-to { total-waste: u0, last-update: u0 } (map-get? waste-records { user: tx-sender }))))
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (ok (map-set waste-records
      { user: tx-sender }
      {
        total-waste: (+ (get total-waste current-record) amount),
        last-update: block-height
      }
    ))
  )
)

(define-public (reduce-waste (amount uint))
  (let
    ((current-record (default-to { total-waste: u0, last-update: u0 } (map-get? waste-records { user: tx-sender }))))
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (>= (get total-waste current-record) amount) ERR_INVALID_AMOUNT)
    (ok (map-set waste-records
      { user: tx-sender }
      {
        total-waste: (- (get total-waste current-record) amount),
        last-update: block-height
      }
    ))
  )
)

;; Read-only Functions
(define-read-only (get-waste-record (user principal))
  (default-to { total-waste: u0, last-update: u0 } (map-get? waste-records { user: user }))
)

