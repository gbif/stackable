# Matching WS

Charts for deploying the ChecklistBank Matching WS.
There are several docker images for the matching-ws, which ship with different lucene indexes
generated from datasets in ChecklistBank.

## Deployment

Install of Catalogue of Life matching-ws
```bash
helm install checklistbank-matching-ws-xcol . -f values.yaml -n dev2 --set image.tag=xcol-latest --set ingress.path=/xcol
```

Install of GBIF Backbone matching-ws
```bash
helm install checklistbank-matching-ws-gbif . -f values.yaml -n dev2 --set image.tag=gbif-latest --set ingress.path=/gbif
```

Install of WoRMS matching-ws
```bash
helm install checklistbank-matching-ws-worms . -f values.yaml -n dev2 --set image.tag=worms-latest --set ingress.path=/worms
```

Install of ITIS matching-ws
```bash
helm install checklistbank-matching-ws-itis . -f values.yaml -n dev2 --set image.tag=itis-latest --set ingress.path=/itis
```

Install of IPNI matching-ws
```bash
helm install checklistbank-matching-ws-ipni . -f values.yaml -n dev2 --set image.tag=ipni-latest --set ingress.path=/ipni
```

Install of Dyntaxa matching-ws
```bash
helm install checklistbank-matching-ws-dyntaxa . -f values.yaml -n dev2 --set image.tag=dyntaxa-latest --set ingress.path=/dyntaxa
```

Install of UK Species inventory matching-ws
```bash
helm install checklistbank-matching-ws-uksi . -f values.yaml -n dev2 ---set image.tag=uksi-latest --set ingress.path=/uksi
```
