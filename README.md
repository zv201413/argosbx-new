# Argosbx-New一键无交互小钢炮脚本💣：基于甬哥原版优化定制

---------------------------------------
基于[甬哥argosbx小钢炮](https://github.com/yonggekkk/argosbx)项目改造

## 建议配合SSH一键脚本命令生成器网页使用：https://zv201413.github.io/argosbx-new/

----------------------------------------------------------
## 原版对比优化说明

| 优化项 | 原版 | 新版 |
|:---|:---|:---|
| 国家代码检测 | ❌ 无 | ✅ 自动检测并添加节点前缀 |
| GitHub Gist推送 | ❌ 无 | ✅ 支持节点订阅推送 |
| 优选IP/域名 | ❌ 无 | ✅ argoip变量支持 |
| 直连节点地址 | ❌ 无 | ✅ nodeaddr变量支持 |
| IPv4/IPv6出站 | ❌ 无 | ✅ ippref变量支持 |
| WARP出站控制 | 基础 | ✅ wippref变量增强 |
| VLESS ENC加密 | ✅ 支持 | ✅ 支持（按需启用Xray） |
| Vless-ws绑定 | 强制跟随Xray | ✅ 按需启动，独立运行 |
| 节点地址切换 | ippz | 优化为Address选项 |
| IPv6优先回退 | ❌ 无 | ✅ ippz=6支持回退 |
| 容器兼容性 | ❌ 无检测 | ✅ 自动检测，回退Xray |
| 探针安装转换 | ❌ 无 | ✅ 支持哪吒/Komari探针一键转免systemd命令 |

### 容器兼容性自动回退

原版在某些容器环境下可能无法正常运行Sing-box（需要netlink支持）。

新版新增自动检测逻辑：
- 自动检测容器是否支持Sing-box路由订阅
- 不支持时自动切换到Xray模式
- 无需手动干预，确保脚本在任何环境下都能运行

### 哪吒 / Komari 探针一键转换

原版的官方安装脚本通常强依赖 `systemd`，在 Docker 或 PaaS 容器中直接运行会报错。新版 Web 面板彻底解决了这个问题：
- **智能解析**：直接把官方带 `-e` 和 `-t` 的安装命令粘贴进面板，自动剥离出核心的 Server 和 Secret。
- **TLS 自动探测**：如果填写的连接端口为 `443`、`8443`、`2096`、`2087`、`2083`、`2053` 之一，面板生成的命令将自动判定并开启 TLS (HTTPS) 安全连接。
- **免 systemd 生成**：点击新增的闪电按钮 ⚡，一键生成纯粹的二进制下载与后台执行命令，并提供针对常规 PaaS 和极度受限环境(无 wget/nohup)的双轨方案。
- **完全兼容容器**：生成的命令完美绕过 systemd 检查，可在任何极简容器环境中稳定运行。

> **适用场景提示**：此转换功能专为**没有 systemd 的 PaaS 平台和纯 Docker 容器**打造。如果你使用的是真实的 VPS 或独立服务器，仍建议直接使用官方原始的 `install.sh` 命令。

### ENC加密说明

新版支持VLESS ENC加密，但采用了不同的实现方式：

**原版问题**：ENC加密强制使用Xray内核，即使只启用Sing-box协议也会启动Xray，导致资源浪费。

**新版方案**：
- ENC加密只在用户需要时启用
- 启用ENC时会自动按需启动Xray内核
- 不启用ENC时，Vless-ws默认使用Sing-box运行，减少资源占用

**支持的ENC协议**：
- Vless-tcp-reality-vision（vlpt）
- Vless-xhttp-reality（xhpt）
- Vless-xhttp（vxpt）
- Vless-ws（vwpt）

### Vless-ws按需启动

原版中Vless-ws必须跟随Xray内核运行，新版可以：
- 独立使用Sing-box运行
- 按需启用，不强制绑定Xray
- 减少资源占用

----------------------------------------------------------

## 一、变量参数说明

### 必选协议端口变量

| 变量 | 说明 | 示例 |
|:---|:---|:---|
| vlpt | Vless-tcp-reality-vision | `vlpt=""` 或 `vlpt="443"` |
| xhpt | Vless-xhttp-reality | `xhpt=""` 或 `xhpt="443"` |
| vxpt | Vless-xhttp | `vxpt=""` 或 `vxpt="443"` |
| vwpt | Vless-ws | `vwpt=""` 或 `vwpt="443"` |
| vmpt | Vmess-ws | `vmpt=""` 或 `vmpt="443"` |
| anpt | AnyTLS | `anpt=""` 或 `anpt="443"` |
| arpt | Any-reality | `arpt=""` 或 `arpt="443"` |
| sspt | Shadowsocks-2022 | `sspt=""` 或 `sspt="443"` |
| hypt | Hysteria2 | `hypt=""` 或 `hypt="443"` |
| hyjpt | Hysteria2 端口跳跃 | `hyjpt="20000:30000 40000"` |
| tupt | Tuic | `tupt=""` 或 `tupt="443"` |
| sopt | Socks5 | `sopt=""` 或 `sopt="443"` |

### ENC加密变量（可选）

| 变量 | 说明 | 备注 |
|:---|:---|:---|
| vlpt_enc | Vless-tcp-reality-vision 加密 | 勾选启用ENC加密 |
| xhpt_enc | Vless-xhttp-reality 加密 | 勾选启用ENC加密 |
| vxpt_enc | Vless-xhttp 加密 | 勾选启用ENC加密 |
| vwpt_enc | Vless-ws 加密 | 勾选启用ENC加密 |

**注意**：启用ENC加密时会自动启动Xray内核处理加密。

### 可选功能变量

| 变量 | 说明 | 默认值 | 示例 |
|:---|:---|:---|:---|
| ippz | 节点地址显示（Address） | 默认IPv4优先 | `ippz=""` 默认 / `ippz="6"` IPv6优先 |
| ippref | 非Warp出站路由 | 默认IPv4优先出站 | `ippref=""` 默认 / `ippref="prefer_ipv6"` IPv6优先出站 |
| wippref | WARP出站路由 | 默认IPv6 | `wippref=""` / `wippref="sx4"` 双核IPv4出站 |
| argo | Argo隧道开关 | 关闭 | `argo="vwpt"` 或 `argo="vmpt"` |
| agn | Argo固定隧道域名 | 临时隧道 | `agn="cf域名"` |
| agk | Argo固定隧道token | 临时隧道 | `agk="ey开头的token"` |
| uuid | UUID密码 | 随机生成 | `uuid="你的uuid"` |
| reym | Reality域名 | apple.com | `reym="apple.com"` |
| cdnym | CDN域名 | 直连 | `cdnym="CF解析域名"` |
| name | 节点名称前缀 | 默认协议名前缀 | `name="mynode"` |
| warp | WARP出站模式 | 关闭 | 详见下方WARP模式 |
| argoip | Argo优选IP/域名 | 自动 | `argoip="优选IP或域名"` |
| nodeaddr | 直连节点地址 | VPS IP | `nodeaddr="自定义地址"` |
| gh_token | GitHub Token | 关闭 | `gh_token="ghp_xxx"` |
| gh_gist_id | Gist ID | 新建 | `gh_gist_id="已有ID"` |
| oap | 开放所有端口 | 关闭 | `oap="y"` |
| KNOCK | 敲门+空闲自关 总开关 | 关闭 | `KNOCK="1"` |
| KNOCK_PORT | 敲门端口 | 自动分配 | `KNOCK_PORT="38000"` |
| IDLE_TIMEOUT | 空闲多少秒后关代理 | 300 | `IDLE_TIMEOUT="300"` |
| STEALTH_NAME | 进程伪装名（逗号分隔3个=sing-box,xray,cloudflared） | 不伪装 | `STEALTH_NAME="[kworker/0:1],[kworker/1:2],[kworker/2:0]"` |

### 敲门唤醒 / 进程隐身（KNOCK，默认关闭）

可选的隐蔽机制：空闲时自动关闭代理进程、连接前“敲门”自动拉起，配合进程改名降低被检测概率。**不传 `KNOCK` 时行为与原版完全一致。**

- `KNOCK="1"` 启用。空闲超过 `IDLE_TIMEOUT` 秒（默认 300）无连接 → 关闭代理；连接前先敲门：`nc -w1 <服务器IP> <KNOCK_PORT>`，代理随后自动拉起。
- `STEALTH_NAME` 填进程伪装名，**逗号分隔 3 个**依次对应 sing-box、xray、cloudflared；只填 1 个则三者共用；留空不伪装。建议用 `[kworker/x:y]` 这类内核线程名。**伪装需要 bash**（Alpine：`apk add bash`），无 bash 时不伪装但敲门/空闲自关照常。
- 启用后由内置 watchdog 独占管理代理生命周期（不再走 systemd/OpenRC 自启）。
- **cloudflared 行为按隧道类型不同**：
  - **固定隧道**（填 `agn`+`agk`）：cloudflared 与 sing-box/xray 一样**按需启停**——空闲时一起关闭、敲门时一起拉起，域名稳定不变。隐蔽性最佳（空闲时三个进程全消失）。
  - **临时隧道**（不填 `agn`/`agk`）：cloudflared **改名后常驻**（不参与空闲关闭），因为重启会换域名。

> ⚠️ **隧道重启限制**：Cloudflare **临时隧道**每次启动都会分配新的 `*.trycloudflare.com` 域名，因此**重启 / 关闭后无法用原域名恢复**——客户端节点会失效，需重新运行脚本。**只有固定隧道**（Zero Trust 命名隧道）域名稳定，支持随意重启 / 空闲关闭 / 开机自启。要用「敲门隐蔽 + 可自动恢复 + cloudflared 也按需」，请使用固定隧道。

### Hysteria2 端口跳跃（hyjpt）

仅当开启了 Hy2 协议（`hypt=""`）时才生效。格式说明：
- 端口范围用 **冒号** 分隔，如 `20000:30000` 表示 20000～30000 的所有端口
- 多个范围或单端口用 **空格** 分隔，如 `20000:30000 40000`
- 脚本会自动下发 iptables DNAT 规则，将跳跃端口的 UDP 流量转发到实际监听的 Hy2 端口
- 节点链接会自动追加 `&mport=20000-30000,40000` 参数供客户端识别

**示例**：
```bash
hypt=yes hyjpt="20000:30000 40000" ./argosbx.sh
```

**注意**：需要 root 权限操作 iptables。生成的链接中 `mport` 参数使用连字符（`-`）而非冒号（`:`），这是客户端标准解析格式。

### WARP出站模式（warp变量）

| warp值 | 说明 |
|:---|:---|
| 空 | 服务器本地IP出站 |
| s | Singbox套WARP IPv4+IPv6、Xray本地IP |
| s4 | Singbox套WARP IPv4、Xray本地IP |
| s6 | Singbox套WARP IPv6、Xray本地IP |
| x | Singbox本地IP、Xray套WARP IPv4+IPv6 |
| x4 | Singbox本地IP、Xray套WARP IPv4 |
| x6 | Singbox本地IP、Xray套WARP IPv6 |
| sx | Singbox+Xray同时套WARP IPv4+IPv6 |
| s4x4 | Singbox+Xray同时套WARP IPv4 |
| 其他 | 查看脚本完整选项 |

---------------------------------------------------------

## 二、快捷命令

| 命令 | 说明 |
|:---|:---|
| `agsbx list` 或 `主脚本 list` | 查看节点信息 |
| `agsbx rep` 或 `主脚本 rep` | 重置协议配置 |
| `agsbx upx` | 更新Xray内核 |
| `agsbx ups` | 更新Singbox内核 |
| `agsbx res` | 重启脚本 |
| `agsbx del` | 卸载脚本 |

### 临时切换节点地址类型
```
ippz=6 agsbx list    # 切换到IPv6优先
ippz=4 agsbx list    # 切换到IPv4
```

---------------------------------------------------------

## 三、ippz变量使用场景说明

### 适用场景

`ippz=6`（IPv6优先）适用于以下情况：

1. **双栈VPS的IPv4内外部端口不一致**
   - 服务商提供端口映射（如外部22325→内部2325）
   - AnyTLS/Shadowsocks-2022/Any-Reality使用外部端口时可能不通
   - 使用IPv6地址可直接访问容器内部端口，无需端口映射

2. **服务商端口转发不稳定**
   - IPv4端口转发可能影响TLS指纹验证
   - IPv6直连通常更稳定

3. **需要统一内外部端口**
   - IPv6访问：`[IPv6地址]:2325`（内部端口）
   - 无需配置额外的端口映射规则

### 示例对比

| 方式 | 节点地址 | 端口 |
|:---|:---|:---|
| 默认（IPv4） | `31.22.111.169` | 22325（外部端口） |
| IPv6优先 | `[2001:470:1f18::15b]` | 2325（内部端口） |

### 选择建议

- 如果服务商端口转发正常工作 → 使用默认设置
- 如果AnyTLS等协议不通 → 尝试 `ippz=6`
- 如果只需要单一端口 → IPv6是最简单的解决方案

---------------------------------------------------------

## 四、探针卸载指南

无论你是部署的哪吒探针还是 Komari 探针，请根据你的**初始安装方式**选择对应的清理流程：

### 1. 真实 VPS（使用官方 `.sh` 脚本安装的）
官方脚本会自动把探针塞进系统服务里（systemd）并安装到 `/opt` 目录。在当前目录执行 `rm` 是没用的！

**正确卸载方式**：
```bash
# 停止并禁用服务（如果是 komari 请替换 nezha 为 komari）
sudo systemctl stop nezha-agent
sudo systemctl disable nezha-agent

# 删除系统服务文件并刷新
sudo rm /etc/systemd/system/nezha-agent.service
sudo systemctl daemon-reload

# 删掉真正存放程序的安装目录（关键步骤）
sudo rm -rf /opt/nezha    # 或者是 /opt/komari
```
*(注：对于哪吒探针，你也可以在原机重新运行一次官方安装命令，然后在弹出的交互菜单里选择 `卸载 Agent`)*

### 2. 纯容器环境 / PaaS（使用本面板生成的 `nohup` 裸跑命令）
使用我们面板转换出来的指令，属于“绿色免安装”模式，不触及系统服务。

**正确卸载方式**：
```bash
# 1. 猎杀后台驻留的进程
pkill -f nezha-agent    # 或 pkill -f komari-agent

# 2. 直接删掉当前目录下下载的二进制文件及日志
rm -f nezha-agent agent.log    # 或 komari-agent
```
