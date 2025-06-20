
# Perform action Step by Step 





## Create the S3 bucket

```bash 

    aws s3 mb s3://<name-of-the-bucket> --region <region name >
```
## Prepare the website configuration
```bash 

    aws s3api put-bucket-website --bucket swan-htet-aung-phyo-static-site-101 --website-configuration '
    {
      "IndexDocument": {
        "Suffix": "index.html"
      },
      "ErrorDocument": {
        "Key": "error.html"
      }
    }
'
```


## Change the public policy
```bash

  aws s3api put-public-access-block \
  --bucket swan-htet-aung-phyo-static-site-101 \
  --public-access-block-configuration '{
    "BlockPublicAcls": false, 
    "IgnorePublicAcls": false, 
    "BlockPublicPolicy": false, 
    "RestrictPublicBuckets": false
  }'
```


## Update the website for the website configuration

```bash 
    aws s3api put-bucket-website --bucket swan-htet-aung-phyo-static-site-101 --website-configuration '
    {
      "IndexDocument": {
        "Suffix": "index.html"
      },
      "ErrorDocument": {
        "Key": "error.html"
      }
    }
'
```

##  Request the certificate

```bash
   aws acm request-certificate \
> --domain-name swan.com \
> --subject-alternative-names "*.swan.com" \
> --validation-method DNS \
> --region us-east-1
{
    "CertificateArn": "arn:aws:acm:us-east-1:162047532564:certificate/f50587fc-e27a-474d-a9f2-19da099d063e"
}
```
# Get the DNS validation Record

```bash 
     aws acm describe-certificate \
> --certificate-arn arn:aws:acm:us-east-1:162047532564:certificate/f50587fc-e27a-474d-a9f2-19da099d063e \
> --region us-east-1
```

# Wait for the certificate validation

```bash 
    aws acm describe-certificate \
    --certificate-arn arn:aws:acm:us-east-1:162047532564:certificate/f50587fc-e27a-474d-a9f2-19da099d063e \
    --region us-east-1 \
    --query 'Certificate.Status'
```
# Get the distribution ID


```bash 
    aws cloudfront list-distributions --query 'DistributionList.Items[*].[Id,Comment,DomainName]' --output table

```

# Create cloud front distribution

```bash 
    cat > cloudfront-distribution-basic.json << 'EOF'
{
    "CallerReference": "swan-website-$(date +%s)",
    "Comment": "Swan.com static website distribution",
    "DefaultRootObject": "index.html",
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3-swan-website-bucket",
                "DomainName": "swan-website-bucket.s3.amazonaws.com",
                "CustomOriginConfig": {
                    "HTTPPort": 80,
                    "HTTPSPort": 443,
                    "OriginProtocolPolicy": "http-only"
                }
            }
        ]
    },
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3-swan-website-bucket",
        "ViewerProtocolPolicy": "allow-all",
        "TrustedSigners": {
            "Enabled": false,
            "Quantity": 0
        },
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {
                "Forward": "none"
            }
        },
        "MinTTL": 0,
        "DefaultTTL": 86400,
        "MaxTTL": 31536000
    },
    "Enabled": true,
    "PriceClass": "PriceClass_100"
}
EOF
```
# Create the distribution

```bash 
    aws cloudfront create-distribution --distribution-config file://cloudfront-distribution-basic.json
```