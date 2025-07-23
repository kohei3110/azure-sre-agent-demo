# GitHub Actions で動的 tfvars 生成

## 概要

GitHub Actions上で `demo.tfvars` ファイルを動的に生成することで、環境固有の設定やシークレットを安全に管理し、リポジトリにセンシティブな情報を保存することなくデプロイメントを実行できます。

## 実装方法

### 1. ワークフロー入力パラメータ

Infrastructure ワークフローでは以下のパラメータを受け取れます：

- **action**: `plan` / `apply` / `destroy`
- **environment**: `demo`（将来的に他の環境も追加可能）
- **location**: Azure リージョン（デフォルト: `East US 2`）
- **project_name**: プロジェクト名（デフォルト: `todo-app`）
- **container_image**: コンテナイメージ（デフォルト: Hello World イメージ）
- **confirm_destroy**: 削除時の確認文字列

### 2. 動的生成ステップ

```yaml
- name: Generate tfvars file
  run: |
    # 環境設定値の取得
    ENVIRONMENT="${{ github.event.inputs.environment || 'demo' }}"
    LOCATION="${{ github.event.inputs.location || 'East US 2' }}"
    PROJECT="${{ github.event.inputs.project_name || 'todo-app' }}"
    CONTAINER_IMAGE="${{ github.event.inputs.container_image || 'default-image' }}"
    
    # tfvars ファイルの動的生成
    cat > environments/${ENVIRONMENT}.tfvars << EOF
    environment_name = "${ENVIRONMENT}"
    location        = "${LOCATION}"
    project_name    = "${PROJECT}"
    container_image = "${CONTAINER_IMAGE}"
    # ... その他の設定
    EOF
```

### 3. 生成される内容

- **基本設定**: environment_name, location, project_name
- **リソース名**: 自動生成されるリソース名（空文字で自動命名）
- **Container Apps**: CPU、メモリ、レプリカ数の設定
- **Container Image**: ワークフロー入力で指定可能
- **Cosmos DB**: データベース・コンテナ設定
- **タグ**: GitHub情報を含む包括的なタグ設定

## メリット

### 🔒 セキュリティ
- リポジトリにセンシティブな情報を保存しない
- 環境変数とシークレットを分離
- ワークフロー実行時のみファイル生成

### 🔄 柔軟性
- 実行時にパラメータを変更可能
- 複数環境への対応が容易
- CI/CDパイプライン間での設定共有

### 📊 トレーサビリティ
- GitHub Run ID、Commit SHA、Actor など自動記録
- デプロイメント履歴の完全な追跡
- 実行コンテキストの自動埋め込み

### 🚀 自動化
- 手動でのファイル作成・更新が不要
- ワークフロー間での一貫した設定
- エラーの削減

## 使用方法

### 1. 手動実行

GitHub UI から Infrastructure ワークフローを実行：

1. Actions タブ → "Deploy Infrastructure" ワークフロー
2. "Run workflow" をクリック
3. パラメータを設定：
   - Action: `plan` / `apply` / `destroy`
   - Environment: `demo`
   - Location: `East US 2`（またはお好みのリージョン）
   - Project Name: `todo-app`（またはカスタム名）
   - Container Image: カスタムイメージ（オプション）

### 2. 自動実行

main ブランチへの push 時に自動実行される場合、デフォルト値が使用されます。

### 3. バックエンドとの連携

バックエンドワークフローでビルドされたコンテナイメージを使用する場合：

```bash
# バックエンドワークフロー完了後
gh workflow run infrastructure.yml \
  -f action=apply \
  -f environment=demo \
  -f container_image="your-acr.azurecr.io/todo-backend:v1.2.3"
```

## 設定の拡張

### 新しいパラメータの追加

1. ワークフロー入力に追加：
```yaml
inputs:
  new_parameter:
    description: 'New Parameter Description'
    required: false
    default: 'default-value'
    type: string
```

2. 生成スクリプトに追加：
```bash
NEW_PARAM="${{ github.event.inputs.new_parameter || 'default-value' }}"
```

3. tfvars テンプレートに追加：
```hcl
new_parameter = "${NEW_PARAM}"
```

### 環境変数の利用

リポジトリの Settings → Secrets and variables → Actions で設定：

- **Secrets**: 機密情報（Azure credentials など）
- **Variables**: 非機密設定（リージョン、SKU など）

## トラブルシューティング

### よくある問題

1. **tfvars ファイルが見つからない**
   ```
   Error: Failed to read variables file
   Given variables file environments/demo.tfvars does not exist.
   ```
   → 動的生成ステップが正常に実行されているか確認

2. **パラメータの値が反映されない**
   → ワークフロー入力の記法とシェルスクリプトの変数参照を確認

3. **タグの値が不正**
   → GitHub コンテキスト変数の参照方法を確認

### デバッグ方法

1. **生成内容の確認**:
   ```bash
   echo "📋 Content preview:"
   head -20 environments/${ENVIRONMENT}.tfvars
   ```

2. **パラメータ値の確認**:
   ```bash
   echo "📝 Configuration values:"
   echo "  Environment: ${ENVIRONMENT}"
   echo "  Location: ${LOCATION}"
   ```

## 関連ファイル

- `.github/workflows/infrastructure.yml`: Infrastructure ワークフロー
- `infra/tfvars-template.hcl`: tfvars テンプレート（参考用）
- `infra/variables.tf`: Terraform 変数定義
- `infra/environments/`: 生成される tfvars ファイルの保存先

## 今後の拡張計画

- 複数環境対応（staging, production）
- より詳細なリソース設定のカスタマイズ
- 設定バリデーション機能
- 設定のバージョン管理
