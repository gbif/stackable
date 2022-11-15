# Comparison of Trino to Hive
As part of the migration, we have to determine if Trino is suited to cover the existing usage of Hive as a query engine. The comparison test was performed against the POC Kubernetes cluster and the GBIF Dev cluster. As the resources are managed differently, one by YARN and the other by allocated number of workers, our setup isn't one-to-one but an approximation.

## Resource Configuration
Below is sections describing how the resources were configured.

### GBIF Dev Cluster
As the Dev cluster is configured and managed through the Cloudera stack, the resources are allocated to processes through YARN. For the comparison test we used the root.default resource group which is able to allocate:
- CPU: 48 VCores max
- Memory: 72 GB max

**Note:** The cluster was in an idle state so the query should be able to allocate all the resources it would need.

### POC Kubenetes Cluster
The Kubernetes cluster relies on the Trino-operator from **Stackable** which creates a coordinator and n number of workers of user defined dimensions. As we are trying to get as close to a comparable state with the Dev cluster, we decided to create 6 workers total of the size:
- CPU: 8 VCores max
- Memory: 12 GB max

This totals a resource pool similar to the GBIF Dev Cluster.

## Queries for Comparison
We ran two queries; one select with aggregation and one create table stored as TEXTFILE. We let YARN and Trino do their own resource allocation within the resource pools, as to minimize misconfiguration during the execution. **However** it was necessary to configure the following two options for hive:
``` Bash
spark.yarn.executor.memory = 12000
hive.execution.engine = spark
```

As there are variance in name convention from the authors side and the language between Hive and Trino, all the specific queries will be listed.

<details>

<summary>Trino Specific Queries</summary>

**Trino Select from Parquet data**
```SQL
SELECT v_countryCode, count(*) FROM occurrence_new WHERE v_basisofrecord='HumanObservation' GROUP BY v_countryCode;
```

**Trino Select from Avro data**
```SQL
SELECT v_countryCode, count(*) FROM occurrence WHERE v_basisofrecord='HumanObservation' GROUP BY v_countryCode;
```

**Trino Create Table based on Parquet data**
```SQL
Create TABLE birds_text_from_parquet WITH (format = 'TEXTFILE') AS (SELECT v_modified, v_publisher, v_basisofrecord, v_datasetname, v_collectioncode, v_catalognumber, v_countrycode, v_stateprovince, v_scientificname, v_family, v_subfamily FROM occurrence_new WHERE v_class = 'Aves');
```
**Trino Create Table based on Avro data**
``` SQL
Create TABLE birds_text_from_avro WITH (format = 'TEXTFILE') AS (SELECT v_modified, v_publisher, v_basisofrecord, v_datasetname, v_collectioncode, v_catalognumber, v_countrycode, v_stateprovince, v_scientificname, v_family, v_subfamily FROM occurrence WHERE v_class = 'Aves');
```
</details>

<details>
<summary>Hive Specific Queries</summary>

### Hive Specific Queries
**Hive Select from Parquet data**
```SQL
SELECT v_countryCode, count(*) FROM occurrence_parquet_aln WHERE v_basisofrecord='HumanObservation' GROUP BY v_countryCode;
```

**Hive Select from Avro data**
```SQL
SELECT v_countryCode, count(*) FROM occurrence_aln WHERE v_basisofrecord='HumanObservation' GROUP BY v_countryCode;
```

**Hive Create Table based on Parquet data**
```SQL
CREATE TABLE birds_parque_aln STORED AS TEXTFILE AS SELECT v_modified, v_publisher, v_basisofrecord, v_datasetname, v_collectioncode, v_catalognumber, v_countrycode, v_stateprovince, v_scientificname, v_family, v_subfamily FROM occurrence_parquet_aln where v_class = 'Aves'
```
**Hive Create Table based on Parquet data**
``` SQL
CREATE TABLE birds_avro_aln STORED AS TEXTFILE AS SELECT v_modified, v_publisher, v_basisofrecord, v_datasetname, v_collectioncode, v_catalognumber, v_countrycode, v_stateprovince, v_scientificname, v_family, v_subfamily FROM occurrence_aln where v_class = 'Aves'
```
</details>

## Results
Single execution of the queries resulting in the following results:

| Env   | Select Parquet | Select Avro   | Create Table Parquet  | Create Table Avro |
| :---  | :---:          | :---:         | :---:                 | :---:             |
| Kube  | 4,7 sec        | 475 sec       | 40,8 sec              | 442 sec           |
| Yarn  | 90,93 sec      | 716,25 sec    | 67,76 sec             | 738,22 sec        |

For at more precise estimate a larger dataset should be generated.