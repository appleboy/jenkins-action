# 🚀 GitHub Actions 觸發 Jenkins 任務

[![Trivy Security Scan](https://github.com/appleboy/jenkins-action/actions/workflows/trivy.yml/badge.svg)](https://github.com/appleboy/jenkins-action/actions/workflows/trivy.yml)

[English](./README.md) | 繁體中文 | [简体中文](./README.zh-CN.md)

用於觸發 [Jenkins](https://jenkins.io/) 任務的 [GitHub Action](https://github.com/features/actions)。

## 目錄

- [🚀 GitHub Actions 觸發 Jenkins 任務](#-github-actions-觸發-jenkins-任務)
  - [目錄](#目錄)
  - [為什麼要使用 Jenkins Action？](#為什麼要使用-jenkins-action)
  - [簡報](#簡報)
  - [使用方式](#使用方式)
  - [Jenkins 設定](#jenkins-設定)
  - [身份驗證與 CSRF 保護](#身份驗證與-csrf-保護)
    - [了解 Jenkins 的 CSRF 保護](#了解-jenkins-的-csrf-保護)
    - [認證方式](#認證方式)
      - [1. 使用者 + API Token（建議）](#1-使用者--api-token建議)
      - [2. 遠端 Token（舊版）](#2-遠端-token舊版)
  - [範例](#範例)
  - [輸入參數](#輸入參數)
  - [輸出變數](#輸出變數)
  - [完整工作流程範例](#完整工作流程範例)

## 為什麼要使用 Jenkins Action？

在許多企業內部，不同團隊各自使用不同的 CI/CD 平台。舊有系統多半仍在 Jenkins 上運行，而 GitHub Actions 和 Gitea Actions 等現代化平台則提供了更強大的功能與更佳的開發體驗。這造成了一個兩難：團隊想要採用新工具，卻無法捨棄既有的 Jenkins 基礎設施。

**Jenkins Action 正是為了解決這個問題而生。** 它在現代 CI/CD 平台與 Jenkins 之間建立了無縫橋接，讓團隊能夠：

- **按照自己的步調遷移** - 立即開始使用 GitHub Actions 或 Gitea Actions，同時保留對既有 Jenkins 任務的調用，無需立即改寫
- **跨平台協作** - 不同團隊可以使用各自偏好的工具，同時維持系統間的互通性
- **消除採用障礙** - 解決「要嘛全換、要嘛不換」的困境，讓團隊能夠逐步現代化

透過串接現代化的 GitHub Actions 或 Gitea Actions 工作流程與既有的 Jenkins 基礎設施，這個 action 為組織提供了一條實際可行、低風險的 CI/CD 現代化路徑。

## 簡報

查看 [Connecting Your Worlds: A Guide to Integrating GitHub Actions and Jenkins](https://speakerdeck.com/appleboy/connecting-your-worlds-a-guide-to-integrating-github-actions-and-jenkins) 了解更多詳情。

![jenkins](./images/jenkins-action_1024x572.png)

## 使用方式

觸發新的 Jenkins 任務。

```yaml
name: trigger jenkins job
on: [push]
jobs:

  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
    - name: trigger single Job
      uses: appleboy/jenkins-action@v1
      with:
        url: "http://example.com"
        user: "example"
        token: ${{ secrets.TOKEN }}
        job: "foobar"
```

## Jenkins 設定

使用 docker 命令設定 Jenkins 伺服器：

```sh
docker run \
  --name jenkins-docker \
  -d --restart always \
  -p 8080:8080 -p 50000:50000 \
  -v /data/jenkins:/var/jenkins_home \
  jenkins/jenkins:lts
```

請確保在啟動 Jenkins 之前建立 `/data/jenkins` 目錄。

前往使用者設定檔並點擊 `Configure`：

![jenkins](./images/user-api-token_1024x704.png)

## 身份驗證與 CSRF 保護

### 了解 Jenkins 的 CSRF 保護

CSRF（跨站請求偽造）保護使用在 Jenkins 中稱為 **crumb** 的 token。此 crumb 由 Jenkins 建立並傳送給使用者。任何表單提交或導致修改的動作（如觸發建置或變更設定）都需要提供 crumb。crumb 包含識別其建立對象的使用者資訊，因此使用其他使用者 token 的提交將被拒絕。所有這些都在背景中進行，除了在極少數情況下（例如使用者的 session 過期並重新登入後）外，不會產生可見的影響。

更多詳情請參閱 [Jenkins CSRF Protection 文件](https://www.jenkins.io/doc/book/security/csrf-protection/)。

### 認證方式

此 action 支援兩種認證方式：

#### 1. 使用者 + API Token（建議）

```yaml
- name: trigger with user authentication
  uses: appleboy/jenkins-action@v1
  with:
    url: http://example.com
    user: example
    token: ${{ secrets.TOKEN }}
    job: job_1
```

**運作方式：**

- 使用 Jenkins 使用者名稱和 API token 進行認證
- **自動處理 CSRF 保護**，會取得並包含 crumb token
- action 會額外呼叫 `/crumbIssuer/api/json` API 來取得 crumb
- crumb 會被包含在所有後續的請求中
- 更安全且建議在大多數情況下使用

**何時使用：**

- 預設啟用 CSRF 保護的標準 Jenkins 安裝
- 需要完整 API 存取和安全性時
- 正式環境

#### 2. 遠端 Token（舊版）

```yaml
- name: trigger with remote token
  uses: appleboy/jenkins-action@v1
  with:
    url: http://example.com
    remote_token: ${{ secrets.REMOTE_TOKEN }}
    job: job_1
```

**運作方式：**

- 使用 Jenkins 任務特定的遠端觸發 token
- **繞過 CSRF 保護** - 不需要 crumb token
- 在 Jenkins 任務設定中的「建置觸發器」>「遠端觸發建置」進行設定
- 較不安全，因為只需要知道任務名稱和遠端 token

**何時使用：**

- 停用 CSRF 保護的 Jenkins 執行個體
- 舊版系統或特定安全需求
- 僅需要觸發特定任務而不需要完整 API 存取權限時
- 無法處理 crumb token 的外部系統

**注意：** 遠端 token 認證被認為較不安全，應謹慎使用。建議在大多數情況下使用「使用者 + API token」認證方式。

## 範例

觸發多個 Jenkins 任務：

```yaml
- name: trigger multiple Job
  uses: appleboy/jenkins-action@v1
  with:
    url: http://example.com
    user: example
    token: ${{ secrets.TOKEN }}
    job: job_1,job_2
```

使用參數觸發 Jenkins 任務：

```yaml
- name: trigger Job with parameters
  uses: appleboy/jenkins-action@v1
  with:
    url: http://example.com
    user: example
    token: ${{ secrets.TOKEN }}
    job: job_1
    parameters: |
      ENVIRONMENT=production
      VERSION=1.0.0
      COMMIT_SHA=${{ github.sha }}
      BRANCH=${{ github.ref_name }}
```

使用遠端 token 觸發 Jenkins 任務：

```yaml
- name: trigger Job with remote token
  uses: appleboy/jenkins-action@v1
  with:
    url: http://example.com
    remote_token: ${{ secrets.REMOTE_TOKEN }}
    job: job_1
```

等待任務完成並自訂逾時時間：

```yaml
- name: trigger Job and wait for completion
  uses: appleboy/jenkins-action@v1
  with:
    url: http://example.com
    user: example
    token: ${{ secrets.TOKEN }}
    job: job_1
    wait: true
    poll_interval: 5s
    timeout: 60m
```

使用自訂 CA 憑證（用於自簽 SSL）：

```yaml
- name: trigger Job with custom CA certificate
  uses: appleboy/jenkins-action@v1
  with:
    url: https://jenkins.example.com
    user: example
    token: ${{ secrets.TOKEN }}
    job: job_1
    ca_cert: ${{ secrets.CA_CERT }}
```

您也可以指定檔案路徑或 HTTP URL 來載入 CA 憑證：

```yaml
- name: trigger Job with CA certificate from file
  uses: appleboy/jenkins-action@v1
  with:
    url: https://jenkins.example.com
    user: example
    token: ${{ secrets.TOKEN }}
    job: job_1
    ca_cert: /path/to/ca-certificate.pem
```

## 輸入參數

| 參數           | 必填          | 預設值  | 說明                                                         |
| -------------- | ------------- | ------- | ------------------------------------------------------------ |
| url            | 是            |         | Jenkins 基礎 URL（例如：`http://jenkins.example.com/`）      |
| user           | 條件式\*      |         | Jenkins 使用者名稱                                           |
| token          | 條件式\*      |         | Jenkins API token                                            |
| remote_token   | 條件式\*      |         | Jenkins 遠端觸發 token                                       |
| job            | 是            |         | Jenkins 任務名稱 - 可指定多個                                |
| parameters     | 否            |         | 建置參數，多行 `key=value` 格式（每行一個）                  |
| insecure       | 否            | `false` | 允許不安全的 SSL 連線                                        |
| wait           | 否            | `false` | 等待任務完成                                                 |
| poll_interval  | 否            | `10s`   | 狀態檢查間隔                                                 |
| timeout        | 否            | `30m`   | 等待任務完成的最長時間                                       |
| debug          | 否            | `false` | 啟用除錯模式以顯示詳細的參數資訊                             |
| ca_cert        | 否            |         | 自訂 CA 憑證（PEM 內容、檔案路徑或 HTTP URL）                |

> \* **認證方式**：需要 `user` + `token` 或 `remote_token` 其中一種。

## 輸出變數

| 參數   | 說明                                                                     |
| ------ | ------------------------------------------------------------------------ |
| result | Jenkins 任務結果（`SUCCESS`、`FAILURE`、`ABORTED`、`UNSTABLE` 或空值）   |
| url    | Jenkins 任務 URL                                                         |

使用範例：

```yaml
- name: Trigger Jenkins Job
  id: jenkins
  uses: appleboy/jenkins-action@v1
  with:
    url: ${{ secrets.JENKINS_URL }}
    user: ${{ secrets.JENKINS_USER }}
    token: ${{ secrets.JENKINS_TOKEN }}
    job: your-job-name
    wait: true

- name: Use outputs
  run: |
    echo "Result: ${{ steps.jenkins.outputs.result }}"
    echo "URL: ${{ steps.jenkins.outputs.url }}"
```

## 完整工作流程範例

以下是一個完整的範例，展示了具有條件觸發、多環境和任務狀態處理的實際 CI/CD 工作流程：

```yaml
name: Deploy via Jenkins
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  deploy:
    name: Trigger Jenkins Deployment
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set environment variables
        id: vars
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "environment=production" >> $GITHUB_OUTPUT
            echo "jenkins_job=deploy-prod" >> $GITHUB_OUTPUT
          else
            echo "environment=staging" >> $GITHUB_OUTPUT
            echo "jenkins_job=deploy-staging" >> $GITHUB_OUTPUT
          fi

      - name: Trigger Jenkins Build and Wait
        uses: appleboy/jenkins-action@v1
        with:
          url: ${{ secrets.JENKINS_URL }}
          user: ${{ secrets.JENKINS_USER }}
          token: ${{ secrets.JENKINS_TOKEN }}
          job: ${{ steps.vars.outputs.jenkins_job }}
          wait: true
          timeout: 30m
          poll_interval: 10s
          parameters: |
            ENVIRONMENT=${{ steps.vars.outputs.environment }}
            VERSION=${{ github.sha }}
            BRANCH=${{ github.ref_name }}
            TRIGGERED_BY=${{ github.actor }}

      - name: Notify on success
        if: success()
        run: echo "Jenkins 任務執行成功！"

      - name: Notify on failure
        if: failure()
        run: echo "Jenkins 任務執行失敗！"
```
