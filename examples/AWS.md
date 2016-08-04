# AWS Account Setup

A set of recommended instructions when running through the examples

1. [Signup] for an account or [Signin] to the account

[Signup]: https://portal.aws.amazon.com/gp/aws/developer/registration/index.html
[Signin]: https://console.aws.amazon.com/

2. Create an [IAM user] in the us-east-1 with API keys (save credentials)

[IAM user]: https://console.aws.amazon.com/iam/home?region=us-east-1#users

3. Add an inline custom policy to the IAM user (example below)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1469773655000",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
```

The AWS IAM user account is now setup, please continue on with the [README]

[README]: README.md
