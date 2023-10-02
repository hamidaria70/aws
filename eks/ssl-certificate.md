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
        --validation-method DNS
    ```

