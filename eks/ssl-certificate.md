## Secure Load Balancing

Id order to recieve requests over `https` in `EKS` cluster, we need to request
a ssl certificate using `Amazon Certificate Manager` or `ACM`. So Follow the
structure step by step:

1. Get the `hostnamezone` name, which is actually is the domain name.

    ```
    aws route53 list-hosted-zones
    ```

2. Request a certificate for your domain.

    ```
    aws acm request-certificate \
        --domain-name *.cmcloudlab367.info \
        --subject-alternative-names cmcloudlab367.info \
        --validation-method DNS \
        --tags Key=Name,Value=cmcloudlab367.info
    ```

3. Now, we should change ingress of the cluster, to do so all you need to do is
   run the `run-with-ssl` script in test directory.

   ```
   cd test
   ./run-with-ssl.sh
   ```

4. we are going to find out the `LoadBalancerArn` of the ELB, when it is ready.
In order to find the loadbalancer of the cluster node run the following commands:

    * At first, we need to get the vpcId of the cluster:

    ```
    aws eks describe-cluster \
        --name mycluster \
        --query "cluster.resourcesVpcConfig.vpcId" \
        | tr -d '"'
    ```

    * Then, we should get the LoadBalancerArn of the Loadbalancer:

    ```
    aws elbv2 describe-load-balancers \
        --query 'LoadBalancers[?VPCId=="<VPC FROM THE LAST COMMAND>"]|[]' \
        | jq .[].LoadBalancerArn \
        | tr -d '"'
    ```

5. For checking the result, we can check the `listeners` in the loadbalancer:

    ```
    aws elbv2 describe-listeners \
        --load-balancer-arn <LOADBALANCER ARN FROM THE LAST COMMAND>
    ```

6. Get the `ListenerArn` of the one which is listen on `443` or `HTTPS`
   protocol.

    ```
    aws elbv2 describe-listeners \
        --load-balancer-arn <LOADBALANCER ARN FROM THE LAST COMMAND> \
        --query "Listeners[0].ListenerArn"
    ```

7. Get the `HostHeaderConfig` of the rule, in order to set it on `Route53`, by
   running the:

    ```
    aws elbv2 describe-rules \
        --listener-arn <LISTENER ARM FROM THE LAST COMMAND> \
        --query "Rules[].Conditions[].HostHeaderConfig.Values"
    ```

8. Follow these bulletpoints to set a recored in `Route53` for accessing the
   application securely.

    * In the AWS console go to route53
    * Click on `HostedZones`
    * Click on your domain
    * Click on `Create Record`
    * In `Quick create record` under the `Record Name` type your subdomain
        name. In our case is `sample-app`.
    * Turn on the `Alias` button
    * Choose `Alias to Application and Classic Load Balancer` as an endpoint
    * Select your region in next drop-down
    * Select your load balancer
    * In the last click on `Create Records`

    Open the browser and brows for your domain, it has to be secure over https.
