# バックエンドAPI仕様書

## 概要

本仕様書では、ToDoアプリケーションのバックエンドAPIの詳細な仕様を定義します。
CRUD操作に加え、SRE Agent のデモンストレーション用途として、意図的にアプリケーションをダウンさせるメモリ消費処理も含みます。

## アーキテクチャ概要

### 技術スタック
- **ランタイム**: Python 3.13
- **フレームワーク**: FastAPI
- **パッケージ管理**: uv
- **データベース**: Azure Cosmos DB (SQL API)
- **認証**: Azure AD B2C (オプション)
- **ログ**: Application Insights SDK (opencensus-ext-azure)
- **コンテナ**: Docker

### デプロイメント
- **プラットフォーム**: Azure Container Apps
- **スケーリング**: 0-10インスタンス（ゼロスケール対応）
- **リソース**: CPU 0.25 vCPU, メモリ 0.5 GB

## API仕様

### ベースURL
```
https://{container-app-name}.{region}.azurecontainerapps.io/api
```

### 共通仕様

#### レスポンス形式
```json
{
  "success": true,
  "data": {},
  "message": "string",
  "timestamp": "2025-07-23T10:00:00.000Z"
}
```

#### エラーレスポンス
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "エラーメッセージ",
    "details": {}
  },
  "timestamp": "2025-07-23T10:00:00.000Z"
}
```

#### HTTPステータスコード
- `200 OK`: 成功
- `201 Created`: リソース作成成功
- `400 Bad Request`: リクエストエラー
- `404 Not Found`: リソースが見つからない
- `500 Internal Server Error`: サーバーエラー
- `503 Service Unavailable`: メモリ消費処理実行中

## エンドポイント仕様

### 1. ヘルスチェック

#### GET /health
**目的**: アプリケーションの生存確認

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "uptime": 1234567,
    "memory": {
      "used": "50MB",
      "total": "512MB",
      "percentage": 9.8
    },
    "database": "connected",
    "version": "1.0.0",
    "python_version": "3.13.0"
  },
  "timestamp": "2025-07-23T10:00:00.000Z"
}
```

#### GET /health/ready
**目的**: Readiness Probe用エンドポイント

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "status": "ready",
    "dependencies": {
      "database": "connected",
      "insights": "connected"
    }
  }
}
```

### 2. ToDoアイテム管理

#### GET /todos
**目的**: ToDoアイテム一覧取得

**クエリパラメータ**:
- `limit`: 取得件数（デフォルト: 50, 最大: 100）
- `offset`: オフセット（デフォルト: 0）
- `completed`: 完了状態フィルタ（true/false）
- `sortBy`: ソート項目（createdAt/updatedAt/title）
- `sortOrder`: ソート順（asc/desc）

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "todos": [
      {
        "id": "uuid-string",
        "title": "タスクのタイトル",
        "description": "タスクの詳細",
        "completed": false,
        "createdAt": "2025-07-23T10:00:00.000Z",
        "updatedAt": "2025-07-23T10:00:00.000Z",
        "userId": "user-id"
      }
    ],
    "total": 100,
    "limit": 50,
    "offset": 0
  }
}
```

#### GET /todos/:id
**目的**: 特定ToDoアイテム取得

**パスパラメータ**:
- `id`: ToDoアイテムID

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "id": "uuid-string",
    "title": "タスクのタイトル",
    "description": "タスクの詳細",
    "completed": false,
    "createdAt": "2025-07-23T10:00:00.000Z",
    "updatedAt": "2025-07-23T10:00:00.000Z",
    "userId": "user-id"
  }
}
```

#### POST /todos
**目的**: 新規ToDoアイテム作成

**リクエストボディ**:
```json
{
  "title": "タスクのタイトル",
  "description": "タスクの詳細（オプション）"
}
```

**バリデーション**:
- `title`: 必須、1-200文字
- `description`: オプション、最大1000文字

**デモ機能（意図的障害）**:
- 約50%の確率でメモリ大量消費処理を実行
- 600MBのメモリを30秒間消費してアプリケーションをダウンさせる
- 環境変数`DEMO_FEATURES_ENABLED=true`の場合のみ実行

**レスポンス**: `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "uuid-string",
    "title": "タスクのタイトル",
    "description": "タスクの詳細",
    "completed": false,
    "createdAt": "2025-07-23T10:00:00.000Z",
    "updatedAt": "2025-07-23T10:00:00.000Z",
    "userId": "user-id"
  }
}
```

#### PUT /todos/:id
**目的**: ToDoアイテム更新

**パスパラメータ**:
- `id`: ToDoアイテムID

**リクエストボディ**:
```json
{
  "title": "更新されたタイトル",
  "description": "更新された詳細",
  "completed": true
}
```

**バリデーション**:
- `title`: オプション、1-200文字
- `description`: オプション、最大1000文字
- `completed`: オプション、boolean

**デモ機能（意図的障害）**:
- 約50%の確率でメモリ大量消費処理を実行
- 600MBのメモリを30秒間消費してアプリケーションをダウンさせる
- 環境変数`DEMO_FEATURES_ENABLED=true`の場合のみ実行

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "id": "uuid-string",
    "title": "更新されたタイトル",
    "description": "更新された詳細",
    "completed": true,
    "createdAt": "2025-07-23T10:00:00.000Z",
    "updatedAt": "2025-07-23T10:30:00.000Z",
    "userId": "user-id"
  }
}
```

