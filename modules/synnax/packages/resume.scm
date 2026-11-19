(define-module (synnax packages resume)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages tex))

(define-public resume
  (let ((commit "c62c7ad05ed6d2d0af5266233bcf014bae332787")
        (revision "15"))
    (package
     (name "raven-resume")
     (version (git-version "0.0.0" revision commit))
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "git://raven.hallsby.com/resume.git")
               (commit commit)))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "0ra4m5df49zll0fcrxpxcmqjv3jsjzw6jb369jpjk2rf8fxfbmz6"))))
     (build-system gnu-build-system)
     (native-inputs
      (list perl
            texlive-scheme-medium
            (texlive-local-tree
             (list
              ;; Fonts
              texlive-collection-fontsrecommended
              texlive-collection-fontsextra
              texlive-latex-fonts
              texlive-amsfonts
              ;; Actual packages
              texlive-biber
              texlive-biblatex
              texlive-changepage
              texlive-csquotes
              texlive-datetime2 texlive-datetime2-english
              texlive-enumitem
              texlive-siunitx
              texlive-titlesec
              texlive-tocbibind
              texlive-upquote
              texlive-xcolor))))
     (arguments
      (list
       #:phases
       #~(modify-phases %standard-phases
           (delete 'configure)
           (delete 'check)
           (replace 'install
             (lambda _ (copy-file "cv.pdf" #$output))))))
     (home-page "https://raven.hallsby.com")
     (synopsis "Personal Resume/CV built using LaTeX")
     (description "Karl Hallsby's personal resume/curriculum vitae built using LaTeX.")
     (license #f))))
