# Sync-runner

GitHub Actions 工作流集合，用于仓库同步、Release 镜像、Actions 清理和坚果云备份。

## Variables & Secrets

PATH：Repository Settings → Secrets and variables → Actions

| Name | Type | Purpose |
| --- | --- | --- |
| APP_ID | Variable | Shared by all workflows |
| APP_PRIVATE_KEY | Secret | Shared by all workflows |
| JIANGUOYUN_USER | Secret | For Jianguoyun backup |
| JIANGUOYUN_PASSWORD | Secret | For Jianguoyun backup |

## GitHub Apps Permissions

PATH：GitHub Settings → Developer settings → GitHub Apps → Permissions & events

| Name | Permissions | Description |
|----------------|-------------| --- |
| Actions | Read and Write | Workflows, workflow runs and artifacts. |
| Administration | Read and Write | Repository creation, deletion, settings, teams, and collaborators. |
| Contents | Read and Write | Repository contents, commits, branches, downloads, releases, and merges. |
| Workflows | Read and Write | Update GitHub Action workflow files. |