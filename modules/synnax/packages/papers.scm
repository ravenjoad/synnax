(define-module (synnax packages papers)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages tex))

(define acm-latex-packages
  (list
   ;; Fonts
   texlive-collection-fontsrecommended
   texlive-collection-fontsextra
   texlive-latex-fonts
   ;; Actual packages
   texlive-booktabs
   texlive-caption
   texlive-cmap
   texlive-comment
   texlive-enumitem
   texlive-environ
   texlive-etoolbox
   texlive-everyshi
   texlive-float
   texlive-hyperxmp
   texlive-ifmtarg
   texlive-microtype
   texlive-ncctools ; manyfoot.sty
   texlive-preprint ; balance.sty
   texlive-totpages
   texlive-upquote
   texlive-xcolor
   texlive-xkeyval
   texlive-xstring))

(define-public latte26
  (let ((commit "6c87713b21f173a3b36352ee019d5274b4ea2ffa")
        (revision "0"))
    (package
      (name "latte26")
      (version (git-version "0.0.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
                (url "https://github.com/ravenjoad/latte26-paper")
                ;; (url "git://raven.hallsby.com/papers/latte26.git")
                (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "0xks4bhw3dcibrbl8xx4bxg00bv0mhpyl443rcxq905nn985rmsw"))))
      (build-system gnu-build-system)
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
              (lambda _ (copy-file "paper.pdf" #$output))))))
      (native-inputs
       (list perl
             texlive-scheme-medium
             (texlive-local-tree
              (append
               (list
                texlive-cleveref
                texlive-enumitem
                texlive-listings
                texlive-multirow
                texlive-pgf ; tikz.sty
                texlive-siunitx)
               acm-latex-packages))))
      (home-page "https://raven.hallsby.com")
      (synopsis "LATTE '26 Paper \"Hardware Deserves a REPL\"")
      (description
       "")
      (license #f))))
