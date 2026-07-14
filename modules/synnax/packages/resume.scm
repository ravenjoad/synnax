(define-module (synnax packages resume)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages tex))

(define-public resume
  (let ((commit "04890519a825209e5c85dfaa4fc3a4549fe38cb8")
        (revision "10"))
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
          "03pbsgrn6cj77mz3qwqwv9dnjpv8lb2h194ra81r2cr67p4485vd"))))
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
             (lambda _ (copy-file "Hallsby_Karl.pdf" #$output))))))
     (home-page "https://raven.hallsby.com")
     (synopsis "Personal Resume/CV built using LaTeX")
     (description "Karl Hallsby's personal resume/curriculum vitae built using LaTeX.")
     (license #f))))
