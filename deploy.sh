rake build
aws s3 sync build/ s3://docs.heatintelligence.com
