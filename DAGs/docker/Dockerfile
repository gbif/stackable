FROM alpine:3.14
RUN apk add --no-cache bash
RUN mkdir -p "/gbif/DAGs" && addgroup -S stackable && adduser -S stackable -G stackable
USER stackable
COPY --chown=stackable:stackable ./dag-files /gbif/DAGs
ENTRYPOINT ["/bin/bash"]