#!/bin/bash

set -e

CLUSTER_NAME=mycluster
REGION=us-east-1
CLUSTER_VERSION=1.27
CIDR=10.0.0.0/16
NODEGROUP_NAME=mycluster-node-group
TYPE=t3.medium
PRIVATE_NETWORK=true
VOLUME_SIZE=30
MINIMUM_NODE=3
NAT_MODE=HighlyAvailable

STACK_NAME=aws-load-balancer-iam-policy

echo "Creating cluster..."
eksctl create cluster --name=$CLUSTER_NAME \
    --region=$REGION \
    --version=$CLUSTER_VERSION \
    --vpc-cidr=$CIDR \
    --nodegroup-name=$NODEGROUP_NAME \
    --instance-types=$TYPE \
    --node-private-networking=$PRIVATE_NETWORK \
    --node-volume-size=$VOLUME_SIZE \
    --nodes-min=$MINIMUM_NODE \
    --vpc-nat-mode=$NAT_MODE \
	--zones "us-east-1a,us-east-1b,us-east-1c"

echo "Deploying sample application..."
helm install sample-app test 
echo "Adding AWS loadbalancer controller..."
helm repo add eks https://aws.github.io/eks-charts

helm upgrade --install \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=true \
  aws-load-balancer-controller eks/aws-load-balancer-controller

aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file iam-policy.yaml \
    --capabilities CAPABILITY_IAM

echo "Getting policy name and role name..."
POLICY_NAME=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query "Stacks[0].Outputs[0]" \
    | jq .OutputValue \
	| tr -d '"')

ROLE_NAME=$(eksctl get iamidentitymapping \
    --cluster $CLUSTER_NAME \
    --output json \
    | jq .[].rolearn \
    | tr -d '"' \
	| cut -d "/" -f 2)

echo "Attaching policy to role..."
aws iam attach-role-policy \
    --role-name $ROLE_NAME \
    --policy-arn $POLICY_NAME

VPCID=$(aws eks describe-cluster \
    --name $CLUSTER_NAME \
    --query "cluster.resourcesVpcConfig.vpcId" \
	| tr -d '"')

echo "Getting status of loadbalancer..."
LOADBALANCER_STATE=$(aws elbv2 describe-load-balancers \
	--query 'LoadBalancers[?VPCId=="vpc-09d517ca0e88c1e24"]|[]' \
	| jq .[].State.Code \
	| tr -d '"')

while [[ $LOADBALANCER_STATE != "active" ]];do
	echo "wait..."
	sleep 5s;
	LOADBALANCER_STATE=$(aws elbv2 describe-load-balancers \
		--query 'LoadBalancers[?VPCId=="vpc-09d517ca0e88c1e24"]|[]' \
		| jq .[].State.Code \
		| tr -d '"')
	done

echo "Getting DNS Name of loadbalancer..."
DNS_NAME=$(aws elbv2 describe-load-balancers \
    --query 'LoadBalancers[?VPCId=="'$VPCID'"]|[]' \
    | jq .[].DNSName \
	| tr -d '"')

curl $DNS_NAME

echo "Kubeconfig is in ~/.kube/config and the cluster setup is done."
