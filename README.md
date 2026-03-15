## 甬哥-Argosbx-new一键无交互脚本-zv修改版：极简 + 轻量 + 快速

---------------------------------------

#### 1、基于Sing-box + Xray + Cloudflared-Argo 三内核自动分配

#### 2、支持Linux类主流VPS系统（建议最新版系统），SSH脚本支持非root环境运行，几乎无需依赖，无脑一次回车搞定

#### 3、所有代理协议都无需域名（除了argo固定隧道、IP端口CDN），支持单个或多个代理协议任意组合并快速重置更换
【 已支持：AnyTLS、Any-reality、Vless-xhttp-reality-vison、Vless-tcp-reality-vision、Vless-xhttp-vison、Vless-ws-vision、Shadowsocks-2022、Vmess-ws、Socks5、Hysteria2、Tuic、Argo临时/固定隧道支持Vless-ws或Vmess-ws 】

#### 4、建议配合SSH一键脚本命令生成器网页使用：https://zv201413.github.io/argosbx-new/

----------------------------------------------------------

## 新增nohup模式（绕过systemd/openrc）

在无systemd权限的容器环境（如某些VPS容器、Docker等），可使用novps参数强制使用nohup后台运行：

Argo临时隧道 + nohup模式（简化配置，无ENC加密）
```
novps=yes vwpt="" argo="vwpt" bash <(curl -Ls https://raw.githubusercontent.com/zv201413/argosbx-new/main/argosbx.sh)
```

Vmess-ws-argo临时隧道 + nohup模式
```
novps=yes vmpt="" argo="vmpt" bash <(curl -Ls https://raw.githubusercontent.com/zv201413/argosbx-new/main/argosbx.sh)
```

常规协议 + nohup模式（无WARP）
```
novps=yes vlpt="" bash <(curl -Ls https://raw.githubusercontent.com/zv201413/argosbx-new/main/argosbx.sh)
```

> 注意：使用novps=yes时，脚本会自动生成简化配置的节点（无ENC加密），适用于不需要加密的轻量场景。
![alt text](26-03-15-15-43-42.png)

---------------------------------------------------------

## 多功能SSH快捷方式命令组

#### 说明：首次安装成功后需重连SSH，```agsbx 命令```的快捷方式才可生效；如未生效，请使用```主脚本 命令```的快捷方式

1、查看Argo的固定域名、固定隧道的token、临时域名、当前已安装的节点信息命令：```agsbx list``` 或者 ```主脚本 list```

2、更换、增加、删除变量组命令：```自定义各种协议变量组 agsbx rep``` 或者 ```自定义各种协议变量组 主脚本 rep```

3、更新脚本命令：```原已安装的自定义各种协议变量组 主脚本 rep``` 

4、更新Xray或Singbox内核命令：agsbx upx或ups 【或者】 主脚本 upx或ups

5、重启脚本命令：```agsbx res``` 或者 ```主脚本 res```

6、卸载脚本命令：```agsbx del``` 或者 ```主脚本 del```

7、临时切换IPV4/IPV6节点配置 (双栈VPS专享)：

显示IPV4节点配置：```ippz=4 agsbx list```或者```ippz=4 主脚本 list```

显示IPV6节点配置：```ippz=6 agsbx list```或者```ippz=6 主脚本 list```

---------------------------------------
