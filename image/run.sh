#!/bin/bash

# Copyright 2014 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

sed -i  "s/%%ip%%/$(hostname -i)/g" /etc/cassandra/conf/cassandra.yaml
# endpoints of a k8s service may be unavailable to query via apiserver right after pod creation. 
# wait until service's endpoint ready  
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
while [ $(curl -k https://${KUBERNETES_SERVICE_HOST}/api/v1/namespaces/${POD_NAMESPACE}/endpoints/cassandra -H "Authorization: Bearer ${KUBE_TOKEN}" | jq -r '.subsets[0].addresses[0].ip == null') == true ]; do
  echo "Endpoint of Cassandra Service is not ready..."
  sleep 2
done
echo "Endpoint(s) of Cassandra Service have been ready!" 

bin/cassandra -f
