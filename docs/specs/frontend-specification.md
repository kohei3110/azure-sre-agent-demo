# フロントエンド仕様書

## 概要

本仕様書では、SRE Agent デモンストレーション用ToDoアプリケーションのフロントエンドの詳細な仕様を定義します。
シンプルなUI設計により、SRE Agentの監視・自動回復機能の動作確認に焦点を当てた実装とします。

## アーキテクチャ概要

### 技術スタック
- **フレームワーク**: React 18
- **言語**: TypeScript
- **UI ライブラリ**: Material-UI (MUI)
- **状態管理**: React Query (TanStack Query)
- **HTTP クライアント**: Axios
- **ビルドツール**: Vite
- **パッケージ管理**: npm

### デプロイメント
- **プラットフォーム**: Azure Static Web Apps (Standard)
- **CDN**: 内蔵CDN機能
- **バックエンド連携**: Container Apps統合（Linked Backend）
- **認証**: Azure Static Web Apps Built-in認証（オプション）
- **API統合**: `/api/*` ルートの自動プロキシ機能
- **環境構成**: ローカル開発環境とAzureデモ環境の2環境構成

## UI設計

### デザインコンセプト
- **シンプル**: SRE Agentデモに必要最小限の機能
- **レスポンシブ**: モバイル・デスクトップ対応
- **アクセシブル**: WCAG 2.1 AA準拠
- **モダン**: Material Design 3対応

### カラーパレット
```css
:root {
  --primary-color: #1976d2;     /* Blue 700 */
  --secondary-color: #dc004e;   /* Pink A400 */
  --success-color: #2e7d32;     /* Green 800 */
  --warning-color: #ed6c02;     /* Orange 800 */
  --error-color: #d32f2f;       /* Red 700 */
  --background-color: #fafafa;  /* Grey 50 */
  --surface-color: #ffffff;     /* White */
  --text-primary: #212121;      /* Grey 900 */
  --text-secondary: #757575;    /* Grey 600 */
}
```

## 画面仕様

### 1. メイン画面（Todo リスト）

#### レイアウト
```
┌─────────────────────────────────────┐
│ Header                              │
│ ┌─ Todo App ─────────────────────┐  │
│ │ [新規作成ボタン] [統計表示]     │  │
│ └─────────────────────────────────┘  │
├─────────────────────────────────────┤
│ Todo List                           │
│ ┌─────────────────────────────────┐  │
│ │ □ タスク1 [編集] [削除]         │  │
│ │ ☑ タスク2 [編集] [削除]         │  │
│ │ □ タスク3 [編集] [削除]         │  │
│ └─────────────────────────────────┘  │
├─────────────────────────────────────┤
│ Footer                              │
│ システム状態: [正常] | API応答: 150ms│
└─────────────────────────────────────┘
```

#### 機能
- **Todo一覧表示**: ページネーション対応（50件/ページ）
- **新規作成**: モーダルダイアログで作成
- **編集・削除**: インライン編集、確認ダイアログ
- **完了/未完了切り替え**: チェックボックスクリック
- **統計表示**: 総数、完了数、完了率
- **システム状態**: API応答時間、エラー状態の表示

### 2. 新規作成・編集モーダル

#### レイアウト
```
┌─────────────────────────┐
│ Todo作成/編集           │
├─────────────────────────┤
│ タイトル*               │
│ [________________]      │
│                         │
│ 説明                    │
│ [________________]      │
│ [________________]      │
│ [________________]      │
│                         │
│ □ 完了済み（編集時のみ） │
│                         │
│ [キャンセル] [保存]      │
└─────────────────────────┘
```

#### 機能
- **バリデーション**: リアルタイム入力検証
- **エラーハンドリング**: API エラーの適切な表示
- **ローディング状態**: 保存中のローディング表示

### 3. 統計ダッシュボード（オプション）

#### レイアウト
```
┌─────────────────────────────────────┐
│ 統計情報                            │
├─────────────────────────────────────┤
│ [総タスク数: 150] [完了: 75] [未完了: 75]│
│ [完了率: 50%]     [今日作成: 5]      │
├─────────────────────────────────────┤
│ システム監視                        │
│ API応答時間: 150ms                  │
│ 最後の障害: 2時間前                 │
│ アプリ状態: 正常動作中              │
└─────────────────────────────────────┘
```

## コンポーネント設計

### ディレクトリ構造
```
src/
├── components/
│   ├── common/
│   │   ├── Header.tsx
│   │   ├── Footer.tsx
│   │   ├── Loading.tsx
│   │   └── ErrorBoundary.tsx
│   ├── todo/
│   │   ├── TodoList.tsx
│   │   ├── TodoItem.tsx
│   │   ├── TodoForm.tsx
│   │   └── TodoStats.tsx
│   └── system/
│       └── SystemStatus.tsx
├── hooks/
│   ├── useTodos.ts
│   ├── useSystemStatus.ts
│   └── useErrorHandler.ts
├── services/
│   ├── api.ts
│   ├── todoService.ts
│   └── systemService.ts
├── types/
│   ├── todo.ts
│   └── system.ts
├── utils/
│   ├── constants.ts
│   └── helpers.ts
└── App.tsx
```

### 主要コンポーネント

#### TodoList.tsx
```typescript
interface TodoListProps {
  todos: Todo[];
  onEdit: (todo: Todo) => void;
  onDelete: (id: string) => void;
  onToggle: (id: string) => void;
  loading: boolean;
  error: string | null;
}

const TodoList: React.FC<TodoListProps> = ({
  todos,
  onEdit,
  onDelete,
  onToggle,
  loading,
  error
}) => {
  // 実装
};
```

