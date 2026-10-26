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
| 二维码分享       | ❌ 无                     | ✅ 网页与终端默认开启；Gist 聚合订阅二维码 / 逐节点二维码 |
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
直接下载探针二进制并后台运行，适用于 Docker 或 PaaS 容器：
- **完整导入**：识别探针类型、Server、Secret、完整 HTTP(S) 地址、`--install-dir` 和 Komari 的 GitHub fork 来源；支持 `-e` / `-t`、`--endpoint` / `--token` 与哪吒 `NZ_*` 格式。
- **独立选择类型**：手动填写时选择 Komari 或哪吒；整合命令携带 `nz_type`，避免把 Komari 密钥传给哪吒。
- **TLS 自动探测**：未写协议时按端口推断；明确填写的 `http://` / `https://`、URL 路径和 IPv6 地址保持原意。
- **目录与日志**：导入的目录填入 `AGSBX_DIR`。整合安装放在 `<目录>/agsbx/komari` 或 `<目录>/agsbx/nezha`，日志为该子目录内的 `agent.log`；单独探针命令使用填写的目录。`agsbx res`、`del` 同时管理本项目安装的探针。

例如从 `zv201413/komari-agent_new` 导入带 `--install-dir /var/www` 的命令后，整合命令使用 `AGSBX_DIR="/var/www" nz_type="komari" nz_repo="zv201413/komari-agent_new"`，下载该 fork 的发布包，安装到 `/var/www/agsbx/komari`。直接命令行调用时，未传 `nz_type` 仍默认哪吒以兼容旧命令；Komari 应显式传 `nz_type=komari`。

IPv4/IPv6 公网地址会通过多个站点验证。一次请求失败不会改掉 `ippz=6` 或 `ippref=prefer_ipv6`；未取得 IPv6 时节点地址暂用 IPv4，后续检测成功自动恢复 IPv6，出站偏好保留协议本身的 IPv4 回退能力。

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

### 8、二维码分享（默认开启）

安装完成或运行 `agsbx list` 后，脚本输出一个**二维码分享页链接**，并保存到 `~/agsbx/qr-share-url.txt`（自定义安装目录时位于该目录下）。打开链接即可扫码或下载二维码 PNG / SVG：

- **本次 Gist 推送成功**：分别展示原版与 iOS 兼容版订阅二维码，供客户端一次导入全部节点，同时保留逐节点二维码。
- **未配置 Gist 或推送失败**：提供逐节点二维码。多条节点 URI 放进同一个二维码缺少通用导入格式，因此使用逐节点方式。
- **节点过长**：提示复制链接导入，并支持复制全部节点、下载节点文本。

