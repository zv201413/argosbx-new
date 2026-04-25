# Argosbx-New一键无交互小钢炮脚本💣：基于甬哥原版优化定制

---------------------------------------
基于[甬哥argosbx小钢炮](https://github.com/yonggekkk/argosbx)项目改造

## 建议配合SSH一键脚本命令生成器网页使用：https://zv201413.github.io/argosbx-new/

----------------------------------------------------------

#### 1、基于甬哥Argosbx原版优化，保留核心功能，新增实用特性

#### 2、三内核自动分配：Sing-box + Xray + Cloudflared-Argo

#### 3、支持各种容器系统，自动检测容器兼容性

#### 4、【新增】支持节点订阅推送到GitHub Gist

#### 5、【新增】支持国家代码自动检测，节点名称自动添加地区前缀

#### 6、【新增】支持优选IP/域名指定

#### 7、【新增】支持直连节点自定义地址

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

## 四、原版对比优化说明

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

### 容器兼容性自动回退

原版在某些容器环境下可能无法正常运行Sing-box（需要netlink支持）。

新版新增自动检测逻辑：
- 自动检测容器是否支持Sing-box路由订阅
- 不支持时自动切换到Xray模式
- 无需手动干预，确保脚本在任何环境下都能运行

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

---------------------------------------------------------
