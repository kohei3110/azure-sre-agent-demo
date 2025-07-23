# インフラストラクチャ仕様書

## 概要

本仕様書では、コスト最適化とゼロスケール機能を活用したToDoアプリケーションのインフラストラクチャ構成を定義します。

## アーキテクチャ概要

### 全体構成
- **フロントエンド**: Azure Static Web Apps
- **バックエンド**: Azure Container Apps
- **データベース**: Azure Cosmos DB (Serverless)
- **監視**: Application Insights
- **Infrastructure as Code**: Terraform (モジュール構成)
- **管理**: SRE Agent

### 特徴
- ゼロスケール対応による大幅なコスト削減
- サーバーレス・コンテナベースの構成
- 完全マネージドサービスの活用

## サービス仕様

### 1. Azure Static Web Apps
**目的**: フロントエンド（React）のホスティング

**仕様**:
- プラン: Standard（Container Appsとの連携のため）
- フレームワーク: React（TypeScript）
- 自動ビルド・デプロイ: GitHub Actions連携
- カスタムドメイン対応
- CDN機能内蔵
- SPA対応のルーティング
- 認証・認可機能（任意）
- API統合: Container Apps Backend連携

**Container Apps連携機能**:
- Linked Backend設定によるContainer Appsとの統合
- `/api/*` ルートの自動プロキシ転送
- Static Web Apps認証のContainer Appsへの継承
- 環境変数による動的設定
- SSL終端とHTTPS通信の一元化

**Linked Backend の仕組み**:
```
Client Request: https://myapp.azurestaticapps.net/api/todos
                                ↓
Static Web Apps: プロキシ処理 + 認証チェック
                                ↓
Container Apps: https://backend.internal/api/todos
                                ↓
Response: JSON データ → Client
```

**設定例**:
```json
{
  "linkedBackend": {
    "resourceId": "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.App/containerApps/todo-backend",
    "region": "East US 2"
  },
  "routing": {
    "rules": [
      {
        "route": "/api/*",
        "allowedRoles": ["anonymous"]
      }
    ]
  }
}
```

**コスト最適化**:
- Standardプランの固定費用（約$9/月）
- 帯域幅制限による予期しない課金防止
- Container Appsとの統合によるアーキテクチャ簡素化

### 2. Azure Container Apps
**目的**: バックエンドAPI（REST API）のホスティング

**仕様**:
- 最小レプリカ数: 0（ゼロスケール対応）
- 最大レプリカ数: 10
- CPU: 0.25 vCPU
- メモリ: 0.5 GB
- コンテナイメージ: Azure Container Registry
- イングレス: HTTPS有効、外部トラフィック許可
- 環境変数による設定管理

**Static Web Apps連携**:
- リンクされたバックエンド設定
- `/api/*` エンドポイントの自動ルーティング
- 統合認証とセッション管理
- 環境間での一貫した設定管理

**スケーリング**:
- HTTP リクエストベーススケーリング
- ゼロインスタンス時の自動スケールアップ
- アイドル状態でのゼロスケールダウン

**セキュリティ**:
- マネージドID利用
- 環境変数での接続文字列管理
- HTTPS強制
- Static Web Appsとの内部通信暗号化

### 3. Azure Cosmos DB (SQL API)
**目的**: ToDoデータの永続化

**仕様**:
- モード: Serverless
- API: Core (SQL)
- 地理的冗長性: 無効（コスト最適化）
- バックアップ: 自動バックアップ（7日間保持）
- 整合性レベル: Session

**コスト最適化**:
- Serverlessモードによる使用量ベース課金
- 自動パーティション管理
- 需要に応じた自動スケーリング

