#!/bin/bash

# Usage:
#   source ./assume_role.sh <TARGET_ACCOUNT_ID> <ROLE_NAME>
#
# Example:
#   source ./assume_role.sh 478198878478 PaastryCrossAccountIAMRole-us-east-1

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: source ./assume_role.sh <TARGET_ACCOUNT_ID> <ROLE_NAME>"
    return 1 2>/dev/null || exit 1
fi

account="$1"
role="$2"
source_profile="paastry-prod"

echo "Checking SSO credentials..."

if ! aws sts get-caller-identity --profile "$source_profile" >/dev/null 2>&1; then
    echo "SSO session expired or not logged in."
    echo "Run: aws sso login --profile $source_profile"
    return 1 2>/dev/null || exit 1
fi

echo "Assuming role ${role} in account ${account}..."

temp_role=$(aws sts assume-role \
    --profile "$source_profile" \
    --role-arn "arn:aws:iam::${account}:role/${role}" \
    --role-session-name "${account}-PaastryCrossAccountRole")

if [ $? -ne 0 ]; then
    echo "Failed to assume role."
    return 1 2>/dev/null || exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo "$temp_role" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$temp_role" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$temp_role" | jq -r '.Credentials.SessionToken')
export AWS_REGION="us-east-1"

echo "Successfully assumed role."
aws sts get-caller-identity