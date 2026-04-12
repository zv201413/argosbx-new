# Argosbx-New 技术总结归档

**归档状态**: Finalized (v2026.03.30)
**更新日期**: 2026-03-30
**技术栈**: Shell Script + GitHub Pages + Gist API + ip-api.com

---

## 1. 项目背景

Argosbx-New 是基于甬哥的 Argosbx 项目的修改版，旨在提供一个更简洁、更易用的代理节点一键部署脚本。本项目在原项目的基础上进行了多项功能增强和用户体验优化。

**核心需求**：
- 支持多种代理协议（VLESS、VMess、Hysteria2、TUIC、AnyTLS、Shadowsocks-2022 等）
- 支持 Argo 隧道部署
- 支持 WARP 出站配置
- 提供直观的 Web 界面生成命令
- 自动推送到 Gist 分享节点信息

---

## 2. 核心架构与调度策略

### 2.1 项目组成

| 组件 | 职能 |
|:---|:---|
| `argosbx.sh` | 核心部署脚本 |
| `index.html` | Web 命令生成器界面 |
| `_worker.js` | GitHub Pages 部署入口 |
| `container/nodejs/` | 容器部署支持 |

### 2.2 环境变量映射

| 变量名 | 说明 |
|:---|:---|
| `uuid` | UUID 密码 |
| `vlpt` / `vmpt` / `vwpt` | VLESS 协议端口 |
| `hypt` / `tupt` | Hysteria2 / TUIC 端口 |
| `argo` | Argo 隧道开关 |
| `argoip` | Argo 优选 IP/域名 |
| `nodeaddr` | 直连节点自定义地址 |
| `ippref` | 优先 IPv4/IPv6 出站 |
| `gh_token` | GitHub Token |
| `gh_gist_id` | Gist ID |

---

## 3. 文件职能与逻辑

### 3.1 argosbx.sh
| 函数/步骤 | 职能 |
|:---|:---|
| `v4v6()` | 检测 IPv4/IPv6 地址 |
| `get_country_code()` | 根据 IP 获取国家代码 |
| `warpsx()` | 处理 WARP 配置 |
| `push_gist()` | 推送节点信息到 Gist |
| `sbrestart()` | 重启 Sing-box |

### 3.2 index.html
- 提供 Web 界面生成一键部署命令
- 实时预览节点名称前缀
- 支持多种协议选择
- 生成 curl/wget 命令

---

## 4. 核心技术突破

### 4.1 国家代码自动检测
**背景**: 需要为节点名称添加国家代码前缀
**解决方案**: 使用 ip-api.com 获取 IP 地址对应的国家代码
```bash
get_country_code(){
  local ip="$1"
  country_code=$(curl -s "http://ip-api.com/json/$ip?fields=countryCode" 2>/dev/null | grep -o '"[A-Z][A-Z]"' | tr -d '"' | head -1)
  echo "$country_code"
}
```

### 4.2 Gist 推送
**背景**: 需要自动推送节点信息到 Gist
**解决方案**: 使用 GitHub API 实现 Gist 创建和更新
```bash
gist_data="{\"description\":\"Argosbx节点信息\",\"public\":false,\"files\":{\"${gist_filename}\":{\"content\":\"$gist_content\"}}}"
curl -s -X POST -H "Authorization: token $gh_token" -H "Content-Type: application/json" -d "$gist_data" "https://api.github.com/gists"
```

### 4.3 路径转义
**背景**: 代理软件对订阅链接中的路径有兼容性要求
**解决方案**: 统一将 `/ws` 转义为 `%2Fws`
```bash
sed -i 's|path=/ws|path=%2Fws|g' "$HOME/agsbx/jh.txt"
```

---

## 5. 踩坑记录

| 问题现象 | 错误尝试 | 正确解法 |
|:---|:---|:---|
| Gist 文件名过长导致软件不识别 | 使用长文件名如 `SG_zvps_super.txt` | 使用简单文件名如 `sub.txt` |
| 节点路径不转义导致软件不识别 | 手动转义每个链接 | 使用 sed 统一批量替换 |
| 优选 IP 不生效 | 在所有地方使用优选 IP | 只替换 Argo 节点的 address 字段 |

---

## 6. 后续项目移植注意事项

### 6.1 技术选型
- ✅ 推荐使用 Shell 脚本，兼容性好
- ✅ 使用 GitHub Pages 托管 Web 界面
- ✅ 使用 Gist API 推送节点信息

### 6.2 代理配置
- 🔒 确保路径正确转义
- ⏱️ 使用 ip-api.com 获取国家代码

### 6.3 状态管理
- 📊 使用 `$HOME/agsbx/` 目录存储配置
- 🔄 通过 bashrc 恢复变量

---

## 7. 更新记录

| 日期 | 版本 | 变更内容 |
|:---|:---|:---|
| 2026-03-30 | v2026.03.30 | 添加国家代码、Gist推送、优先IPv4/IPv6 |