#### DELETE /todos/:id
**目的**: ToDoアイテム削除

**パスパラメータ**:
- `id`: ToDoアイテムID

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "id": "uuid-string",
    "deleted": true
  }
}
```

### 3. 統計情報

#### GET /stats
**目的**: ToDoアイテムの統計情報取得

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "totalTodos": 150,
    "completedTodos": 75,
    "pendingTodos": 75,
    "completionRate": 50.0,
    "todaysCreated": 5,
    "todaysCompleted": 3
  }
}
```

## デモ用機能（意図的障害発生）

### 4. CRUD処理内でのランダム障害発生

#### メモリ大量消費処理の自動実行
**概要**: ToDoアイテムの作成（POST）・更新（PUT）処理時に約50%の確率で自動実行される

**実行条件**:
- 環境変数`DEMO_FEATURES_ENABLED=true`が設定されている場合のみ
- `random.random() < 0.5`で確率判定
- POST /todos または PUT /todos/:id の処理時

**処理内容**:
- メモリ消費量: 600MB（Container Appsの制限0.5GB=512MBを超過）
- 持続時間: 30秒
- 実装方式: `bytearray`による大量メモリ確保
- 実行方式: バックグラウンドタスクで非同期実行

**実装詳細**:
```python
import random
import asyncio
import gc
from typing import Optional

class MemoryStressService:
    def __init__(self):
        self.active_stress: Optional[asyncio.Task] = None
        self.stress_data: list = []
    
    async def maybe_trigger_memory_stress(self) -> bool:
        """50%の確率でメモリストレステストを実行"""
        if not os.getenv("DEMO_FEATURES_ENABLED", "false").lower() == "true":
            return False
            
        if random.random() < 0.5:
            # バックグラウンドでメモリ消費を開始
            self.active_stress = asyncio.create_task(self._consume_memory())
            return True
        return False
    
    async def _consume_memory(self):
        """600MBのメモリを30秒間消費"""
        try:
            # 600MB のメモリを確保
            size_mb = 600
            chunk_size = 1024 * 1024  # 1MB
            
            for i in range(size_mb):
                self.stress_data.append(bytearray(chunk_size))
                await asyncio.sleep(0.01)  # 他の処理に譲る
            
            # 30秒間保持
            await asyncio.sleep(30)
            
        finally:
            # メモリを解放
            self.stress_data.clear()
            gc.collect()
```

**影響範囲**:
- 対象エンドポイント: `POST /todos`, `PUT /todos/:id`
- 発生確率: 約50%
- 影響時間: 30秒間
- Container Appsインスタンスのクラッシュとなる

**ログ出力例**:
```json
{
  "timestamp": "2025-07-23T10:00:00.000Z",
  "level": "warn",
  "message": "Memory stress test triggered during TODO creation",
  "metadata": {
    "request_id": "req-123",
    "endpoint": "POST /todos",
    "memory_target": "600MB",
    "duration": "30s",
    "triggered": true
  }
}
```

## データモデル

### ToDoアイテム
```python
from pydantic import BaseModel
from datetime import datetime
from typing import Optional
import uuid

class TodoItem(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    completed: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    user_id: str = Field(..., description="ユーザーID（認証有効時）")

class TodoCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)

class TodoUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    completed: Optional[bool] = None
```

