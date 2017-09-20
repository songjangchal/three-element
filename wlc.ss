;;; wlc.ss
;;;


;;; wlc binding

(define WLC_BIT_ACTIVATED  16)

(load-shared-object "libwlc.so")

(define wlc-init
  (foreign-procedure "wlc_init" ()
    boolean))
(define wlc-run
  (foreign-procedure "wlc_run" ()
    void))

(define-ftype wlc-handle uptr)

(define-ftype view-created-cb-t (function (wlc-handle) boolean))
(define-ftype view-focus-cb-t (function (wlc-handle boolean) void))

;; (define wlc-set-view-created-cb
;;   (foreign-procedure "wlc_set_view_created_cb" ((* view-created-cb-t))
;;     void))

(define wlc-set-view-created-cb
  (foreign-procedure "wlc_set_view_created_cb" (int)
    void))

(define wlc-set-view-focus-cb
  ;;  (foreign-procedure "wlc_set_view_focus_cb" ((* view-focus-cb-t) boolean)
    (foreign-procedure "wlc_set_view_focus_cb" (int)
    void))

(define wlc-view-set-mask
  (foreign-procedure "wlc_view_set_mask" (wlc-handle unsigned-32)
    void))

(define wlc-view-bring-to-front
  (foreign-procedure "wlc_view_bring_to_front" (wlc-handle)
    void))

(define wlc-view-focus
  (foreign-procedure "wlc_view_focus" (wlc-handle)
    void))

(define wlc-view-set-state
  (foreign-procedure "wlc_view_set_state" (wlc-handle unsigned-32 boolean)
    void))

(define wlc-output-get-mask
  (foreign-procedure "wlc_output_get_mask" (wlc-handle)
    unsigned-32))

(define wlc-view-get-output
  (foreign-procedure "wlc_view_get_output" (wlc-handle)
    wlc-handle))


(define wlc-callback-created
  (lambda (p)
    (let ([code (foreign-callable p (wlc-handle) boolean )])
      (lock-object code)
;;      (code))))
      (foreign-callable-entry-point code))))

(define view-created
  (wlc-callback-created
    (lambda (h)
      (wlc-view-set-mask h (wlc-output-get-mask (wlc-view-get-output h)))
      (wlc-view-bring-to-front h)
      (wlc-view-focus h)
      )))

(define wlc-callback-focus
  (lambda (p)
    (let ([code (foreign-callable p (wlc-handle boolean) void)])
      (lock-object code)
      (foreign-callable-entry-point code))))

(define view-focus
  (wlc-callback-focus
    (lambda (h focus)
            (wlc-view-set-state h WLC_BIT_ACTIVATED focus))))



(wlc-set-view-created-cb view-created)
(wlc-set-view-focus-cb view-focus)
(wlc-init)
(wlc-run)


