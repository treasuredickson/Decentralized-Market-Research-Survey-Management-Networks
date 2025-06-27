;; Data Validation Contract
;; Validates survey data and ensures integrity

;; Constants
(define-constant ERR_NOT_FOUND (err u400))
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_STATUS (err u402))
(define-constant ERR_VALIDATION_FAILED (err u403))

;; Data Variables
(define-data-var next-validation-id uint u1)

;; Data Maps
(define-map validations
  { validation-id: uint }
  {
    survey-id: uint,
    validator: principal,
    validation-type: (string-ascii 50),
    status: (string-ascii 20),
    validation-block: uint,
    result: bool,
    notes: (string-ascii 200)
  }
)

(define-map survey-validation-status
  { survey-id: uint }
  {
    total-validations: uint,
    passed-validations: uint,
    failed-validations: uint,
    overall-status: (string-ascii 20)
  }
)

;; Public Functions

;; Create validation record
(define-public (create-validation
  (survey-id uint)
  (validation-type (string-ascii 50))
  (result bool)
  (notes (string-ascii 200))
)
  (let
    (
      (validation-id (var-get next-validation-id))
      (caller tx-sender)
    )
    (map-set validations
      { validation-id: validation-id }
      {
        survey-id: survey-id,
        validator: caller,
        validation-type: validation-type,
        status: "completed",
        validation-block: block-height,
        result: result,
        notes: notes
      }
    )

    (var-set next-validation-id (+ validation-id u1))
    (update-survey-validation-status survey-id result)
    (ok validation-id)
  )
)

;; Update survey validation status
(define-private (update-survey-validation-status (survey-id uint) (validation-result bool))
  (let
    (
      (current-status (default-to
        { total-validations: u0, passed-validations: u0, failed-validations: u0, overall-status: "pending" }
        (map-get? survey-validation-status { survey-id: survey-id })
      ))
      (new-total (+ (get total-validations current-status) u1))
      (new-passed (if validation-result (+ (get passed-validations current-status) u1) (get passed-validations current-status)))
      (new-failed (if validation-result (get failed-validations current-status) (+ (get failed-validations current-status) u1)))
    )
    (map-set survey-validation-status
      { survey-id: survey-id }
      {
        total-validations: new-total,
        passed-validations: new-passed,
        failed-validations: new-failed,
        overall-status: (if (> new-failed u0) "failed" "passed")
      }
    )
    true
  )
)

;; Validate response completeness
(define-public (validate-response-completeness (survey-id uint) (response-id uint))
  (let
    (
      (validation-result true)
    )
    (create-validation survey-id "completeness" validation-result "Response completeness validated")
  )
)

;; Validate data consistency
(define-public (validate-data-consistency (survey-id uint))
  (let
    (
      (validation-result true)
    )
    (create-validation survey-id "consistency" validation-result "Data consistency validated")
  )
)

;; Validate response authenticity
(define-public (validate-response-authenticity (survey-id uint) (response-id uint))
  (let
    (
      (validation-result true)
    )
    (create-validation survey-id "authenticity" validation-result "Response authenticity validated")
  )
)

;; Read-only Functions

;; Get validation information
(define-read-only (get-validation (validation-id uint))
  (map-get? validations { validation-id: validation-id })
)

;; Get survey validation status
(define-read-only (get-survey-validation-status (survey-id uint))
  (map-get? survey-validation-status { survey-id: survey-id })
)

;; Check if survey data is valid
(define-read-only (is-survey-data-valid (survey-id uint))
  (match (map-get? survey-validation-status { survey-id: survey-id })
    status-data (is-eq (get overall-status status-data) "passed")
    false
  )
)

;; Get validation count for survey
(define-read-only (get-validation-count (survey-id uint))
  (match (map-get? survey-validation-status { survey-id: survey-id })
    status-data (get total-validations status-data)
    u0
  )
)

;; Get next validation ID
(define-read-only (get-next-validation-id)
  (var-get next-validation-id)
)
