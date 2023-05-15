FROM alpine:3.14
RUN apk add --no-cache bash && mkdir -p "/gbif/DAGs" && mkdir -p "/gbif/plugins" && addgroup -S stackable && adduser -S stackable -G stackable
COPY --chown=stackable:stackable ./DAGs/dag-files /gbif/DAGs
COPY --chown=stackable:stackable ./DAGs/airflow-plugins /gbif/plugins
USER stackable
ENTRYPOINT ["/bin/bash"]