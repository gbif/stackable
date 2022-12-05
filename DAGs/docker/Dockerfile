FROM alpine/helm:3.10.2 as BUILDER
RUN mkdir -p /build/result
ADD ./helm /build/helm
WORKDIR /build/helm
RUN helm template large-map-processor --namespace stack-demo --set installMode=app ./charts/gbif-spark-map-proces > ../result/spark-map-proces.yaml
FROM alpine:3.14
RUN apk add --no-cache bash && mkdir -p "/gbif/DAGs" && mkdir -p "/gbif/plugins" && addgroup -S stackable && adduser -S stackable -G stackable
COPY --chown=stackable:stackable --from=BUILDER /build/result /gbif/DAGs
COPY --chown=stackable:stackable ./DAGs/dag-files /gbif/DAGs
COPY --chown=stackable:stackable ./DAGs/airflow-plugins /gbif/plugins
USER stackable
ENTRYPOINT ["/bin/bash"]