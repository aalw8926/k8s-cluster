The cross-account IAM role belongs to the target AWS account. We authenticate to the source/Prod account using AWS SSO, then use the `assume_role_paastry_prod.sh` script to assume the role and access resources in the target account.

### 1. Log in to the source/Prod account using SSO

```bash
aws sso login --profile <PROD_PROFILE>
```

Verify the SSO session:

```bash
aws sts get-caller-identity --profile <PROD_PROFILE>
```

### 2. Run the cross-account assume-role script

```bash
source ./assume_role.sh <TARGET_ACCOUNT_ID> <ROLE_NAME>
```

The script uses the Prod SSO credentials to assume the role in the target account and exports the temporary credentials into the current shell.

### 3. Verify the target account

```bash
aws sts get-caller-identity
```

The returned `Account` should be the target AWS account.

### 4. Check EKS clusters

```bash
aws eks list-clusters --region <REGION>
```
