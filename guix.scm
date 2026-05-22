; SPDX-License-Identifier: MPL-2.0
;; guix.scm — GNU Guix package definition for thunderbird-template-reloaded
;; Usage: guix shell -f guix.scm

(use-modules (guix packages)
             (guix build-system gnu)
             (guix licenses))

(package
  (name "thunderbird-template-reloaded")
  (version "0.1.0")
  (source #f)
  (build-system gnu-build-system)
  (synopsis "thunderbird-template-reloaded")
  (description "thunderbird-template-reloaded — part of the hyperpolymath ecosystem.")
  (home-page "https://github.com/hyperpolymath/thunderbird-template-reloaded")
  (license ((@@ (guix licenses) license) "MPL-2.0"
             "https://github.com/hyperpolymath/palimpsest-license")))
