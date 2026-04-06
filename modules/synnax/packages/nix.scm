(define-module (synnax packages nix)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system guile)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages package-management)
  #:use-module ((guix licenses) #:prefix license:))

(define-public diff-drv
  (let ((commit "6dbfca28dc23a8aa2bc77e53b43f14cf444c42d8")
        (revision "0"))
    (package
      (name "diff-drv")
      (version (git-version "0.0.2" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
                (url "https://codeberg.org/theesm/diff-drv")
                (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1ahpcjpc9nqhg15vg27xvp75m2av4lp8n2s7l1yi3yzdq3jxrpgv"))))
      (build-system guile-build-system)
      (arguments
       (list
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'build 'install
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (bin (string-append out "/bin/")))
                  (mkdir-p bin)
                  (install-file "scripts/diff-drv" bin))))
            (add-after 'install 'wrap-program
              (lambda _
                (let* ((bin (string-append #$output "/bin/"))
                       (version (target-guile-effective-version))
                       (scm (string-append "/share/guile/site/" version))
                       (go (string-append "/lib/guile/" version "/site-ccache")))
                  (wrap-program (string-append bin "/diff-drv")
                    `("GUILE_LOAD_PATH" ":" prefix
                      (,(string-append #$output scm)))
                    `("GUILE_LOAD_COMPILED_PATH" ":" prefix
                      (,(string-append #$output go)))))))
                  )))
      (native-inputs (list guile-3.0))
      (inputs (list bash guix))
      (home-page "https://codeberg.org/theesm/diff-drv")
      (synopsis "Diff ATerm derivation (.drv) files")
      (description
       "Compare two ATerm derivations and print a cute and useful diff.")
      (license license:eupl1.2))))
