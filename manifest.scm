(define-module (manifest)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages docker)
  #:use-module (gnu packages node)
  #:use-module (guix profiles)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (guix utils)
  #:use-module (gnu packages node)
  #:use-module (ice-9 match))

(define-public docker-compose-plugin
  (package
    (inherit docker-compose)
    (version "2.24.5")
    (source (origin
              (method url-fetch)
              (uri
               (let ((arch (match (or (%current-target-system) (%current-system))
                             ("aarch64-linux" "aarch64")
                             ("armhf-linux" "armv7")
                             (_ "x86_64"))))
                 (string-append
                  "https://github.com/docker/compose/releases/download/v"
                  version "/docker-compose-linux-" arch)))
              (sha256
               (base32
                "1qdklhrxm3x7ybhmaycag4q7qqn7snc0yjd1pl5h95fks7hmndcl"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:substitutable? #f
      #:install-plan
      #~'(("docker-compose" "libexec/docker/cli-plugins/"))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda _
              (copy-file #$source "./docker-compose")
              (chmod "docker-compose" #o644)))
          (add-before 'install 'chmod
            (lambda _
              (chmod "docker-compose" #o555)))
          (add-after 'install 'setup-bin
            (lambda _
              (let ((bin (string-append #$output "/bin"))
                    (lib (string-append #$output "/libexec/docker/cli-plugins")))
                (mkdir bin)
                (symlink (string-append lib "/docker-compose")
                         (string-append bin "/docker-compose"))))))))))

(define-public docker-cli-with-docker-compose
  (package
    (inherit docker-cli)
    (arguments
     (substitute-keyword-arguments (package-arguments docker-cli)
       ((#:phases phases)
        #~(modify-phases #$phases
           (add-after 'unpack 'patch-plugin-path
             (lambda _
               (substitute* "src/github.com/docker/cli/cli-plugins/manager/manager_unix.go"
                 (("/usr/libexec/docker/cli-plugins")
                  (string-append #$output "/libexec/docker/cli-plugins")))))
           (add-after 'install 'symlink-plugin
             (lambda _
               (let ((plugins-directory
                      (string-append #$output "/libexec/docker/cli-plugins")))
                 (mkdir-p plugins-directory)
                 (symlink (string-append #$(this-package-input "docker-compose")
                                         "/libexec/docker/cli-plugins/docker-compose")
                          (string-append plugins-directory "/docker-compose")))))))))
    (inputs (list docker-compose-plugin))))

(define-public yarn
  (package
   (name "yarn")
   (version "4.1.0")
   (source (origin
            (method url-fetch/tarbomb)
            (uri (string-append "https://github.com/yarnpkg/yarn/releases/download/v"
                                version
                                "/yarn-v"
                                version
                                ".tar.gz"))

            (sha256
             (base32
              "0hf15amsn54cbsy4pvqcq2c03d1l11w3799p19sympz4j93gnr66"))))
   (build-system copy-build-system)
   (inputs (list coreutils bash-minimal node-lts sed))
   (arguments
    (list #:install-plan
          #~'(("yarn-v1.22.5/bin" "bin")
              ("yarn-v1.22.5/lib" "lib")
              ("yarn-v1.22.5/package.json"
               "lib/package.json"))
          #:phases
          #~(modify-phases %standard-phases
              (add-after 'install 'delete-powershell-entrypoints
               (lambda _
                 (delete-file (string-append #$output "/bin/yarn.cmd"))
                 (delete-file (string-append #$output "/bin/yarnpkg.cmd"))))
              (add-after 'delete-powershell-entrypoints 'wrap-entrypoints
                (lambda _
                  (for-each
                   (lambda (entrypoint)
                     (wrap-program (string-append #$output "/bin/" entrypoint)
                       `("PATH" = (,(string-append
                                     #$output "/bin:"
                                     #$(this-package-input "bash-minimal") "/bin:"
                                     #$(this-package-input "coreutils") "/bin:"
                                     #$(this-package-input "sed") "/bin:"
                                     #$(this-package-input "node") "/bin")))))
                   '("yarn" "yarnpkg")))))))
   (home-page "https://yarnpkg.com/")
   (synopsis "Dependency management tool for JavaScript")
   (description "Fast, reliable, and secure dependency management tool
for JavaScript.  Acts as a drop-in replacement for NodeJS's npm.")
   (license bsd-2)))

(packages->manifest
 (append (list yarn)
         (map specification->package
              '("erlang"
                "elixir"
                "elixir-hex"
                "gcc-toolchain"
                "just"
                "inotify-tools"
                "make"
                "node"
                "rebar3"))))
