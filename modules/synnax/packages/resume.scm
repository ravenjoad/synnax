(define-module (synnax packages resume)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages tex))

(define-public resume
  (let ((commit "68f16f7aadf5499feac88ba31d313970861ac8fd")
        (revision "16"))
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
          "1sjxf796q6pasc78m9irn4m95c935d2vszly0syfppdi7kzzwyg4"))))
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
