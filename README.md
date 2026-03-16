# ArgoSBX 支持非root运行版 (zv修改版)

这是一个改造自[yonggekkk/argosbx](https://github.com/yonggekkk/argosbx)的版本，**支持非root用户运行**，特别适配Docker容器环境。

## 本版本特色功能

✓ **国家代码显示**：自动查询服务器IP所属国家，节点名称显示国家代码（如US、DE、JP等）  
✓ **路径修改**：所有配置和程序存放在用户目录`$HOME/agsbx`，而非`/root/agsbx`  
✓ **兼容性**：自动检测运行权限，root用户和非root用户均可使用，新增**强制nohup模式**
✓ **容器友好**：适配Docker等非root容器环境
✓ **协议兼容**：vless去除enc加密，兼容性更强

## 极速使用（ssh命令方式）
[zv201413/argosbx-网页端](https://zv201413.github.io/argosbx-new)

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

**完整变量列表请查看原版README。**

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
