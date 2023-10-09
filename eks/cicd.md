# CI/CD in AWS

Here is all we need for `creating git repository`, `automatically build the 
docker image`, `pushing` image to `AWS ECR`, which stands for `elastic
container registry`, and in the last `deploy` it in our EKS cluster.

1. To create a `Git` repository in AWS run the command below:

```
aws codecommit create-repository \
    --repository-name <REPO NAME> \
    --repository-description "DESCRIPTION"
```

`Clone https` and `ssh` url is already in the output.

2. There are two options for each type of cloning the repo with `https` and 
`ssh`...#TODO Complete this!!!
