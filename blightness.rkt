#lang racket

(require racket/gui/easy
         racket/gui/easy/operator)

(define @brightness-file (@ "/sys/class/backlight/intel_backlight/brightness"))

(define (load-brightness file)
  (call-with-input-file file
    (lambda (in)
      (string->number (read-line in)))))

(define @bright (@ (load-brightness (obs-peek @brightness-file))))

(define (sub500 val)
  (- val 500))

(define (add500 val)
  (+ val 500))

(define (update-brightness brightness action)
  (call-with-output-file (obs-peek @brightness-file)
    (lambda (out)
      (display (number->string brightness) out))
    #:exists 'truncate)
  (obs-update! @bright action))


(define (app)
  (window
   #:title "Blightness Adjustor Robot"
   (hpanel
    (button "-" (lambda () (update-brightness (- (obs-peek @bright) 500) sub500)))
    (text (@bright . ~> . number->string))
    (button "+" (lambda () (update-brightness (+ (obs-peek @bright) 500) add500))))))

(module+ main
  (render (app)))
