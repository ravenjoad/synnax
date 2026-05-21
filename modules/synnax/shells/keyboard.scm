(define-module (synnax shells keyboard)
  #:use-module (guix profiles)
  #:use-module (guix packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages embedded))

(define (make-qmk-newlib-nano-arm-none-eabi)
  (let ((base (make-newlib-nano-arm-none-eabi)))
    (package
      (inherit base)
      (native-inputs
       (modify-inputs native-inputs
         (replace "xgcc" (make-gcc-arm-none-eabi-12.3.rel1)))))))

(concatenate-manifests
 (list
  (packages->manifest
   (list (make-qmk-newlib-nano-arm-none-eabi)
         ;; We need to provide GCC to the environment too.
         ;; *-newlib-* above only provides the toolchain libraries, but gcc is
         ;; a native-input, which means the manifest won't see it.
         (make-arm-none-eabi-nano-toolchain-12.3.rel1)))

  (specifications->manifest
   (list "qmk"
         "dfu-util"
         "python"
         "make"))))
