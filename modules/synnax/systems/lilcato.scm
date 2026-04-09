(define-module (synnax systems lilcato)
  #:use-module (gnu)
  #:use-module (gnu packages linux) ; brightnessctl
  #:use-module (gnu packages qt)
  #:use-module (gnu packages wm)
  #:use-module (gnu services desktop)
  #:use-module (gnu services pm)
  #:use-module (gnu services vpn)
  #:use-module (synnax systems base-system)
  #:export (lilcato))

(define-public lilcato
  (operating-system
   (inherit %base-system)
   (host-name "lilcato")

   (packages
    (append
     (list sway
           swaylock
           ;; Swaylock with extra goodies.
           ;; swaylock-effects
           quickshell
           ;; Adds a QT_PLATFORM_PLUGIN for wayland
           qtwayland
           brightnessctl
           bluez)
     (operating-system-packages %base-system)))

   (services
    (append
     (list (service bluetooth-service-type
                    (bluetooth-configuration
                     (auto-enable? #t)))
           (service power-profiles-daemon-service-type)
           (service wireguard-service-type
                    (wireguard-configuration
                      (addresses '("10.0.0.4/32"))
                      (shepherd-requirement '(networking))
                      (peers
                       (list
                        (wireguard-peer
                          (name "avocato")
                          (public-key "X3Ku6TUMvyx9uGrrP5EUJHhxz5yJf4xt2Kbof1kv7TU=")
                          (preshared-key "/etc/wireguard/avocato-lilcato.psk")
                          (allowed-ips '("10.0.0.3/32")))
                        (wireguard-peer
                          (name "korphus")
                          (public-key "4NRyR06AiYgtFpmqOcNrGtTZNBUfKLQB7wan6EKlJyc=")
                          (preshared-key "/etc/wireguard/lilcato-router.psk")
                          (allowed-ips '("10.0.0.2/32"))
                          (endpoint (string-append "korphus.hallsby.com" ":"
                                                   (number->string 51820)))
                          (keep-alive 60))
                        (wireguard-peer
                          (name "website")
                          (public-key "KUoopzIFt1umejE5TPryLU8F457bfjdmShRc1dHHAlM=")
                          (preshared-key "/etc/wireguard/lilcato-website.psk")
                          (allowed-ips '("10.0.0.1/32"))
                          (endpoint (string-append "raven.hallsby.com" ":"
                                                   (number->string 51820)))
                          (keep-alive 60)))))))
     (operating-system-user-services %base-system)))

   (mapped-devices
    (list (mapped-device
           (source
            (uuid "34627d93-4e91-42e8-8eb8-b64c8fa4729f"))
           (target "cryptroot")
           (type luks-device-mapping))))
   (file-systems
    (cons* (file-system
             (mount-point "/boot/efi")
             (device (uuid "C899-DB8A" 'fat32))
             (type "vfat"))
           (file-system
             (mount-point "/")
             (device "/dev/mapper/cryptroot")
             (type "ext4")
             (dependencies mapped-devices))
           %base-file-systems))))

lilcato
