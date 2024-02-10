(lang dune 3.12)
(using melange 0.1)
(using directory-targets 0.1)

(name bazaar)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name bazaar)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends 
   (nomad (>= "0.0.1"))
   (riot (>= "0.0.8"))
   (serde (>= "0.0.1"))
   (serde_derive (>= "0.0.1"))
   (serde_json (>= "0.0.1"))
   (trail (>= "0.0.1"))
   opam-check-npm-deps
   ppx_deriving
   dune 
   ocaml
   melange)
 (tags
  (topics "to describe" your project)))

(dialect
 (name mlx)
 (implementation
  (extension mlx)
  (preprocess (with-stdin-from %{input-file} (run mlx))))
 (interface
  (extension mlxi)
  (preprocess (with-stdin-from %{input-file} (run mlx))))
 )