#### TodoForm.tsx
```typescript
interface TodoFormProps {
  todo?: Todo;
  open: boolean;
  onClose: () => void;
  onSubmit: (todo: CreateTodoRequest | UpdateTodoRequest) => void;
  loading: boolean;
  error: string | null;
}

const TodoForm: React.FC<TodoFormProps> = ({
  todo,
  open,
  onClose,
  onSubmit,
  loading,
  error
}) => {
  // 実装
};
```

#### SystemStatus.tsx
```typescript
interface SystemStatusProps {
  apiResponseTime: number;
  lastError: Date | null;
  appStatus: 'healthy' | 'warning' | 'error';
}

const SystemStatus: React.FC<SystemStatusProps> = ({
  apiResponseTime,
  lastError,
  appStatus
}) => {
  // 実装
};
```

## データ型定義

### Todo関連
```typescript
interface Todo {
  id: string;
  title: string;
  description?: string;
  completed: boolean;
  createdAt: string;
  updatedAt: string;
  userId: string;
}

interface CreateTodoRequest {
  title: string;
  description?: string;
}

interface UpdateTodoRequest {
  title?: string;
  description?: string;
  completed?: boolean;
}

interface TodoStats {
  totalTodos: number;
  completedTodos: number;
  pendingTodos: number;
  completionRate: number;
  todaysCreated: number;
  todaysCompleted: number;
}
```

### システム監視
```typescript
interface SystemHealth {
  status: 'healthy' | 'warning' | 'error';
  uptime: number;
  memory: {
    used: string;
    total: string;
    percentage: number;
  };
  database: 'connected' | 'disconnected';
  version: string;
  pythonVersion: string;
}

interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  timestamp: string;
}

interface ApiError {
  success: false;
  error: {
    code: string;
    message: string;
    details: any;
  };
  timestamp: string;
}
```

## API統合

### Static Web Apps と Container Apps の連携アーキテクチャ

#### 統合概要
Static Web Apps の Standard プランでは、Container Apps をリンクされたバックエンドとして統合できます。
この機能により、フロントエンドからバックエンドAPIへのシームレスなアクセスが可能になります。

#### 統合の仕組み
```
┌─────────────────────────┐    ┌──────────────────────────┐    ┌─────────────────────────┐
│   Client Browser        │    │  Static Web Apps         │    │   Container Apps        │
│                         │    │                          │    │                         │
│  React App              │    │  ┌─────────────────────┐ │    │  ┌─────────────────────┐│
│  └─ fetch('/api/todos') │───▶│  │ CDN + Proxy Engine │ │───▶│  │ FastAPI Backend     ││
│                         │    │  └─────────────────────┘ │    │  └─────────────────────┘│
│                         │    │                          │    │                         │
└─────────────────────────┘    └──────────────────────────┘    └─────────────────────────┘
```

#### Linked Backend の特徴
1. **自動プロキシ**: `/api/*` パスへのリクエストは自動的にContainer Apps へ転送
2. **統合認証**: Static Web Apps の認証機能がContainer Apps にも適用
3. **環境分離**: ローカル開発環境とAzureデモ環境で独立したContainer Apps インスタンスとの連携
4. **SSL終端**: Static Web Apps が SSL終端を担当し、セキュアな通信を提供
5. **CDNキャッシュ**: APIレスポンスの適切なキャッシュ戦略

