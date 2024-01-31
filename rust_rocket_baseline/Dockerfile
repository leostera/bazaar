FROM rust:1 as builder
WORKDIR /app
COPY . .
RUN cargo build --release


FROM ubuntu:latest as runner
COPY --from=builder /app/target/release/rust_rocket_baseline /usr/local/bin/rust_rocket_baseline
ENV ROCKET_ADDRESS=0.0.0.0
EXPOSE 8000
CMD ["rust_rocket_baseline"]
