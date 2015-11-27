# k8s-cassandra: cassandra cluster of DRAFT on Kubernetes
##### Steps:
* Build docker image via Quay.io
* Create kuberbetes pods & service

        kubectl create -f cassandra.yaml [--namespace=xxx]
* Teardown

        ./teardown.sh [--namespace=xxx]
* Cluster maintenance/management 

        Remove a C* node (e.g. C* pod deleted)
        (1) find the "Host ID" of the downed node via "kubectl exec -it <pod> -- bin/nodetool status"
        (2) remove the zombie  via "kubectl exec <pod> -- bin/nodetool removenode <HostID>"

-----
##### Notes:
* DataStax suggests use Oracle JDK instead of OpenJDK.
* Query apiserver for endpoints (e.g. finding counterpart pods) would be "unauthorized" if not in default namespace. Therefore, cassandra pods can't form a cluster. Resolved it via setting auth_policy with {"user":"system:serviceaccount:kube-system:default"} (refer to https://github.com/kubernetes/kubernetes/blob/master/docs/admin/authorization.md)  

-----
##### TODO:
* ~~Kubernetes 1.0.x doesn't support emptyDir volumes for containers running as non-root (it's commit in master branch, not v1.0.0 branch, refer to https://github.com/kubernetes/kubernetes/pull/9384 & https://github.com/kubernetes/kubernetes/issues/12627). Use root rather than cassandra user instead at this moment.~~ (Done: It's verified OK in kubernetes 1.1.1 in using cassandra user instead of root)
* ~~Endpoints not available to query via apiserver right after pod creation, workaround it by delay 10 seconds to start cassandra program at this moment.~~ (Done: Repeatedly polling until service's endpoint ready in run.sh)
* Is OpsCenter workable in k8s?
