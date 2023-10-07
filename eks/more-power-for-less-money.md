## More Power for Less Money

Here we are going to learn about solutions for cost optimization and the ways
to manage loads in our cluster.

### Spot Instaces

They are short-running machines becuase AWS give us access to the virtual
machines of in specific family and type with a lower cost. But the point is
that these machines have a lifetime and AWS is going to take machines back 
with a 2-minute notice and that is why they are cheaper. What important is that
you have to develop something around it to maintaine reliablity.

By using `Spot Instances`, we are using the same `EC2` instances but cost
around 80% less.

//#TODO Adding commands

### Managed Node Groups

It is a set of worker nodes that are fully managed by `AWS` so we do not need
to deal with any details such as auto-scaling rules and so on. There is also no
additional cost, and it can be used in both `Spot` and `On-demand` instances.

In order to create a `managed node group` use the following command:

```
eksctl create nodegroup \
    --cluster <CLUSTER NAME> \
    --name <NAME OF NODEGROUP> \
    --node-private-networking true \
    --nodes-min=<NUMBER OF NODES> \
    --instance-types <INSTANCE TYPE>
```

To check the status of `nodegroup` run the below command:

```
eksctl get nodegroup \
    --cluster <CLUSTER NAME> \
```

If you want more details about the specific `nodegroup` use the:

```
aws eks describe-nodegroup \
    --cluster-name <CLUSTER NAME> \
    --nodegroup-name <NODEGROUP NAME> \
    --output table
```

You can also do some changes from the `AWS Console` or from the `AWS CLI`.


### Fargate


