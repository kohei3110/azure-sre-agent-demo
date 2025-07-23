# CI/CD Pipeline Setup Guide

このドキュメントでは、Azure Todo Appの CI/CD パイプラインのセットアップ手順を説明します。

## 📋 概要

このプロジェクトは以下のワークフローで構成されています：

1. **Infrastructure Deployment** (`infrastructure.yml`) - Terraformを使用したAzureインフラのデプロイ
2. **Backend API Deployment** (`backend.yml`) - Container AppsへのPython APIデプロイ
3. **Frontend Deployment** (`frontend.yml`) - Static Web Appsへのフロントエンドデプロイ
4. **Integration Tests** (`integration.yml`) - 統合テストとヘルスチェック

## 🔧 事前準備

### 1. Azure Service Principal の作成

```bash
# Azure CLIでログイン
az login

# Service Principalを作成
az ad sp create-for-rbac --name "azure-sre-agent-demo-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --sdk-auth
```

出力されたJSONから以下の値を記録してください：
- `clientId` → `AZURE_CLIENT_ID`
- `clientSecret` → `AZURE_CLIENT_SECRET`
- `subscriptionId` → `AZURE_SUBSCRIPTION_ID`
- `tenantId` → `AZURE_TENANT_ID`

### 2. GitHub Environment の作成

1. GitHubリポジトリの **Settings** → **Environments** へ移動
2. **New environment** をクリック
3. 環境名に `demo` を入力
4. **Configure environment** をクリック

#### Environment Protection Rules（推奨設定）
- ✅ **Required reviewers**: リポジトリ管理者を設定
- ✅ **Wait timer**: 0 minutes
- ✅ **Deployment branches**: Selected branches → `main`

## 🔐 GitHub Secrets の設定

### Environment Secrets（推奨）

`demo` 環境の **Environment secrets** に以下を設定：

#### Azure認証
```
AZURE_CLIENT_ID          = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
AZURE_CLIENT_SECRET      = your-service-principal-secret
AZURE_SUBSCRIPTION_ID    = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
AZURE_TENANT_ID          = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

#### Azureリソース
```
AZURE_RESOURCE_GROUP            = rg-todo-demo
AZURE_REGISTRY_NAME             = acrtododemo
AZURE_REGISTRY_USERNAME         = acrtododemo
AZURE_REGISTRY_PASSWORD         = your-acr-password
AZURE_CONTAINER_APP_NAME        = ca-todo-backend-demo
AZURE_STATIC_WEB_APPS_API_TOKEN = your-swa-api-token
AZURE_LOAD_TESTING_RESOURCE     = lt-todo-demo
```

#### 接続文字列
```
AZURE_COSMOS_CONNECTION_STRING      = AccountEndpoint=https://...
APPLICATIONINSIGHTS_CONNECTION_STRING = InstrumentationKey=...
```

#### Static Web Apps
```
STATIC_WEB_APP_HOSTNAME  = myapp.azurestaticapps.net
```

#### 通知（オプション）
```
SLACK_WEBHOOK_URL        = https://hooks.slack.com/services/...
```

### Repository Secrets（代替方法）

Environment Secretsの代わりに、リポジトリレベルのSecretsを使用することも可能です：
**Settings** → **Secrets and variables** → **Actions** → **Repository secrets**

## 🚀 ワークフローの実行方法

### 自動実行

#### Push to main
```bash
git add .
git commit -m "Update infrastructure"
git push origin main
```
→ インフラストラクチャが自動的にデプロイされます

#### Pull Request
```bash
git checkout -b feature/new-feature
# 変更を加える
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
# GitHub でPRを作成
```
→ Terraform Planが自動的に実行され、PRにコメントが追加されます

### 手動実行（Workflow Dispatch）

#### インフラストラクチャの手動デプロイ

1. **Actions** タブ → **Deploy Infrastructure** を選択
2. **Run workflow** をクリック
3. パラメータを設定：

**計画確認のみ**
```
Action: plan
Environment: demo
Confirm Destroy: (空白)
```

**即座にデプロイ**
```
Action: apply
Environment: demo
Confirm Destroy: (空白)
```

**環境を削除（⚠️注意）**
```
Action: destroy
Environment: demo
Confirm Destroy: CONFIRM
```

## 📊 ワークフローの詳細

### Infrastructure Workflow

- **トリガー**: main ブランチへのpush、PR、手動実行
- **実行内容**:
  - Terraform format check
  - Terraform init, validate, plan
  - Apply（mainブランチまたは手動実行時）
  - Plan結果をPRにコメント
  - 出力値をGitHub Step Summaryに表示

### Backend Workflow

- **トリガー**: backend/ フォルダの変更、手動実行
- **実行内容**:
  - Python環境のセットアップ（uv使用）
  - テストの実行とカバレッジ計測  
  - Dockerイメージのビルドとプッシュ
  - Container Appsへのデプロイ

### Frontend Workflow

- **トリガー**: frontend/ フォルダの変更、手動実行
- **実行内容**:
  - Node.js環境のセットアップ
  - ユニットテストとE2Eテストの実行
  - ビルドとStatic Web Appsへのデプロイ

### Integration Workflow

- **トリガー**: 他の3つのワークフローの完了後、手動実行
- **実行内容**:
  - 統合テストの実行
  - 負荷テストの実行
  - ヘルスチェック
  - Slack通知（オプション）

## 🛡️ セキュリティ機能

### Environment Protection
- `demo` 環境での承認ルール
- デプロイメント前のレビュー必須

### Destroy Protection
- 削除操作時の明示的確認（`CONFIRM`入力）
- 誤った削除の防止

### Audit Trail
- すべてのワークフロー実行の完全な履歴
- GitHub Actions の実行ログ

## 🔍 トラブルシューティング

### よくある問題

#### 1. Terraform の認証エラー
```
Error: building AzureRM Client: obtain subscription() from Azure CLI: Azure CLI Profile either not found or not set up.
```

**解決方法**: Azure認証用のSecretsが正しく設定されているか確認

#### 2. Container Registry の認証エラー
```
Error: failed to authorize: failed to fetch anonymous token: unexpected status: 401 Unauthorized
```

**解決方法**: `AZURE_REGISTRY_USERNAME` と `AZURE_REGISTRY_PASSWORD` を確認

#### 3. Static Web Apps APIトークンエラー
```
Error: The provided token is invalid.
```

**解決方法**: Azure PortalでStatic Web AppsのAPIトークンを再生成

### ログの確認方法

1. **Actions** タブで該当のワークフロー実行を選択
2. 失敗したジョブをクリック
3. ログを展開して詳細を確認

## 📚 関連ドキュメント

- [Infrastructure Specification](../docs/specs/infrastructure-specification.md)
- [Backend Specification](../docs/specs/backend-specification.md)
- [Frontend Specification](../docs/specs/frontend-specification.md)
- [CI/CD Pipeline Specification](../docs/specs/cicd-pipeline-specification.md)

## 🏷️ タグとリリース

ワークフローは以下のタグ付けルールに従います：

- Docker images: `latest` と `{git-sha}`
- Terraform plan artifacts: 30日間保持
- ワークフロー実行ログ: GitHubの標準保持期間

## 💰 コスト最適化

- **条件付きデプロイ**: 変更のあるコンポーネントのみビルド
- **パラレル実行**: ビルド時間の短縮
- **キャッシュ活用**: 依存関係のキャッシュでリソース削減
