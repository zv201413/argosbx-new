# Argosbx-New 一键无交互代理脚本

基于 [yonggekkk/argosbx](https://github.com/yonggekkk/argosbx) 改造。

## 特性

- ✓ 支持非root用户运行
- ✓ 支持Docker容器环境
- ✓ VLESS去除ENC加密，兼容性更强
- ✓ 支持自定义节点地址（nodeaddr）

## 快速使用

[网页生成器](https://zv201413.github.io/argosbx-new)

```bash
bash <(curl -Ls https://raw.githubusercontent.com/zv201413/argosbx-new/main/argosbx.sh)
```

## 常用命令

```bash
# 查看节点
agsbx list

# 重启脚本
agsbx res

# 卸载
agsbx del
```

## 变量说明

| 变量 | 说明 | 示例 |
|------|------|------|
| vlpt | Vless-tcp-reality | 端口号 |
| vwpt | Vless-ws | 端口号 |
| vmpt | Vmess-ws | 端口号 |
| hypt | Hysteria2 | 端口号 |
| tupt | Tuic | 端口号 |
| warp | WARP出站模式 | sx, x, s4, x6 等 |
| nodeaddr | 自定义直连地址 | domain.com |

## Docker

```bash
docker run -d \
  --name argosbx \
  -e vwpt="" \
  -e argo="vwpt" \
  -p 80:80 \
  zv201413/argosbx-new
```
