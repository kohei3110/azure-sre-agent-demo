# Terraform Backend Configuration Examples

本プロジェクトではTerraformの状態管理をより堅牢にするため、Remote Backendの使用を推奨します。

## Azure Storage Backend (推奨)

### 1. Storage Account の準備

```bash
# リソースグループの作成
az group create --name rg-terraform-state --location "East US 2"

# Storage Accountの作成
az storage account create \
  --resource-group rg-terraform-state \
  --name sttodoterraformstate \
  --sku Standard_LRS \
  --encryption-services blob

# Containerの作成
az storage container create \
  --name tfstate \
  --account-name sttodoterraformstate
```

### 2. providers.tf への追加

```terraform
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttodoterraformstate"
    container_name       = "tfstate"
    key                  = "todo-app-demo.terraform.tfstate"
  }
}
```

### 3. GitHub Actions での認証

`infrastructure.yml` に以下の環境変数を追加：

```yaml
env:
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  # Backend用の環境変数
  ARM_ACCESS_KEY: ${{ secrets.TERRAFORM_STATE_ACCESS_KEY }}
```

必要なSecrets:
```
TERRAFORM_STATE_ACCESS_KEY = storage-account-access-key
```

## Terraform Cloud Backend (代替案)

### 1. Terraform Cloud の設定

1. [Terraform Cloud](https://app.terraform.io/) でアカウント作成
2. Organization と Workspace を作成
3. API Token を生成

### 2. providers.tf への追加

```terraform
terraform {
  cloud {
    organization = "your-org-name"
    
    workspaces {
      name = "azure-sre-agent-demo"
    }
  }
}
```

### 3. GitHub Actions での認証

```yaml
env:
  TF_API_TOKEN: ${{ secrets.TF_API_TOKEN }}
```

## ローカル開発時の注意

Remote Backend使用時は、初回に以下を実行：

```bash
cd infra
terraform init
```

既存のlocal stateがある場合：

```bash
# 既存の状態をリモートにマイグレート
terraform init -migrate-state
```

## セキュリティ考慮事項

### State File の保護
- Storage Accountへのアクセス制限
- RBAC による適切な権限設定
- 暗号化の有効化

### Service Principal の権限最小化
```bash
# 必要最小限の権限でService Principal作成
az ad sp create-for-rbac --name "terraform-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/rg-todo-demo"
```

## State のバックアップ

### 定期バックアップ（推奨）
```bash
# State file のダウンロード
terraform state pull > backup-$(date +%Y%m%d).tfstate

# Storage Account への手動バックアップ
az storage blob upload \
  --account-name sttodoterraformstate \
  --container-name tfstate-backup \
  --name "backup-$(date +%Y%m%d).tfstate" \
  --file backup-$(date +%Y%m%d).tfstate
```

### GitHub Actions での自動バックアップ

```yaml
    - name: Backup Terraform State
      run: |
        terraform state pull > tfstate-backup-${{ github.sha }}.json
        
    - name: Upload State Backup
      uses: actions/upload-artifact@v4
      with:
        name: terraform-state-backup-${{ github.sha }}
        path: infra/tfstate-backup-${{ github.sha }}.json
        retention-days: 90
```
