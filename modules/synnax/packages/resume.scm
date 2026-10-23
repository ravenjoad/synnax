(define-module (synnax packages resume)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages tex))

(define-public resume
  (let ((commit "e7690afee68b1f73c58c6094d1460e32e1d33050")
        (revision "13"))
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
          "1lw65asxd631hlx63zx0g730821fwv1ppv8lx68qyxxmakpk6a8g"))))
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
              texlive-ec
              texlive-amsfonts
              ;; Actual packages
              texlive-biber
              texlive-biblatex
              texlive-booktabs
              texlive-cm
              texlive-cm-super
              texlive-csquotes
              texlive-ctable
              texlive-datetime2 texlive-datetime2-english
              texlive-enumitem
              texlive-siunitx
              texlive-titlesec
              texlive-titling
              texlive-tocbibind
              texlive-transparent
              texlive-tools
              texlive-xcolor))))
     (arguments
      (list
       #:phases
       #~(modify-phases %standard-phases
           (delete 'configure)
           (delete 'check)
           (add-before 'build 'set-HOME
             (lambda _
               (setenv "HOME" (getcwd))))
           (replace 'install
             (lambda _ (copy-file "cv.pdf" #$output))))))
     (home-page "https://raven.hallsby.com")
     (synopsis "Personal Resume/CV built using LaTeX")
     (description "Karl Hallsby's personal resume/curriculum vitae built using LaTeX.")
     (license #f))))
