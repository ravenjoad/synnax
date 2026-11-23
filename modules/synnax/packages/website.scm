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
  (let ((commit "a430897aa38cd23f24c765553183312d12c99fe6")
        (revision "37"))
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
          "1nnfgs287if1b0rppsv0knljkqsbagimzb6bzs3zzj7q0n8r2wmc"))))
     (build-system gnu-build-system)
     (arguments
      (list
       ;; #:install-plan
       ;; #~'((#$resume (string-append #$output "/assets/pdf/cv.pdf")))
       #:phases
       #~(modify-phases %standard-phases
           (delete 'configure)
           (delete 'check)
           ;; (replace 'install (@@ (gnu build-system copy) install)))))
           (replace 'install
             (lambda _
               (copy-recursively "site" #$output)
               (mkdir-p (string-append #$output "/assets/pdf/resume"))
               (symlink #$resume (string-append #$output "/assets/pdf/cv.pdf"))
               (symlink #$latte26 (string-append #$output "/assets/pdf/latte26.pdf"))
               (symlink #$(file-append hpdc26 "/hpdc26-summary.pdf")
                        (string-append #$output "/assets/pdf/hpdc26-summary.pdf"))
               (symlink #$(file-append hpdc26 "/hpdc26-poster.pdf")
                        (string-append #$output "/assets/pdf/hpdc26-poster.pdf")))))))
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
     (description "Raven Hallsby's personal website built using the Haunt
static site generator.")
     (license #f))))
