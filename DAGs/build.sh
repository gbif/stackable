#!/bin/bash
ver=$1
docker build --platform=linux/amd64 -t docker.gbif.org/airflow-dags:${ver} ../ -f ./docker/Dockerfile