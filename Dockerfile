# ---- Build réteg: függőségek + csomag telepítése ----
FROM python:3.12-slim AS builder
WORKDIR /build
COPY pyproject.toml README.md ./
COPY src ./src
RUN pip install --no-cache-dir --prefix=/install .

# ---- Futtató réteg: minimális, nem-root ----
FROM python:3.12-slim

# Az org.opencontainers.image.source label köti a ghcr.io package-et a
# GitHub repóhoz (publikus repo → a package is publikussá tehető).
LABEL org.opencontainers.image.source="https://github.com/mattycska/Kafka" \
      org.opencontainers.image.description="Posta Csomagkövető — Kafka + Redis demó" \
      org.opencontainers.image.licenses="MIT"

COPY --from=builder /install /usr/local

RUN useradd --uid 10001 --no-create-home appuser
USER 10001

EXPOSE 8000 8001

# Egy image, három szerep: az argumentum dönti el, mi fut.
#   api:       parcel_tracker.api        (alapértelmezés)
#   worker:    parcel_tracker.worker
#   simulator: parcel_tracker.simulator
ENTRYPOINT ["python", "-m"]
CMD ["parcel_tracker.api"]
#
