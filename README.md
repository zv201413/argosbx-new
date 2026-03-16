# ArgoSBX 非root运行版 (zv修改版)

这是一个改造自[yonggekkk/argosbx](https://github.com/yonggekkk/argosbx)的版本，**支持非root用户运行**，特别适配Docker容器环境。

## 本版本特色功能

✓ **浏览器UA伪装**：WARP获取请求使用真实浏览器User-Agent，提高成功率  
✓ **国家代码显示**：自动查询服务器IP所属国家，节点名称显示国家代码（如US、DE、JP等）  
✓ **WARP状态提示**：清晰的WARP获取进度和成功/失败提示  
✓ **路径修改**：所有配置和程序存放在用户目录`$HOME/agsbx`，而非`/root/agsbx`  
✓ **systemd支持**：使用用户级systemd服务（`systemctl --user`）而非系统级  
✓ **兼容性**：自动检测运行权限，root用户和非root用户均可使用  
✓ **容器友好**：适配Docker等非root容器环境

## 快速使用（Docker方式）

在支持非root的容器平台（如PVE、LXC、Docker）中运行：

```bash
# 1. 启动容器（使用默认配置）
docker run -d \
  --name my-vps \
  -e SSH_USER=zv \
  -e SSH_PWD=YOUR_PASSWORD \
  -v /opt/zvps_data:/home/zv \
  -p 2222:22 \
  zv201413/zvps-super

# 2. 进入容器
ssh -p 2222 zv@localhost

# 3. 下载脚本
cd ~
wget https://raw.githubusercontent.com/zv201413/argosbx-new/main/argosbx.sh
chmod +x argosbx.sh

# 4. 设置必要变量（可选）
export UUID="$(cat /proc/sys/kernel/random/uuid)"

# 5. 运行（非root会自动适配）
vwpt="" warp="sx" novps="yes" argo="vwpt" bash ./argosbx.sh
```

## 节点名称显示国家代码

运行脚本后，生成的节点链接会自动添加国家代码后缀，例如：
- `vl-ws-US-hostname` - 美国节点
- `vl-ws-DE-hostname` - 德国节点
- `vl-ws-JP-hostname` - 日本节点

这方便用户快速识别节点服务器所在地区。

## WARP获取状态提示

脚本运行时会显示清晰的WARP获取进度：
- `正在尝试获取 WARP 密钥...` - 正在获取
- `✅ 自动获取成功，正在生成WARP配置` - 成功获取
- `⚠️ 自动获取失败，应用指定的兜底配置...` - 获取失败使用备用

## 在普通用户环境下的安装步骤

如果你已有普通用户账户（非root），直接运行：

```bash
# 下载脚本
curl -Lo argosbx.sh https://raw.githubusercontent.com/zv201413/argosbx-new/main/argosbx.sh
chmod +x argosbx.sh

# 运行方式1：使用默认配置
./argosbx.sh

# 运行方式2：指定协议端口
vwpt="24640" vmpt="28115" hypt="23000" ./argosbx.sh

# 运行方式3：配合WARP开启
warp="4" vwpt="24640" ./argosbx.sh
```

生成的配置文件和用户数据将保存在`$HOME/agsbx/`目录下。

## systemd用户级服务

非root用户会自动使用systemd用户级服务：

```bash
# 查看服务状态（无需sudo）
systemctl --user status xr  # 查看Xray服务
systemctl --user status sb  # 查看Sing-box服务
systemctl --user status argo  # 查看Argo隧道

# 管理服务
systemctl --user start xr
systemctl --user stop xr
systemctl --user restart xr
```

## 支持的协议（配置方式不变）

原版支持的所有协议都支持：

**必选协议（至少选一个）：**
- `vwpt` - VLESS-WS（支持CDN优选和Argo）
- `vmpt` - VMESS-WS（支持CDN优选和Argo）
- `vlpt` - VLESS-TCP-Reality
- `xhpt` - VLESS-XHTTP-Reality
- `vxpt` - VLESS-XHTTP
- `arpt` - Any-Reality
- `anpt` - AnyTLS
- `sspt` - Shadowsocks-2022
- `hypt` - Hysteria2
- `tupt` - Tuic

**可选功能：**
- `warp` - 开启Warp出站（解锁流媒体，更换IP）
- `argo` - 开启Argo隧道（填写"vmpt"或"vwpt"）
- `uuid` - 自定义UUID（留空则随机生成）

完整变量列表请查看原版README。

## 持久化存储（Docker）

在Docker中使用持久化存储非常重要：

```bash
# 第一次启动（开启数据持久化）
docker run -d \
  --name my-vps \
  -e SSH_USER=zv \
  -e SSH_PWD=your_password \
  -v /path/on/host:/home/zv \
  -p 2222:22 \
  zv201413/zvps-super

# 持久化数据包括：
# - 所有配置：~/.config/systemd/user/*.service
# - 配置文件：~/agsbx/*.json
# - 隧道token：~/agsbx/*.log
# - 流量统计：~/agsbx/vnstat/
```

## 文件路径说明

在所有环境中（root或非root）的文件路径：

- **运行目录**：`~/agsbx/` 或 `$HOME/agsbx/
- **Xray配置**：`~/agsbx/xr.json`
- **Sing-box配置**：`~/agsbx/sb.json`
- **systemd服务**：`~/.config/systemd/user/`
- **进程ID文件**：`~/agsbx/*.pid`

## 注意事项

1. 非root用户无法使用1024以下端口，脚本会自动使用10000-65535随机端口
2. 系统重启后需要重新登录用户会话，或使用`systemctl --user`管理服务
3. 在Docker环境中，请确保挂载了用户家目录以获得持久化存储
4. 使用Argo固定隧道时，需要在环境变量中设置`CF_TOKEN`

## 技术细节

**环境变量检测：**

脚本会自动检测`$EUID`环境变量：
- `EUID=0`（root用户）：使用系统级systemd服务（原行为）
- `EUID≠0`（普通用户）：使用用户级systemd服务（`--user`）

**二进制文件：**

所有程序二进制文件（xray、sing-box、cloudflared）都下载到`$HOME/agsbx/`目录。

**服务工作原理：**

非root用户的服务通过systemd用户管理器运行：
- 服务文件位置：`~/.config/systemd/user/`
- 管理命令：`systemctl --user [start|stop|status] <service>`
- 开机自启：`systemctl --user enable <service>`

## 故障排除

**问题1**：systemctl --user 报错 "Failed to connect to bus"
**解决**：确保在正确的用户会话中运行，Docker中需要启动dbus服务

**问题2**：端口已被占用
**解决**：使用`ss -tuln | grep <port>`检查，或修改脚本使用其他端口

**问题3**：找不到systemctl命令
**解决**：脚本会自动回退到nohup模式，可以正常启动服务

## 开发与贡献

本版本基于原始项目argosbx改造，主要改动：
- 移除所有 `/root/agsbx` 硬编码路径
- 改为 `$HOME/agsbx` 动态用户目录  
- 添加用户级systemd服务支持
- 增强非root运行的兼容性

原始项目： https://github.com/yonggekkk/argosbx

## License

与原始项目相同（GPL v3）
