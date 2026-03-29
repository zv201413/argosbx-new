# 测试novps参数

## 使用方法
设置novps参数来强制使用nohup而不是systemd/openrc:

```bash
# 基础安装使用nohup
novps=yes vlpt=8443 bash argosbx.sh

# WARP模式使用nohup
novps=yes vlpt=8443 warp=y bash argosbx.sh

# Argo隧道使用nohup
novps=yes vlpt=8443 argo=vlpt bash argosbx.sh
```

## 原理
当设置novps=yes时：
1. 脚本会设置force_nohup=yes变量
2. 在启动Xray、Sing-box和Cloudflared服务时，会优先检查force_nohup变量
3. 如果force_nohup=yes，则直接使用nohup启动服务，跳过systemd/openrc检查
4. 这样可以确保在任何环境下都使用nohup方式运行，完全绕开systemd

## 优点
- 完全绕开systemd，适用于没有systemd权限的环境
- 保持原有功能完整性，不过度简化
- 可选功能，不影响原有使用方式
- 适用于容器化等特殊环境