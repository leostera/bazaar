# syntax=docker/dockerfile:1
# FROM ocaml/opam:ubuntu-22.04-ocaml-5.1
FROM ocaml/opam:alpine-ocaml-5.1-flambda
WORKDIR /app

USER 0

# PINNED DEPS
# weird dep that we need because crypto stuff needs zarith
# RUN apt-get update -y && apt-get install libgmp-dev -y
RUN apk add gmp-dev

# hack to get opam 2.1 running
RUN ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN opam --version
RUN opam init

RUN opam pin riot.0.0.8 git+https://github.com/leostera/riot
RUN opam pin atacama.0.0.5 git+https://github.com/leostera/atacama
RUN opam pin trail.0.0.1 git+https://github.com/leostera/trail
RUN opam pin nomad.0.0.1 git+https://github.com/leostera/nomad

# ACTUAL APP DEPS
COPY *.opam .
RUN opam install --deps-only --with-test ./bazaar.opam

# BUILD APP
COPY . .
RUN eval $(opam env) && dune build --profile=docker @all

FROM scratch
COPY --from=0 /app/_build/default/bazaar/bazaar.exe /bin/bazaar
CMD ["/bin/bazaar"]
