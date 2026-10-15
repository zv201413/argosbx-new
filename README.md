# Argosbx-New一键无交互小钢炮脚本💣：基于甬哥原版优化定制

---

基于 [甬哥argosbx小钢炮](https://github.com/yonggekkk/argosbx) 项目改造。专为无交互自动化部署、容器环境兼容、极致隐身与安全加固设计。

> 📌 **相关资源与文档导航**：
> - 🌐 **可视化面板**：[SSH 一键脚本命令生成器网页](https://zv201413.github.io/argosbx-new/)
> - 📖 **进阶技术文档**：[完整参数字典与高级特性指南 (DOCS.md)](DOCS.md)（含全量变量、KNOCK 敲门原理、端口跳跃 NAT 链、WARP 出站矩阵与双栈实战）

---

## 原版对比优化说明

| 优化项            | 原版                     | 新版                                          |
|:----------------- |:------------------------ |:--------------------------------------------- |
| 国家代码检测      | ❌ 无                     | ✅ 自动检测并添加节点前缀                      |
| GitHub Gist推送   | ❌ 无                     | ✅ 支持节点订阅推送                            |
| 优选IP/域名       | ❌ 无                     | ✅ argoip变量支持                              |
| 直连节点地址      | ❌ 无                     | ✅ nodeaddr变量支持                            |
| IPv4/IPv6出站     | ❌ 无                     | ✅ ippref变量支持                              |
| WARP出站控制      | 基础                     | ✅ wippref变量增强                             |
| VLESS ENC加密     | ✅ 支持                   | ✅ 支持（按需启用Xray）                        |
| Vless-ws绑定      | 强制跟随Xray             | ✅ 按需启动，独立运行                          |
| 节点地址切换      | ippz                     | 优化为Address选项                             |
| IPv6优先回退      | ❌ 无                     | ✅ ippz=6支持回退                              |
| 容器兼容性        | ❌ 无检测                 | ✅ 自动检测，回退Xray                          |
| 探针安装转换      | ❌ 无                     | ✅ 支持哪吒/Komari探针一键转免systemd命令      |
| iptables 端口跳跃 | `-F PREROUTING` 全量清空 | ✅ 自定义链 `ARGOSBX_PRE`，不干扰其他 NAT 规则 |
| 证书生成保护      | 无去重、失败仅警告       | ✅ SHA256 指纹持久化、失败 `exit 1` 中止       |
| 防探测隐身机制    | ❌ 无                     | ✅ 支持 KNOCK 单包敲门唤醒 + 进程伪装内核线程  |

---

## 核心改进亮点

### 1、容器兼容性自动回退
原版在某些容器环境下可能无法正常运行 Sing-box（需要 netlink 路由订阅支持）。
- 自动探测宿主环境是否支持 Sing-box 路由；
- 不支持时无感切换至 Xray 核心运行；
- 确保在各类 Docker 容器、LXC、PaaS 环境下一键部署无阻。

### 2、哪吒 / Komari 探针一键转换（免 systemd）
官方安装脚本强依赖 `systemd`，在 Docker 或 PaaS 容器中运行易报错：
- **智能解析**：直接粘贴官方含 `-e` / `-t` 的安装命令，自动剥离 Server 与 Secret；
- **TLS 自动探测**：填入 443、8443、2096 等端口自动启用安全连接；
- **免 systemd 绿色命令**：一键生成 nohup 后台二进制运行指令，在极度受限容器中即可稳定驻留。

### 3、ENC 加密按需启动
支持 VLESS 协议的 ENC 加密（防止 TLS in TLS 阻断）：
- **支持协议**：`Vless-tcp-reality-vision`（vlpt）、`Vless-xhttp-reality`（xhpt）、`Vless-xhttp`（vxpt）、`Vless-ws`（vwpt）；
- **资源解耦**：原版只要涉及 ENC 即强制全量拉起 Xray。新版默认走极轻量的 Sing-box，仅在明确开启 ENC 时才按需调用 Xray 处理加密，内存占用大幅下降。

### 4、Vless-ws 独立运行
原版中 Vless-ws 必须与 Xray 绑定。新版支持使用 Sing-box 独立运行 Vless-ws，按需启用，不强制依赖 Xray。

### 5、Hy2 / TUIC 安全与生成优化
- **公钥钉扎（pinSHA256）**：弃用不安全的跳过验证，采用 base64 公钥真指纹校验，并在链接中加入 URL Percent-Encoding 编码，防止 `+` 变空格导致客户端验签失败；
- **证书稳定与兼容**：首次安装持久化生成带 SAN（Subject Alternative Name）的标准自签证书，重装不被覆盖；
- **TUIC 兼容升级**：链接保留兼容参数同时追加 `pinSHA256`；
- **客户端适配说明**：
  | 客户端 | URI `pinSHA256` 解析状态 | 手动配置说明 |
  |:---|:---|:---|
  | **v2rayN（fork 补丁版，sing_box 核）** | ✅ base64 公钥 pin 映射 | Hy2 建议核心映射 → sing_box；内核 ≥1.13，导入免 PEM |
  | **v2rayN（Hy2 / Xray 26.x 核）** | 仅认 hex 整证书指纹 | `pinnedPeerCertSha256` 只认 hex（v2rayN 从 PEM 自产导出即此格式）；脚本 base64 公钥 pin 会导致加载失败 |
  | **NekoBox / sing-box GUI**| ✅ 自动识别为公钥指纹 | 导入即用 |
  | **v2rayN（官方原版）** | ⚠️ TUIC 不识别，Hy2 不调取 | 节点 TLS 设置中粘贴 `~/agsbx/cert.crt` 证书内容 |
  | **其他客户端** | 视实现情况而定 | 可查看 `cat ~/agsbx/PUBKEY_SHA256_B64.txt` 获取公钥指纹 |

### 6、敲门唤醒与进程伪装（KNOCK）
针对严苛扫描环境打造的防探测方案（默认关闭）：
- **空闲自动关停**：连续 `IDLE_TIMEOUT` 秒（默认 300s）无流量，自动杀死后台代理进程；
- **单包敲门唤醒**：连接前向 `KNOCK_PORT` 发送单包（`nc -z -w1 <IP> <端口>`），秒级拉起服务；
- **进程名隐身**：通过 `STEALTH_NAME` 可伪装成 `[kworker/0:1]` 等内核守护线程。  
> 详见进阶文档：[DOCS.md - 敲门唤醒与隧道行为深度说明](DOCS.md#二敲门唤醒与进程隐身knock)。

### 7、Hysteria2 端口跳跃（hyjpt）
支持单端口与范围端口跳跃（如 `hyjpt="20000:30000 40000"`）：
- **专有 NAT 链隔离**：通过自定义链 `ARGOSBX_PRE` 下发 DNAT，配置重置或卸载时仅清空本脚本规则，**绝不误删宿主机 Docker / K8s 原有 NAT 转发**；
- 链接自动生成合规的 `&mport=20000-30000,40000` 供客户端直接识别。

---

## 核心协议与常用变量速览

命令行直接以 `变量名="值" ./argosbx.sh` 传入，更多完整选项与取值请查阅 [DOCS.md 全量参数字典](DOCS.md#一全量变量参数字典)：

| 分类 | 核心变量 | 常用取值与示例 | 说明 |
|:---|:---|:---|:---|
| **常用协议端口** | `vlpt` / `xhpt` / `vxpt` / `vwpt` | `"443"` 或 `""` | Vless 家族（支持对应 `_enc` 开启加密） |
| | `hypt` / `hyjpt` | `hypt="443"` `hyjpt="20000:30000"` | Hysteria2 及其 UDP 端口跳跃 |
| | `tupt` / `sspt` / `vmpt` | `"443"` / `"8388"` / `"8080"` | Tuic / Shadowsocks-2022 / Vmess |
| **网络与出站** | `ippz` | `""`（默认IPv4）或 `"6"`（IPv6优先） | 切换节点 Address 地址策略 |
| | `warp` | `""`（关）/ `s` / `x` / `sx` | Sing-box / Xray 独立套用 WARP 住宅 IP |
| | `argoip` / `nodeaddr` | `"优选IP/域名"` | 覆盖 Argo 优选地址或节点直连公网地址 |
| **隐身与安全** | `KNOCK` / `KNOCK_PORT` | `KNOCK="1"` `KNOCK_PORT="38000"` | 开启空闲自关与敲门唤醒 |
| | `STEALTH_NAME` | `"[kworker/0:1]"` | 伪装代理进程名（需 bash 环境） |
| **Argo 隧道** | `argo` / `agn` / `agk` | `argo="vwpt"` / 固定隧道域名与Token | 开启 Cloudflare 穿透（支持临时与固定隧道） |

---

## 快捷命令与运维管理

部署完成后，在服务器终端可直接使用 `agsbx` 快捷工具：

| 命令 | 等价指令 | 作用说明 |
|:---|:---|:---|
| `agsbx list` | `主脚本 list` | 查看当前已部署节点的配置信息、分享链接及二维码 |
| `agsbx rep`  | `主脚本 rep`  | 重置/清空所有协议配置 |
| `agsbx upx`  | - | 检查并升级 Xray 内核至最新稳定版 |
| `agsbx ups`  | - | 检查并升级 Sing-box 内核至最新稳定版 |
| `agsbx res`  | - | 重启所有代理进程与服务 |
| `agsbx del`  | - | 完整卸载脚本（自动清理专有 NAT 链与残留文件） |

### 临时切换节点地址显示（Address）
无需重新配置脚本，通过在命令前传入环境变量即可即时输出不同协议族的节点链接：
```bash
ippz=6 agsbx list    # 切换为 IPv6 优先展示（有效避开 NAT VPS 端口映射冲突）
ippz=4 agsbx list    # 恢复为 IPv4 优先展示
```
> 💡 **使用场景**：在双栈但 IPv4 存在服务商端口映射（外部端口与容器内部端口不一致）的机器上，使用 `ippz=6` 可直接通过 IPv6 直连内网端口，彻底解决 AnyTLS / SS-2022 握手失败问题。详见 [DOCS.md 双栈场景实战](DOCS.md#六双栈-vps-与-nat-端口映射实战ippz-变量)。

---

## 探针卸载指引速查

若使用了本面板集成的探针部署，请根据宿主环境执行对应卸载清理：

- **真实 VPS（系统服务安装）**：
  ```bash
  sudo systemctl stop nezha-agent && sudo systemctl disable nezha-agent
  sudo rm -f /etc/systemd/system/nezha-agent.service && sudo systemctl daemon-reload
  sudo rm -rf /opt/nezha    # 若为 komari 则替换路径名称
  ```
- **纯容器 / PaaS 环境（免 systemd 绿色命令）**：
  ```bash
  pkill -f nezha-agent    # 或 pkill -f komari-agent
  rm -f nezha-agent komari-agent agent.log
  ```
> 详细排查与卸载说明参见：[DOCS.md 探针深度运维指南](DOCS.md#七哪吒--komari-探针深度运维与规范卸载)。

---

> 📖 **深入进阶**：查阅全量环境变量、高级网络路由、端口跳跃 iptables 原理及客户端配置，请继续阅读 👉 **[参数字典与高级指南 (DOCS.md)](DOCS.md)**
