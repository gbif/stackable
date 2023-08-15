# DAGs for Airflow #
Current this folder is placed within the Stackable repository for Proof-of-Concept purpose. In the long run it would properly reside in its own repository.

The idea is to rely on a versioned docker image to setup the DAGs within the Stackable Airflow cluster.

## Requirements
To work with the cluster and deploy new changes to Airflow the following tools are required:

- kubectl installed
- helm installed
- docker installed

Non-technical requirements are:

- A running GBIF cluster
- Access to the namespace (developer access as a minimum)
- Docker is logged into the Nexus
## How to deploy new changes
To deploy new versions of either; the DAGs themselves, the plugins or the templates, run the build.sh script providing a version of the image. The script requires Docker (or podman) to be installed and login to Nexus. If these two requirements are met, the script will build an image and push it to the GBIF docker repository.

Example of running the script from the DAGs folder:

```
cd ./DAGs
./build.sh 0.6.2
```

After the image is successfully pushed, we need to run a batch job to hot swap the new changes into the targeted environments Airflow storage. To deploy the new image, run the following command from the root of the git repository:

```
VER=0.6.2 bash -c 'helm template dag-loader-$VER ./charts/gbif-dag-loader --namespace=gbif-develop --set versionOverride=$VER'
```

In the the example, we are assuming the user is deploying to the namespace called **gbif-develop**.

After the helm command completes you would be able to find the newly deployed batch job running the cluster with the command:

```
VER=0.6.2 bash -c 'kubectl -n gbif-develop get pods --output=wide | sed -n "1p;/dag-loader-$VER/p"'
```

If the pod has the status complete, the changes, in the specified image, have been deployed to Airflow.