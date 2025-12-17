# 🚀 GitHub Actions 觸發 Jenkins 任務

[![Trivy Security Scan](https://github.com/appleboy/jenkins-action/actions/workflows/trivy.yml/badge.svg)](https://github.com/appleboy/jenkins-action/actions/workflows/trivy.yml)

[English](./README.md) | 繁體中文 | [简体中文](./README.zh-CN.md)

用於觸發 [Jenkins](https://jenkins.io/) 任務的 [GitHub Action](https://github.com/features/actions)。

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
