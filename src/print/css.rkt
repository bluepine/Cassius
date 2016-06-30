#lang racket
(require "../common.rkt")
(provide stylesheet->string header->string value->string selector->string rule->string)

(define (stylesheet->string sheet)
  (format "/* Generated code below */\n\n~a\n"
          (string-join (map rule->string sheet) "\n\n")))

(define (header->string header)
  (format "/* Hand-written header */\n\n~a\n\n" header))

(define (rule->string rule)
  (define selector (car rule))
  (match-define (list (list properties valuess ...) ...) (filter list? (cdr rule)))
  (with-output-to-string
    (λ ()
      (when (member ':style rule) (printf "[inline style] "))
      (printf "~a {\n" (selector->string selector))
      (for ([property properties] [values valuess])
        (printf "  ~a:" property)
        (for ([value values])
          (match value
            [`(,(or 'px '% 'em 'ex) 0)
             (printf " 0")]
            [`(bad ,val)
             (printf " \33[1;31m~a\33[0m" (value->string val))]
            [_
             (printf " ~a" (value->string value))]))
        (printf ";\n"))
      (printf "}"))))

(define/match (value->string value)
  [(`(,_ 0.0)) "0"]
  [(`(px ,px)) (format "~apx" px)]
  [(`(% ,pct)) (format "~a%" pct)]
  [((? symbol?)) (~a value)])

(define (selector->string selector)
  (match selector
    [`(selector ,name) "?"]
    [`(match ,elts ...) (string-join (map ~a elts) ", ")]
    [`(id ,id) (format "#~a" id)]
    [`(class ,cls) (format ".~a" cls)]
    [`(tag ,tag) (~a (slower tag))]
    ['* "*"]
    [(list (? string? sel) sel*) sel]
    [`(or ,sels ...) (string-join (map selector->string sels) ", ")]
    [`(desc ,sels ...) (string-join (map selector->string sels) " ")]
    [`(child ,sels ...) (string-join (map selector->string sels) " > ")]
    [`(and ,sels ...) (string-join (map selector->string sels) "")]))
