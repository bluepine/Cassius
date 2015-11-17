#lang racket

(require racket/path)
(require racket/set)
(require racket/engine)
(require unstable/sequence)
(require racket/cmdline)
(require "common.rkt")
(require "run.rkt")

(define (run-files files #:debug [debug '()] #:output [outname #f] #:fast [fast? #f])
  (define out (if outname (open-output-file outname #:exists 'replace) (current-output-port)))
  (parameterize ([current-output-port out])
    (printf "<!doctype html>\n<html lang='en_US'>\n<meta charset='utf8' />\n")
    (printf "<link rel='stylesheet' href='report.css' />\n")
    (printf "<title>Cassius results for ~a</title>\n" (string-join files ", "))
    (printf "<body>\n")
    (define results
      (for/reap [sow] ([fname files])
        (printf "<h2>~a</h2>\n" fname)
        (printf "<table>\n")
        (define probs (call-with-input-file fname parse-file))
        (for ([(pname prob) (in-pairs (sort (hash->list probs) symbol<? #:key car))]
              #:when (or (not fast?) (subset? (problem-features prob) supported-features)))
          (eprintf "~a\t~a\t" fname pname)
          (define-values (ubase uname udir?) (split-path (problem-url prob)))
          (printf "<tr><td>~a</td><td>~a</td><td>~a</td><td class='out'><pre>" pname uname (problem-desc prob))
          (define status
            (parameterize ([current-error-port (current-output-port)])
              
              (define eng (engine (λ (_) (run-file fname (~a pname) #:debug debug))))
              (define timeout? (not (engine-run 120000 eng))) ; Run for 2m max
              (engine-kill eng)
              (cond
               [timeout?
                (printf "[10.00s] Timed out\n")
                'timeout]
               [(engine-result eng) 'success]
               [(> (length (set-subtract (problem-features prob) supported-features)) 0) 'unsupported]
               [else 'fail])))

          (sow (list status (set-subtract (problem-features prob) supported-features)))
          (eprintf "~a\n" status)

          (printf "</pre></td><td class='~a'>~a</td></tr>\n" status
                  (match status ['success "✔"] ['fail "✘"] ['timeout "🕡"]
                    ['unsupported
                     (define probfeats (set-subtract (problem-features prob) supported-features))
                     (format "<span title='~a'>☹</span>" (string-join (map ~a probfeats) ", "))])))
        (printf "</table>\n")))
    (printf "<h2>Status totals</h2>\n")
    (printf "<dl>\n")
    (for ([status '(success fail timeout unsupported)])
      (printf "<dt>~a</dt><dd>~a</dd>\n" status (count (λ (x) (equal? (first x) status)) results)))
    (printf "</dl>\n")
    (printf "<h2>Feature totals</h2>\n")
    (printf "<dl>\n")
    (for ([feature (remove-duplicates (append-map second results))])
      (printf "<dt>~a</dt><dd>~a</dd>\n" feature (count (λ (x) (member feature (second x))) results)))
    (printf "</dl>\n")
    (printf "</body>\n")
    (printf "</html>\n"))
  (when outname (close-output-port out)))

(module+ main
  (define debug '())
  (define out-file #f)
  (define fast #f)

  (command-line
   #:program "cassius"
   #:multi
   [("-d" "--debug") type "Turn on debug information"
    (set! debug (cons (string->symbol type) debug))]
   [("-f" "--feature") name "Toggle a feature; use -name and +name to unset or set"
    (cond
      [(equal? (substring name 0 1) "+") (flags (cons (string->symbol (substring name 1)) (flags)))]
      [(equal? (substring name 0 1) "-") (flags (remove (string->symbol (substring name 1)) (flags)))]
      [else
       (define name* (string->symbol name))
       (flags (if (memq name* (flags)) (remove name* (flags)) (cons name* (flags))))])]
   #:once-each
   [("-o" "--output") fname "File name for final CSS file"
    (set! out-file fname)]
   [("--fast") "Skip tests with unsupported features"
    (set! fast #t)]
   #:args fnames
   (run-files fnames #:debug debug #:output out-file #:fast fast)))
