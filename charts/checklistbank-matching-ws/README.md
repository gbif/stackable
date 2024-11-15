# Matching WS

Charts for deploying the ChecklistBank Matching WS.
There are several docker images for the matching-ws, which ship with different lucene indexes
generated from datasets in ChecklistBank.

## Deployment

Install of Catalogue of Life matching-ws
```bash
helm install \
-f values.yaml \
-n dev2 \
--set appName=matching-ws-xcol \
--set image.tag=xcol-latest \
--set ingress.path=/xcol \
--set zookeeper.enabled=true \
--set-string zookeeper.connectString="zk1.gbif.org:2181\,zk2.gbif.org:2181\,zk3.gbif.org:2181" \
--set zookeeper.discoveryRoot=dev2/services \
checklistbank-matching-ws-xcol .
```

Install of GBIF Backbone matching-ws
```bash
helm install \
-f values.yaml \
-n dev2 \
--set appName=matching-ws-gbif \
--set image.tag=gbif-latest \
--set ingress.path=/gbif \
--set zookeeper.enabled=true \
--set-string zookeeper.connectString="zk1.gbif.org:2181\,zk2.gbif.org:2181\,zk3.gbif.org:2181" \
--set zookeeper.discoveryRoot=dev2/services \
checklistbank-matching-ws-gbif .
```

Install of WoRMS matching-ws
```bash
helm install \     
-f values.yaml \   
-n dev2 \
--set appName=matching-ws-worms \
--set image.tag=worms-latest \
--set ingress.path=/worms \
--set zookeeper.enabled=true \
--set-string zookeeper.connectString="zk1.gbif.org:2181\,zk2.gbif.org:2181\,zk3.gbif.org:2181" \
--set zookeeper.discoveryRoot=dev2/services \
checklistbank-matching-ws-worms .
```

Install of ITIS matching-ws
```bash
helm install \     
-f values.yaml \   
-n dev2 \
--set appName=matching-ws-itis \
--set image.tag=itis-latest \
--set ingress.path=/itis \
--set zookeeper.enabled=true \
--set-string zookeeper.connectString="zk1.gbif.org:2181\,zk2.gbif.org:2181\,zk3.gbif.org:2181" \
--set zookeeper.discoveryRoot=dev2/services \
checklistbank-matching-ws-itis .
```

Install of IPNI matching-ws
```bash
helm install \     
-f values.yaml \   
-n dev2 \
--set appName=matching-ws-ipni \
--set image.tag=ipni-latest \
--set ingress.path=/ipni \
--set zookeeper.enabled=true \
--set-string zookeeper.connectString="zk1.gbif.org:2181\,zk2.gbif.org:2181\,zk3.gbif.org:2181" \
--set zookeeper.discoveryRoot=dev2/services \
checklistbank-matching-ws-ipni .
```

Install of Dyntaxa matching-ws
```bash
helm install \     
-f values.yaml \   
-n dev2 \
--set appName=matching-ws-dyntaxa \
--set image.tag=dyntaxa-latest \
--set ingress.path=/dyntaxa \
--set zookeeper.enabled=true \
--set-string zookeeper.connectString="zk1.gbif.org:2181\,zk2.gbif.org:2181\,zk3.gbif.org:2181" \
--set zookeeper.discoveryRoot=dev2/services \
checklistbank-matching-ws-dyntaxa .
```

Install of UK Species inventory matching-ws
```bash
helm install \     
-f values.yaml \   
-n dev2 \
--set appName=matching-ws-uksi \
--set image.tag=uksi-latest \
--set ingress.path=/uksi \
--set zookeeper.enabled=true \
--set-string zookeeper.connectString="zk1.gbif.org:2181\,zk2.gbif.org:2181\,zk3.gbif.org:2181" \
--set zookeeper.discoveryRoot=dev2/services \
checklistbank-matching-ws-uksi .
```
