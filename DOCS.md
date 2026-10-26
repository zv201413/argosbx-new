# Argosbx-New 参数字典与进阶配置指南

> 💡 **互补指引**：本文档为 Argosbx-New 项目的**全量参数字典与高级特性指南**。  
> - 快速开始、原版对比及版本亮点请查阅：👉 **[主页面 README.md](README.md)**  
> - 网页可视化配置请使用：👉 **[SSH 一键脚本命令生成器](https://zv201413.github.io/argosbx-new/)**

---

## 目录

- [一、全量变量参数字典](#一全量变量参数字典)
  - [1. 必选协议端口变量](#1-必选协议端口变量)
  - [2. VLESS ENC 加密变量](#2-vless-enc-加密变量)
  - [3. 可选功能与网络控制变量](#3-可选功能与网络控制变量)
- [二、敲门唤醒与进程隐身（KNOCK）](#二敲门唤醒与进程隐身knock)
  - [1. 机制原理](#1-机制原理)
  - [2. 进程伪装（STEALTH_NAME）](#2-进程伪装stealth_name)
  - [3. 固定隧道 vs 临时隧道的按需行为](#3-固定隧道-vs-临时隧道的按需行为)
  - [4. 客户端敲门唤醒方法](#4-客户端敲门唤醒方法)
- [三、Hysteria2 端口跳跃（hyjpt）](#三hysteria2-端口跳跃hyjpt)
  - [1. 语法格式](#1-语法格式)
  - [2. iptables 自定义链（ARGOSBX_PRE）](#2-iptables-自定义链argosbx_pre)
  - [3. 客户端参数转换](#3-客户端参数转换)
- [四、Hy2 / TUIC 安全加固与客户端配置](#四hy2--tuic-安全加固与客户端配置)
  - [1. 证书钉扎与 URL 编码加固](#1-证书钉扎与-url-编码加固)
  - [2. 主流客户端兼容性矩阵与配置方式](#2-主流客户端兼容性矩阵与配置方式)
  - [3. 服务端证书与公钥指纹排查](#3-服务端证书与公钥指纹排查)
- [五、WARP 出站路由矩阵（warp 变量）](#五warp-出站路由矩阵warp-变量)
- [六、双栈 VPS 与 NAT 端口映射实战（ippz 变量）](#六双栈-vps-与-nat-端口映射实战ippz-变量)
  - [1. 适用痛点场景](#1-适用痛点场景)
  - [2. 映射对比示例](#2-映射对比示例)
  - [3. 选用建议](#3-选用建议)
- [七、哪吒 / Komari 探针深度运维与规范卸载](#七哪吒--komari-探针深度运维与规范卸载)
  - [1. 真实 VPS 环境卸载（systemd 彻底清理）](#1-真实-vps-环境卸载systemd-彻底清理)
  - [2. 纯容器 / PaaS 环境清理（免 systemd 模式）](#2-纯容器--paas-环境清理免-systemd-模式)
- [八、快捷命令与临时环境变量](#八快捷命令与临时环境变量)

---

## 一、全量变量参数字典

### 1. 必选协议端口变量

传入端口数值或使用 `""` 占用默认端口：

| 变量名 | 对应协议 / 传输模式 | 示例 | 说明 |
|:---|:---|:---|:---|
| `vlpt` | Vless-tcp-reality-vision | `vlpt="443"` | 支持 ENC 加密扩展 |
| `xhpt` | Vless-xhttp-reality | `xhpt="443"` | 支持 ENC 加密扩展 |
| `vxpt` | Vless-xhttp | `vxpt="443"` | 支持 ENC 加密扩展 |
| `vwpt` | Vless-ws | `vwpt="8080"` | 支持 ENC 加密，支持 Argo 隧道 |
| `vmpt` | Vmess-ws | `vmpt="8080"` | 支持 Argo 隧道 |
| `anpt` | AnyTLS | `anpt="443"` | 任意 SNI 模拟 |
| `arpt` | Any-reality | `arpt="443"` | Reality 增强 |
| `sspt` | Shadowsocks-2022 | `sspt="8388"` | 现代加密标准 |
| `hypt` | Hysteria2 | `hypt="443"` | 支持端口跳跃与证书钉扎 |
| `hyjpt`| Hysteria2 端口跳跃 | `hyjpt="20000:30000 40000"` | 依赖 `hypt` 启用 |
| `tupt` | Tuic v5 | `tupt="443"` | 支持证书公钥验证 |
| `sopt` | Socks5 | `sopt="1080"` | 明文/基础代理出站 |

### 2. VLESS ENC 加密变量

用于开启 Xray 的 VLESS 额外加密层（防止 TLS in TLS 阻断与特征识别）：

| 变量名 | 对应协议 | 作用 |
|:---|:---|:---|
| `vlpt_enc` | Vless-tcp-reality-vision 加密 | 赋值 `1` 或 `y` 启用 ENC |
| `xhpt_enc` | Vless-xhttp-reality 加密 | 赋值 `1` 或 `y` 启用 ENC |
| `vxpt_enc` | Vless-xhttp 加密 | 赋值 `1` 或 `y` 启用 ENC |
| `vwpt_enc` | Vless-ws 加密 | 赋值 `1` 或 `y` 启用 ENC |

> 📌 **内核按需调度机制**：新版进行了资源解耦——未开启 ENC 时，协议优先以轻量的 Sing-box 核心运行；仅在勾选对应 `_enc` 变量时，才会按需拉起 Xray 内核处理加解密，绝不多占内存。

### 3. 可选功能与网络控制变量

| 变量名 | 说明 | 默认值 | 示例及取值说明 |
|:---|:---|:---|:---|
| `ippz` | 节点连接地址策略（Address） | 空（IPv4优先） | `ippz="6"`：IPv6优先（适合NAT端口映射） |
| `ippref` | 非 WARP 原生出站分流偏好 | 空（IPv4优先） | `ippref="prefer_ipv6"`：IPv6出站优先 |
| `nz_type` | 探针类型 | 命令行默认 `nezha`；网页默认 `komari` | `nezha` / `komari`，导入命令时自动识别 |
| `nz_host` / `nz_port` | 探针服务端主机 / 端口 | 空 / `5555` | 网页根据服务器地址拆分 |
| `nz_sec` / `nz_tls` | 探针密钥 / TLS | 空 / 空 | 哪吒通过 `NZ_*` 配置；`nz_tls="--tls"` 开启 TLS |
| `nz_endpoint` | Komari 完整服务端 URL | 根据主机、端口及 TLS 构造 | `https://monitor.example.com/`；显式 URL 保留协议与路径 |
| `nz_repo` | Komari 发布包来源 | `komari-monitor/komari-agent` | 导入 fork 时保留，如 `zv201413/komari-agent_new` |
| `wippref` | WARP 出站路由选择 | 空（IPv6） | `wippref="sx4"`：双核均强制通过 WARP IPv4 出站 |
| `argo` | Argo 隧道绑定目标 | 关闭 | `argo="vwpt"`（绑定Vless-ws）或 `argo="vmpt"` |
| `agn` | Argo 固定隧道域名 | 临时隧道 | `agn="tunnel.yourdomain.com"`（Zero Trust 命名隧道） |
| `agk` | Argo 固定隧道 Token | 临时隧道 | `agk="eyJh..."`（Cloudflare 隧道密钥） |
| `uuid` | 节点认证 UUID / 密码 | 随机生成 | `uuid="自定义UUID字符串"` |
| `reym` | Reality 目标偷取域名 | `apple.com` | `reym="gateway.icloud.com"` |
| `cdnym` | CDN 节点反代域名 | 直连 | `cdnym="自定义CF解析域名"` |
| `name` | 节点名称前缀 | 协议名前缀 | `name="HK-Node"`（支持自动识别并附加国家Emoji） |
| `warp` | WARP 模式全集选择 | 关闭 | 详见后文 [WARP 出站模式矩阵](#五warp-出站路由矩阵warp-变量) |
| `argoip` | Argo 优选 IP 或 CDN 域名 | 自动 | `argoip="104.16.80.1"` 或优选反代域名 |
| `nodeaddr` | 直连节点外网地址覆盖 | VPS 公网 IP | `nodeaddr="hk.example.com"`（用于 DDNS 或自定义域名） |
| `gh_token` | GitHub Personal Access Token | 关闭 | 用于订阅节点信息自动推送 Gist |
| `gh_gist_id`| 已有 GitHub Gist ID | 自动新建 | `gh_gist_id="abc123xxx"`（更新覆盖已有 Gist） |
| `QR_SHARE` | 二维码分享页 | `1`（开启） | `QR_SHARE="0"` 关闭；选择持久化。Gist 推送成功时分享订阅二维码，否则逐节点二维码 |
| `QR_TERM` | SSH 终端二维码 | `1`（开启） | 自动安装/复用 `qrencode`；Gist 成功时显示订阅，否则逐节点，沿用 `IOS_SHARE`。“二维码分享”下拉框按启用/不启用 qrencode 分组，包含网页+终端、仅终端、仅网页各两种版本及全部关闭；默认双版本网页+终端。仅网页或全部关闭对应 `QR_TERM="0"`，不安装、不运行终端工具，选择持久化；命令行也可单独控制。Debian/Ubuntu 在 `$AGSBX/qrencode-runtime` 解包，无需 root；其他支持的发行版用 root 系统包管理器，安装失败时保留链接输出 |
| `IOS_SHARE` | 同时生成 iOS 兼容版 | `1`（开启） | 原版始终保留；同时生成 `jh-ios.txt`、独立 Gist 订阅和兼容二维码，分别下载 PNG/SVG。`IOS_SHARE="0"` 手动关闭，选择持久化；兼容版 Hy2/TUIC5 跳过证书验证 |
| `oap` | 开放所有协议与全部功能端口 | 关闭 | `oap="y"` |
| `KNOCK` | 敲门唤醒 + 空闲自关总开关 | 关闭（0） | `KNOCK="1"` 开启极致隐身防御 |
| `KNOCK_PORT`| 敲门唤醒端口（UDP/TCP） | 自动分配 | `KNOCK_PORT="38000"` |
| `IDLE_TIMEOUT`| 连续无连接自动关停秒数 | `300` | `IDLE_TIMEOUT="600"`（10分钟无流量自关） |
| `STEALTH_NAME`| 进程伪装名称 | 真实名字 | 逗号隔开对应 sing-box,xray,cloudflared |

---

## 二、敲门唤醒与进程隐身（KNOCK）

### 1. 机制原理
在严苛网络检测或需要长时间静默的环境下，长时间开启代理监听端口容易被主动扫描。  
`KNOCK="1"` 提供了一种“平时完全关闭、用前单包唤醒”的低特征运行模式：
- **空闲超时自关**：启动内置精简 watchdog，连续监测 `IDLE_TIMEOUT` 秒（默认 300 秒）内无活动 TCP/UDP 连接后，自动优雅杀死 sing-box / xray / cloudflared 代理进程。
- **端口敲门唤醒**：客户端在建立连接前，向指定的 `KNOCK_PORT` 发送单包，watchdog 捕获信号后秒级拉起代理后台。

### 2. 进程伪装（STEALTH_NAME）
通过 Linux 的 `exec -a` 将真实二进制名字替换为内核守护线程名（如 `[kworker/0:1]`）：
- 格式要求：以逗号隔开 3 个名字，依次对应 `sing-box`、`xray`、`cloudflared`。若只填 1 个，则三者共用该伪装名。
- 示例：`STEALTH_NAME="[kworker/0:1],[kworker/1:2],[kworker/2:0]"`
- 系统环境：伪装功能需要调用 `/bin/bash`（Alpine 容器请先执行 `apk add bash`）。无 bash 时伪装自动跳过，但敲门和空闲关闭依然生效。

### 3. 固定隧道 vs 临时隧道的按需行为
- **固定隧道（填写 `agn` 与 `agk`）**：  
  cloudflared 与代理内核一同纳入按需启停管理——空闲时三者全关闭，主机上无任何监听与特征；敲门后全部恢复。由于固定隧道域名固定，客户端链接永久有效。
- **临时隧道（未填 `agn`/`agk`）**：  
  ⚠️ **隧道重启限制**：Cloudflare 临时隧道每次启动均会重新分配 `*.trycloudflare.com` 子域名，关闭后再拉起原域名会失效。因此在临时隧道模式下，cloudflared 将会改名后保持常驻，不参与空闲关闭。**若追求全进程隐身，强烈建议搭配固定隧道使用**。

### 4. 客户端敲门唤醒方法
连接节点前在本地终端或脚本中执行一次快速敲门即可：
```bash
# TCP 探测敲门（超时 1 秒）
nc -z -w1 <服务器IP> <KNOCK_PORT>

# 或 curl 探测
curl --connect-timeout 1 http://<服务器IP>:<KNOCK_PORT> >/dev/null 2>&1
```

---

## 三、Hysteria2 端口跳跃（hyjpt）

### 1. 语法格式
当启用了 Hysteria2（`hypt`）时，通过 `hyjpt` 变量即可开启 UDP 端口跳跃防 QoS：
- **连续范围**：使用冒号 `:` 分隔，如 `20000:30000`
- **离散端口或多段范围**：使用空格分隔，如 `20000:30000 40000 45000:50000`

```bash
# 启动示例
hypt="443" hyjpt="20000:30000 40000" ./argosbx.sh
```

### 2. iptables 自定义链（ARGOSBX_PRE）
- **原版痛点**：甬哥原版在清理规则时直接全量清空 `iptables -t nat -F PREROUTING`，极易误删宿主机上的 Docker、K8s 或其他业务系统的转发规则。
- **新版架构**：新版在 NAT 表中独立创建 `ARGOSBX_PRE` 链，仅在脚本专有链内添加 DNAT 转发规则：
  ```
  PREROUTING ---> [ARGOSBX_PRE 专有链] ---> 其他系统原有规则
  ```
  在脚本卸载（`agsbx del`）或配置重置（`agsbx rep`）时，仅针对 `ARGOSBX_PRE` 链进行刷新和剥离，**绝不影响系统其他任何 NAT 规则**。

### 3. 客户端参数转换
脚本生成的节点链接会自动把输入的冒号转换为标准规范的连字符，并追加 `&mport=20000-30000,40000` 参数，主流 Hy2 客户端导入后可直接识别。

---

## 四、Hy2 / TUIC 安全加固与客户端配置

### 1. 证书钉扎与 URL 编码加固
- **base64 公钥钉扎**：弃用不安全的 `insecure=1`，升级为 `insecure=0` + `pinSHA256=<base64指纹>`，通过 `certificate_public_key_sha256` 进行真公钥校验，彻底规避中间人劫持。
- **URL Percent-Encoding 编码**：base64 字符串中常包含 `+`、`/`、`=` 等保留字符，直接拼接到 URI 查询参数中容易导致客户端解析时将 `+` 替换为空格从而校验失败。新版已内置 `pin_urlenc` 函数实现百分号转义，保障指纹无损传输。
- **证书 SAN 扩展持久化**：首次生成包含 Subject Alternative Name（SAN）的现代标准证书，重装时不被冲刷，客户端指纹长期稳定。

### 2. 主流客户端兼容性矩阵与配置方式

| 客户端类别 | 对 URI `pinSHA256` 参数的处理 | 推荐配置方式 |
|:---|:---|:---|
| **v2rayN（fork 补丁版）** | ✅ 完美解析（Hy2 与 TUIC 均映射为 `certificate_public_key_sha256`） | 导入即用，无需任何手动修改 |
| **NekoBox / sing-box GUI** | ✅ 自动识别并解析为 `certificate_public_key_sha256` | 导入即用 |
| **v2rayN（官方原版）** | ⚠️ Hy2 导入为 CertSha（内核不读取）；TUIC 不识别该参数 | 打开节点设置 → TLS → 完整证书（链）框 → 粘贴 VPS 端的 `~/agsbx/cert.crt` |
| **其他常规客户端** | 根据客户端内核支持情况而定 | 备用方案：手动填入 VPS 生成的 `~/agsbx/PUBKEY_SHA256_B64.txt` 公钥指纹 |

### 3. 服务端证书与公钥指纹排查
在 VPS 上可通过以下命令直接调取凭据：
```bash
# 查看 Base64 格式公钥 SHA256 指纹
cat ~/agsbx/PUBKEY_SHA256_B64.txt

# 查看完整自签证书内容（PEM 格式）
cat ~/agsbx/cert.crt
```

---

## 五、WARP 出站路由矩阵（warp 变量）

通过 `warp` 变量可以精细化控制 Sing-box 与 Xray 双核心是走宿主机原生网络，还是套用 Cloudflare WARP 住宅 IP 出站：

| `warp` 变量值 | Sing-box 出站策略 | Xray 出站策略 |
|:---|:---|:---|
| *(空)* | 本地原生 IP | 本地原生 IP |
| `s` | WARP 双栈 (IPv4 + IPv6) | 本地原生 IP |
| `s4` | WARP 单栈 IPv4 | 本地原生 IP |
| `s6` | WARP 单栈 IPv6 | 本地原生 IP |
| `x` | 本地原生 IP | WARP 双栈 (IPv4 + IPv6) |
| `x4` | 本地原生 IP | WARP 单栈 IPv4 |
| `x6` | 本地原生 IP | WARP 单栈 IPv6 |
| `sx` | WARP 双栈 (IPv4 + IPv6) | WARP 双栈 (IPv4 + IPv6) |
| `s4x4`| WARP 单栈 IPv4 | WARP 单栈 IPv4 |

> 💡 **出站协议族微调**：配合 `wippref` 变量还可进一步指定 WARP 双核出口偏好（如 `wippref="sx4"` 强制 IPv4 优先）。

---

## 六、双栈 VPS 与 NAT 端口映射实战（ippz 变量）

### 1. 适用痛点场景
部分 VPS 商家（如各类 NAT VPS、教育网 VPS、轻量云）的 IPv4 采用了**外网映射端口与容器内监听端口不一致**的架构（例如：公网访问 `31.22.111.169:22325`，内部监听 `2325`）。  
在此类环境下，AnyTLS、Shadowsocks-2022、Any-Reality 等协议在握手校验端口时极易出现阻断或指纹校验不通过。

### 2. 映射对比示例

| 模式 | 节点 Address 字段 | 端口策略 | 适用网络效果 |
|:---|:---|:---|:---|
| **默认（IPv4）** | `31.22.111.169` | 外部映射端口 `22325` | 依赖商家 NAT 转发稳定性，特殊协议可能受限 |
| **IPv6 优先 (`ippz=6`)** | `[2001:470:1f18::15b]` | 内部真实端口 `2325` | 直接打通容器内网端口，免除 NAT 映射，全协议畅通 |

### 3. 选用建议
- 常规独立公网 IP 的 VPS：保持默认留空即可。
- 存在外部端口映射、或 AnyTLS 握手报错的 NAT VPS：在安装命令中追加 `ippz="6"`。
- 在已安装的机器上临时查看 IPv6 节点：执行 `ippz=6 agsbx list`。

---

## 七、哪吒 / Komari 探针深度运维与规范卸载

**通过本项目整合安装的探针**位于 `$AGSBX/komari` 或 `$AGSBX/nezha`。例如 `AGSBX_DIR=/var/www` 时，查看日志使用 `cat /var/www/agsbx/komari/agent.log`。`start.sh` 保存启动配置，`agent.pid` 记录进程；`agsbx res` 重启探针，`agsbx del` 清理对应进程、目录和开机任务。启动成功提示仅说明进程存活，是否已连接到面板需在面板确认。无可用 crontab 时会提示未设置开机自启。

**网页生成的单独探针命令**使用安装目录输入框的路径，不添加 `agsbx` 子目录；日志为该目录下的 `agent.log`。下列卸载方式用于另行运行的官方安装脚本或独立命令。

根据安装时采用的途径选择对应的彻底清理方案：

### 1. 真实 VPS 环境卸载（systemd 彻底清理）
如果是在独立服务器上通过官方脚本安装，探针会注册为 systemd 守护进程并落盘在 `/opt` 目录下：
```bash
# 1. 停止并禁用开机自启（以 nezha 为例，若为 komari 则替换名称）
sudo systemctl stop nezha-agent
sudo systemctl disable nezha-agent

# 2. 移除守护进程服务配置并重载
sudo rm -f /etc/systemd/system/nezha-agent.service
sudo systemctl daemon-reload

# 3. 彻底删除核心程序与配置目录
sudo rm -rf /opt/nezha    # 或 sudo rm -rf /opt/komari
```

### 2. 纯容器 / PaaS 环境清理（免 systemd 模式）
若使用本项目网页端一键生成的免 systemd 绿色命令（nohup 后台启动）：
```bash
# 1. 终结后台运行中的探针进程
pkill -f nezha-agent    # 或 pkill -f komari-agent

# 2. 删除工作目录下的探针二进制与运行日志
rm -f nezha-agent komari-agent agent.log
```

---

## 八、快捷命令与临时环境变量

在 VPS 终端中可随时运行以下快捷指令：

| 快捷命令 | 完整指令等价 | 功能描述 |
|:---|:---|:---|
| `agsbx list` | `主脚本 list` | 查看当前所有运行协议的分享链接与二维码 |
| `agsbx rep` | `主脚本 rep` | 重置并清空所有协议配置 |
| `agsbx upx` | - | 一键检查并升级 Xray 内核到最新稳定版 |
| `agsbx ups` | - | 一键检查并升级 Sing-box 内核到最新稳定版 |
| `agsbx res` | - | 重启所有相关内核服务 |
| `agsbx del` | - | 完整卸载脚本，释放 iptables 专有链与进程 |

### 临时环境变量切换演示
无需重新配置脚本，通过在命令前传入环境变量即可即时生效：
```bash
# 临时按 IPv6 优先展示分享链接
ippz=6 agsbx list

# 临时按 IPv4 强制展示分享链接
ippz=4 agsbx list
```

---

> 🔗 **返回主页**：[Argosbx-New README.md](README.md)


### NAT 外部端口的持久化与旧安装迁移

`*_ext` 会写入安装目录的 `port_*_ext` 文件。以后直接执行 `agsbx list`，以及重启服务器后，
都会从文件回读；它不自动探测 NAT，也不修改宿主机端口转发。

| 外部端口参数 | 持久化文件 |
|---|---|
| `hypt_ext` | `port_hy2_ext` |
| `tupt_ext` | `port_tu_ext` |
| `anpt_ext` | `port_an_ext` |
| `arpt_ext` | `port_ar_ext` |
| `vlpt_ext` / `xhpt_ext` / `vxpt_ext` / `vwpt_ext` | `port_vl_re_ext` / `port_xh_ext` / `port_vx_ext` / `port_vw_ext` |
| `vmpt_ext` / `sspt_ext` / `sopt_ext` | `port_vm_ws_ext` / `port_ss_ext` / `port_so_ext` |

旧版没有保存过的端口无法凭内部监听端口恢复。更新脚本后，按商家实际映射给所有已启用协议
补传一次外部端口；只传 `hypt_ext` 只会补齐 Hy2，不能同时恢复 AnyTLS/TUIC 等其它协议。
后续传入非空的新值会更新对应记录，未传值则保留现有记录。
