# GBIF Helm Repository
**NOTE:** This project is still WIP

## Description
The Helm repository contains the charts and templates to provision the components into a given Kubernetes cluster. The charts are utilizing charts from [Stackable](https://stackable.tech/) organization which provides a wide selection of operators to work with technologies: **Hadoop HDFS**, **Trino**, **Hbase**, **Zookeeper**, etc. **Stackable's** operators provide a convenient and packaged solution for configuring  and organization the technology stack within the range of technologies they support.

## Migration in phases
As the transition from bare-metal hosting of infrastructure to on-site Kubernetes cluster is a complicated and large operation, it is done through an iterative process. 

An example of how to use the helmfile to deploy to a given namespace:

``` bash
helmfile apply -n <namespace> -f ./helmfile.yaml
```

Before deploying to a namespace, you should fetch and process any dependencies your charts might have:

``` bash
helmfile deps -f ./helmfile.yaml
```
### Prototyping phase
Before committing to a large and unknown migration from old version of the software to newer version and different way of hosting it, it was decided to do some prototyping to prove and estimate the feasibility of such migration.

The first part, that we have prototyped is the setup and configuration of the HDFS cluster together with a Hbase and a Spark application. The goal is to successfully load data into the HDFS cluster and run a Spark application to process the data.

The second part is to test the query engine Trino to see if it can fill in on the area we use the Hive engine for. The test is documented under docs/comparison_of_query_engines.md.

The third part is to test Airflow as a substitution for Oozie as a workflow executor.
## Tech stack
Current components deployed via Helm charts:
- Spark application
- Vectortile-server
- Hbase
- HiveMetastore
- Zookeeper
- HDFS
- Trino
- Airflow
- Postgres (used by HiveMetastore and Airflow)
- Redis (Used by Airflow)
- Stackable Operators (Mainly uses Stackable provided charts)

It is possible to use the helmfile.yaml to install the whole cluster. **BEWARE** if you chooses to uninstall or reinstall the common-operator, the CRDs will be removed and thereby all the deployed components. The option currently kept for testing purposes.
## Requirements

In order to work with Helm charts you need the following tools: 
- [Helm](https://helm.sh/)
- [Helmfile](https://github.com/helmfile/helmfile)

The following plug-in is required:
- [Helm-diff](https://github.com/databus23/helm-diff)

In order for Helm to be able to communicate with the Kubernetes cluster, the local kube-context need to be configured.
## TODOs
This helm repository is still **under construction** so here is a list of tasks that still needs to be implemented for it to completed:

- [X] Implement a better way to configure and deploy a number of predefined volumes
- [X] Write charts for the raw Kubernetes manifest files
- [X] Create chart for Trino
- [ ] Create chart for Airflow
- [ ] Create move helmfile.d to own repository to keep env specific variables hidden