### パーティション戦略
- **パーティションキー**: `user_id` または `"global"`（認証なしの場合）
- **ソートキー**: `id`

## エラーハンドリング

### エラーコード一覧
- `VALIDATION_ERROR`: バリデーションエラー
- `TODO_NOT_FOUND`: ToDoが見つからない
- `DATABASE_ERROR`: データベースエラー
- `MEMORY_STRESS_TRIGGERED`: CRUD処理中にメモリ消費処理が発動
- `INTERNAL_SERVER_ERROR`: 内部サーバーエラー

### ログ出力
```python
import logging
from datetime import datetime
from typing import Optional

class LogEntry:
    def __init__(
        self,
        level: str,
        message: str,
        request_id: str,
        user_id: Optional[str] = None,
        endpoint: str = "",
        response_time: float = 0.0,
        memory_usage: int = 0
    ):
        self.timestamp = datetime.utcnow().isoformat()
        self.level = level
        self.message = message
        self.metadata = {
            "request_id": request_id,
            "user_id": user_id,
            "endpoint": endpoint,
            "response_time": response_time,
            "memory_usage": memory_usage
        }
```

## パフォーマンス要件

### 通常時のパフォーマンス目標
- **API応答時間**: 95%ile < 200ms
- **スループット**: 100 req/sec
- **メモリ使用量**: < 200MB
- **CPU使用率**: < 70%

### メモリ消費処理実行時
- **想定応答時間**: > 10秒または無応答
- **メモリ使用量**: 容器上限（512MB）まで消費
- **回復時間**: 処理終了後30秒以内

## 監視・アラート

### メトリクス
- HTTP リクエスト数・レスポンス時間
- エラー率
- メモリ・CPU使用率
- データベース接続状況
- アクティブな障害デモ処理

### アラート条件
- API応答時間 > 2秒
- エラー率 > 5%
- メモリ使用率 > 90%
- CPU使用率 > 90%
- データベース接続失敗
- CRUD処理中のメモリ消費処理発動時

## セキュリティ

### 認証・認可
- Azure AD B2C統合（オプション）
- JWT トークン検証（PyJWT使用）
- ユーザーベースのデータ分離

### 入力検証
- Pydanticによる自動バリデーション
- SQLインジェクション対策（Cosmos DB SDKによる自動エスケープ）
- XSS対策（fastapi.security使用）

### レート制限
- 通常API: 100 req/min/IP（slowapi使用）
- デモAPI: 5 req/min/IP

## 環境変数

```bash
# データベース接続（統一変数名）
AZURE_COSMOS_CONNECTION_STRING=AccountEndpoint=https://{account}.documents.azure.com:443/;AccountKey={key};

# Application Insights（統一変数名）
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...

# 認証（オプション）
AZURE_CLIENT_ID=client-id
AZURE_CLIENT_SECRET=client-secret
AZURE_TENANT_ID=tenant-id

# アプリケーション設定
ENVIRONMENT=production
PORT=8080
LOG_LEVEL=INFO
UVICORN_HOST=0.0.0.0
UVICORN_PORT=8080

# デモ機能制御
DEMO_FEATURES_ENABLED=true
MAX_MEMORY_STRESS_MB=600
MEMORY_STRESS_DURATION=30
MEMORY_STRESS_PROBABILITY=0.5

# uv設定
UV_SYSTEM_PYTHON=1
```

## Docker設定

