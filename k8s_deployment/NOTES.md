# K8S Basic Tutorials

For installing tools please take a look at file [init_master.sh](./init_master.sh)

## I. [Overview](https://docs.docker.com/get-started/orchestration/)


1. Create a "pod.yaml" file

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo
spec:
  containers:
  - name: testpod
    image: alpine:latest
    command: ["ping", "8.8.8.8"]
```

2. In a terminal, navigate to where you created pod.yaml and create your pod & check that pod is up & running: 
```bash
$ kubectl apply -f pod.yaml
$ kubectl get pods

# Output should be something like this
NAME      READY     STATUS    RESTARTS   AGE
demo      1/1       Running   0          4s

# If not please debug: https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/
$ kubectl describe pods demo

```


3. Get pod's logs
```bash
$ kubectl logs demo
# Output should be like:
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: seq=0 ttl=37 time=21.393 ms
64 bytes from 8.8.8.8: seq=1 ttl=37 time=15.320 ms
64 bytes from 8.8.8.8: seq=2 ttl=37 time=11.111 ms
...
```
4. Delete the pod
   
```bash
$ kubectl delete -f pod.yaml
```

## II. [Deploy to Kubernetes](https://docs.docker.com/get-started/kube-deploy/)

1. Describing apps using Kubernetes YAML

   - All containers in Kubernetes are scheduled as pods, which are groups of co-located containers that share some resources. Furthermore, in a realistic application you almost never create individual pods. Instead, most of your workloads are scheduled as deployments, which are scalable groups of pods maintained automatically by Kubernetes


