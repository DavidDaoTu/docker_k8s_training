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

## II. [Deploy to Kubernetes (from Docker Tutorials)](https://docs.docker.com/get-started/kube-deploy/)

1. Describing apps using Kubernetes YAML

   - All containers in Kubernetes are scheduled as pods, which are groups of co-located containers that share some resources. Furthermore, in a realistic application **_you almost never create individual pods_**. Instead, most of your workloads are scheduled as deployments, which are scalable groups of pods maintained automatically by Kubernetes


   - Lastly, all Kubernetes objects can and should be described in manifests called Kubernetes YAML files. **These YAML files describe all the components and configurations of your Kubernetes app, and can be used to create and destroy your app in any Kubernetes environment**
   
   - Create a 'bb.yaml' file:
    ```yaml
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: bb-demo
        namespace: default
      spec:
        replicas: 1
        selector:
            matchLabels:
              bb: web
        template:
            metadata:
              labels:
                  bb: web
            spec:
              containers:
                  - name: bb-site
                    image: getting-started
                    imagePullPolicy: Never
      ---
      apiVersion: v1
      kind: Service
      metadata:
        name: bb-entrypoint
        namespace: default
      spec:
        type: NodePort
        selector:
            bb: web
        ports:
            - port: 3000
              targetPort: 3000
              nodePort: 30001
      ```
  In this Kubernetes YAML file, there are two objects, separated by the ---:

  - A **Deployment**, describing a scalable group of identical pods. In this case, you'll get just one **replica**, or copy of your pod, and that pod (which is described under the **template**: key) has just one container in it, based off of your **getting-started** image from the previous step in this tutorial.

  - A **NodePort** service, which will route traffic from port 30001 on your host to port 3000 inside the pods it routes to, allowing you to reach your Todo app from the network.


  - Also, notice that while Kubernetes YAML can appear long and complicated at first, it almost always follows the same pattern:

    + The **apiVersion**, which indicates the Kubernetes API that parses this object
    + The **kind** indicating what sort of object this is
    + Some **metadata** applying things like names to your objects
    + The **spec** specifying all the parameters and configurations of your object.


## III. [Kubernetes Tasks - Run applications](https://kubernetes.io/docs/tasks/run-application/)
### 1. Run a Stateless Applications using a Deployment

The stateless app deployment could be found at [kubernetes-bootcamp.yaml](./kubernetes-bootcamp.yaml)

Please refer to: 

1. https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
2. https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/

### 2. Run a Stateful Applications using a Deployment

Please refer to this guideline: https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/

+ The mongodb deployment is at [mongodb-deployment.yaml](./stateful_apps/mongodb-deployment.yaml)
+ The mongodb persistent volume (PV) & persistent volume claim (PVC) is at [mongodb-persistent-volume.yaml](./stateful_apps/mongodb-persistent-volume.yaml)

Run the demo under the folder *"stateful_apps"*
```bash
$ kubectl apply -f mongodb-persistent-volume.yaml
$ kubectl apply -f mongodb-deployment.yaml
```

Accessing the MongoDB instance:
Run a MySQL client to connect to the MongoDB community server:
```bash
$ kubectl run -it --rm --image=mongodb/mongodb-community-server:6.0.8-ubi8 --restart=Never mongosh -- mongosh "mongodb://admin:admin@mongodb"
```
Seed/initiate the data for a new MongoDB instance:
Refer to the mongodb tutorials
1. https://www.w3schools.com/mongodb/mongodb_mongosh_create_collection.php
2. https://www.mongodb.com/developer/products/mongodb/cheat-sheet/
3. https://www.tutorialspoint.com/mongodb/index.htm

```bash
$ db.createCollection('users')
$ db.users.insertOne({name: 'tudao', age: '30'})
$ db.users.find().pretty()
```

### 3. [Run a Replicated Stateful Application](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/)

How to deploy ReplicaSet in MongoDB
Refer: https://www.mongodb.com/docs/manual/tutorial/deploy-replica-set/

```bash
rs.initiate( {
   _id : "rs0",
   members: [
      { _id: 0, host: "mongodb-sts-0.mongodb-svc.default.svc.cluster.local:27017" },
      { _id: 1, host: "mongodb-sts-1.mongodb-svc.default.svc.cluster.local:27017" },
      { _id: 2, host: "mongodb-sts-2.mongodb-svc.default.svc.cluster.local:27017" }
   ]
})
```



Refer to configmap:
1. https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
2. https://kubernetes.io/docs/concepts/configuration/configmap/#using-configmaps-as-files-from-a-pod



Debug:
1. How to run a Shell in Pod's container: 
   ```bash
   $ kubectl get pods
   $ kubectl exec -it mynginx-56766fcf49-4b6ls -- /bin/bash
   ```
