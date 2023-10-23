# EC2 Instances

In order to create `ec2` instance follow these structures:

1. Create a `VPC` and set a name for it:

```
aws ec2 create-vpc \
    --cidr-block <IP BLOCK/MASK>
```

Tag the vpc:

```
aws ec2 create-tags \
    --resources <vpcId from the last command output> \
    --tags Key=Name,Value=<NAME>
```

2. Create an `internet-gateway` for connecting resources to the internet:

```
aws ec2 create-internet-gateway
```

Tag the internet gateway:

```
aws ec2 create-tags \
    --resources <InternetGatewayId from the last command output> \
    --tags Key=Name,Value=<NAME>
```

3. Attach the `internet gateway` to `vpc`:

```
aws ec2 attach-internet-gateway \
    --vpc-id <VPCID from the output of No.1> \
    --internet-gateway-id <InternetGatewayId from the output of No.2>
```

4. Create a public `subnet` fromt the vpc:

```
aws ec2 create-subnet \
    --vpc-id <VPCID from the output of No.1> \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key="Name",Value="<NAME>"}]' \
    --cidr-block <SUBNET CIDR BLOCK/MASK>
```