### APIクライアント設定（Static Web Apps対応）
```typescript
// services/api.ts
import axios from 'axios';

// Static Web Apps環境の検出
const isStaticWebApp = () => {
  return typeof window !== 'undefined' && 
         window.location.hostname.includes('.azurestaticapps.net');
};

// 環境別のAPI Base URL設定
# 環境別のAPI Base URL設定
const getApiBaseUrl = () => {
  if (process.env.NODE_ENV === 'development') {
    // ローカル開発環境: Container Apps の直接接続
    return process.env.VITE_CONTAINER_APPS_URL || 'http://localhost:8080/api';
  }
  
  // Azureデモ環境（Azure Static Web Apps）: プロキシ経由でアクセス
  return '/api';
};

export const apiClient = axios.create({
  baseURL: getApiBaseUrl(),
  timeout: 60000, // メモリ消費処理を考慮した長めのタイムアウト
  headers: {
    'Content-Type': 'application/json',
    // Static Web Apps認証ヘッダー（必要に応じて）
    'X-Static-Web-App-Version': process.env.VITE_APP_VERSION || '1.0.0',
  },
});

// Static Web Apps特有のリクエストインターセプター
apiClient.interceptors.request.use((config) => {
  // リクエスト開始時刻を記録
  config.metadata = { startTime: new Date() };
  
  // Static Web Apps環境での追加ヘッダー設定
  if (isStaticWebApp()) {
    // ユーザー認証情報の取得（必要に応じて）
    const userInfo = getUserInfo(); // Static Web Apps認証情報
    if (userInfo) {
      config.headers['X-MS-CLIENT-PRINCIPAL-ID'] = userInfo.userId;
      config.headers['X-MS-CLIENT-PRINCIPAL-NAME'] = userInfo.userName;
    }
    
    // リクエストID生成（トレーシング用）
    config.headers['X-Request-ID'] = generateRequestId();
  }
  
  return config;
});

// レスポンス・エラーハンドリング（Static Web Apps対応）
apiClient.interceptors.response.use(
  (response) => {
    const duration = new Date().getTime() - response.config.metadata.startTime.getTime();
    
    // Static Web Apps特有のメトリクス収集
    if (isStaticWebApp()) {
      // Application Insights への統合ログ送信
      trackApiCall(response.config.url, duration, true);
    }
    
    console.log(`API Response: ${response.config.url} took ${duration}ms`);
    return response;
  },
  (error) => {
    const duration = error.config?.metadata ? 
      new Date().getTime() - error.config.metadata.startTime.getTime() : 0;
    
    // Static Web Apps特有のエラーハンドリング
    if (isStaticWebApp()) {
      // Container Apps接続エラーの検知
      if (error.response?.status === 502 || error.response?.status === 503) {
        console.warn('Container Apps backend is temporarily unavailable');
        trackApiCall(error.config?.url, duration, false, 'backend_unavailable');
      }
    }
    
    if (error.code === 'ECONNABORTED') {
      console.warn('API timeout - possible memory stress test in progress');
      trackApiCall(error.config?.url, duration, false, 'timeout');
    }
    
    return Promise.reject(error);
  }
);

// Static Web Apps認証情報取得
const getUserInfo = () => {
  // Static Web Apps Built-in認証の利用
  return fetch('/.auth/me')
    .then(response => response.json())
    .then(payload => payload.clientPrincipal)
    .catch(() => null);
};

// リクエストID生成（トレーシング用）
const generateRequestId = () => {
  return `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
};
```

### Static Web Apps設定ファイル（staticwebapp.config.json）
```json
{
  "routes": [
    {
      "route": "/api/*",
      "allowedRoles": ["anonymous"]
    },
    {
      "route": "/*",
      "serve": "/index.html",
      "statusCode": 200
    }
  ],
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/api/*", "/*.{css,scss,js,png,gif,ico,jpg,svg}"]
  },
  "responseOverrides": {
    "400": {
      "rewrite": "/custom-error-pages/400.html"
    },
    "401": {
      "redirect": "/.auth/login/aad"
    },
    "403": {
      "rewrite": "/custom-error-pages/403.html"
    },
    "404": {
      "rewrite": "/custom-error-pages/404.html"
    }
  },
  "globalHeaders": {
    "content-security-policy": "default-src https: 'unsafe-eval' 'unsafe-inline'; object-src 'none'"
  },
  "mimeTypes": {
    ".json": "text/json"
  }
}
```

### 環境別Container Apps連携設定

#### ローカル開発環境
```typescript
// ローカル開発環境では直接Container Apps URL を使用
const LOCAL_DEVELOPMENT_CONFIG = {
  containerAppsUrl: process.env.VITE_CONTAINER_APPS_URL || 'http://localhost:8080/api',
  authRequired: false,
  corsEnabled: true,
  timeout: 30000,
  environment: 'development',
  features: {
    demoMode: true,
    monitoring: false,
    authentication: false,
  },
};
```

#### Azureデモ環境
```typescript
// Azureデモ環境ではStatic Web Apps経由でアクセス
const AZURE_DEMO_CONFIG = {
  apiBasePath: '/api', // Static Web Apps プロキシ経由
  authRequired: false, // デモ用途のため認証なし
  corsEnabled: false, // プロキシ経由のため不要
  timeout: 60000,
  linkedBackend: 'todo-backend-demo',
  environment: 'demo',
  features: {
    demoMode: true,
    monitoring: true,
    authentication: false,
  },
  cacheStrategy: 'optimistic',
  retryPolicy: {
    maxRetries: 3,
    backoffMultiplier: 2,
    initialDelay: 1000,
  },
};
```

### TodoService（Static Web Apps統合対応）
```typescript
// services/todoService.ts
export class TodoService {
  private static instance: TodoService;
  
  public static getInstance(): TodoService {
    if (!TodoService.instance) {
      TodoService.instance = new TodoService();
    }
    return TodoService.instance;
  }

  async getTodos(params?: {
    limit?: number;
    offset?: number;
    completed?: boolean;
    sortBy?: string;
    sortOrder?: 'asc' | 'desc';
  }): Promise<{ todos: Todo[], total: number }> {
    try {
      const response = await apiClient.get<ApiResponse<{
        todos: Todo[];
        total: number;
        limit: number;
        offset: number;
      }>>('/todos', { params });
      
      return response.data.data;
    } catch (error) {
      this.handleApiError(error, 'getTodos');
      throw error;
    }
  }

  async createTodo(todo: CreateTodoRequest): Promise<Todo> {
    try {
      const response = await apiClient.post<ApiResponse<Todo>>('/todos', todo);
      
      // Static Web Apps環境での成功ログ
      if (isStaticWebApp()) {
        trackEvent('TodoCreated', {
          method: 'POST',
          backend: 'container-apps',
          success: true,
        });
      }
      
      return response.data.data;
    } catch (error) {
      this.handleApiError(error, 'createTodo');
      throw error;
    }
  }

  async updateTodo(id: string, todo: UpdateTodoRequest): Promise<Todo> {
    try {
      const response = await apiClient.put<ApiResponse<Todo>>(`/todos/${id}`, todo);
      
      // Static Web Apps環境での成功ログ
      if (isStaticWebApp()) {
        trackEvent('TodoUpdated', {
          method: 'PUT',
          backend: 'container-apps',
          success: true,
        });
      }
      
      return response.data.data;
    } catch (error) {
      this.handleApiError(error, 'updateTodo');
      throw error;
    }
  }

  async deleteTodo(id: string): Promise<void> {
    try {
      await apiClient.delete(`/todos/${id}`);
      
      // Static Web Apps環境での成功ログ
      if (isStaticWebApp()) {
        trackEvent('TodoDeleted', {
          method: 'DELETE',
          backend: 'container-apps',
          success: true,
        });
      }
    } catch (error) {
      this.handleApiError(error, 'deleteTodo');
      throw error;
    }
  }

  async getStats(): Promise<TodoStats> {
    try {
      const response = await apiClient.get<ApiResponse<TodoStats>>('/stats');
      return response.data.data;
    } catch (error) {
      this.handleApiError(error, 'getStats');
      throw error;
    }
  }

  // Container Apps特有のヘルスチェック
  async checkBackendHealth(): Promise<SystemHealth> {
    try {
      const response = await apiClient.get<ApiResponse<SystemHealth>>('/health');
      return response.data.data;
    } catch (error) {
      // Container Apps が利用不可の場合のフォールバック
      return {
        status: 'error',
        uptime: 0,
        memory: { used: '0MB', total: '0MB', percentage: 0 },
        database: 'disconnected',
        version: 'unknown',
        pythonVersion: 'unknown',
      };
    }
  }

  private handleApiError(error: unknown, operation: string) {
    let errorMessage = `${operation} failed`;
    let errorCategory = 'unknown';
    
    if (axios.isAxiosError(error)) {
      if (error.code === 'ECONNABORTED') {
        errorMessage = 'アプリケーションが一時的に応答していません（メモリ消費処理の可能性）';
        errorCategory = 'timeout';
      } else if (error.response?.status === 502) {
        errorMessage = 'バックエンドサービスが一時的に利用できません';
        errorCategory = 'backend_unavailable';
      } else if (error.response?.status === 503) {
        errorMessage = 'Container Apps が一時的にスケールアップ中です';
        errorCategory = 'scaling';
      } else if (error.response?.data?.error?.code === 'MEMORY_STRESS_TRIGGERED') {
        errorMessage = 'デモ用メモリ消費処理が実行されました。SRE Agentが対処中です...';
        errorCategory = 'demo_failure';
      }
    }
    
    // Static Web Apps環境でのエラーログ
    if (isStaticWebApp()) {
      trackEvent('ApiError', {
        operation,
        errorCategory,
        backend: 'container-apps',
        statusCode: axios.isAxiosError(error) ? error.response?.status : null,
      });
    }
    
    console.error(`API Error [${operation}]:`, errorMessage);
  }
}

// シングルトンインスタンスのエクスポート
export const todoService = TodoService.getInstance();
```

### Static Web Apps認証統合
```typescript
// services/authService.ts
export class AuthService {
  private userInfo: ClientPrincipal | null = null;
  
  async getCurrentUser(): Promise<ClientPrincipal | null> {
    if (process.env.NODE_ENV === 'development') {
      return null; // ローカル開発環境では認証なし
    }
    
    try {
      const response = await fetch('/.auth/me');
      const payload = await response.json();
      this.userInfo = payload.clientPrincipal;
      return this.userInfo;
    } catch (error) {
      console.warn('Failed to get user info:', error);
      return null;
    }
  }
  
  async login(provider: 'aad' | 'github' | 'twitter' = 'aad'): Promise<void> {
    if (isStaticWebApp() && process.env.NODE_ENV !== 'development') {
      window.location.href = `/.auth/login/${provider}`;
    }
  }
  
  async logout(): Promise<void> {
    if (isStaticWebApp() && process.env.NODE_ENV !== 'development') {
      window.location.href = '/.auth/logout';
    }
  }
  
  isAuthenticated(): boolean {
    return this.userInfo !== null;
  }
  
  getUserId(): string | null {
    return this.userInfo?.userId || null;
  }
  
  getUserName(): string | null {
    return this.userInfo?.userDetails || null;
  }
}

interface ClientPrincipal {
  identityProvider: string;
  userId: string;
  userDetails: string;
  userRoles: string[];
}

export const authService = new AuthService();
```

## React Query統合

### カスタムフック
```typescript
// hooks/useTodos.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export const useTodos = (params?: GetTodosParams) => {
  return useQuery({
    queryKey: ['todos', params],
    queryFn: () => todoService.getTodos(params),
    staleTime: 5 * 60 * 1000, // 5分
    retry: (failureCount, error) => {
      // メモリ消費処理中は3回まで再試行
      if (axios.isAxiosError(error) && error.code === 'ECONNABORTED') {
        return failureCount < 3;
      }
      return failureCount < 1;
    },
  });
};

export const useCreateTodo = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: todoService.createTodo,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] });
      queryClient.invalidateQueries({ queryKey: ['stats'] });
    },
    onError: (error) => {
      console.error('Todo creation failed:', error);
    },
  });
};

export const useUpdateTodo = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, todo }: { id: string; todo: UpdateTodoRequest }) =>
      todoService.updateTodo(id, todo),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] });
      queryClient.invalidateQueries({ queryKey: ['stats'] });
    },
  });
};
```

## エラーハンドリング

### ErrorBoundary
```typescript
// components/common/ErrorBoundary.tsx
interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends React.Component<
  React.PropsWithChildren<{}>,
  ErrorBoundaryState
> {
  constructor(props: React.PropsWithChildren<{}>) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('アプリケーションエラー:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <Box sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="h5" color="error" gutterBottom>
            アプリケーションエラーが発生しました
          </Typography>
          <Typography variant="body1" sx={{ mb: 2 }}>
            SRE Agentが問題を検知し、回復処理を実行中です...
          </Typography>
          <Button 
            variant="contained" 
            onClick={() => window.location.reload()}
          >
            ページを再読み込み
          </Button>
        </Box>
      );
    }

    return this.props.children;
  }
}
```

### 統一エラーハンドリング
```typescript
// hooks/useErrorHandler.ts
export const useErrorHandler = () => {
  const showError = (error: unknown) => {
    let message = 'エラーが発生しました';
    
    if (axios.isAxiosError(error)) {
      if (error.code === 'ECONNABORTED') {
        message = 'サーバーが応答していません。SRE Agentが対処中です...';
      } else if (error.response?.data?.error?.message) {
        message = error.response.data.error.message;
      }
    } else if (error instanceof Error) {
      message = error.message;
    }
    
    // Toast通知などで表示
    console.error(message);
    return message;
  };

  return { showError };
};
```

## パフォーマンス最適化

### 最適化手法
- **Code Splitting**: React.lazy による遅延読み込み
- **Memoization**: React.memo, useMemo, useCallback活用
- **Virtual Scrolling**: 大量データの効率的表示
- **Image Optimization**: WebP対応、遅延読み込み

### ビルド最適化
```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          mui: ['@mui/material', '@mui/icons-material'],
          query: ['@tanstack/react-query'],
        },
      },
    },
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
```

## テスト

### テスト戦略
- **ユニットテスト**: React Testing Library + Jest
- **統合テスト**: Cypress または Playwright
- **Visual Regression Test**: Chromatic

### テスト例
```typescript
// __tests__/TodoList.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import TodoList from '../components/todo/TodoList';

const createTestQueryClient = () => new QueryClient({
  defaultOptions: {
    queries: { retry: false },
    mutations: { retry: false },
  },
});

describe('TodoList', () => {
  it('should render todo items', () => {
    const queryClient = createTestQueryClient();
    const mockTodos = [
      { id: '1', title: 'Test Todo', completed: false, /* ... */ },
    ];

    render(
      <QueryClientProvider client={queryClient}>
        <TodoList 
          todos={mockTodos}
          onEdit={jest.fn()}
          onDelete={jest.fn()}
          onToggle={jest.fn()}
          loading={false}
          error={null}
        />
      </QueryClientProvider>
    );

    expect(screen.getByText('Test Todo')).toBeInTheDocument();
  });
});
```

## デプロイメント

### package.json
```json
{
  "name": "todo-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "jest",
    "test:e2e": "playwright test"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@mui/material": "^5.14.0",
    "@mui/icons-material": "^5.14.0",
    "@emotion/react": "^11.11.0",
    "@emotion/styled": "^11.11.0",
    "@tanstack/react-query": "^5.0.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.0.0",
    "typescript": "^5.0.0",
    "vite": "^5.0.0"
  }
}
```

### Azure Static Web Apps設定（シンプル構成）
```yaml
# .github/workflows/azure-static-web-apps.yml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches: [main]
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [main]