在 [命令生成器](https://zv201413.github.io/argosbx-new/) 的 **配置与部署 → 订阅分享**中选择“二维码分享 → 关闭”（位于 Gist 设置下方），同时关闭网页分享和终端二维码。命令行也可分别控制：

```bash
QR_SHARE=0 agsbx list    # 关闭并记住选择
QR_SHARE=1 agsbx list    # 恢复开启
IOS_SHARE=0 agsbx list  # 关闭 iOS 兼容版，仅生成原版，记住选择
IOS_SHARE=1 agsbx list  # 恢复同时生成原版和 iOS 兼容版（默认）
```

网页二维码在浏览器本地生成，无需服务器安装额外依赖。分享链接通过 URL 的 `#` 片段携带节点，分享页不上传节点数据、不访问在线二维码 API；链接仍包含节点凭据，只应分享给需要使用的人。

**终端二维码也默认开启**，与网页分享合并在同一个“二维码分享”下拉框中。菜单按 **启用 qrencode（自动安装 / 复用）** 与 **不启用 qrencode（不安装 / 不运行）**分组，提供“网页 + 终端”“仅终端”“仅网页”三种方式，每种方式均可选择原版或原版 + iOS 兼容版，另有“全部关闭”。默认同时生成原版与 iOS 兼容版的网页、终端二维码。安装完成或运行 `agsbx list` 时，启用的终端功能会自动安装并调用轻量工具 `qrencode`，直接在 SSH 终端显示可扫描的二维码：本次 Gist 推送成功时显示订阅，否则逐节点显示。选择“仅网页”或“全部关闭”不会安装或运行终端二维码工具。命令行仍可分别控制 `QR_SHARE`、`QR_TERM` 和 `IOS_SHARE`。

```bash
QR_TERM=0 agsbx list  # 关闭终端二维码并记住选择，也不安装 qrencode
QR_TERM=1 agsbx list  # 恢复终端二维码（默认）
```

Ubuntu amd64 的 `qrencode` 程序和 `libqrencode4` 软件包安装体积合计约 **136 KiB**（63 + 73 KiB；缺少 PNG 等依赖时会增加），只在生成时运行，无常驻进程。Debian/Ubuntu 使用发行版软件包，解包到 `$AGSBX/qrencode-runtime`，无需 root，卸载项目时随目录清理。下载失败时自动刷新临时 APT 索引并重试；Ubuntu 使用对应版本的官方签名 `main + universe` 源，解决精简 VPS 缺少索引或未启用 `universe` 的情况，不修改系统软件源或安装状态。首次重试需要额外下载软件源索引，临时索引在结束后清理；具体错误保存在 `$AGSBX/qrencode-install.log`（仅当前用户可读写）。Alpine/Fedora/RHEL/Arch 使用系统包管理器，需要 root。已有可用的 `qrencode` 时直接复用。下载失败、没有适用安装权限或节点过长时跳过相应二维码，继续提供节点链接和已开启的网页分享。终端太窄导致二维码换行时，请拉宽窗口或使用网页二维码。

**默认同时生成原版和 iOS 兼容版二维码**，在分享页并排展示，用户按需扫码或分别下载 PNG、SVG、节点文本。可在“订阅分享”的“二维码分享”下拉框中选择对应方式的“原版”选项，关闭 iOS 兼容版；原版始终保留原有证书参数。

兼容版的 Hy2 移除公钥 pin，添加 `peer` 和 `insecure=1`；TUIC 保留字面 `UUID:密码` 分隔符，添加 `version=5`、`allow_insecure=1` 并移除 pin。其他协议沿用原链接。原版节点保存为 `jh.txt`，兼容版保存为 `jh-ios.txt`；Gist 推送两份独立文件，二维码分别对应各自的订阅或节点。服务端证书和认证配置保持原样。**选择兼容版导入时，Hy2 / TUIC 会跳过手机端证书验证。** 小火箭 2.2.92 的 TUIC5 兼容二维码已实测导入连通；Loon 3.5.2 仅适用 Hy2，不支持 TUIC。

项目文件中的 [share.html](share.html)、[分享逻辑](assets/share.js) 与二维码库需一并发布到 GitHub Pages，脚本输出的在线分享页才会生效。

---

## 命令生成器的配置与部署

在 [命令生成器](https://zv201413.github.io/argosbx-new/) 中，顶部保留原来的完整项目标题和 GitHub 链接。桌面上方左侧保留协议端口区，右侧 **连接与节点**集中放置 Argo 隧道、节点名称和地址偏好；其下 **安装设置**常显安装目录和 UUID。

- **二维码分享**位于 **订阅分享**页签的 Gist 设置下方，同一菜单中提供七种组合：“网页 + 终端”“仅网页”“仅终端”各有原版、原版 + iOS 兼容版两项，以及“全部关闭”。三种方式的 `QR_SHARE/QR_TERM` 分别为 `1/1`、`1/0`、`0/1`；全部关闭为 `0/0`。兼容版对应 `IOS_SHARE=1`，仅原版及全部关闭对应 `IOS_SHARE=0`。默认 `QR_SHARE=1 IOS_SHARE=1 QR_TERM=1`；安装、更新配置和查看节点命令都携带当前选择。
- **自定义安装目录（`AGSBX_DIR`）**位于 UUID 密码正上方；留空自动探测，填写时脚本会在该目录下创建 `agsbx` 子目录。
- 下方 **配置与部署**左侧依次设有 **订阅分享、探针配置、网络与安全**三个页签，**订阅分享位于最左侧并默认展示**；设置栏与右侧命令区宽度约为 30:70，命令面板向左扩展。
- **网络与安全**页签的折叠菜单 **WARP、直连与端口设置**集中提供套 WARP-IP 出站（`warp`）、Warp IPv4/IPv6 出站（`wippref`）、直连节点自定义地址（`nodeaddr`）、Reality 域名（`reym`）与当前系统开放所有端口（`oap`）；**敲门唤醒与进程隐身**提供敲门、空闲自关与进程伪装选项。
- 右侧先展示生成的命令，下方控制区横向展开为三行：环境模式、命令类型、复制与重置。**快捷命令**常显在“配置与部署”标题区，**客户端与使用文档**默认折叠。

**探针配置**页签保留哪吒 / Komari 类型、服务器地址、密钥及安装命令导入；填写后随主脚本一起安装。**单独安装探针**默认折叠，展开后可选择独立环境与命令类型并生成、复制探针命令。页签可使用左右方向键切换；窄屏下设置与主命令区按单栏排列。

---

## Chrome 记住 Gist ID 与 GitHub Token

命令生成器将 **Gist ID 作为用户名、GitHub Token 作为密码**，通过标准的 `autocomplete="username"` / `autocomplete="current-password"` 和浏览器凭据接口配对保存。Token 输入框默认遮挡内容。

Gist ID、GitHub Token 与下方的“保存到浏览器”“填入已存凭据”按钮位于默认展示的 **订阅分享**页签中，作为一组凭据操作。

直接双击 `index.html` 的 `file://` 页面无法使用这里的浏览器凭据保存/读取功能。本地使用时，在终端运行：

```bash
python3 -m http.server 8765 --bind 127.0.0.1 --directory /home/zv/github/argosbx-new
```

然后用 Chrome 打开并收藏 **http://localhost:8765/index.html**，终端在使用期间保持运行：

1. 在 Chrome 设置 → 自动填充和密码 → Google 密码管理工具 → 设置中，打开“提示保存密码和通行密钥”，并确认此网站未被列为拒绝保存。
2. 填写 Gist ID 与 Token，点击“保存到浏览器”，在 Chrome 提示中确认保存或更新。新建 Gist 时仍可留空 ID 生成命令；获得 ID 后再补填并保存。
3. 下次访问同一地址，Chrome 可自动填入；也可点击“填入已存凭据”选择已保存的一组。保存请求是否显示提示由 Chrome 决定，页面不能强制弹出或替你确认。

若 Chrome 未提示，可在其密码管理工具中手动添加：网站填 `http://localhost:8765`，用户名填 Gist ID，密码填 Token。保持访问地址一致；`localhost`、`127.0.0.1` 和在线 GitHub Pages 地址对应各自的凭据。在线版本发布这些修改后也可在 HTTPS 下使用。

本功能由浏览器密码管理器保存凭据，页面不将其写入 `localStorage`。生成的 SSH 命令仍会按原有功能包含所填 Token。

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
| **二维码分享** | `QR_SHARE` | `"1"`（默认）/ `"0"`（关闭） | 输出分享页；选择持久化，Gist 成功时聚合 |
| **终端二维码** | `QR_TERM` | `"1"`（默认）/ `"0"`（关闭） | 自动安装/复用 qrencode，直接在 SSH 终端扫码；网页中与分享开关联动，命令行可单独控制，选择持久化 |
| **同时生成 iOS 兼容版** | `IOS_SHARE` | `"1"`（默认）/ `"0"`（关闭） | 在原版旁增加兼容版二维码和订阅；高级设置可关闭，选择持久化 |
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
