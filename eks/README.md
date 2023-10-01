# Elastic Kubernetes Service

## To run eks follow along:

### Create Role

#### To create your Amazon EKS cluster role in the IAM console

1. Open the IAM console at https://console.aws.amazon.com/iam/.

2. Choose Roles, then Create role.

3. Under Trusted entity type, select AWS service.

4. From the Use cases for other AWS services dropdown list, choose EKS.

5. Choose EKS - Cluster for your use case, and then choose Next.

6. On the Add permissions tab, choose Next.

7. For Role name, enter a unique name for your role, such as eksClusterRole.

8. For Description, enter descriptive text such as Amazon EKS - Cluster role.

9. Choose Create role.

#### To create role from AWS CLI

1. Copy the following contents to a file named cluster-trust-policy.json.

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

2. Create the role. You can replace eksClusterRole with any name that you choose.

```￼
aws iam create-role \
  --role-name eksClusterRole \
  --assume-role-policy-document file://"cluster-trust-policy.json"
```

3. Attach the required IAM policy to the role.

```￼
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --role-name eksClusterRole
```

For more information click [here](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html#create-service-role).

#### Create EKS cluster using eksctl

1. To install `eksctl` run the following commands:

```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
```

once it is installed, go ahead to next command.

2. To create cluster run the command below:

```
eksctl create cluster --name=mycluster \
    --region=us-east-1 \
    --version=1.27 \
    --vpc-cidr=10.0.0.0/16 \
    --nodegroup-name=mycluster-node-group \
    --instance-types=t3.micro \
    --node-private-networking=true \
    --node-volume-size=30 \
    --nodes-min=3 \
    --vpc-nat-mode=HighlyAvailable
```

after a while, you will see something like this message az the end of the logs on screen:

`2023-09-29 17:06:39 [✔]  EKS cluster "mycluster" in "us-east-1" region is ready`

and also the `kubeconfig` file will be located at `$HOME/.kube/config` automatically.

#### Create AWS Loadbalancer

Next step is to create a `loadbalancer` in order to client be able to send 
their request from the internet.

***Note: AWS Loadbalancer is something like ingress nginx controller***

Run the following commands:

1. Adding `eks-chart` helm repository.
    
    ```
    helm repo add eks https://aws.github.io/eks-charts
    ```
2. Installing the `aws-loadbalancer-controller`

    ```
    helm upgrade --install \
      -n kube-system \
      --set clusterName=eks-acg \
      --set serviceAccount.create=true \
      aws-load-balancer-controller eks/aws-load-balancer-controller
    ``` 
3. Now, it is time to deploy an `IAM` policy in our AWS space: 

    ```
    aws cloudformation deploy \
        --stack-name aws-load-balancer-iam-policy \
        --template-file iam-policy.yaml \
        --capabilities CAPABILITY_IAM
    ```

the point is that the `AWS loadbalancer controller` will not work with the 
policy that we created a few moments ago. So we have to attach the iam policy 
to the worker nodes iam role.

4. Finding policy name by running this command:

    ```
    aws cloudformation describe-stacks \
        --stack-name aws-load-balancer-iam-policy \
        --query "Stacks[0].Outputs[0]" \
        | jq .OutputValue \
        | tr -d '"'
    ```

5. Getting the `IAM Identity` of the eks cluster by running:


    ```
    eksctl get iamidentitymapping \
        --cluster mycluster \
        --output json \
        | jq .[].rolearn \
        | tr -d '"' \
        | cut -d "/" -f 2
    ```

6. Now, we should attach the `policy` in number 5 to the `Role` in number
   6, so run the following command:

    ```
    aws iam attach-role-policy \
        --role-name <OUTPUT OF NUMBER 5> \
        --policy-arn <OUTPUT OF NUMBER 4>
    ```

7. Final step is to test the cluster. So we should deploy a sample app like 
nginx in cluster. But first we are going to find out the `DNSName` of the ELB,
when it is ready. In order to find the loadbalancer of the cluster node run the
following commands:

    1. At first, we need to get the `vpcId` of the cluster:

        ```
        aws eks describe-cluster \
            --name mycluster \
            --query "cluster.resourcesVpcConfig.vpcId" \
            | tr -d '"'
        ```
    2. Then, we should get the `DNSName` of the `Loadbalancer`:

        ```
        aws elbv2 describe-load-balancers \
            --query 'LoadBalancers[?VPCId=="<VPC FROM THE LAST COMMAND>"]|[]' \
            | jq .[].DNSName \
            | tr -d '"'
        ```

Now, Open a browser and paste the `DNSName` in it. If everything is ok , you
will see the nginx welcome page.