**データモデル**:
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "completed": "boolean",
  "createdAt": "datetime",
  "updatedAt": "datetime",
  "userId": "string"
}
```

### 4. Application Insights
**目的**: アプリケーション監視・ログ収集

**仕様**:
- データ保持期間: 90日
- サンプリング率: 100%（開発時）、10%（本番時）
- カスタムメトリクス設定
- アラート設定

**監視項目**:
- API応答時間
- エラー率
- 可用性
- パフォーマンスカウンタ
- カスタムイベント

### 5. Azure Container Registry
**目的**: コンテナイメージの管理

**仕様**:
- SKU: Basic（コスト最適化）
- 地理的レプリケーション: 無効
- イメージの脆弱性スキャン: Standard以上で有効化

### 6. Azure Load Testing
**目的**: パフォーマンステスト・負荷テストの実行

**仕様**:
- エンジン数: 1-10（テスト規模に応じて動的調整）
- 負荷生成: JMeter または Apache Bench ベース
- 地理的分散テスト: 複数リージョンからの負荷生成対応
- CI/CD統合: GitHub Actions、Azure DevOpsとの連携
- リアルタイム監視: Application Insightsとの統合

**テストシナリオ**:
- 基本負荷テスト: 通常トラフィックのシミュレーション
- スパイクテスト: 急激な負荷増加のテスト
- 持続負荷テスト: 長時間の負荷耐性テスト
- ゼロスケール検証: Container Appsのコールドスタート性能

**統合機能**:
- Application Insightsメトリクス連携
- Container Appsオートスケール検証
- Cosmos DBパフォーマンス測定
- Static Web Apps CDN効果測定

**コスト最適化**:
- テスト実行時のみ課金
- 自動テスト終了によるコスト制御
- 最小限のエンジン数での効率的テスト

## セキュリティ要件

### 認証・認可
- Azure AD B2C または Entra ID連携（任意）
- Static Web AppsのBuilt-in認証機能活用
- Container Apps間通信のマネージドID利用

### ネットワークセキュリティ
- HTTPS強制
- CORS設定
- Container Apps環境の分離

### パフォーマンステスト
- Load Testing環境の分離
- テストデータの匿名化
- 本番環境への影響回避

### データ保護
- Cosmos DB暗号化（保存時・転送時）
- 接続文字列の安全な管理
- Key Vaultによるシークレット管理（必要に応じて）

## Terraform構成

### ディレクトリ構造
```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── modules/
│   ├── static-web-app/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── container-apps/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── cosmos-db/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── monitoring/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── load-testing/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    └── demo.tfvars
```

### 活用するAzure Verified Modules
- `Azure/avm-res-web-staticsite`
- `Azure/avm-res-app-containerapp`
- `Azure/avm-res-documentdb-databaseaccount`
- `Azure/avm-res-insights-component`
- `Azure/avm-res-loadtesting-loadtest`

### 共通リソース
- Resource Group
- Log Analytics Workspace
- Application Insights
- Load Testing リソース

### Terraform設定例（Linked Backend）

#### Static Web Apps + Container Apps統合設定
```hcl
# Container Apps環境
resource "azurerm_container_app_environment" "main" {
  name                = "cae-${var.environment_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  tags = local.common_tags
}

