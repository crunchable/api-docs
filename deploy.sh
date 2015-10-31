rake build
aws s3 sync build/ s3://crunchable.io/docs
