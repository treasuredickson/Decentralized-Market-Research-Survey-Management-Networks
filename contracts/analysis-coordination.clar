;; Analysis Coordination Contract
;; Coordinates survey analysis and manages results

;; Constants
(define-constant ERR_NOT_FOUND (err u500))
(define-constant ERR_UNAUTHORIZED (err u501))
(define-constant ERR_INVALID_STATUS (err u502))
(define-constant ERR_ANALYSIS_EXISTS (err u503))

;; Data Variables
(define-data-var next-analysis-id uint u1)

;; Data Maps
(define-map analyses
  { analysis-id: uint }
  {
    survey-id: uint,
    analyst: principal,
    analysis-type: (string-ascii 50),
    status: (string-ascii 20),
    start-block: uint,
    completion-block: (optional uint),
    result-hash: (optional (buff 32))
  }
)

(define-map analysis-results
  { analysis-id: uint }
  {
    summary: (string-ascii 500),
    key-findings: (string-ascii 1000),
    recommendations: (string-ascii 500),
    confidence-score: uint
  }
)

(define-map survey-analysis-status
  { survey-id: uint }
  {
    total-analyses: uint,
    completed-analyses: uint,
    in-progress-analyses: uint,
    overall-status: (string-ascii 20)
  }
)

;; Public Functions

;; Start analysis
(define-public (start-analysis
  (survey-id uint)
  (analysis-type (string-ascii 50))
)
  (let
    (
      (analysis-id (var-get next-analysis-id))
      (caller tx-sender)
    )
    (map-set analyses
      { analysis-id: analysis-id }
      {
        survey-id: survey-id,
        analyst: caller,
        analysis-type: analysis-type,
        status: "in-progress",
        start-block: block-height,
        completion-block: none,
        result-hash: none
      }
    )

    (var-set next-analysis-id (+ analysis-id u1))
    (update-survey-analysis-status survey-id "started")
    (ok analysis-id)
  )
)

;; Complete analysis
(define-public (complete-analysis
  (analysis-id uint)
  (summary (string-ascii 500))
  (key-findings (string-ascii 1000))
  (recommendations (string-ascii 500))
  (confidence-score uint)
  (result-hash (buff 32))
)
  (let
    (
      (analysis-data (unwrap! (map-get? analyses { analysis-id: analysis-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq (get analyst analysis-data) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status analysis-data) "in-progress") ERR_INVALID_STATUS)

    (map-set analyses
      { analysis-id: analysis-id }
      (merge analysis-data {
        status: "completed",
        completion-block: (some block-height),
        result-hash: (some result-hash)
      })
    )

    (map-set analysis-results
      { analysis-id: analysis-id }
      {
        summary: summary,
        key-findings: key-findings,
        recommendations: recommendations,
        confidence-score: confidence-score
      }
    )

    (update-survey-analysis-status (get survey-id analysis-data) "completed")
    (ok true)
  )
)

;; Update survey analysis status
(define-private (update-survey-analysis-status (survey-id uint) (action (string-ascii 20)))
  (let
    (
      (current-status (default-to
        { total-analyses: u0, completed-analyses: u0, in-progress-analyses: u0, overall-status: "pending" }
        (map-get? survey-analysis-status { survey-id: survey-id })
      ))
    )
    (if (is-eq action "started")
      (map-set survey-analysis-status
        { survey-id: survey-id }
        (merge current-status {
          total-analyses: (+ (get total-analyses current-status) u1),
          in-progress-analyses: (+ (get in-progress-analyses current-status) u1),
          overall-status: "in-progress"
        })
      )
      (map-set survey-analysis-status
        { survey-id: survey-id }
        (merge current-status {
          completed-analyses: (+ (get completed-analyses current-status) u1),
          in-progress-analyses: (- (get in-progress-analyses current-status) u1),
          overall-status: (if (is-eq (- (get in-progress-analyses current-status) u1) u0) "completed" "in-progress")
        })
      )
    )
    true
  )
)

;; Cancel analysis
(define-public (cancel-analysis (analysis-id uint))
  (let
    (
      (analysis-data (unwrap! (map-get? analyses { analysis-id: analysis-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq (get analyst analysis-data) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status analysis-data) "in-progress") ERR_INVALID_STATUS)

    (map-set analyses
      { analysis-id: analysis-id }
      (merge analysis-data { status: "cancelled" })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get analysis information
(define-read-only (get-analysis (analysis-id uint))
  (map-get? analyses { analysis-id: analysis-id })
)

;; Get analysis results
(define-read-only (get-analysis-results (analysis-id uint))
  (map-get? analysis-results { analysis-id: analysis-id })
)

;; Get survey analysis status
(define-read-only (get-survey-analysis-status (survey-id uint))
  (map-get? survey-analysis-status { survey-id: survey-id })
)

;; Check if survey analysis is complete
(define-read-only (is-survey-analysis-complete (survey-id uint))
  (match (map-get? survey-analysis-status { survey-id: survey-id })
    status-data (is-eq (get overall-status status-data) "completed")
    false
  )
)

;; Get next analysis ID
(define-read-only (get-next-analysis-id)
  (var-get next-analysis-id)
)
