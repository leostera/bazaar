# syntax=docker/dockerfile:1
FROM ocaml/opam:ubuntu-22.04-ocaml-5.1
# FROM ocaml/opam:ubuntu-ocaml-5.1-flambda
WORKDIR /app

USER 0

# PINNED DEPS
# weird dep that we need because crypto stuff needs zarith
RUN apt-get update -y && apt-get install libgmp-dev -y
# RUN apk add gmp-dev

# hack to get opam 2.1 running
RUN ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN opam --version
RUN opam init

RUN echo "cache-version: 13"
RUN opam pin config.0.0.1 git+https://github.com/leostera/config.ml
RUN CONFIG_DEBUG=true opam pin libc.0.0.1 git+https://github.com/leostera/libc.ml
RUN echo "cache-version: 0"
RUN opam pin io.0.0.8 git+https://github.com/leostera/riot
RUN opam pin bytestring.0.0.8 git+https://github.com/leostera/riot
RUN echo "cache-version: 4"
RUN opam pin gluon.0.0.8 git+https://github.com/leostera/riot
RUN echo "cache-version: 1"
RUN opam pin riot.0.0.8 git+https://github.com/leostera/riot
RUN echo "cache-version: 8"
RUN opam pin atacama.0.0.5 git+https://github.com/leostera/atacama
RUN opam pin trail.0.0.1 git+https://github.com/leostera/trail
RUN echo "cache-version: 4"
RUN opam pin nomad.0.0.1 git+https://github.com/leostera/nomad
RUN echo "cache-version: 1"
RUN opam pin serde.0.0.1 git+https://github.com/leostera/serde.ml
RUN opam pin serde_derive.0.0.1 git+https://github.com/leostera/serde.ml
RUN opam pin serde_json.0.0.1 git+https://github.com/leostera/serde.ml
RUN opam pin mlx.0.0.1 git+https://github.com/leostera/mlx
RUN echo "cache-version: 4"
RUN opam pin sidewinder.0.0.1 git+https://github.com/leostera/trail

# ACTUAL APP DEPS
COPY *.opam .
RUN opam install --deps-only --with-test ./bazaar.opam

# BUILD APP
COPY . .
RUN eval $(opam env) && dune build --release @all

FROM debian:12-slim as runner
COPY --from=0 /app/_build/default/bazaar/main.exe /bin/bazaar
CMD ["/bin/bazaar"]
