구독 기본 환경설정

```bash
export ARM_SUBSCRIPTION_ID="<subscription_id>"
```

```pwsh
$env:ARM_SUBSCRIPTION_ID = "1e2f8c37-113b-42c2-b03b-d8917ccfbb26"
```

Terraform install
https://developer.hashicorp.com/terraform/install

Azure CLI install
https://learn.microsoft.com/ko-kr/cli/azure/install-azure-cli?view=azure-cli-latest

Azure CLI Login
```
az login --use-device-code
```