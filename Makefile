ENV ?= dev
DIR = infra/envs/$(ENV)


fmt:
terraform -chdir=$(DIR) fmt -recursive


init:
terraform -chdir=$(DIR) init \
-backend-config="bucket=$(TF_BACKEND_BUCKET)" \
-backend-config="key=$(ENV)/terraform.tfstate" \
-backend-config="region=$(AWS_REGION)" \
-backend-config="dynamodb_table=$(TF_BACKEND_TABLE)"


plan:
terraform -chdir=$(DIR) plan -var-file=vars.tfvars -out=tfplan.bin


apply:
terraform -chdir=$(DIR) apply tfplan.bin


validate:
terraform -chdir=$(DIR) validate