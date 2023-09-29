# Elastic Kubernetes Service

##To run eks follow along:

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

