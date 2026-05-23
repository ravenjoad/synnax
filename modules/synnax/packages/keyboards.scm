(define-module (synnax packages keyboards)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages avr-xyz)
  #:use-module (gnu packages cross-base)
  #:use-module (gnu packages embedded)
  #:use-module (gnu packages firmware)
  #:use-module (gnu packages flashing-tools)
  #:use-module (gnu packages python)
  #:use-module (ice-9 regex))


;;;
;;; Parts of (gnu packages firmware) that I copied to get QMK's source code and
;;; build my keyboard firmware by "overlaying" my configuration onto the
;;; upstream QMK repository.
;;;

(define (make-qmk-newlib-nano-arm-none-eabi)
  (let ((base (make-newlib-nano-arm-none-eabi)))
    (package
      (inherit base)
      (native-inputs
       (modify-inputs native-inputs
         (replace "xgcc" (make-gcc-arm-none-eabi-12.3.rel1)))))))

(define* (make-qmk-firmware-ravenjoad keyboard keymap
                                      #:key (description "")
                                      keymap-json
                                      keymap-source-directory
                                      keyboard-source-directory)
  (let ((base (make-qmk-firmware keyboard keymap
                                 #:description description
                                 #:keymap-json keymap-json
                                 #:keymap-source-directory keymap-source-directory
                                 #:keyboard-source-directory keyboard-source-directory)))
    (package
      (inherit base)
      (name (string-append "qmk-firmware-"
                           (regexp-substitute/global #f "[_/]" keyboard
                                                     'pre "-" 'post)
                           "-"
                           (string-replace-substring keymap "_" "-")))
      ;; Note: When updating this package, make sure to also update the commit
      ;; used for the LUFA submodule in the 'copy-lufa-source' phase below.
      (version "0.32.14")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/qmk/qmk_firmware")
                      (commit version)))
                (file-name (git-file-name "qmk-firmware" version))
                (sha256
                 (base32
                  "1rpj46q0q0w2j0r5d5h3446sq3dqiwnbifj4myb457qc52hj6lzw"))))
      (arguments
       (substitute-keyword-arguments arguments
         ((#:phases phases)
          #~(modify-phases #$phases
              (replace 'copy-lufa-source
                ;; QMK carries a custom fork of LUFA as a git submodule; make sure
                ;; the same commit is used (see:
                ;; https://github.com/qmk/qmk_firmware/tree/master/lib).
                (lambda _
                  (copy-recursively
                   #$(let ((commit "549b97320d515bfca2f95c145a67bd13be968faa"))
                       (origin
                         (inherit (package-source lufa))
                         (uri (git-reference
                               (url "https://github.com/qmk/lufa")
                               (commit commit)))
                         (file-name (git-file-name "lufa" commit))
                         (sha256
                          (base32
                           "1rmhm4rxvq8skxqn6vc4n4ly1ak6whj7c386zbsci4pxx548n9h4"))))
                   "lib/lufa")))
              (add-after 'unpack 'setenv
                (lambda _
                  ;; Because newlib-nano is also compiled without FPU.
                  (setenv "USE_FPU" "no")))
              (add-after 'unpack 'copy-chibios-source
                (lambda _
                  ;; Newest version.
                  (copy-recursively
                   #$(origin
                       (method git-fetch)
                       (uri (git-reference
                             (url "https://github.com/qmk/ChibiOS")
                             (commit "8bd61b804303f1614d574546c2dd735eeabb09f5")))
                                        ;(file-name (git-file-name name version))
                       (sha256
                        (base32
                         "1waixxdgr48385k1dkf6zpvngdpp78kagkvdpag9y9pg610gqzd2")))
                   "lib/chibios")))
              (add-after 'unpack 'copy-printf-source
                ;; Newest version.
                (lambda _
                  (copy-recursively
                   #$(origin
                       (method git-fetch)
                       (uri (git-reference
                             (url "https://github.com/qmk/printf.git")
                             (commit "c2e3b4e10d281e7f0f694d3ecbd9f320977288cc")))
                                        ;(file-name (git-file-name name version))
                       (sha256
                        (base32
                         "0r501hkk0idwfm6qs09g1wb808ga452gz39dw32x13rmg3a901s6")))
                   "lib/printf")))))))
      (native-inputs
       (modify-inputs native-inputs
         (prepend
          (package
            (inherit (make-qmk-newlib-nano-arm-none-eabi))
            (native-search-paths
             (list (search-path-specification
                    (variable "CROSS_C_INCLUDE_PATH")
                    (files '("arm-none-eabi/include")))
                   (search-path-specification
                    (variable "CROSS_CPLUS_INCLUDE_PATH")
                    (files '("arm-none-eabi/include"
                             "arm-none-eabi/include/c++"
                             "arm-none-eabi/include/c++/arm-none-eabi")))
                   (search-path-specification
                    (variable "CROSS_LIBRARY_PATH")
                    (files '("arm-none-eabi/lib"))))))
          (make-gcc-arm-none-eabi-12.3.rel1)
          (cross-binutils "arm-none-eabi")))))))


;;;
;;; My keyboard configurations as packages.
;;;

(define ravenjoad-keyboards-source
  (let ((name "ravenjoad-keyboards")
        (commit "111a0d1bbc44c906d0d5cab96dff0d04c58566ce")
        (revision "0"))
    (origin
      (method git-fetch)
      (uri (git-reference
             (url "git://raven.hallsby.com/keyboards.git")
             (commit commit)))
      (file-name
       (git-file-name name (git-version "1.0.0" revision commit)))
      (sha256
       (base32 "0fd1irvycvywdb80g7znw774bxl5a7q49pskglf9ia0hyyjir487")))))

(define-public qmk-firmware-moonlander-ravenjoad
  (make-qmk-firmware-ravenjoad
   "zsa/moonlander" "ravenjoad"
   #:description
   "This package provides Ravenjoad's custom firmware for the ZSA Moonlander
Mk. I.  The keymap is designed for operating inside of Emacs all day while also
being reasonably easy for other people to use.  Each layer is given a custom
background color which is used to highlight which layer the user is currently
on."
   #:keymap-source-directory
   (file-append ravenjoad-keyboards-source
                "/keyboards/zsa/moonlander/keymaps/ravenjoad")))

(define-public qmk-firmware-preonic-ravenjoad
  (make-qmk-firmware-ravenjoad
   "preonic/rev3_drop" "ravenjoad"
   #:description
   "This package provides Ravenjoad's custom firmware for the Preonic.  The
keymap is desigtned to feel similar to the ZSA keyboard, where the thumbs handle
a majority of the heavy work around modifiers."
   #:keymap-source-directory
   (file-append ravenjoad-keyboards-source
                "/keyboards/preonic/keymaps/ravenjoad")))
