#/bin/bash

invalid_quotas=0

account_id=$(aws sts get-caller-identity --output text | awk '{print $1}')
region=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')

validate_quota_value_above_threshold() {
    service_code=$1
    quota_arn=$2
    threshold=$3
    description=$4
    
    val=`aws service-quotas list-service-quotas --service-code $service_code | jq ".Quotas[] | select(.QuotaArn == \"$quota_arn\").Value"`

    if [ $val -lt $threshold ]; then
      echo "Value of $description ($quota_arn) is too low: $val < $threshold"
    fi
}

# max number of on-demand Inf instances
q=$(validate_quota_value_above_threshold "ec2" "arn:aws:servicequotas:${region}:${account_id}:ec2/L-1945791B" 32 "max number of on-demand Inf instances")
if [ ! -z "$q" ]; then
    echo $q
    invalid_quotas=$((invalid_quotas + 1))
fi

# max number of on-demand P instances
q=$(validate_quota_value_above_threshold "ec2" "arn:aws:servicequotas:${region}:${account_id}:ec2/L-417A185B" 20 "max number of on-demand P instances")
if [ ! -z "$q" ]; then
    echo $q
    invalid_quotas=$((invalid_quotas + 1))
fi

# max number of on-demand Trn instances L-2C3B7624
q=$(validate_quota_value_above_threshold "ec2" "arn:aws:servicequotas:${region}:${account_id}:ec2/L-2C3B7624" 24 "max number of on-demand Trn instances")
if [ ! -z "$q" ]; then
    echo $q
    invalid_quotas=$((invalid_quotas + 1))
fi

# max number of VPCs
q=$(validate_quota_value_above_threshold "ec2" "arn:aws:servicequotas:${region}:${account_id}:ec2/L-0263D0A3" 100 "max number of VPCs")
if [ ! -z "$q" ]; then
    echo $q
    invalid_quotas=$((invalid_quotas + 1))
fi

# max number of NAT gateways per AZ
q=$(validate_quota_value_above_threshold "vpc" "arn:aws:servicequotas:${region}:${account_id}:vpc/L-FE5A380F" 100 "max number of NAT gateways per AZ")
if [ ! -z "$q" ]; then
    echo $q
    invalid_quotas=$((invalid_quotas + 1))
fi

echo "Number of quotas that need adjustment: $invalid_quotas"
exit $invalid_quotas