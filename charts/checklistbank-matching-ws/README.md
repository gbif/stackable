# Matching WS

Charts for deploying the ChecklistBank Matching WS.
There are several docker images for the matching-ws, which ship with different lucene indexes
generated from datasets in ChecklistBank.

## Deployment

Install of Catalogue of Life matching-ws
```bash
helm install checklistbank-matching-ws-xcol . -f values.yaml -n uat --set image.tag=1.0-SNAPSHOT-3LXRC --set service.nodePort=30080
```

Install of GBIF Backbone matching-ws
```bash
helm install checklistbank-matching-ws-gbif . -f values.yaml -n uat --set image.tag=1.0-SNAPSHOT-53147 --set service.nodePort=30081
```
