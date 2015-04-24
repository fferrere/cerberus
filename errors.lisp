;;;; Copyright (c) Frank James 2015 <frank.a.james@gmail.com>
;;;; This code is licensed under the MIT license.

(in-package #:cerberus)

(defvar *krb-errors*
  '((:none 0 "No error")
    (:NAME-EXP 1 "Client's entry in database has expired")
    (:SERVICE-EXP 2 "Server's entry in database has expired")
    (:BAD-PVNO 3 "Requested protocol version number not supported")
    (:C-OLD-MAST-KVNO 4 "Client's key encrypted in old master key")
    (:S-OLD-MAST-KVNO 5 "Server's key encrypted in old master key")
    (:C-PRINCIPAL-UNKNOWN 6 "Client not found in Kerberos database")
    (:S-PRINCIPAL-UNKNOWN 7 "Server not found in Kerberos database")
    (:PRINCIPAL-NOT-UNIQUE 8 "Multiple principal entries in database")
    (:NULL-KEY 9 "The client or server has a null key")
    (:CANNOT-POSTDATE 10 "Ticket not eligible for postdating")
    (:NEVER-VALID 11 "Requested starttime is later than end time")
    (:POLICY 12 "KDC policy rejects request")
    (:BADOPTION 13 "KDC cannot accommodate requested option")
    (:ETYPE-NOSUPP 14 "KDC has no support for encryption type")
    (:SUMTYPE-NOSUPP 15 "KDC has no support for checksum type")
    (:PADATA-TYPE-NOSUPP 16 "KDC has no support for padata type")
    (:TRTYPE-NOSUPP 17 "KDC has no support for transited type")
    (:CLIENT-REVOKED 18 "Clients credentials have been revoked")
    (:SERVICE-REVOKED 19 "Credentials for server have been revoked")
    (:TGT-REVOKED 20 "TGT has been revoked")
    (:CLIENT-NOTYET 21 "Client not yet valid; try again later")
    (:SERVICE-NOTYET 22 "Server not yet valid; try again later")
    (:KEY-EXPIRED 23 "Password has expired; change password to reset")
    (:PREAUTH-FAILED 24 "Pre-authentication information was invalid")
    (:PREAUTH-REQUIRED 25 "Additional pre-authentication required")
    (:SERVER-NOMATCH 26 "Requested server and ticket don't match")
    (:MUST-USE-USER2USER 27 "Server principal valid for user2user only")
    (:PATH-NOT-ACCEPTED 28 "KDC Policy rejects transited path")
    (:SVC_UNAVAILABLE 29 "A service is not available")
    (:BAD-INTEGRITY 31 "Integrity check on decrypted field failed")
    (:TKT-EXPIRED                32  "Ticket expired")
    (:TKT_NYV                    33  "Ticket not yet valid")
    (:REPEAT                     34  "Request is a replay")
    (:NOT_US                     35  "The ticket isn't for us")
    (:BADMATCH                   36  "Ticket and authenticator don't match")
    (:SKEW                       37  "Clock skew too great")
    (:BADADDR                    38  "Incorrect net address")
    (:BADVERSION                 39  "Protocol version mismatch")
    (:MSG_TYPE                   40  "Invalid msg type")
    (:MODIFIED                   41  "Message stream modified")
    (:BADORDER                   42  "Message out of order")
    (:BADKEYVER                  44  "Specified version of key is not available")
    (:NOKEY                      45  "Service key not available")
    (:MUT_FAIL                   46  "Mutual authentication failed")
    (:BADDIRECTION               47  "Incorrect message direction")
    (:METHOD                     48  "Alternative authentication method required")
    (:BADSEQ                     49  "Incorrect sequence number in message")
    (:INAPP-CKSUM                50  "Inappropriate type of checksum in message")
    (:PATH-NOT-ACCEPTED              51  "Policy rejects transited path")
    (:RESPONSE-TOO-BIG              52  "Response too big for UDP; retry with TCP")
    (:GENERIC                       60  "Generic error (description in e-text)")
    (:FIELD-TOOLONG                 61  "Field is too long for this implementation")
    (:CLIENT-NOT-TRUSTED          62  "Reserved for PKINIT")
    (:KDC-NOT-TRUSTED             63  "Reserved for PKINIT")
    (:INVALID-SIG                 64  "Reserved for PKINIT")
    (:KEY-TOO-WEAK                  65  "Reserved for PKINIT")
    (:CERTIFICATE-MISMATCH          66  "Reserved for PKINIT")
    (:NO-TGT                     67  "No TGT available to validate USER-TO-USER")
    (:WRONG-REALM                   68  "Reserved for future use")
    (:USER-TO-USER-REQUIRED      69  "Ticket must be for USER-TO-USER")
    (:CANT-VERIFY-CERTIFICATE       70  "Reserved for PKINIT")
    (:INVALID-CERTIFICATE           71  "Reserved for PKINIT")
    (:REVOKED-CERTIFICATE           72  "Reserved for PKINIT")
    (:REVOCATION-STATUS-UNKNOWN     73  "Reserved for PKINIT")
    (:REVOCATION-STATUS-UNAVAILABLE 74  "Reserved for PKINIT")
    (:CLIENT-NAME-MISMATCH          75  "Reserved for PKINIT")
    (:KDC-NAME-MISMATCH             76  "Reserved for PKINIT")))

(defun krb-code-error-stat (code)
  (first (find code *krb-errors* :key #'second :test #'=)))
(defun krb-error-stat-code (stat)
  (second (find stat *krb-errors* :key #'first)))

(defxtype krb-error-code ()
  ((stream)
   (let ((code (read-xtype 'asn1-integer stream)))
     (krb-code-error-stat code)))
  ((stream stat)
   (write-xtype 'asn1-integer 
		stream 
		(krb-error-stat-code stat))))

;; general error
(define-condition krb-error-t (error)
  ((err :initarg :err :initform nil :reader krb-error-err))
  (:report (lambda (condition stream)
	     (let ((err (krb-error-err condition)))
	       (format stream "KRB-ERROR ~A: ~A~%~S" 
		       (krb-error-error-code err)
		       (third (assoc (krb-error-error-code err) *krb-errors*))
		       (when (krb-error-edata err) 			   
			 (krb-error-edata err)))))))

;; would be nice to map from a krb-error structure and generate a krb-error-t 
(defun krb-error (err)
  (declare (type krb-error err))
  (error 'krb-error-t :err err))


(define-condition checksum-error (error)
  ()
  (:report (lambda (c stream)
	     (declare (ignore c))
	     (format stream "CHECKSUM-ERROR: Invalid checksum"))))

