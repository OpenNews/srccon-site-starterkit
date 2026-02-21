### AWS Authentication Setup (Completed!)

OpenNews is migrating to use [**OpenID Connect (OIDC)**](https://docs.github.com/en/actions/concepts/security/openid-connect#overview-of-openid-connect-oidc) for secure, keyless AWS authentication via a single `AWS_ROLE_ARN` secret.

This eliminates the need for long-lived credentials in the cloud or on local machines, which previously looked like `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY`. These are not configured in the GitHub Actions Workflows for security reasons. But older sites/repos that still include Travis-based deployments still use them, until we fully migrate all repos to GitHub Actions (in progress in 2025-2026).

The `AWS_ROLE_ARN` secret is stored on the GitHub [OpenNews Organization]() itself, in [Settings → Secrets and variables → Actions](https://github.com/organizations/OpenNews/settings/secrets/actions). There are no other copies of it.

**It is already working!** However, if you need to recreate its setup, here are the steps:

**Setup:**

1. **Create an OIDC Identity Provider in AWS IAM:**
   - Provider URL: `https://token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`
   - [AWS Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

2. **Create an IAM Role for GitHub Actions:**

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
         },
         "Action": "sts:AssumeRoleWithWebIdentity",
         "Condition": {
           "StringLike": {
             "token.actions.githubusercontent.com:sub": "repo:OpenNews/*:*"
           },
           "StringEquals": {
             "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
           }
         }
       }
     ]
   }
   ```

3. **Attach permissions policy to the role:**

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": ["s3:PutObject", "s3:DeleteObject", "s3:ListBucket"],
         "Resource": ["arn:aws:s3:::srccon-*", "arn:aws:s3:::srccon-*/*"]
       },
       {
         "Effect": "Allow",
         "Action": "cloudfront:CreateInvalidation",
         "Resource": "*"
       }
     ]
   }
   ```

   **Note:** The CloudFront resource is set to `*` to allow invalidation of any distribution. For tighter security, replace with specific distribution ARN patterns: `arn:aws:cloudfront::ACCOUNT_ID:distribution/*`

4. **Set the role ARN as an organization secret:**
   - Secret name: `AWS_ROLE_ARN`
   - Value: `arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActions-SRCCON-Deploy`
