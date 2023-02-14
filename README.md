# GBIF Helm Repository
**NOTE:** This project is still WIP

## Description
The Helm repository contains the charts and templates to provision the components into a given Kubernetes cluster. The charts are utilizing charts from [Stackable](https://stackable.tech/) organization which provides a wide selection of operators to work with technologies: **Hadoop HDFS**, **Trino**, **Hbase**, **Zookeeper**, etc. **Stackable's** operators provide a convenient and packaged solution for configuring  and organization the technology stack within the range of technologies they support.

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

~~It is possible to use the helmfile.yaml to install the whole cluster.~~ **BEWARE** if you chooses to uninstall or reinstall the common-operator, the CRDs will be removed and thereby all the deployed components. The option currently kept for testing purposes.
## Requirements
In order to work with Helm charts you need the following tools: 
- [Helm](https://helm.sh/)
- ~~[Helmfile](https://github.com/helmfile/helmfile)~~

The following plug-in is required:
- [Helm-diff](https://github.com/databus23/helm-diff)
- [Helm-push](https://github.com/chartmuseum/helm-push)

In order for Helm to be able to communicate with the Kubernetes cluster, the local kube-context need to be configured.
## Releasing Charts
In this project we are using [semver 2.0](https://semver.org/) for the versioning of the helm charts. The charts can be released to GBIF helm repository by running the command:
``` bash
helm cm-push charts/<chart_to_release> https://repository.gbif.org/repository/gbif-helm-release/ --context-path=/repository/gbif-helm-release --username=<your_nexus_username> --password=<your_nexus_password>
```
After a successful push the new version of the chart should be ready for use.

**NOTE:** Currently all charts are released to the snapshot repository as the first version is not ready.

Releasing to the snapshot repository is similar to previous command but pointing to the another repository:

``` bash
helm cm-push charts/<chart_to_release> https://repository.gbif.org/repository/gbif-helm-snapshot/ --context-path=/repository/gbif-helm-snapshot --username=<your_nexus_username> --password=<your_nexus_password>
```
## Deploying the Charts
In GBIF we have adopted Helmfile to manage the state of our cluster contained in state files. The state files are stored in a separate repository to protect sensitive information.

The helm charts can still be deployed through the traditional way following these steps:

1. Add the GBIF helm repository:
``` bash
helm repo add gbif-charts-release https://repository.gbif.org/repository/gbif-helm-release/
```
1. Get helm to fetch depdencies for the chart:
``` bash
helm dependency update charts/<chart_to_deploy>
```
1. Run the install / upgrade command to:
``` bash
helm upgrade --install <my_release> charts/<chart_to_deploy> -n <namespace_to_deploy_to> --set <key_1>=<value_1> --set <key_2>=<value_2>
```

## Feedback & Bugs
Feel free to create an issue within this repository.
### Bug
Describe the scenario the bug was spotted in and attach the **bug** label to the issue.

### Feature Request
Describe the feature you are request together with an use-case scenario, use the **enchantment** label for the issue.