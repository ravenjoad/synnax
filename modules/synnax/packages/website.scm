(define-module (synnax packages website)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (synnax packages papers)
  #:use-module (synnax packages resume))

(define-public personal-website
  (let ((commit "0db2b2a2348a2c5344dc498f820bd4e3a8e3353a")
        (revision "29"))
    (package
     (name "personal-website")
     (version (git-version "0.0.0" revision commit))
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "git://raven.hallsby.com/website.git")
               (commit commit)))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "1hrsmgxmaqljln52nqg7iyg9rlby3hky8r3klzbv574qrz183q4a"))))
     (build-system gnu-build-system)
     (arguments
      (list
       ;; #:install-plan
       ;; #~'((#$resume (string-append #$output "/assets/pdf/resume/Hallsby_Karl.pdf")))
       #:phases
       #~(modify-phases %standard-phases
           (delete 'configure)
           (delete 'check)
           ;; (replace 'install (@@ (gnu build-system copy) install)))))
           (replace 'install
             (lambda _
               (copy-recursively "site" #$output)
               (mkdir-p (string-append #$output "/assets/pdf/resume"))
               (symlink #$resume (string-append #$output "/assets/pdf/resume/Hallsby_Karl.pdf"))
               (symlink #$latte26 (string-append #$output "/assets/pdf/latte26.pdf")))))))
     (native-inputs
      `(("guile" ,guile-3.0)
        ("guile-reader" ,guile-reader)
        ("guile-commonmark" ,guile-commonmark)
        ("guile-syntax-highlight" ,guile-syntax-highlight)
        ;; Emacs is needed to build the built-in Modus-themes CSS
        ("emacs" ,emacs-minimal)))
     (inputs
      `(("haunt" ,haunt)))
     (home-page "https://raven.hallsby.com")
     (synopsis "Personal website built using Haunt static site generator")
     (description "Karl Hallsby's personal website built using the Haunt static site
generator.")
     (license #f))))