### Dockerfile
```dockerfile
# マルチステージビルドでuvを活用
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder

# 作業ディレクトリ設定
WORKDIR /app

# uvを使用してPythonとパッケージをインストール
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-cache

# アプリケーションコードをコピー
COPY . .

# 本番用イメージ
FROM python:3.13-slim AS runtime

# 作業ディレクトリ設定
WORKDIR /app

# uvから仮想環境をコピー
COPY --from=builder /app/.venv /app/.venv

# アプリケーションコードをコピー
COPY --from=builder /app .

# 仮想環境をPATHに追加
ENV PATH="/app/.venv/bin:$PATH"

# ポート公開
EXPOSE 8080

# 非rootユーザーで実行
RUN useradd --create-home --shell /bin/bash app
USER app

# アプリケーション起動
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

### pyproject.toml
```toml
[project]
name = "todo-backend"
version = "1.0.0"
description = "ToDo Application Backend API"
requires-python = ">=3.13"
dependencies = [
    "fastapi>=0.104.0",
    "uvicorn[standard]>=0.24.0",
    "azure-cosmos>=4.5.0",
    "azure-identity>=1.15.0",
    "pydantic>=2.5.0",
    "python-multipart>=0.0.6",
    "slowapi>=0.1.9",
    "opencensus-ext-azure>=1.1.13",
    "pyjwt>=2.8.0",
    "python-jose[cryptography]>=3.3.0",
    "psutil>=5.9.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "httpx>=0.25.0",
    "black>=23.0.0",
    "ruff>=0.1.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.ruff]
target-version = "py313"
line-length = 88

[tool.black]
target-version = ["py313"]
line-length = 88
```

### ヘルスチェック設定
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/api/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

## 開発・テスト

### 開発環境
- ローカル開発: Docker Compose + uv
- データベース: Cosmos DB Emulator
- 監視: Application Insights（開発用）
- 開発サーバー: `uvicorn main:app --reload`

### テストカバレッジ
- ユニットテスト: > 80%（pytest使用）
- 統合テスト: 全エンドポイント（httpx使用）
- 負荷テスト: Azure Load Testing統合

## デプロイメント

### Container Apps設定
```yaml
properties:
  configuration:
    ingress:
      external: true
      targetPort: 8080
    secrets: []
  template:
    containers:
    - name: todo-backend
      image: {acr}.azurecr.io/todo-backend:latest
      resources:
        cpu: 0.25
        memory: 0.5Gi
    scale:
      minReplicas: 0
      maxReplicas: 10
```

### 環境別設定

#### ローカル開発環境
- ポート: 8080
- インスタンス数: 1
- デモ機能: 有効
- ログレベル: debug
- 環境変数:
  - AZURE_COSMOS_CONNECTION_STRING: ローカル開発用接続文字列
  - APPLICATIONINSIGHTS_CONNECTION_STRING: ローカル開発用接続文字列

#### Azureデモ環境
- インスタンス数: 0-10（ゼロスケール対応）
- デモ機能: 有効
- ログレベル: info
- Static Web Apps連携: Linked Backend経由
- 環境変数:
  - AZURE_COSMOS_CONNECTION_STRING: Azure Cosmos DB接続文字列
  - APPLICATIONINSIGHTS_CONNECTION_STRING: Application Insights接続文字列

## 付録

### API クライアント例
```python
import httpx
import asyncio

# ToDoアイテム作成（50%の確率でメモリ消費処理が発動）
async def create_todo():
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                '/api/todos',
                headers={'Content-Type': 'application/json'},
                json={
                    'title': '新しいタスク',
                    'description': 'タスクの詳細'
                },
                timeout=60.0  # メモリ消費処理を考慮したタイムアウト
            )
            return response.json()
        except httpx.TimeoutException:
            print("メモリ消費処理によりタイムアウトが発生した可能性があります")
            return None

# ToDoアイテム更新（50%の確率でメモリ消費処理が発動）
async def update_todo(todo_id: str):
    async with httpx.AsyncClient() as client:
        try:
            response = await client.put(
                f'/api/todos/{todo_id}',
                headers={'Content-Type': 'application/json'},
                json={
                    'title': '更新されたタスク',
                    'completed': True
                },
                timeout=60.0  # メモリ消費処理を考慮したタイムアウト
            )
            return response.json()
        except httpx.TimeoutException:
            print("メモリ消費処理によりタイムアウトが発生した可能性があります")
            return None

# 複数回実行してランダム障害をテスト
async def test_random_failures():
    for i in range(10):
        print(f"試行 {i+1}/10")
        result = await create_todo()
        if result:
            print("✓ 正常に作成されました")
        else:
            print("✗ 障害が発生しました（メモリ消費処理の可能性）")
        await asyncio.sleep(1)

# 実行例
asyncio.run(test_random_failures())
```

### 関連ドキュメント
- [インフラストラクチャ仕様書](./infrastructure-specification.md)
- [フロントエンド仕様書](./frontend-specification.md)
- [運用手順書](./operation-manual.md)

### 更新履歴
- 2025年7月23日: 初版作成（CRUD API + デモ用障害機能）
- 2025年7月23日: Python + FastAPI + uv パッケージ管理に変更
- 2025年7月23日: Python 3.13 に更新
- 2025年7月23日: メモリ消費処理をCRUD処理内でランダム実行する仕様に変更