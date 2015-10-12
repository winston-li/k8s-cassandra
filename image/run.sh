#!/bin/bash

sed -i  "s/%%ip%%/$(hostname -i)/g" /etc/cassandra/conf/cassandra.yaml
# endpoints of a k8s service may be unavailable to query via apiserver right after pod creation. 
# wait until service's endpoint ready  
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
# curl -m: max operation timeout; -Ss: hide progress meter but show error; --stderr -: redirect all writes to stdout
RET=$(curl -m 2 -Ss --stderr - -k https://${KUBERNETES_SERVICE_HOST}/api/v1/namespaces/${POD_NAMESPACE}/endpoints/cassandra -H "Authorization: Bearer ${KUBE_TOKEN}" | jq -r '.subsets[0].addresses[0].ip != null')
while [ ${RET} != true ]; do
  echo "Endpoint of Cassandra Service is not ready...(RET=${RET})"
  sleep 2
  RET=$(curl -m 2 -Ss --stderr - -k https://${KUBERNETES_SERVICE_HOST}/api/v1/namespaces/${POD_NAMESPACE}/endpoints/cassandra -H "Authorization: Bearer ${KUBE_TOKEN}" | jq -r '.subsets[0].addresses[0].ip != null')
done
echo "Endpoint(s) of Cassandra Service have been ready!" 

bin/cassandra -f
