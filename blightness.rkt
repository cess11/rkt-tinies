#lang racket/base

(require racket/gui/easy
         racket/gui/easy/operator
         racket/match)

; configure by reading the .screenlayout directory
(define layouts (in-directory (build-path (find-system-path 'home-dir) (string->path ".screenlayout"))))

; configure screen brightness file, this one works with my toshiba laptop
(define @brightness-file (@ "/sys/class/backlight/intel_backlight/brightness"))

; read and return first line from screen brightness file,
; converted from string to number
(define (load-brightness file)
  (call-with-input-file file
    (lambda (in)
      (string->number (read-line in)))))

; observable holding the current screen brightness
(define @bright (@ (load-brightness (obs-peek @brightness-file))))

; write to the screen brightness file, takes a
; string representing a number, e.g. "1500"
(define (write-brightness numstring)
  (call-with-output-file (obs-peek @brightness-file)
    (lambda (out)
      (display numstring out))
    #:exists 'truncate))

; subtract 500 from val if bigger than 550
; at 0 screen is black, hence the +50
(define (sub500 val)
  (if (> val 550)
      (- val 500)
      500))

; add 500 to val if less than 4000
(define (add500 val)
  (if (< val 4000)
      (+ val 500)
      4000))

; update @bright and write to the screen brightness file,
; takes a function that works with obs-update!
(define (update-brightness! action)
  (obs-update! @bright action)
  (write-brightness (number->string (obs-peek @bright))))

; write arbitrary value to screen brightness file
(define (set-brightness! value)
  (write-brightness (number->string value)))

(define (app)
  (window
   #:title "Blightness Adjustor Robot"
   (vpanel
    (hpanel
     (button "-" (lambda () (update-brightness! sub500)))
     (button "+" (lambda () (update-brightness! add500)))
     (button "500" (lambda () (update-brightness! (lambda (ev) 500))))
     (button "1500" (lambda () (update-brightness! (lambda (ev) 1500))))
     (button "3500" (lambda () (update-brightness! (lambda (ev) 3500)))))
    (vpanel
     (slider
      #:min-value 0
      #:max-value 100000
      @bright (lambda (val) (and (set-brightness! val) val)) ; (λ:= @bright)
      #:style '(horizontal plain)))
    (vpanel
     (choice
      '("Val 1" "Val 2")
      (lambda (val) (print val)))))))

(module+ main
  (render (app)))