jobs:
  build_and_deploy_job:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true
          lfs: false

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build
        env:
          # デモ環境用設定
          VITE_APP_VERSION: ${{ github.sha }}
          VITE_ENVIRONMENT: demo
          VITE_APPINSIGHTS_CONNECTION_STRING: ${{ secrets.APPLICATIONINSIGHTS_CONNECTION_STRING }}

      - name: Build And Deploy to Static Web Apps
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/"
          api_location: "" # Container Apps を使用するため空
          output_location: "dist"
          config_file_location: "/"
        env:
          # Container Apps統合設定（デモ環境）
          LINKED_BACKEND_RESOURCE_ID: ${{ secrets.CONTAINER_APPS_RESOURCE_ID }}

  close_pull_request_job:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request Job
    steps:
      - name: Close Pull Request
        id: closepullrequest
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          action: "close"
```

### staticwebapp.config.json（デモ用設定）
```json
{
  "routes": [
    {
      "route": "/api/*",
      "allowedRoles": ["anonymous"],
      "headers": {
        "cache-control": "no-cache"
      }
    },
    {
      "route": "/",
      "serve": "/index.html",
      "headers": {
        "cache-control": "must-revalidate, max-age=3600"
      }
    },
    {
      "route": "/*",
      "serve": "/index.html",
      "statusCode": 200
    }
  ],
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/api/*", "/*.{css,scss,js,png,gif,ico,jpg,svg,woff,woff2}"]
  },
  "responseOverrides": {
    "502": {
      "rewrite": "/maintenance.html",
      "statusCode": 502
    },
    "503": {
      "rewrite": "/maintenance.html",
      "statusCode": 503
    },
    "404": {
      "rewrite": "/index.html",
      "statusCode": 200
    }
  },
  "globalHeaders": {
    "content-security-policy": "default-src 'self' https://dc.applicationinsights.azure.com; script-src 'self' 'unsafe-inline' https://js.monitor.azure.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://dc.applicationinsights.azure.com",
    "x-frame-options": "DENY",
    "x-content-type-options": "nosniff"
  },
  "mimeTypes": {
    ".json": "application/json"
  },
  "trailingSlashes": false,
  "platform": {
    "apiRuntime": "none"
  }
}
```

### Container Apps統合監視機能
```typescript
// hooks/useContainerAppsHealth.ts
export const useContainerAppsHealth = () => {
  const [healthStatus, setHealthStatus] = useState<{
    isHealthy: boolean;
    lastCheck: Date;
    responseTime: number;
    error: string | null;
  }>({
    isHealthy: true,
    lastCheck: new Date(),
    responseTime: 0,
    error: null,
  });

  const checkHealth = useCallback(async () => {
    const startTime = Date.now();
    
    try {
      const response = await apiClient.get('/health', {
        timeout: 10000, // ヘルスチェック用の短いタイムアウト
      });
      
      const responseTime = Date.now() - startTime;
      
      setHealthStatus({
        isHealthy: true,
        lastCheck: new Date(),
        responseTime,
        error: null,
      });
      
      // Static Web Apps環境でのメトリクス送信
      if (isStaticWebApp()) {
        trackEvent('ContainerAppsHealthCheck', {
          healthy: true,
          responseTime,
          timestamp: new Date().toISOString(),
        });
      }
      
    } catch (error) {
      const responseTime = Date.now() - startTime;
      const errorMessage = axios.isAxiosError(error) 
        ? `HTTP ${error.response?.status}: ${error.message}`
        : 'Unknown error';
      
      setHealthStatus({
        isHealthy: false,
        lastCheck: new Date(),
        responseTime,
        error: errorMessage,
      });
      
      // Static Web Apps環境でのエラーメトリクス送信
      if (isStaticWebApp()) {
        trackEvent('ContainerAppsHealthCheck', {
          healthy: false,
          responseTime,
          error: errorMessage,
          timestamp: new Date().toISOString(),
        });
      }
    }
  }, []);

  // 定期的なヘルスチェック
  useEffect(() => {
    checkHealth(); // 初回実行
    
    const interval = setInterval(checkHealth, 30000); // 30秒間隔
    
    return () => clearInterval(interval);
  }, [checkHealth]);

  return {
    ...healthStatus,
    checkHealth,
  };
};
```

### Static Web Apps特有のエラーページ
```typescript
// components/error/MaintenancePage.tsx
const MaintenancePage: React.FC = () => {
  const [retryCount, setRetryCount] = useState(0);
  const navigate = useNavigate();
  
  const handleRetry = async () => {
    setRetryCount(prev => prev + 1);
    
    try {
      // Container Apps の復旧確認
      await apiClient.get('/health', { timeout: 5000 });
      
      // 復旧した場合はメインページへリダイレクト
      navigate('/', { replace: true });
      
    } catch (error) {
      // まだ復旧していない場合は待機
      if (retryCount < 5) {
        setTimeout(handleRetry, 10000); // 10秒後に再試行
      }
    }
  };
  
  return (
    <Container maxWidth="md" sx={{ py: 8 }}>
      <Paper elevation={3} sx={{ p: 4, textAlign: 'center' }}>
        <CircularProgress size={60} sx={{ mb: 3 }} />
        
        <Typography variant="h4" gutterBottom>
          システムメンテナンス中
        </Typography>
        
        <Typography variant="body1" sx={{ mb: 3 }}>
          バックエンドサービス（Container Apps）が一時的に利用できません。
          <br />
          SRE Agent が自動復旧処理を実行中です...
        </Typography>
        
        <Box sx={{ mb: 3 }}>
          <Chip
            label={`再試行回数: ${retryCount}/5`}
            color={retryCount >= 5 ? 'error' : 'info'}
            variant="outlined"
          />
        </Box>
        
        <Button
          variant="contained"
          onClick={handleRetry}
          disabled={retryCount >= 5}
          startIcon={<RefreshIcon />}
        >
          手動で再試行
        </Button>
        
        {retryCount >= 5 && (
          <Alert severity="warning" sx={{ mt: 3 }}>
            システムの復旧に時間がかかっています。
            しばらく時間をおいてからアクセスしてください。
          </Alert>
        )}
      </Paper>
    </Container>
  );
};
```

## 監視・ログ

### Application Insights統合
```typescript
// utils/telemetry.ts
import { ApplicationInsights } from '@microsoft/applicationinsights-web';

const appInsights = new ApplicationInsights({
  config: {
    connectionString: process.env.APPLICATIONINSIGHTS_CONNECTION_STRING,
    enableAutoRouteTracking: true,
    enableCorsCorrelation: true,
  }
});

appInsights.loadAppInsights();

export const trackEvent = (name: string, properties?: any) => {
  appInsights.trackEvent({ name, properties });
};

export const trackError = (error: Error, properties?: any) => {
  appInsights.trackException({ exception: error, properties });
};
```

### カスタムメトリクス
```typescript
// SRE Agent向けカスタムメトリクス
export const trackUserAction = (action: string, duration?: number) => {
  trackEvent('UserAction', {
    action,
    duration,
    timestamp: new Date().toISOString(),
  });
};

export const trackApiCall = (endpoint: string, duration: number, success: boolean) => {
  trackEvent('ApiCall', {
    endpoint,
    duration,
    success,
    timestamp: new Date().toISOString(),
  });
};
```

## 環境設定

### 環境変数（2環境構成）
```bash
# .env.development（ローカル開発環境）
VITE_CONTAINER_APPS_URL=http://localhost:8080/api
VITE_APP_VERSION=dev
VITE_ENVIRONMENT=development
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=dev-key...

# ローカル開発用の追加設定
VITE_DEBUG_MODE=true
VITE_MOCK_DELAY=0
VITE_CORS_ENABLED=true

# .env（Azureデモ環境）
VITE_APP_VERSION=demo
VITE_ENVIRONMENT=demo
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=demo-key...
VITE_STATIC_WEB_APP_NAME=todo-app-demo
VITE_CONTAINER_APPS_NAME=todo-backend-demo

# デモ用設定
VITE_AUTH_ENABLED=false
VITE_MAX_RETRY_ATTEMPTS=3
VITE_HEALTH_CHECK_INTERVAL=30000
VITE_REQUEST_TIMEOUT=60000
VITE_DEMO_MODE=true
```

### 環境判定とconfig取得
```typescript
// utils/environment.ts
export const getCurrentEnvironment = () => {
  return process.env.NODE_ENV === 'development' ? 'local' : 'demo';
};

export const getEnvironmentConfig = () => {
  const environment = getCurrentEnvironment();
  
  if (environment === 'local') {
    return {
      name: 'Local Development',
      apiBaseUrl: process.env.VITE_CONTAINER_APPS_URL || 'http://localhost:8080/api',
      authEnabled: false,
      debugMode: true,
      corsEnabled: true,
      timeout: 30000,
      monitoring: false,
      features: {
        demoMode: true,
        authentication: false,
        realTimeMonitoring: false,
      },
    };
  }
  
  // Azureデモ環境
  return {
    name: 'Azure Demo Environment',
    apiBaseUrl: '/api',
    authEnabled: false, // デモ用途のため認証なし
    debugMode: false,
    corsEnabled: false,
    timeout: 60000,
    monitoring: true,
    features: {
      demoMode: true,
      authentication: false,
      realTimeMonitoring: true,
    },
  };
};
```

### Container Apps統合テスト（2環境対応）
```typescript
// __tests__/integration/containerAppsIntegration.test.ts
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import App from '../../App';

// Container Apps APIモック（ローカル・クラウド両環境対応）
const server = setupServer(
  // ヘルスチェック - 正常レスポンス
  rest.get('/api/health', (req, res, ctx) => {
    return res(
      ctx.json({
        success: true,
        data: {
          status: 'healthy',
          uptime: 12345,
          memory: { used: '50MB', total: '512MB', percentage: 9.8 },
          database: 'connected',
          version: '1.0.0',
          pythonVersion: '3.13.0'
        }
      })
    );
  }),
  
  // Todo一覧取得
  rest.get('/api/todos', (req, res, ctx) => {
    return res(
      ctx.json({
        success: true,
        data: {
          todos: [
            { 
              id: '1', 
              title: 'Demo Todo', 
              completed: false, 
              createdAt: '2025-01-01T00:00:00Z', 
              updatedAt: '2025-01-01T00:00:00Z', 
              userId: 'demo-user' 
            }
          ],
          total: 1,
          limit: 50,
          offset: 0
        }
      })
    );
  }),
  
  // Todo作成 - デモ用メモリ消費処理シミュレーション
  rest.post('/api/todos', (req, res, ctx) => {
    // 50%の確率でタイムアウトをシミュレート（SRE Agentデモ用）
    if (Math.random() < 0.5) {
      return res(
        ctx.delay('infinite') // タイムアウトを引き起こす
      );
    }
    
    return res(
      ctx.json({
        success: true,
        data: {
          id: '2',
          title: 'New Demo Todo',
          completed: false,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
          userId: 'demo-user'
        }
      })
    );
  }),
  
  // Todo更新 - デモ用メモリ消費処理シミュレーション
  rest.put('/api/todos/:id', (req, res, ctx) => {
    // 50%の確率でタイムアウトをシミュレート
    if (Math.random() < 0.5) {
      return res(
        ctx.delay('infinite')
      );
    }
    
    return res(
      ctx.json({
        success: true,
        data: {
          id: req.params.id,
          title: 'Updated Demo Todo',
          completed: true,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: new Date().toISOString(),
          userId: 'demo-user'
        }
      })
    );
  }),
  
  // 統計情報 - Container Apps障害シミュレーション
  rest.get('/api/stats', (req, res, ctx) => {
    return res(
      ctx.status(502),
      ctx.json({
        success: false,
        error: {
          code: 'BACKEND_UNAVAILABLE',
          message: 'Container Apps backend is temporarily unavailable'
        }
      })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('Container Apps Integration (Demo Environment)', () => {
  const createTestQueryClient = () => new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  it('should handle Container Apps health check', async () => {
    const queryClient = createTestQueryClient();
    
    render(
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    );

    // システム状態が正常に表示されることを確認
    await waitFor(() => {
      expect(screen.getByText(/システム状態.*正常/)).toBeInTheDocument();
    });
  });

  it('should handle memory stress simulation during Todo creation', async () => {
    const queryClient = createTestQueryClient();
    
    render(
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    );

    // Todo作成フローをテスト
    const createButton = screen.getByText('新規作成');
    fireEvent.click(createButton);

    const titleInput = screen.getByLabelText('タイトル');
    fireEvent.change(titleInput, { target: { value: 'Test SRE Demo' } });

    const saveButton = screen.getByText('保存');
    fireEvent.click(saveButton);

    // メモリ消費処理のタイムアウトまたは正常完了を確認
    await waitFor(() => {
      const hasTimeoutMessage = screen.queryByText(/メモリ消費処理の可能性/);
      const hasSuccessMessage = screen.queryByText(/Test SRE Demo/);
      
      expect(hasTimeoutMessage || hasSuccessMessage).toBeTruthy();
    }, { timeout: 10000 });
  });

  it('should handle Container Apps backend unavailable scenario', async () => {
    const queryClient = createTestQueryClient();
    
    render(
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    );

    // 統計表示をクリック（502エラーが返される設定）
    const statsButton = screen.getByText('統計表示');
    fireEvent.click(statsButton);

    // バックエンド利用不可メッセージが表示されることを確認
    await waitFor(() => {
      expect(screen.getByText(/バックエンドサービスが一時的に利用できません/)).toBeInTheDocument();
    });
  });

  it('should display SRE Agent recovery message', async () => {
    const queryClient = createTestQueryClient();
    
    render(
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    );

    // エラー発生時にSRE Agentメッセージが表示されることを確認
    const statsButton = screen.getByText('統計表示');
    fireEvent.click(statsButton);

    await waitFor(() => {
      expect(screen.getByText(/SRE Agent.*対処中/)).toBeInTheDocument();
    });
  });
});
```
  
  // メモリ消費処理シミュレーション（タイムアウト）
  rest.post('/api/todos', (req, res, ctx) => {
    // 50%の確率でタイムアウトをシミュレート
    if (Math.random() < 0.5) {
      return res(
        ctx.delay('infinite') // タイムアウトを引き起こす
      );
    }
    
    return res(
      ctx.json({
        success: true,
        data: {
          id: '2',
          title: 'New Todo',
          completed: false,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
          userId: 'user1'
        }
      })
    );
  }),
  
  // Container Apps障害シミュレーション
  rest.get('/api/stats', (req, res, ctx) => {
    return res(
      ctx.status(502),
      ctx.json({
        success: false,
        error: {
          code: 'BACKEND_UNAVAILABLE',
          message: 'Container Apps backend is temporarily unavailable'
        }
      })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('Container Apps Integration', () => {
  const createTestQueryClient = () => new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  it('should handle Container Apps health check', async () => {
    const queryClient = createTestQueryClient();
    
    render(
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    );

    // ヘルスチェックが成功することを確認
    await waitFor(() => {
      expect(screen.getByText(/システム状態: 正常/)).toBeInTheDocument();
    });
  });

  it('should handle Container Apps timeout (memory stress)', async () => {
    const queryClient = createTestQueryClient();
    
    render(
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    );

    // Todo作成ボタンをクリック
    const createButton = screen.getByText('新規作成');
    fireEvent.click(createButton);

    // フォームに入力
    const titleInput = screen.getByLabelText('タイトル');
    fireEvent.change(titleInput, { target: { value: 'Test Todo' } });

    // 保存ボタンをクリック
    const saveButton = screen.getByText('保存');
    fireEvent.click(saveButton);

    // タイムアウトエラーメッセージが表示されることを確認
    await waitFor(() => {
      expect(screen.getByText(/メモリ消費処理の可能性/)).toBeInTheDocument();
    }, { timeout: 10000 });
  });

  it('should handle Container Apps backend unavailable', async () => {
    const queryClient = createTestQueryClient();
    
    render(
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    );

    // 統計ボタンをクリック（502エラーが返される）
    const statsButton = screen.getByText('統計表示');
    fireEvent.click(statsButton);

    // バックエンド利用不可メッセージが表示されることを確認
    await waitFor(() => {
      expect(screen.getByText(/バックエンドサービスが一時的に利用できません/)).toBeInTheDocument();
    });
  });
});
```

### Static Web Apps最適化（デモ環境用）
```typescript
// utils/staticWebAppsOptimization.ts

// デモ環境用の最適化設定
export const optimizeForDemo = () => {
  const environment = getCurrentEnvironment();
  
  if (environment === 'local') {
    // ローカル開発環境用の軽量設定
    return new QueryClient({
      defaultOptions: {
        queries: {
          staleTime: 0, // 常に最新データを取得
          cacheTime: 0, // キャッシュなし
          retry: false, // リトライなし（デバッグしやすさ優先）
        },
        mutations: {
          retry: false,
        },
      },
    });
  }
  
  // Azure クラウド環境用の最適化設定
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 2 * 60 * 1000, // 2分間はフレッシュとみなす
        cacheTime: 5 * 60 * 1000, // 5分間キャッシュ保持
        retry: (failureCount, error) => {
          // Container Apps特有のエラーハンドリング（デモ用）
          if (axios.isAxiosError(error)) {
            if (error.response?.status === 502 || error.response?.status === 503) {
              return failureCount < 3; // バックエンドエラーは3回まで再試行
            }
            if (error.code === 'ECONNABORTED') {
              return failureCount < 2; // タイムアウトは2回まで再試行
            }
          }
          return false; // その他のエラーはリトライしない
        },
      },
      mutations: {
        retry: (failureCount, error) => {
          // メモリ消費処理の可能性がある場合は再試行しない
          if (axios.isAxiosError(error) && error.code === 'ECONNABORTED') {
            return false;
          }
          return failureCount < 1;
        },
      },
    },
  });
};

// 環境設定の取得
export const getDemoConfig = () => {
  const environment = getCurrentEnvironment();
  
  return {
    environment,
    isLocal: environment === 'local',
    isAzure: environment === 'azure',
    apiConfig: {
      baseUrl: environment === 'local' 
        ? process.env.VITE_CONTAINER_APPS_URL || 'http://localhost:8080/api'
        : '/api',
      timeout: environment === 'local' ? 30000 : 60000,
      retryAttempts: environment === 'local' ? 0 : 3,
    },
    features: {
      authentication: false, // デモ用途のため認証なし
      monitoring: environment === 'azure',
      debugMode: environment === 'local',
      demoMode: true,
    },
  };
};

// Container Apps統合のためのルーティング（デモ用）
export const setupDemoApiRouting = () => {
  const config = getDemoConfig();
  
  return {
    basePath: config.apiConfig.baseUrl,
    endpoints: {
      health: `${config.apiConfig.baseUrl}/health`,
      todos: `${config.apiConfig.baseUrl}/todos`,
      stats: `${config.apiConfig.baseUrl}/stats`,
    },
    timeout: config.apiConfig.timeout,
    retryAttempts: config.apiConfig.retryAttempts,
    environment: config.environment,
  };
};

// ローカル開発用のCORS設定確認
export const checkLocalCorsSetup = () => {
  if (getCurrentEnvironment() === 'local') {
    console.log('🔧 Local Development Mode');
    console.log('📡 API Base URL:', process.env.VITE_CONTAINER_APPS_URL || 'http://localhost:8080/api');
    console.log('🌐 CORS Enabled:', process.env.VITE_CORS_ENABLED === 'true');
    console.log('🐛 Debug Mode:', process.env.VITE_DEBUG_MODE === 'true');
  }
};
```

## SRE Agent連携

### 監視指標の提供
- **ユーザーアクション**: クリック、作成、更新、削除
- **API レスポンス時間**: 各エンドポイントの応答時間
- **エラー発生**: フロントエンドエラー、API エラー
- **パフォーマンス**: ページ読み込み時間、レンダリング時間

### 障害時の表示
```typescript
// 障害検知時の UI
const SystemDownAlert = () => (
  <Alert severity="warning" sx={{ mb: 2 }}>
    <AlertTitle>システム障害を検知しました</AlertTitle>
    SRE Agentが自動回復処理を実行中です。しばらくお待ちください...
    <LinearProgress sx={{ mt: 1 }} />
  </Alert>
);
```

## 付録

### 関連ドキュメント
- [インフラストラクチャ仕様書](./infrastructure-specification.md)
- [バックエンド仕様書](./backend-specification.md)
- [運用手順書](./operation-manual.md)

### 更新履歴
- 2025年7月23日: 初版作成（React + TypeScript + MUI）