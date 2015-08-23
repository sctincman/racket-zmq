#lang racket/base

(require rackunit
	 rackunit/text-ui
	 "main.rkt")

(define zmq-tests
  (test-suite
   "Tests for ZMQ binding"
   (test-case
    "Test PUB/SUB socket creation/binding"
    (check-not-exn (lambda () (socket 'pub #:bind '("ipc://*"))) "Test PUB binding to IPC transport")
    (check-not-exn (lambda () (socket 'pub #:bind '("tcp://127.0.0.1:*"))) "Test PUB binding to local TCP transport")
    (check-not-exn (lambda () (socket 'pub #:bind '("inproc://pubtest1"))) "Test PUB binding to in-process transport")

    (check-not-exn (lambda ()
		     (let* ([pub (socket 'pub #:bind '("ipc://*"))]
			    [addr (socket-last-endpoint pub)])
		       (socket 'sub #:connect (list addr))))
		   "Test SUB connecting to IPC transport")
    (check-not-exn (lambda ()
		     (let* ([pub (socket 'pub #:bind '("tcp://127.0.0.1:*"))]
			    [addr (socket-last-endpoint pub)])
		       (socket 'sub #:connect (list addr))))
		   "Test SUB connecting to TCP transport")
    (check-not-exn (lambda ()
		     (let* ([pub (socket 'pub #:bind '("inproc://subtest1"))]
			    [addr (socket-last-endpoint pub)])
		       (socket 'sub #:connect (list addr))))
		   "Test SUB connecting to in-process transport"))

   (test-case
    "Test PUB/SUB socket sending/receiving"
    (let* ([pub (socket 'pub #:bind '("ipc://*"))]
	   [addr (socket-last-endpoint pub)]
	   [message (string->bytes/utf-8 "Hello IPC World")]
	   [sub (socket 'sub #:subscribe '("") #:connect (list addr))])
      (socket-send pub message)
      (check-equal? message
		    (car (socket-receive sub))
		    "Test Pub sending over IPC transport"))
    (let* ([pub (socket 'pub #:bind '("tcp://127.0.0.1:*"))]
	   [addr (socket-last-endpoint pub)]
	   [message (string->bytes/utf-8 "Hello TCP World")]
	   [sub (socket 'sub #:subscribe '("") #:connect (list addr))])
      (socket-send pub message)
      (check-equal? message
		    (car (socket-receive sub))
		    "Test Pub sending over TCP transport"))
    (let* ([pub (socket 'pub #:bind '("inproc://pubsubtest"))]
	   [addr (socket-last-endpoint pub)]
	   [message (string->bytes/utf-8 "Hello INPROC World")]
	   [sub (socket 'sub #:subscribe '("") #:connect (list addr))])
      (socket-send pub message)
      (check-equal? message
		    (car (socket-receive sub))
		    "Test Pub sending over inproc transport")))
   ))

(run-tests zmq-tests 'normal)
