#lang racket

(require "common.rkt")
(require "smt.rkt")
(require "dom.rkt")
(require "css-properties.rkt")

(provide css-declarations css-functions
         css-properties css-property-pairs css-defaults
         css-shorthand-properties css-type)

(define css-declarations
  `((declare-datatypes () (,@(for/list ([(type decl) (in-css-types)]) (cons type decl))))

    (declare-datatypes ()
      ((Selector sel/all (sel/tag (sel.tag TagNames)) (sel/id (sel.id Id)))
       (ImportanceOrigin UserAgent UserNormal AuthorNormal AuthorImportant UserImportant)
       (CascadeScore (cascadeScore (precedence ImportanceOrigin) (scoreIsFromStyle Bool)
                                   (idNum Int) (classNum Int) (elementNum Int)
                                   (positionNum Int)) useDefault)
       (Style (style ,@(for/reap [field] ([(prop type default) (in-css-properties)])
                                 (field `(,(sformat "style.~a" prop) ,type))
                                 (field `(,(sformat "style.~a$" prop) CascadeScore)))))
       (Rule (rule (selector Selector) (index Int) (origin ImportanceOrigin)
                   (score CascadeScore) (isFromStyle Bool)
                   ,@(for/reap [field] ([(prop type default) (in-css-properties)])
                               (field `(,(sformat "rule.~a" prop) ,type))
                               (field `(,(sformat "rule.~a?" prop) Bool)))))))

    (define-const width/0% Width (width/px 0))
    (define-const height/0% Height (height/px 0))
    (define-const margin/0% Margin (margin/px 0))
    (define-const padding/0% Padding (padding/px 0))
    (define-const border/0% Border (border/px 0))
    ;; Firefox's values
    (define-const border/thin Border (border/px 1))
    (define-const border/medium Border (border/px 3))
    (define-const border/thick Border (border/px 5))
    (define-const text-align/start Text-Align text-align/left)
    (define-const text-align/end Text-Align text-align/right)))

(define css-functions
  `((define-fun selector-applies? ((sel Selector) (elt Element)) Bool
      ,(smt-cond
        [(is-sel/all sel) true]
        [(is-sel/tag sel) (= (sel.tag sel) (tagname elt))]
        [(is-sel/id sel) (= (sel.id sel) (idname elt))]
        [else false]))

    (define-fun compute-score ((rule Rule)) CascadeScore
      ,(smt-cond
        [(is-sel/all (selector rule)) (cascadeScore (origin rule) (isFromStyle rule) 0 0 0 (index rule))]
        [(is-sel/tag (selector rule)) (cascadeScore (origin rule) (isFromStyle rule) 0 0 1 (index rule))]
        [(is-sel/id  (selector rule)) (cascadeScore (origin rule) (isFromStyle rule) 1 0 0 (index rule))]
        [else (cascadeScore AuthorNormal false 0 0 0 0)]))

    (define-fun importanceOrigin-score ((io ImportanceOrigin)) Int
      ,(smt-cond
        [(is-UserAgent io)       0]
        [(is-UserNormal io)      1]
        [(is-AuthorNormal io)    2]
        [(is-AuthorImportant io) 3]
        [else                    4]))

    (define-fun score-ge ((a CascadeScore) (b CascadeScore)) Bool
      ,(smt-cond
        [(is-useDefault b) true]
        [(is-useDefault a) false]
        [(> (importanceOrigin-score (precedence a)) (importanceOrigin-score (precedence b))) true]
        [(< (importanceOrigin-score (precedence a)) (importanceOrigin-score (precedence b))) false]
        [(and (scoreIsFromStyle a) (not (scoreIsFromStyle b))) true]
        [(and (not (scoreIsFromStyle a)) (scoreIsFromStyle b)) false]
        [(> (idNum a) (idNum b)) true]
        [(< (idNum a) (idNum b)) false]
        [(> (classNum a) (classNum b)) true]
        [(< (classNum a) (classNum b)) false]
        [(> (elementNum a) (elementNum b)) true]
        [(< (elementNum a) (elementNum b)) false]
        [(> (positionNum a) (positionNum b)) true]
        [(< (positionNum a) (positionNum b)) false]
        [else true]))

    (define-fun is-a-rule ((r Rule) (o ImportanceOrigin) (i Int) (ifs Bool)) Bool
      (and
       (= (origin r) o)
       (= (index r) i)
       (= (isFromStyle r) ifs)
       (=> (is-sel/id (selector r)) (not (is-no-id (sel.id (selector r)))))
       (=> (is-sel/tag (selector r)) (not (is-no-tag (sel.tag (selector r)))))))))

(define css-properties
  (for/list ([(type decl) (in-css-types)])
    (cons type
          (for/list ([(prop ptype default) (in-css-properties)] #:when (eq? type ptype))
            prop))))

(define css-types
  (for/hash ([(prop type default) (in-css-properties)])
    (values prop type)))

(define (css-type prop)
  (hash-ref css-types prop))

(define css-defaults
  (for/hash ([(prop name default) (in-css-properties)])
    (values prop default)))

(define css-property-pairs
  (for*/list ([type css-properties] [prop (cdr type)])
    (cons prop (car type))))

(define css-shorthand-properties
  '((margin margin-top margin-right margin-bottom margin-left)
    (padding padding-top padding-right padding-bottom padding-left)
    (border-width border-top-width border-right-width border-bottom-width border-left-width)))