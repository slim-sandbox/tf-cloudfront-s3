# Overview
Solution to create a static site using S3 and Cloudfront

# Setup
## 1. Download example static site
Have a copy of the static site within this project's root directory.
```bash
git clone git@github.com:cloudacademy/static-website-example.git
```

Content of the project would be as follows
```bash
# command: tree . -L 2
.
├── README.md
├── data.tf
├── main.tf
├── output.tf
├── provider.tf
├── static-website-example
│   ├── LICENSE.MD
│   ├── README.MD
│   ├── assets
│   ├── error
│   ├── images
│   └── index.html
└── variables.tf
```

## 2. Create resources
Execute the following terraform commands
```bash
terraform init
terraform plan
terraform apply
```

## 4. Upload static site
Get the bucket name before executing commands
```bash
BUCKET_NAME="" #replace value

cd static-website-example
aws s3 sync . s3://${BUCKET_NAME} --exclude '*.MD' --exclude '.git*'
```

# Tips
Following a successful build for activity 1, feel free to comment/uncomment the required codeblocks to fulfill activity 2 requirements.