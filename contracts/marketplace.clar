;; Marketplace Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_INVALID_LISTING (err u402))
(define-constant ERR_INVALID_AMOUNT (err u403))

;; Data Maps
(define-map listings
  { listing-id: uint }
  {
    seller: principal,
    material: (string-ascii 50),
    amount: uint,
    price: uint,
    active: bool
  }
)

(define-data-var listing-nonce uint u0)

;; Public Functions
(define-public (create-listing (material (string-ascii 50)) (amount uint) (price uint))
  (let
    ((new-listing-id (+ (var-get listing-nonce) u1)))
    (asserts! (and (> amount u0) (> price u0)) ERR_INVALID_AMOUNT)
    (map-set listings
      { listing-id: new-listing-id }
      {
        seller: tx-sender,
        material: material,
        amount: amount,
        price: price,
        active: true
      }
    )
    (var-set listing-nonce new-listing-id)
    (ok new-listing-id)
  )
)

(define-public (cancel-listing (listing-id uint))
  (let
    ((listing (unwrap! (map-get? listings { listing-id: listing-id }) ERR_INVALID_LISTING)))
    (asserts! (is-eq (get seller listing) tx-sender) ERR_NOT_AUTHORIZED)
    (ok (map-set listings
      { listing-id: listing-id }
      (merge listing { active: false })
    ))
  )
)

(define-public (purchase-listing (listing-id uint))
  (let
    ((listing (unwrap! (map-get? listings { listing-id: listing-id }) ERR_INVALID_LISTING)))
    (asserts! (get active listing) ERR_INVALID_LISTING)
    (asserts! (not (is-eq (get seller listing) tx-sender)) ERR_NOT_AUTHORIZED)
    ;; Note: In a real-world scenario, you would handle the token transfer here
    ;; For simplicity, we're just marking the listing as inactive
    (ok (map-set listings
      { listing-id: listing-id }
      (merge listing { active: false })
    ))
  )
)

;; Read-only Functions
(define-read-only (get-listing (listing-id uint))
  (map-get? listings { listing-id: listing-id })
)

(define-read-only (get-total-listings)
  (ok (var-get listing-nonce))
)

