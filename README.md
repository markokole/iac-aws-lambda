# iac-aws-lambda
 AWS Lambda from Terraform

Pull terraform environment

```bash
docker pull markokole/terraformer
```

Prepare the AWS credentials file before running the below command.

```bash
docker run -itd --name lambda --env-file "creds/aws/credentials" --env-file "creds/kaggle/credentials" --volume C:\marko\GitHub\iac-aws-lambda\terraform:/local-git markokole/terraformer
```

```bash
docker exec -it lambda /bin/sh
```

## In docker

cd /local-git/provision-lambda

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply -auto-approve
```

Destroy provisioned infrastructure

```bash
terraform destroy -auto-approve
```


```bash

```

```bash

```