# Container Apps - Backend API
resource "azurerm_container_app" "backend" {
  name                         = "ca-todo-backend-${var.environment_name}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name         = azurerm_resource_group.main.name
  revision_mode               = "Single"

  template {
    min_replicas = 0  # ゼロスケール対応
    max_replicas = 10

    container {
      name   = "todo-backend"
      image  = "${azurerm_container_registry.main.login_server}/todo-backend:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "AZURE_COSMOS_CONNECTION_STRING"
        value = azurerm_cosmosdb_account.main.connection_strings[0]
      }
      
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.main.connection_string
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled          = true
    target_port               = 8080

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  tags = local.common_tags
}

# Static Web Apps with Linked Backend
resource "azurerm_static_site" "main" {
  name                = "stapp-todo-${var.environment_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku_tier           = "Standard"
  sku_size           = "Standard"

  # Linked Backend設定
  linked_backend {
    backend_resource_id = azurerm_container_app.backend.id
    region             = var.location
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
  }

  tags = local.common_tags
}

# 統合環境変数管理
locals {
  environment_variables = {
    # 統一された環境変数名
    VITE_CONTAINER_APPS_URL = azurerm_container_app.backend.ingress[0].fqdn
    AZURE_COSMOS_CONNECTION_STRING = azurerm_cosmosdb_account.main.connection_strings[0]
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main.connection_string
  }
}

# Terraform出力値（CI/CDパイプライン連携用）
output "container_apps_fqdn" {
  description = "Container Apps Backend FQDN"
  value       = azurerm_container_app.backend.ingress[0].fqdn
}

output "static_web_app_hostname" {
  description = "Static Web Apps Hostname"
  value       = azurerm_static_site.main.default_host_name
}

output "cosmos_db_endpoint" {
  description = "Cosmos DB Endpoint"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "application_insights_connection_string" {
  description = "Application Insights Connection String"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}
```

## 環境構成

### ローカル開発環境
- Container Apps の直接接続
- デバッグ機能有効
- サンプリング率100%
- 認証無効（デモ用途）

### Azureデモ環境
- Static Web Apps + Container Apps Linked Backend構成
- 監視・アラート有効
- Application Insights統合
- Load Testing統合テスト実行
- サンプリング率10%

## SRE Agent管理項目

### 監視対象
- アプリケーションヘルス
- パフォーマンスメトリクス
- コスト使用量
- セキュリティアラート
- 負荷テスト結果とトレンド

### 自動化対象
- リソーススケーリング
- 定期的なヘルスチェック
- バックアップ検証
- コスト最適化提案
- 定期的な負荷テスト実行

### アラート設定
- API応答時間 > 2秒
- エラー率 > 5%
- 月次コスト上限超過
- 可用性 < 99%
- 負荷テスト失敗時のアラート
- パフォーマンス劣化検知

## コスト見積もり

### 月額概算コスト（使用量ベース）
- Static Web Apps: $9/月（Standard プラン）
- Container Apps: $0-50/月（ゼロスケール時$0）
- Cosmos DB Serverless: $0-25/月（使用量による）
- Application Insights: $0-10/月
- Container Registry: $5/月
- Load Testing: $0-20/月（テスト実行時のみ）

**総額**: $14-119/月（使用量により変動）

## デプロイメント戦略

### CI/CD Pipeline
1. GitHub Actions による自動ビルド
2. React アプリケーションのビルド・最適化
3. Container イメージのビルド・プッシュ
4. Terraform apply による Infrastructure更新
5. Container Apps デプロイ
6. Static Web Apps デプロイ（Container Apps連携設定含む）
7. 負荷テスト実行（Load Testing）
8. パフォーマンス検証とレポート生成
9. 統合テスト実行

### ロールバック戦略
- Infrastructure: Terraform state管理
- Application: コンテナイメージのバージョン管理
- Database: Point-in-time recovery機能活用
- Load Testing: テストシナリオのバージョン管理

## 運用・保守

### 定期メンテナンス
- 月次コストレビュー
- 四半期セキュリティレビュー
- 年次アーキテクチャレビュー
- 月次パフォーマンステスト実行
- 負荷テストシナリオの定期見直し

### 災害対策
- 自動バックアップ機能の活用
- 地理的冗長性（必要に応じて有効化）
- RTO: 4時間、RPO: 1時間

## 付録

### 関連ドキュメント
- [アプリケーション仕様書](./application-specification.md)
- [運用手順書](./operation-manual.md)
- [セキュリティガイドライン](./security-guidelines.md)

### 更新履歴
- 2025年7月23日: 初版作成
- 2025年7月23日: React フロントエンド、Static Web Apps Standard プラン対応
- 2025年7月23日: Azure Load Testing 追加、パフォーマンステスト機能強化