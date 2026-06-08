#!/bin/sh
# =============================================================================
# SECTION 0: 脚本头部初始化 - 环境配置与全局变量定义
# 功能: 
#   - 设置UTF-8语言环境
#   - 定义所有协议开关变量(vlpt/vmpt/vwpt等)
#   - 定义ENC加密变量(vlpt_enc/xhpt_enc/vxpt_enc/vwpt_enc)
#   - 导入环境变量(uuid/port_vl_re/port_vm_ws等)
#   - 检测进程运行状态,防止重复安装
#   - 定义资源下载URL
# 依赖: 无
# =============================================================================
export LANG=en_US.UTF-8
[ -z "${vlpt+x}" ] || vlp=yes
[ -z "${vmpt+x}" ] || { vmp=yes; vmag=yes; }
[ -z "${vwpt+x}" ] || { vwp=yes; vmag=yes; }
[ -z "${hypt+x}" ] || hyp=yes
[ -z "${tupt+x}" ] || tup=yes
[ -z "${xhpt+x}" ] || xhp=yes
[ -z "${vxpt+x}" ] || vxp=yes
[ -z "${anpt+x}" ] || anp=yes
[ -z "${sspt+x}" ] || ssp=yes
[ -z "${arpt+x}" ] || arp=yes
[ -z "${sopt+x}" ] || sop=yes
[ -z "${warp+x}" ] || wap=yes
if find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -Eq 'agsbx/(s|x)' || pgrep -f 'agsbx/(s|x)' >/dev/null 2>&1; then
if [ "$1" = "rep" ]; then
[ "$vwp" = yes ] || [ "$sop" = yes ] || [ "$vxp" = yes ] || [ "$ssp" = yes ] || [ "$vlp" = yes ] || [ "$vmp" = yes ] || [ "$hyp" = yes ] || [ "$tup" = yes ] || [ "$xhp" = yes ] || [ "$anp" = yes ] || [ "$arp" = yes ] || { echo "提示：rep重置协议时，请在脚本前至少设置一个协议变量哦，再见！💣"; exit; }
fi
else
[ "$1" = "del" ] || [ "$vwp" = yes ] || [ "$sop" = yes ] || [ "$vxp" = yes ] || [ "$ssp" = yes ] || [ "$vlp" = yes ] || [ "$vmp" = yes ] || [ "$hyp" = yes ] || [ "$tup" = yes ] || [ "$xhp" = yes ] || [ "$anp" = yes ] || [ "$arp" = yes ] || { echo "提示：未安装argosbx脚本，请在脚本前至少设置一个协议变量哦，再见！💣"; exit; }
fi
export uuid=${uuid:-''}
export port_vl_re=${vlpt:-''}
export port_vl_re_ext=${vlpt_ext:-''}
export port_vl_re_enc=${vlpt_enc:-''}
export port_xh_enc=${xhpt_enc:-''}
export port_vx_enc=${vxpt_enc:-''}
export port_vw_enc=${vwpt_enc:-''}
export port_vm_ws=${vmpt:-''}
export port_vm_ws_ext=${vmpt_ext:-''}
export port_vw=${vwpt:-''}
export port_vw_ext=${vwpt_ext:-''}
export port_hy2=${hypt:-''}
export port_hy2_ext=${hypt_ext:-''}
export port_tu=${tupt:-''}
export port_tu_ext=${tupt_ext:-''}
export port_xh=${xhpt:-''}
export port_xh_ext=${xhpt_ext:-''}
export port_vx=${vxpt:-''}
export port_vx_ext=${vxpt_ext:-''}
export port_an=${anpt:-''}
export port_an_ext=${anpt_ext:-''}
export port_ar=${arpt:-''}
export port_ar_ext=${arpt_ext:-''}
export port_ss=${sspt:-''}
export port_ss_ext=${sspt_ext:-''}
export port_so=${sopt:-''}
export port_so_ext=${sopt_ext:-''}
export ym_vl_re=${reym:-''}
export cdnym=${cdnym:-''}
export argo=${argo:-''}
export ARGO_DOMAIN=${agn:-''}
export ARGO_AUTH=${agk:-''}
export ippz=${ippz:-''}
export ippref=${ippref:-''}
export enc=${enc:-''}
export warp=${warp:-''}
export name=${name:-''}
export oap=${oap:-''}
export argoip=${argoip:-''}
export gh_token=${gh_token:-''}
export gh_gist_id=${gh_gist_id:-''}
export nodeaddr=${nodeaddr:-''}
export wippref=${wippref:-''}
export nz_host=${nz_host:-''}
export nz_port=${nz_port:-'5555'}
export nz_sec=${nz_sec:-''}
export nz_tls=${nz_tls:-''}
v46url="https://icanhazip.com"
agsbxurl="https://raw.githubusercontent.com/zv201413/argosbx-new/main-new/argosbx.sh"

# =============================================================================
# SECTION 1: 脚本欢迎信息与环境自适应检测
# 功能:
#   - 系统基础信息检测 (CPU、OS、虚拟化)
#   - 深度检测容器兼容性: check_netlink_full_support()
#   - 智能标记 XRAY_FORCE_MODE: 当 Sing-box 路由订阅不受支持时强制分流
#   - 设置工作目录与系统兼容层
# =============================================================================
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "甬哥-Argosbx-new一键无交互脚本-zv修改版"
echo 
echo "Github项目 ：github.com/zv201413/argosbx-new"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
hostname=$(uname -a | awk '{print $2}')
op=$(cat /etc/redhat-release 2>/dev/null || cat /etc/os-release 2>/dev/null | grep -i pretty_name | cut -d \" -f2)
[ -z "$(systemd-detect-virt 2>/dev/null)" ] && vi=$(virt-what 2>/dev/null) || vi=$(systemd-detect-virt 2>/dev/null)
case $(uname -m) in
arm64|aarch64) cpu=arm64;;
amd64|x86_64) cpu=amd64;;
*) echo "目前脚本不支持$(uname -m)架构" && exit
esac
mkdir -p "$HOME/agsbx"
if [ ! -f sbx_update ]; then
echo "执行脚本中，请稍后"
if command -v apk >/dev/null 2>&1; then
apk update >/dev/null 2>&1
apk add gcompat libc6-compat >/dev/null 2>&1
elif command -v apt >/dev/null 2>&1; then
apt update >/dev/null 2>&1 && apt install coreutils util-linux -y >/dev/null 2>&1
fi
touch sbx_update
fi

check_netlink_full_support(){
    # 精确复现 sing-box 的 "subscribe route updates" 操作：setsockopt(SOL_NETLINK=270,
    # NETLINK_ADD_MEMBERSHIP=1, RTNLGRP_IPV4_ROUTE=7 / RTNLGRP_IPV6_ROUTE=11)。
    # 旧版仅 bind LINK 组(groups=1)，Modal 等容器放行 LINK、拦截 ROUTE → 假阳性漏判。
    if python3 -c "import socket; s=socket.socket(socket.AF_NETLINK, socket.SOCK_RAW, socket.NETLINK_ROUTE); s.bind((0,0)); s.setsockopt(270,1,7); s.setsockopt(270,1,11); print('OK')" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

SB_SUPPORTED=1
check_netlink_full_support || SB_SUPPORTED=0

if [ "$SB_SUPPORTED" = 0 ]; then
    SB_SKIP_REASON=""
    [ -n "$hyp" ] && SB_SKIP_REASON="${SB_SKIP_REASON}hyp "
    [ -n "$tup" ] && SB_SKIP_REASON="${SB_SKIP_REASON}tup "
    [ -n "$anp" ] && SB_SKIP_REASON="${SB_SKIP_REASON}anp "
    [ -n "$arp" ] && SB_SKIP_REASON="${SB_SKIP_REASON}arp "
    [ -n "$ssp" ] && SB_SKIP_REASON="${SB_SKIP_REASON}ssp "
    
    if [ -n "$SB_SKIP_REASON" ]; then
        echo "======================================"
        echo "⚠️ 警告：当前环境不支持 Sing-box，已自动切换到 Xray 模式"
        echo "以下参数已被忽略：${SB_SKIP_REASON}"
        echo "======================================"
    fi
    
    XRAY_FORCE_MODE=1
    
    hyp="" tup="" anp="" arp="" ssp=""
fi

# =============================================================================
# SECTION 2: 网络环境检测 - IPv4/IPv6连通性判断
# 功能:
#   - v4v6(): 检测VPS的IPv4/IPv6出口地址
#   - warpsx(): 获取WARP配置(私钥/IPv6/reserved)
#   - 根据v4/v6可用性设置代理策略路由
#   - 支持多种warp模式(sx/xs/s4/s6/x/x4/x6等)
#   - 设置Xray/Sing-box的域名解析策略
#   - 支持ippref变量控制非Warp出站路由
#   - 支持wippref变量控制Warp出站路由
# 依赖: uuid(可能由insuuid生成)
# =============================================================================
v4v6(){
v4=$( (command -v curl >/dev/null 2>&1 && curl -s4m5 -k "$v46url" 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -4 --tries=2 -qO- "$v46url" 2>/dev/null) )
v6=$( (command -v curl >/dev/null 2>&1 && curl -s6m5 -k "$v46url" 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -6 --tries=2 -qO- "$v46url" 2>/dev/null) )
v4dq=$( (command -v curl >/dev/null 2>&1 && curl -s4m5 -k https://ip.fm | sed -n 's/.*Location: //p' | sed 's/[{}"]//g; s/countryCode://g' 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -4 --tries=2 -qO- https://ip.fm | grep '<span class="has-text-grey-light">Location:' | tail -n1 | sed -E 's/.*>Location: <\/span>([^<]+)<.*/\1/' 2>/dev/null) )
v6dq=$( (command -v curl >/dev/null 2>&1 && curl -s6m5 -k https://ip.fm | sed -n 's/.*Location: //p' | sed 's/[{}"]//g; s/countryCode://g' 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -6 --tries=2 -qO- https://ip.fm | grep '<span class="has-text-grey-light">Location:' | tail -n1 | sed -E 's/.*>Location: <\/span>([^<]+)<.*/\1/' 2>/dev/null) )
}
warpsx(){
warpurl=$( (command -v curl >/dev/null 2>&1 && curl -sm5 -k https://warp.xijp.eu.org 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget --tries=2 -qO- https://warp.xijp.eu.org 2>/dev/null) )
if [ -z "$warpurl" ] || printf '%s' "$warpurl" | grep -q html; then
wpv6='2606:4700:110:8d8d:1845:c39f:2dd5:a03a'
pvk='52cuYFgCJXp0LAq7+nWJIbCXXgU9eGggOc+Hlfz5u6A='
res='[215, 69, 233]'
else
pvk=$(echo "$warpurl" | awk -F'：' '/Private_key/{print $2}' | xargs)
wpv6=$(echo "$warpurl" | awk -F'：' '/IPV6/{print $2}' | xargs)
res=$(echo "$warpurl" | awk -F'：' '/reserved/{print $2}' | xargs)
fi
if [ -n "$name" ]; then
sxname=$name
echo "$sxname" > "$HOME/agsbx/name"
echo
echo "所有节点名称前缀：$name"
fi
v4v6
if echo "$v6" | grep -q '^2a09' || echo "$v4" | grep -q '^104.28'; then
s1outtag=direct; s2outtag=direct; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warpargo
echo; echo "请注意：你已安装了warp"
else
if [ "$wap" != yes ]; then
s1outtag=direct; s2outtag=direct; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warpargo
else
case "$warp" in
""|sx|xs) s1outtag=warp-out; s2outtag=warp-out; x1outtag=warp-out; x2outtag=warp-out; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
s ) s1outtag=warp-out; s2outtag=warp-out; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
s4) s1outtag=warp-out; s2outtag=direct; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"0.0.0.0/0"'; wap=warp ;;
s6) s1outtag=warp-out; s2outtag=direct; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"::/0"'; wap=warp ;;
x ) s1outtag=direct; s2outtag=direct; x1outtag=warp-out; x2outtag=warp-out; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
x4) s1outtag=direct; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
x6) s1outtag=direct; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"::/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
s4x4|x4s4) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"0.0.0.0/0"'; sip='"0.0.0.0/0"'; wap=warp ;;
s4x6|x6s4) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"::/0"'; sip='"0.0.0.0/0"'; wap=warp ;;
s6x4|x4s6) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"0.0.0.0/0"'; sip='"::/0"'; wap=warp ;;
s6x6|x6s6) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"::/0"'; sip='"::/0"'; wap=warp ;;
sx4|x4s) s1outtag=warp-out; s2outtag=warp-out; x1outtag=warp-out; x2outtag=direct; xip='"0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
sx6|x6s) s1outtag=warp-out; s2outtag=warp-out; x1outtag=warp-out; x2outtag=direct; xip='"::/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
xs4|s4x) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=warp-out; xip='"::/0", "0.0.0.0/0"'; sip='"0.0.0.0/0"'; wap=warp ;;
xs6|s6x) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=warp-out; xip='"::/0", "0.0.0.0/0"'; sip='"::/0"'; wap=warp ;;
* ) s1outtag=direct; s2outtag=direct; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warpargo ;;
esac
fi
fi
case "$warp" in *x4*) wxryx='ForceIPv4' ;; *x6*) wxryx='ForceIPv6' ;; *) wxryx='ForceIPv6v4' ;; esac
if command -v curl >/dev/null 2>&1; then
curl -s4m5 -k "$v46url" >/dev/null 2>&1 && v4_ok=true
elif command -v wget >/dev/null 2>&1; then
timeout 3 wget -4 --tries=2 -qO- "$v46url" >/dev/null 2>&1 && v4_ok=true
fi
if command -v curl >/dev/null 2>&1; then
curl -s6m5 -k "$v46url" >/dev/null 2>&1 && v6_ok=true
elif command -v wget >/dev/null 2>&1; then
timeout 3 wget -6 --tries=2 -qO- "$v46url" >/dev/null 2>&1 && v6_ok=true
fi
if [ "$v4_ok" = true ] && [ "$v6_ok" = true ]; then
case "$warp" in *s4*) sbyx='prefer_ipv4' ;; *) sbyx='prefer_ipv6' ;; esac
case "$warp" in *x4*) xryx='ForceIPv4v6' ;; *x*) xryx='ForceIPv6v4' ;; *) xryx='ForceIPv4v6' ;; esac
elif [ "$v4_ok" = true ] && [ "$v6_ok" != true ]; then
case "$warp" in *s4*) sbyx='ipv4_only' ;; *) sbyx='prefer_ipv6' ;; esac
case "$warp" in *x4*) xryx='ForceIPv4' ;; *x*) xryx='ForceIPv6v4' ;; *) xryx='ForceIPv4v6' ;; esac
elif [ "$v4_ok" != true ] && [ "$v6_ok" = true ]; then
case "$warp" in *s6*) sbyx='ipv6_only' ;; *) sbyx='prefer_ipv4' ;; esac
case "$warp" in *x6*) xryx='ForceIPv6' ;; *x*) xryx='ForceIPv4v6' ;; *) xryx='ForceIPv6v4' ;; esac
fi

if [ -n "$ippref" ]; then
  case "$ippref" in
    prefer_ipv6)
      sbyx='prefer_ipv6'
      xryx='ForceIPv6v4'
      ;;
    prefer_ipv4)
      sbyx='prefer_ipv4'
      xryx='ForceIPv4v6'
      ;;
  esac
fi
}

ipbest(){
serip=$( (command -v curl >/dev/null 2>&1 && (curl -s4m5 -k "$v46url" 2>/dev/null || curl -s6m5 -k "$v46url" 2>/dev/null) ) || (command -v wget >/dev/null 2>&1 && (timeout 3 wget -4 -qO- --tries=2 "$v46url" 2>/dev/null || timeout 3 wget -6 -qO- --tries=2 "$v46url" 2>/dev/null) ) )
if echo "$serip" | grep -q ':'; then
server_ip="[$serip]"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
else
server_ip="$serip"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
fi
}
ipbest6(){
serip=$( (command -v curl >/dev/null 2>&1 && (curl -s6m5 -k "$v46url" 2>/dev/null || curl -s4m5 -k "$v46url" 2>/dev/null) ) || (command -v wget >/dev/null 2>&1 && (timeout 3 wget -6 -qO- --tries=2 "$v46url" 2>/dev/null || timeout 3 wget -4 -qO- --tries=2 "$v46url" 2>/dev/null) ) )
if echo "$serip" | grep -q ':'; then
server_ip="[$serip]"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
else
server_ip="$serip"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
fi
}

# =============================================================================
# SECTION 3: 内核下载与UUID管理
# 功能:
#   - upxray(): 下载Xray内核二进制文件,设置执行权限,显示版本
#   - upsingbox(): 下载Sing-box内核二进制文件,设置执行权限,显示版本
#   - insuuid(): 生成或读取UUID,持久化到$HOME/agsbx/uuid
# 依赖: upxray/upsingbox下载的内核
# =============================================================================
# 下载二进制并校验：ELF头+体积双校验，防止504/HTML错误页被当二进制执行；直连失败自动切换GitHub加速镜像
dl_bin(){
_url="$1"; _out="$2"
for _pfx in "" "https://gh-proxy.com/" "https://ghfast.top/" "https://ghproxy.net/"; do
_full="${_pfx}${_url}"
_n=0
while [ "$_n" -lt 2 ]; do
_n=$((_n+1))
rm -f "$_out"
if command -v curl >/dev/null 2>&1; then
curl -fL --retry 2 --retry-all-errors --connect-timeout 15 -m 300 -o "$_out" "$_full" 2>/dev/null
elif command -v wget >/dev/null 2>&1; then
wget -q -O "$_out" --tries=2 --timeout=120 "$_full" 2>/dev/null
fi
[ -f "$_out" ] || { sleep 2; continue; }
_sz=$(wc -c < "$_out" 2>/dev/null); _sz=${_sz:-0}
if [ "$_sz" -gt 102400 ] && head -c 4 "$_out" 2>/dev/null | grep -q "ELF"; then
return 0
fi
sleep 2
done
done
rm -f "$_out"
return 1
}
upxray(){
out="$HOME/agsbx/xray"
if dl_bin "https://github.com/yonggekkk/argosbx/releases/download/argosbx/xray-$cpu" "$out"; then
chmod +x "$out"
sbcore=$("$out" version 2>/dev/null | awk '/^Xray/{print $2}')
echo "已安装Xray正式版内核：$sbcore"
else
echo "❌ Xray内核下载失败（已重试多镜像），请检查网络或稍后再试"
return 1
fi
}
upsingbox(){
out="$HOME/agsbx/sing-box"
if dl_bin "https://github.com/yonggekkk/argosbx/releases/download/argosbx/sing-box-$cpu" "$out"; then
chmod +x "$out"
sbcore=$("$out" version 2>/dev/null | awk '/version/{print $NF}')
echo "已安装Sing-box正式版内核：$sbcore"
else
echo "❌ Sing-box内核下载失败（已重试多镜像），请检查网络或稍后再试"
return 1
fi
}
insuuid(){
if [ -z "$uuid" ] && [ ! -e "$HOME/agsbx/uuid" ]; then
if [ -e "$HOME/agsbx/sing-box" ]; then
uuid=$("$HOME/agsbx/sing-box" generate uuid)
else
uuid=$("$HOME/agsbx/xray" uuid)
fi
echo "$uuid" > "$HOME/agsbx/uuid"
elif [ -n "$uuid" ]; then
echo "$uuid" > "$HOME/agsbx/uuid"
fi
uuid=$(cat "$HOME/agsbx/uuid")
echo "UUID密码：$uuid"
}

# =============================================================================
# SECTION 4: installxray - Xray内核配置生成(仅Xray协议)
# 功能:
#   - 生成Xray配置文件$HOME/agsbx/xr.json
#   - 配置VLESS-Reality(xhttp-reality)协议(xtls-rprx-vision/xhttp)
#   - 配置VLESS-xhttp和VLESS-xhttp-reality协议
#   - 配置VMess-WS(已被xrsbvm接管,此处仅保留结构)
#   - 配置SOCKS5代理(已被xrsbso接管)
#   - 自动生成或读取Reality密钥对
#   - 支持VLESS ENC加密(vlpt_enc/xhpt_enc/vxpt_enc/vwpt_enc)
# 条件: 仅当启用xhp/vlp/vxp时调用
# 注意: VMess-WS和SOCKS5配置已移至xrsbvm/xrsbso
# =============================================================================
installxray(){
echo
echo "=========启用xray内核========="
mkdir -p "$HOME/agsbx/xrk"
if [ ! -e "$HOME/agsbx/xray" ] || ! head -c 4 "$HOME/agsbx/xray" 2>/dev/null | grep -q "ELF"; then
upxray || { echo "Xray内核获取失败，安装中止"; exit 1; }
fi
cat > "$HOME/agsbx/xr.json" <<EOF
{
  "log": {
  "loglevel": "none"
  },
  "inbounds": [
EOF
insuuid
if [ -n "$xhp" ] || [ -n "$vlp" ]; then
if [ -z "$ym_vl_re" ]; then
ym_vl_re=apple.com
fi
echo "$ym_vl_re" > "$HOME/agsbx/ym_vl_re"
echo "Reality域名：$ym_vl_re"
if [ ! -e "$HOME/agsbx/xrk/private_key" ]; then
key_pair=$("$HOME/agsbx/xray" x25519)
private_key=$(echo "$key_pair" | awk -F':' '/PrivateKey/ {print $2}' | xargs)
public_key=$(echo "$key_pair" | awk -F':' '/Password/ {print $2}' | xargs)
short_id=$(date +%s%N | sha256sum | cut -c 1-8)
echo "$private_key" > "$HOME/agsbx/xrk/private_key"
echo "$public_key" > "$HOME/agsbx/xrk/public_key"
echo "$short_id" > "$HOME/agsbx/xrk/short_id"
fi
private_key_x=$(cat "$HOME/agsbx/xrk/private_key")
public_key_x=$(cat "$HOME/agsbx/xrk/public_key")
short_id_x=$(cat "$HOME/agsbx/xrk/short_id")
fi

if [ -n "$port_vl_re_enc" ] || [ -n "$port_xh_enc" ] || [ -n "$port_vx_enc" ] || [ -n "$port_vw_enc" ] || [ "$vlpt_enc" = "y" ] || [ "$xhpt_enc" = "y" ] || [ "$vxpt_enc" = "y" ] || [ "$vwpt_enc" = "y" ]; then
if [ ! -e "$HOME/agsbx/xrk/dekey" ]; then
vlkey=$("$HOME/agsbx/xray" vlessenc)
dekey=$(echo "$vlkey" | grep '"decryption":' | sed -n '2p' | cut -d' ' -f2- | tr -d '"')
enkey=$(echo "$vlkey" | grep '"encryption":' | sed -n '2p' | cut -d' ' -f2- | tr -d '"')
echo "$dekey" > "$HOME/agsbx/xrk/dekey"
echo "$enkey" > "$HOME/agsbx/xrk/enkey"
fi
dekey=$(cat "$HOME/agsbx/xrk/dekey")
enkey=$(cat "$HOME/agsbx/xrk/enkey")
fi

if [ -n "$xhp" ]; then
xhp=xhpt
if [ -z "$port_xh" ] && [ ! -e "$HOME/agsbx/port_xh" ]; then
port_xh=$(shuf -i 10000-65535 -n 1)
echo "$port_xh" > "$HOME/agsbx/port_xh"
elif [ -n "$port_xh" ]; then
echo "$port_xh" > "$HOME/agsbx/port_xh"
fi
port_xh=$(cat "$HOME/agsbx/port_xh")
echo "Vless-xhttp-reality端口：$port_xh"
if [ -n "$port_xh_enc" ]; then
dec_xh="$dekey"
else
dec_xh="none"
fi
cat >> "$HOME/agsbx/xr.json" <<EOF
    {
      "tag":"xhttp-reality",
      "listen": "::",
      "port": ${port_xh},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "${dec_xh}"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "reality",
        "realitySettings": {
          "fingerprint": "chrome",
          "target": "${ym_vl_re}:443",
          "serverNames": [
            "${ym_vl_re}"
          ],
          "privateKey": "$private_key_x",
          "shortIds": ["$short_id_x"]
        },
        "xhttpSettings": {
          "host": "",
          "path": "/xhttp",
          "mode": "auto"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "metadataOnly": false
      }
    },
EOF
else
xhp=xhptargo
fi
if [ -n "$vxp" ]; then
vxp=vxpt
if [ -z "$port_vx" ] && [ ! -e "$HOME/agsbx/port_vx" ]; then
port_vx=$(shuf -i 10000-65535 -n 1)
echo "$port_vx" > "$HOME/agsbx/port_vx"
elif [ -n "$port_vx" ]; then
echo "$port_vx" > "$HOME/agsbx/port_vx"
fi
port_vx=$(cat "$HOME/agsbx/port_vx")
echo "Vless-xhttp端口：$port_vx"
if [ -n "$cdnym" ]; then
echo "$cdnym" > "$HOME/agsbx/cdnym"
echo "80系CDN或者回源CDN的host域名 (确保IP已解析在CF域名)：$cdnym"
fi
if [ -n "$port_vx_enc" ]; then
dec_vx="$dekey"
else
dec_vx="none"
fi
cat >> "$HOME/agsbx/xr.json" <<EOF
    {
      "tag":"vless-xhttp",
      "listen": "::",
      "port": ${port_vx},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "${dec_vx}"
      },
      "streamSettings": {
        "network": "xhttp",
        "xhttpSettings": {
          "host": "",
          "path": "/xhttp",
          "mode": "auto"
        }
      },
        "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "metadataOnly": false
      }
    },
EOF
else
vxp=vxptargo
fi
if [ -n "$vlp" ]; then
vlp=vlpt
if [ -z "$port_vl_re" ] && [ ! -e "$HOME/agsbx/port_vl_re" ]; then
port_vl_re=$(shuf -i 10000-65535 -n 1)
echo "$port_vl_re" > "$HOME/agsbx/port_vl_re"
elif [ -n "$port_vl_re" ]; then
echo "$port_vl_re" > "$HOME/agsbx/port_vl_re"
fi
port_vl_re=$(cat "$HOME/agsbx/port_vl_re")
echo "Vless-tcp-reality-v端口：$port_vl_re"
if [ -n "$port_vl_re_enc" ]; then
dec_vl="$dekey"
else
dec_vl="none"
fi
cat >> "$HOME/agsbx/xr.json" <<EOF
        {
            "tag":"reality-vision",
            "listen": "::",
            "port": $port_vl_re,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "${dec_vl}"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "fingerprint": "chrome",
                    "dest": "${ym_vl_re}:443",
                    "serverNames": [
                      "${ym_vl_re}"
                    ],
                    "privateKey": "$private_key_x",
                    "shortIds": ["$short_id_x"]
                }
            },
          "sniffing": {
          "enabled": true,
          "destOverride": ["http", "tls", "quic"],
          "metadataOnly": false
      }
    },  
EOF
else
vlp=vlptargo
fi
}

# =============================================================================
# SECTION 5: installsb - Sing-box内核配置生成(Sing-box专有协议)
# 功能:
#   - 生成Sing-box配置文件$HOME/agsbx/sb.json
#   - 配置Hysteria2协议(port_hy2)
#   - 配置Tuic协议(port_tu)
#   - 配置AnyTLS协议(port_an)
#   - 配置Any-Reality协议(port_ar)
#   - 配置Shadowsocks协议(port_ss)
#   - 生成自签名证书用于TLS
# 条件: 当启用hyp/tup/anp/arp/ssp时调用
# 特点: 所有协议配置均写入sb.json,不使用XR.json
# =============================================================================
installsb(){
if [ "$XRAY_FORCE_MODE" = 1 ]; then
    echo "跳过 Sing-box 安装 (强制Xray模式)"
    return 0
fi
echo
echo "=========启用Sing-box内核========="
if [ ! -e "$HOME/agsbx/sing-box" ] || ! head -c 4 "$HOME/agsbx/sing-box" 2>/dev/null | grep -q "ELF"; then
upsingbox || { echo "Sing-box内核获取失败，安装中止"; exit 1; }
fi
cat > "$HOME/agsbx/sb.json" <<EOF
{
"log": {
    "disabled": false,
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
EOF
insuuid
command -v openssl >/dev/null 2>&1 && openssl ecparam -genkey -name prime256v1 -out "$HOME/agsbx/private.key" >/dev/null 2>&1
command -v openssl >/dev/null 2>&1 && openssl req -new -x509 -days 36500 -key "$HOME/agsbx/private.key" -out "$HOME/agsbx/cert.pem" -subj "/CN=www.bing.com" >/dev/null 2>&1
if [ ! -f "$HOME/agsbx/private.key" ]; then
url="https://github.com/yonggekkk/argosbx/releases/download/argosbx/private.key"; out="$HOME/agsbx/private.key"; (command -v curl>/dev/null 2>&1 && curl -Ls -o "$out" --retry 2 "$url") || (command -v wget>/dev/null 2>&1 && timeout 3 wget -q -O "$out" --tries=2 "$url")
url="https://github.com/yonggekkk/argosbx/releases/download/argosbx/cert.pem"; out="$HOME/agsbx/cert.pem"; (command -v curl>/dev/null 2>&1 && curl -Ls -o "$out" --retry 2 "$url") || (command -v wget>/dev/null 2>&1 && timeout 3 wget -q -O "$out" --tries=2 "$url")
fi
if [ -n "$hyp" ]; then
hyp=hypt
if [ -z "$port_hy2" ] && [ ! -e "$HOME/agsbx/port_hy2" ]; then
port_hy2=$(shuf -i 10000-65535 -n 1)
echo "$port_hy2" > "$HOME/agsbx/port_hy2"
elif [ -n "$port_hy2" ]; then
echo "$port_hy2" > "$HOME/agsbx/port_hy2"
fi
port_hy2=$(cat "$HOME/agsbx/port_hy2")
echo "Hysteria2端口：$port_hy2"
cat >> "$HOME/agsbx/sb.json" <<EOF
    {
        "type": "hysteria2",
        "tag": "hy2_sb",
        "listen": "::",
        "listen_port": ${port_hy2},
        "users": [
            {
                "password": "${uuid}"
            }
        ],
        "ignore_client_bandwidth":false,
        "tls": {
            "enabled": true,
            "alpn": [
                "h3"
            ],
            "certificate_path": "$HOME/agsbx/cert.pem",
            "key_path": "$HOME/agsbx/private.key"
        }
    },
EOF
else
hyp=hyptargo
fi
if [ -n "$tup" ]; then
tup=tupt
if [ -z "$port_tu" ] && [ ! -e "$HOME/agsbx/port_tu" ]; then
port_tu=$(shuf -i 10000-65535 -n 1)
echo "$port_tu" > "$HOME/agsbx/port_tu"
elif [ -n "$port_tu" ]; then
echo "$port_tu" > "$HOME/agsbx/port_tu"
fi
port_tu=$(cat "$HOME/agsbx/port_tu")
echo "Tuic端口：$port_tu"
cat >> "$HOME/agsbx/sb.json" <<EOF
        {
            "type":"tuic",
            "tag": "tuic5-sb",
            "listen": "::",
            "listen_port": ${port_tu},
            "users": [
                {
                    "uuid": "${uuid}",
                    "password": "${uuid}"
                }
            ],
            "congestion_control": "bbr",
            "tls":{
                "enabled": true,
                "alpn": [
                    "h3"
                ],
                "certificate_path": "$HOME/agsbx/cert.pem",
                "key_path": "$HOME/agsbx/private.key"
            }
        },
EOF
else
tup=tuptargo
fi
if [ -n "$anp" ]; then
anp=anpt
if [ -z "$port_an" ] && [ ! -e "$HOME/agsbx/port_an" ]; then
port_an=$(shuf -i 10000-65535 -n 1)
echo "$port_an" > "$HOME/agsbx/port_an"
elif [ -n "$port_an" ]; then
echo "$port_an" > "$HOME/agsbx/port_an"
fi
port_an=$(cat "$HOME/agsbx/port_an")
echo "Anytls端口：$port_an"
cat >> "$HOME/agsbx/sb.json" <<EOF
        {
            "type":"anytls",
            "tag":"anytls_sb",
            "listen":"::",
            "listen_port":${port_an},
            "users":[
                {
                  "password":"${uuid}"
                }
            ],
            "padding_scheme":[],
            "tls":{
                "enabled": true,
                "certificate_path": "$HOME/agsbx/cert.pem",
                "key_path": "$HOME/agsbx/private.key"
            }
        },
EOF
else
anp=anptargo
fi
if [ -n "$arp" ]; then
arp=arpt
if [ -z "$ym_vl_re" ]; then
ym_vl_re=apple.com
fi
echo "$ym_vl_re" > "$HOME/agsbx/ym_vl_re"
echo "Reality域名：$ym_vl_re"
mkdir -p "$HOME/agsbx/sbk"
if [ ! -e "$HOME/agsbx/sbk/private_key" ]; then
key_pair=$("$HOME/agsbx/sing-box" generate reality-keypair)
private_key=$(echo "$key_pair" | awk '/PrivateKey/ {print $2}' | tr -d '"')
public_key=$(echo "$key_pair" | awk '/PublicKey/ {print $2}' | tr -d '"')
short_id=$("$HOME/agsbx/sing-box" generate rand --hex 4)
echo "$private_key" > "$HOME/agsbx/sbk/private_key"
echo "$public_key" > "$HOME/agsbx/sbk/public_key"
echo "$short_id" > "$HOME/agsbx/sbk/short_id"
fi
private_key_s=$(cat "$HOME/agsbx/sbk/private_key")
public_key_s=$(cat "$HOME/agsbx/sbk/public_key")
short_id_s=$(cat "$HOME/agsbx/sbk/short_id")
if [ -z "$port_ar" ] && [ ! -e "$HOME/agsbx/port_ar" ]; then
port_ar=$(shuf -i 10000-65535 -n 1)
echo "$port_ar" > "$HOME/agsbx/port_ar"
elif [ -n "$port_ar" ]; then
echo "$port_ar" > "$HOME/agsbx/port_ar"
fi
port_ar=$(cat "$HOME/agsbx/port_ar")
echo "Any-Reality端口：$port_ar"
cat >> "$HOME/agsbx/sb.json" <<EOF
        {
            "type":"anytls",
            "tag":"anyreality-sb",
            "listen":"::",
            "listen_port":${port_ar},
            "users":[
                {
                  "password":"${uuid}"
                }
            ],
            "padding_scheme":[],
            "tls": {
            "enabled": true,
            "server_name": "${ym_vl_re}",
             "reality": {
              "enabled": true,
              "handshake": {
              "server": "${ym_vl_re}",
              "server_port": 443
             },
             "private_key": "$private_key_s",
             "short_id": ["$short_id_s"]
            }
          }
        },
EOF
else
arp=arptargo
fi
if [ -n "$ssp" ]; then
ssp=sspt
if [ ! -e "$HOME/agsbx/sskey" ]; then
sskey=$("$HOME/agsbx/sing-box" generate rand 16 --base64)
echo "$sskey" > "$HOME/agsbx/sskey"
fi
if [ -z "$port_ss" ] && [ ! -e "$HOME/agsbx/port_ss" ]; then
port_ss=$(shuf -i 10000-65535 -n 1)
echo "$port_ss" > "$HOME/agsbx/port_ss"
elif [ -n "$port_ss" ]; then
echo "$port_ss" > "$HOME/agsbx/port_ss"
fi
sskey=$(cat "$HOME/agsbx/sskey")
port_ss=$(cat "$HOME/agsbx/port_ss")
echo "Shadowsocks-2022端口：$port_ss"
cat >> "$HOME/agsbx/sb.json" <<EOF
        {
            "type": "shadowsocks",
            "tag":"ss-2022",
            "listen": "::",
            "listen_port": $port_ss,
            "method": "2022-blake3-aes-128-gcm",
            "password": "$sskey"
    },  
EOF
else
ssp=ssptargo
fi
}

# =============================================================================
# SECTION 6: xrsbvm - VMess-WS/VLESS-WS双协议配置注入(核心函数)
# 功能:
#   - VMess-WS配置注入:
#     * 检查xr.json是否存在,决定注入目标
#     * 存在 → 注入到Xray (tag: vmess-xr, path: ${uuid}-vm)
#     * 不存在 → 注入到Sing-box (tag: vmess-sb, path: ${uuid}-vm)
#   - VLESS-WS配置注入(与VMess相同逻辑):
#     * 检查xr.json是否存在,决定注入目标
#     * 存在 → 注入到Xray (tag: vless-ws-xr, path: ${uuid}-vw)
#     * 不存在 → 注入到Sing-box (tag: vless-ws-sb, path: ${uuid}-vw)
#   - 自动分配端口,支持CDN域名配置
# 条件: 当启用vmp(VMess)或vwp(VLESS)时调用
# 特点: 遵循"双核模式"逻辑,共享xr.json存在性判断
# =============================================================================
xrsbvm(){
if [ -n "$vmp" ]; then
vmp=vmpt
if [ -z "$port_vm_ws" ] && [ ! -e "$HOME/agsbx/port_vm_ws" ]; then
port_vm_ws=$(shuf -i 10000-65535 -n 1)
echo "$port_vm_ws" > "$HOME/agsbx/port_vm_ws"
elif [ -n "$port_vm_ws" ]; then
echo "$port_vm_ws" > "$HOME/agsbx/port_vm_ws"
fi
port_vm_ws=$(cat "$HOME/agsbx/port_vm_ws")
echo "Vmess-ws端口：$port_vm_ws"
if [ -n "$cdnym" ]; then
echo "$cdnym" > "$HOME/agsbx/cdnym"
echo "80系CDN或者回源CDN的host域名 (确保IP已解析在CF域名)：$cdnym"
fi
if [ -e "$HOME/agsbx/xr.json" ]; then
cat >> "$HOME/agsbx/xr.json" <<EOF
        {
            "tag": "vmess-xr",
            "listen": "::",
            "port": ${port_vm_ws},
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                  "path": "${uuid}-vm"
            }
        },
            "sniffing": {
            "enabled": true,
            "destOverride": ["http", "tls", "quic"],
            "metadataOnly": false
            }
         }, 
EOF
else
cat >> "$HOME/agsbx/sb.json" <<EOF
{
        "type": "vmess",
        "tag": "vmess-sb",
        "listen": "::",
        "listen_port": ${port_vm_ws},
        "users": [
            {
                "uuid": "${uuid}",
                "alterId": 0
            }
        ],
        "transport": {
            "type": "ws",
            "path": "${uuid}-vm",
            "max_early_data":2048,
            "early_data_header_name": "Sec-WebSocket-Protocol"
        }
    },
EOF
fi
else
vmp=vmptargo
fi
# VLESS-WS 配置注入（与 VMess 相同逻辑）
if [ -n "$vwp" ]; then
vwp=vwpt
if [ -z "$port_vw" ] && [ ! -e "$HOME/agsbx/port_vw" ]; then
port_vw=$(shuf -i 10000-65535 -n 1)
echo "$port_vw" > "$HOME/agsbx/port_vw"
elif [ -n "$port_vw" ]; then
echo "$port_vw" > "$HOME/agsbx/port_vw"
fi
port_vw=$(cat "$HOME/agsbx/port_vw")
echo "Vless-ws端口：$port_vw"
if [ -n "$cdnym" ]; then
echo "$cdnym" > "$HOME/agsbx/cdnym"
echo "80系CDN或者回源CDN的host域名 (确保IP已解析在CF域名)：$cdnym"
fi
if [ -n "$port_vw_enc" ] && [ ! -e "$HOME/agsbx/xr.json" ]; then
installxray
fi
if [ -e "$HOME/agsbx/xr.json" ]; then
if [ -n "$port_vw_enc" ]; then
dec_vw="$dekey"
else
dec_vw="none"
fi
cat >> "$HOME/agsbx/xr.json" <<EOF
        {
            "tag": "vless-ws-xr",
            "listen": "::",
            "port": ${port_vw},
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}"
                    }
                ],
                "decryption": "${dec_vw}"
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/${uuid}-vw"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": ["http", "tls", "quic"],
                "metadataOnly": false
            }
        },
EOF
else
cat >> "$HOME/agsbx/sb.json" <<EOF
        {
            "type": "vless",
            "tag": "vless-ws-sb",
            "listen": "::",
            "listen_port": ${port_vw},
            "users": [
                {
                    "uuid": "${uuid}"
                }
            ],
            "transport": {
                "type": "ws",
                "path": "/${uuid}-vw",
                "max_early_data": 2048,
                "early_data_header_name": "Sec-WebSocket-Protocol"
            }
        },
EOF
fi
else
vwp=vwptargo
fi
}

# =============================================================================
# SECTION 7: xrsbso - SOCKS5代理配置注入
# 功能:
#   - SOCKS5代理配置注入
#   - 检查xr.json是否存在,决定注入目标
#     * 存在 → 注入到Xray (tag: socks5-xr)
#     * 不存在 → 注入到Sing-box (tag: socks5-sb)
#   - 使用UUID作为用户名和密码
#   - 支持UDP协议
# 条件: 当启用sop时调用
# 特点: 与VMess-WS/VLESS-WS使用相同的xr.json存在性判断逻辑
# =============================================================================
xrsbso(){
if [ -n "$sop" ]; then
sop=sopt
if [ -z "$port_so" ] && [ ! -e "$HOME/agsbx/port_so" ]; then
port_so=$(shuf -i 10000-65535 -n 1)
echo "$port_so" > "$HOME/agsbx/port_so"
elif [ -n "$port_so" ]; then
echo "$port_so" > "$HOME/agsbx/port_so"
fi
port_so=$(cat "$HOME/agsbx/port_so")
echo "Socks5端口：$port_so"
if [ -e "$HOME/agsbx/xr.json" ]; then
cat >> "$HOME/agsbx/xr.json" <<EOF
        {
         "tag": "socks5-xr",
         "port": ${port_so},
         "listen": "::",
         "protocol": "socks",
         "settings": {
            "auth": "password",
             "accounts": [
               {
               "user": "${uuid}",
               "pass": "${uuid}"
               }
            ],
            "udp": true
          },
            "sniffing": {
            "enabled": true,
            "destOverride": ["http", "tls", "quic"],
            "metadataOnly": false
            }
         }, 
EOF
else
cat >> "$HOME/agsbx/sb.json" <<EOF
    {
      "tag": "socks5-sb",
      "type": "socks",
      "listen": "::",
      "listen_port": ${port_so},
      "users": [
      {
      "username": "${uuid}",
      "password": "${uuid}"
      }
     ]
    },
EOF
fi
else
sop=soptargo
fi
}

# =============================================================================
# SECTION 8: xrsbout - 出站规则与路由配置生成
# 功能:
#   - 完善Xray配置文件的outbounds部分
#   - 配置direct直连出站(带域名策略)
#   - 配置WARP出站(WireGuard协议)
#   - 配置自由出站(freedom)
#   - 设置域名解析策略(ForceIPv4/ForceIPv6/ForceIPv4v6等)
# 条件: 仅当xr.json存在时调用(即双核模式或仅Xray模式)
# 依赖: warpsx()设置的pvk/wpv6/res等变量
# =============================================================================
xrsbout(){
if [ -e "$HOME/agsbx/xr.json" ]; then
sed -i '${s/,[[:space:]]*$//}' "$HOME/agsbx/xr.json"
cat >> "$HOME/agsbx/xr.json" <<EOF
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct",
      "settings": {
      "domainStrategy":"${xryx}"
     }
    },
    {
      "tag": "x-warp-out",
      "protocol": "wireguard",
      "settings": {
        "secretKey": "${pvk}",
        "address": [
          "172.16.0.2/32",
          "${wpv6}/128"
        ],
        "peers": [
          {
            "publicKey": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
            "allowedIPs": [
              "0.0.0.0/0",
              "::/0"
            ],
            "endpoint": "${xendip}:2408"
          }
        ],
        "reserved": ${res}
        }
    },
    {
      "tag":"warp-out",
      "protocol":"freedom",
        "settings":{
        "domainStrategy":"${wxryx}"
       },
       "proxySettings":{
       "tag":"x-warp-out"
     }
}
  ],
  "routing": {
    "domainStrategy": "IPOnDemand",
    "rules": [
      {
        "type": "field",
        "ip": [ ${xip} ],
        "network": "tcp,udp",
        "outboundTag": "${x1outtag}"
      },
      {
        "type": "field",
        "network": "tcp,udp",
        "outboundTag": "${x2outtag}"
      }
    ]
  }
}
EOF
if pidof systemd >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
cat > /etc/systemd/system/xr.service <<EOF
[Unit]
Description=xr service
After=network.target
[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=/root/agsbx/xray run -c /root/agsbx/xr.json
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload >/dev/null 2>&1
systemctl enable xr >/dev/null 2>&1
systemctl start xr >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
cat > /etc/init.d/xray <<EOF
#!/sbin/openrc-run
description="xr service"
command="/root/agsbx/xray"
command_args="run -c /root/agsbx/xr.json"
command_background=yes
pidfile="/run/xray.pid"
command_background="yes"
depend() {
need net
}
EOF
chmod +x /etc/init.d/xray >/dev/null 2>&1
rc-update add xray default >/dev/null 2>&1
rc-service xray start >/dev/null 2>&1
else
nohup "$HOME/agsbx/xray" run -c "$HOME/agsbx/xr.json" > "$HOME/agsbx/xray.log" 2>&1 &
fi
fi
if [ -e "$HOME/agsbx/sb.json" ]; then
sed -i '${s/,[[:space:]]*$//}' "$HOME/agsbx/sb.json"
cat >> "$HOME/agsbx/sb.json" <<EOF
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ],
  "endpoints": [
    {
      "type": "wireguard",
      "tag": "warp-out",
      "address": [
        "172.16.0.2/32",
        "${wpv6}/128"
      ],
      "private_key": "${pvk}",
      "peers": [
        {
          "address": "${sendip}",
          "port": 2408,
          "public_key": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
          "allowed_ips": [
            "0.0.0.0/0",
            "::/0"
          ],
          "reserved": $res
        }
      ]
    }
  ],
  "route": {
    "rules": [
       {
          "action": "sniff"
        },
       {
        "action": "resolve",
         "strategy": "${sbyx}"
       },
      {
        "ip_cidr": [ ${sip} ],         
        "outbound": "${s1outtag}"
      }
    ],
    "final": "${s2outtag}"
  },
  "experimental": {
    "cache_file": {
      "enabled": false
    }
  }
}
EOF
if pidof systemd >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
cat > /etc/systemd/system/sb.service <<EOF
[Unit]
Description=sb service
After=network.target
[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=/root/agsbx/sing-box run -c /root/agsbx/sb.json
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload >/dev/null 2>&1
systemctl enable sb >/dev/null 2>&1
systemctl start sb >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
cat > /etc/init.d/sing-box <<EOF
#!/sbin/openrc-run
description="sb service"
command="/root/agsbx/sing-box"
command_args="run -c /root/agsbx/sb.json"
command_background=yes
pidfile="/run/sing-box.pid"
command_background="yes"
depend() {
need net
}
EOF
chmod +x /etc/init.d/sing-box >/dev/null 2>&1
rc-update add sing-box default >/dev/null 2>&1
rc-service sing-box start >/dev/null 2>&1
else
nohup "$HOME/agsbx/sing-box" run -c "$HOME/agsbx/sb.json" > "$HOME/agsbx/sing-box.log" 2>&1 &
fi
fi
}

# SECTION 9: ins - 智能安装编排函数 (核心)
# 功能:
#   - 智能环境决策: 当 XRAY_FORCE_MODE=1 时，强制跳过 Sing-box 走 Xray 流程
#   - 动态分流逻辑: 根据协议组合自动选择 [纯Xray | 纯Sing-box | 双核] 模式
#   - 流程控制: installsb → installxray → xrsbvm (注入WS) → warpsx → xrsbout
#   - 故障自愈: 修正 .bashrc 恢复语句中的变量键名错误，确保 SSH 重连可正确找回协议
#   - 持久化配置: 写入 crontab 和 bashrc 配置别名
# =============================================================================

insnezha(){
  if [ -n "$nz_host" ] && [ -n "$nz_sec" ]; then
    echo "=========启用 哪吒探针 (Nezha Agent)========="
    
    NEZHA_DIR="$HOME/agsbx/nezha"
    NEZHA_BIN="${NEZHA_DIR}/nezha-agent"
    
    mkdir -p "$NEZHA_DIR"
    if [ ! -e "$NEZHA_BIN" ]; then
      case "$(uname -m)" in
        x86_64|amd64) nz_arch="amd64" ;;
        aarch64|arm64) nz_arch="arm64" ;;
        armv7l|armv7) nz_arch="armv7" ;;
        armv5*) nz_arch="armv5" ;;
        s390x) nz_arch="s390x" ;;
        *) echo "未知架构，跳过安装探针"; return 1 ;;
      esac
      
      nz_url=$(curl -s "https://api.github.com/repos/nezhahq/agent/releases/latest" | grep "browser_download_url" | grep "linux-${nz_arch}.zip" | cut -d '"' -f 4)
      echo "正在下载哪吒探针内核 (${nz_arch})..."
      (command -v curl >/dev/null 2>&1 && curl -Lo "${NEZHA_DIR}/nezha.zip" -# --retry 2 "$nz_url") || wget -O "${NEZHA_DIR}/nezha.zip" --tries=2 "$nz_url"
      unzip -q -o "${NEZHA_DIR}/nezha.zip" -d "$NEZHA_DIR/" 2>/dev/null
      rm -f "${NEZHA_DIR}/nezha.zip"
      chmod +x "$NEZHA_BIN"
    fi

    kill -15 $(pgrep -f 'nezha-agent' 2>/dev/null) >/dev/null 2>&1

    local tls_flag=""
    [ "$nz_tls" = "--tls" ] && tls_flag="--tls"

    local safe_flags=""
    if [ "$(id -u)" -ne 0 ]; then
        safe_flags="--disable-auto-update --disable-command-execute"
        echo "⚠️ 检测到非 Root 环境，已自动启用探针安全限制模式。"
    fi

    nohup "$NEZHA_BIN" -s "${nz_host}:${nz_port}" -p "${nz_sec}" ${tls_flag} ${safe_flags} >/dev/null 2>&1 &
    
    sleep 3
    if pgrep -f 'nezha-agent' >/dev/null 2>&1; then
        echo "✅ 哪吒探针启动成功！"
    else
        echo "❌ 哪吒探针启动失败，请检查参数或网络环境。"
    fi

    if command -v crontab >/dev/null 2>&1; then
        crontab -l > /tmp/crontab.tmp 2>/dev/null
        sed -i '/nezha-agent/d' /tmp/crontab.tmp
        echo "@reboot sleep 15 && /bin/sh -c \"nohup ${NEZHA_BIN} -s ${nz_host}:${nz_port} -p ${nz_sec} ${tls_flag} ${safe_flags} >/dev/null 2>&1 &\"" >> /tmp/crontab.tmp
        crontab /tmp/crontab.tmp >/dev/null 2>&1
        rm -f /tmp/crontab.tmp
    else
        echo "⚠️ 提示：当前环境无 crontab 权限，探针无法设置开机自启，但本次已成功运行。"
    fi
  fi
}

ins(){
# =============================================================================
# 安装模式判断逻辑：
#   - 情况A: 只启用 Xray 协议 (xhp/vlp/vxp) 且不启用 SB 协议
#   - 情况B: 只启用 SB 协议 (hyp/tup/anp/arp/ssp/vwp) 且不启用 Xray 协议
#   - 情况C: 混合模式 (同时启用两边协议)
# 说明: VLESS-WS 和 VMess-WS 现在可以跟随 Sing-box 单独运行
# 特殊: 如果 XRAY_FORCE_MODE=1，强制使用 Xray 模式
# =============================================================================
if [ "$XRAY_FORCE_MODE" = 1 ]; then
# 强制Xray模式 (容器环境不支持 Sing-box)
installxray
xrsbvm
xrsbso
warpsx
xrsbout
hyp="hyptargo"; tup="tuptargo"; anp="anptargo"; arp="arptargo"; ssp="ssptargo"; vwp="vwptargo"
elif [ "$hyp" != yes ] && [ "$tup" != yes ] && [ "$anp" != yes ] && [ "$arp" != yes ] && [ "$ssp" != yes ]; then
# 情况A: 无 sing-box 专属协议 → 纯Xray模式 (vless-ws/vmess-ws/socks5 等双栖协议改走 Xray，不依赖 netlink，容器友好)
installxray
xrsbvm
xrsbso
warpsx
xrsbout
hyp="hyptargo"; tup="tuptargo"; anp="anptargo"; arp="arptargo"; ssp="ssptargo"; vwp="vwptargo"
elif [ "$xhp" != yes ] && [ "$vlp" != yes ] && [ "$vxp" != yes ]; then
# 情况B: 纯SB模式 (不启用任何Xray协议，vwp跟随Sing-box)
installsb
if [ -n "$port_vw_enc" ]; then
installxray
fi
xrsbvm
xrsbso
warpsx
xrsbout
xhp="xhptargo"; vlp="vlptargo"; vxp="vxptargo"
else
# 情况C: 双核模式 (同时启用Xray和SB协议)
installsb
installxray
xrsbvm
xrsbso
warpsx
xrsbout
fi
# 启动Xray内核（如果xr.json存在但Xray未启动）
if [ -f "$HOME/agsbx/xr.json" ]; then
if ! find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/x' && ! pgrep -f 'agsbx/x' >/dev/null 2>&1; then
if pidof systemd >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
systemctl start xr >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
rc-service xray start >/dev/null 2>&1
else
nohup "$HOME/agsbx/xray" run -c "$HOME/agsbx/xr.json" >/dev/null 2>&1 &
fi
fi
fi
if [ -n "$argo" ] && [ -n "$vmag" ]; then
echo
echo "=========启用Cloudflared-argo内核========="
if [ ! -e "$HOME/agsbx/cloudflared" ]; then
argocore=$({ command -v curl >/dev/null 2>&1 && curl -Ls https://data.jsdelivr.com/v1/package/gh/cloudflare/cloudflared || wget -qO- https://data.jsdelivr.com/v1/package/gh/cloudflare/cloudflared; } | grep -Eo '"[0-9.]+"' | sed -n 1p | tr -d '",')
echo "下载Cloudflared-argo最新正式版内核：$argocore"
url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$cpu"; out="$HOME/agsbx/cloudflared"; (command -v curl>/dev/null 2>&1 && curl -Lo "$out" -# --retry 2 "$url") || (command -v wget>/dev/null 2>&1 && timeout 3 wget -O "$out" --tries=2 "$url")
chmod +x "$HOME/agsbx/cloudflared"
fi
if [ "$argo" = "vmpt" ]; then argoport=$(cat "$HOME/agsbx/port_vm_ws" 2>/dev/null); echo "Vmess" > "$HOME/agsbx/vlvm"; elif [ "$argo" = "vwpt" ]; then argoport=$(cat "$HOME/agsbx/port_vw" 2>/dev/null); echo "Vless" > "$HOME/agsbx/vlvm"; fi; echo "$argoport" > "$HOME/agsbx/argoport.log"

# 智能选择传输协议 (UDP受限时自动切换为HTTP2)
if command -v nc >/dev/null 2>&1 && nc -z -w 2 -u 1.1.1.1 443 >/dev/null 2>&1; then
  argoproto="--protocol quic"
else
  argoproto="--protocol http2"
fi
echo "$argoproto" > "$HOME/agsbx/argoproto.log"

if [ -n "${ARGO_DOMAIN}" ] && [ -n "${ARGO_AUTH}" ]; then
argoname='固定'
if pidof systemd >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
cat > /etc/systemd/system/argo.service <<EOF
[Unit]
Description=argo service
After=network.target
[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=/root/agsbx/cloudflared tunnel ${argoproto} --no-autoupdate --edge-ip-version auto run --token "${ARGO_AUTH}"
Restart=on-failure
RestartSec=5s
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload >/dev/null 2>&1
systemctl enable argo >/dev/null 2>&1
systemctl start argo >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
cat > /etc/init.d/argo <<EOF
#!/sbin/openrc-run
description="argo service"
command="/root/agsbx/cloudflared tunnel"
command_args="${argoproto} --no-autoupdate --edge-ip-version auto run --token ${ARGO_AUTH}"
pidfile="/run/argo.pid"
command_background="yes"
depend() {
need net
}
EOF
chmod +x /etc/init.d/argo >/dev/null 2>&1
rc-update add argo default >/dev/null 2>&1
rc-service argo start >/dev/null 2>&1
else
nohup "$HOME/agsbx/cloudflared" tunnel ${argoproto} --no-autoupdate --edge-ip-version auto run --token "${ARGO_AUTH}" >/dev/null 2>&1 &
fi
echo "${ARGO_DOMAIN}" > "$HOME/agsbx/sbargoym.log"
echo "${ARGO_AUTH}" > "$HOME/agsbx/sbargotoken.log"
else
argoname='临时'
nohup "$HOME/agsbx/cloudflared" tunnel ${argoproto} --url http://localhost:$(cat $HOME/agsbx/argoport.log) --edge-ip-version auto --no-autoupdate > $HOME/agsbx/argo.log 2>&1 &
fi
echo "申请Argo$argoname隧道中……请稍等"
if [ -n "${ARGO_DOMAIN}" ] && [ -n "${ARGO_AUTH}" ]; then
sleep 3
argodomain=$(cat "$HOME/agsbx/sbargoym.log" 2>/dev/null)
else
argodomain=""
for i in 1 2 3 4 5 6 7 8 9 10; do
sleep 2
argodomain=$(grep -a trycloudflare.com "$HOME/agsbx/argo.log" 2>/dev/null | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')
[ -n "$argodomain" ] && break
done
fi
if [ -n "${argodomain}" ]; then
echo "Argo$argoname隧道申请成功"
else
echo "Argo$argoname隧道申请失败，请稍后再试"
fi
fi
sleep 5
echo
_sb_up=0; _xr_up=0
	_sb_need=0; _xr_need=0
	[ -f "$HOME/agsbx/sb.json" ] && _sb_need=1
	[ -f "$HOME/agsbx/xr.json" ] && _xr_need=1
	for i in 1 2 3 4 5 6 7; do
		[ "$_sb_need" = 1 ] && [ "$_sb_up" = 0 ] && \
			( find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/s' || pgrep -f 'agsbx/s' >/dev/null 2>&1 ) && _sb_up=1
		[ "$_xr_need" = 1 ] && [ "$_xr_up" = 0 ] && \
			( find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/x' || pgrep -f 'agsbx/x' >/dev/null 2>&1 ) && _xr_up=1
		[ "$_sb_up" = "$_sb_need" ] && [ "$_xr_up" = "$_xr_need" ] && break
		sleep 2
	done
	# systemd 启动失败 → nohup 兜底
	if [ "$_sb_need" = 1 ] && [ "$_sb_up" = 0 ]; then
		if pidof systemd >/dev/null 2>&1 && systemctl is-failed sb >/dev/null 2>&1; then
			echo "WARNING: systemd 启动 sing-box 失败，尝试 nohup 直接启动..."
			systemctl reset-failed sb >/dev/null 2>&1
			nohup "$HOME/agsbx/sing-box" run -c "$HOME/agsbx/sb.json" > "$HOME/agsbx/sing-box.log" 2>&1 &
			sleep 3
			( find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/s' || pgrep -f 'agsbx/s' >/dev/null 2>&1 ) && _sb_up=1
		fi
	fi
	if [ "$_xr_need" = 1 ] && [ "$_xr_up" = 0 ]; then
		if pidof systemd >/dev/null 2>&1 && systemctl is-failed xr >/dev/null 2>&1; then
			echo "WARNING: systemd 启动 xray 失败，尝试 nohup 直接启动..."
			systemctl reset-failed xr >/dev/null 2>&1
			nohup "$HOME/agsbx/xray" run -c "$HOME/agsbx/xr.json" > "$HOME/agsbx/xray.log" 2>&1 &
			sleep 3
			( find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/x' || pgrep -f 'agsbx/x' >/dev/null 2>&1 ) && _xr_up=1
		fi
	fi
	if [ "$_sb_up" = "$_sb_need" ] && [ "$_xr_up" = "$_xr_need" ]; then
[ -f ~/.bashrc ] || touch ~/.bashrc
sed -i '/agsbx/d' ~/.bashrc
SCRIPT_PATH="$HOME/bin/agsbx"
mkdir -p "$HOME/bin"
(command -v curl >/dev/null 2>&1 && curl -sL "$agsbxurl" -o "$SCRIPT_PATH") || (command -v wget >/dev/null 2>&1 && wget -qO "$SCRIPT_PATH" "$agsbxurl")
chmod +x "$SCRIPT_PATH"
# 添加PATH到多个位置，确保不同shell环境都能找到
sed -i '/export PATH="\$HOME\/bin:\$PATH"/d' ~/.bashrc
echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
# Alpine默认使用ash，需要添加到~/.profile
if [ -f "$HOME/.profile" ]; then
  sed -i '/export PATH="\$HOME\/bin:\$PATH"/d' "$HOME/.profile"
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.profile"
else
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.profile"
fi
# 尝试添加到全局profile（如果存在且有权限）
if [ -d /etc/profile.d ] && [ "$(id -u)" -eq 0 ]; then
  echo 'export PATH="$HOME/bin:$PATH"' > /etc/profile.d/agsbx.sh
fi
grep -qxF 'source ~/.bashrc' ~/.bash_profile 2>/dev/null || echo 'source ~/.bashrc' >> ~/.bash_profile
. ~/.bashrc 2>/dev/null
. ~/.profile 2>/dev/null
crontab -l > /tmp/crontab.tmp 2>/dev/null
if ! pidof systemd >/dev/null 2>&1 && ! command -v rc-service >/dev/null 2>&1; then
sed -i '/agsbx\/sing-box/d' /tmp/crontab.tmp
sed -i '/agsbx\/xray/d' /tmp/crontab.tmp
if find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/s' || pgrep -f 'agsbx/s' >/dev/null 2>&1 ; then
echo '@reboot sleep 10 && /bin/sh -c "nohup $HOME/agsbx/sing-box run -c $HOME/agsbx/sb.json >/dev/null 2>&1 &"' >> /tmp/crontab.tmp
fi
if find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/x' || pgrep -f 'agsbx/x' >/dev/null 2>&1 ; then
echo '@reboot sleep 10 && /bin/sh -c "nohup $HOME/agsbx/xray run -c $HOME/agsbx/xr.json >/dev/null 2>&1 &"' >> /tmp/crontab.tmp
fi
fi
sed -i '/agsbx\/cloudflared/d' /tmp/crontab.tmp
if [ -n "$argo" ] && [ -n "$vmag" ]; then
if [ -n "${ARGO_DOMAIN}" ] && [ -n "${ARGO_AUTH}" ]; then
if ! pidof systemd >/dev/null 2>&1 && ! command -v rc-service >/dev/null 2>&1; then
echo '@reboot sleep 10 && /bin/sh -c "nohup $HOME/agsbx/cloudflared tunnel $(cat $HOME/agsbx/argoproto.log 2>/dev/null) --no-autoupdate --edge-ip-version auto run --token $(cat $HOME/agsbx/sbargotoken.log 2>/dev/null) >/dev/null 2>&1 &"' >> /tmp/crontab.tmp
fi
else
echo '@reboot sleep 10 && /bin/sh -c "nohup $HOME/agsbx/cloudflared tunnel $(cat $HOME/agsbx/argoproto.log 2>/dev/null) --url http://localhost:$(cat $HOME/agsbx/argoport.log) --edge-ip-version auto --no-autoupdate > $HOME/agsbx/argo.log 2>&1 &"' >> /tmp/crontab.tmp
fi
fi
crontab /tmp/crontab.tmp >/dev/null 2>&1
rm /tmp/crontab.tmp
insnezha
echo "Argosbx脚本进程启动成功，安装完毕" && sleep 2
else
	echo "ERROR: Argosbx script process not started, installation failed"
	# Output diagnostic info
	if [ -f "$HOME/agsbx/sb.json" ]; then
		echo "sb.json last 20 lines:"
		tail -20 "$HOME/agsbx/sb.json" 2>/dev/null
	fi
	if [ -f "$HOME/agsbx/xr.json" ]; then
		echo "xr.json last 20 lines:"
		tail -20 "$HOME/agsbx/xr.json" 2>/dev/null
	fi
	if [ -f "$HOME/agsbx/sing-box.log" ]; then
		echo "===== sing-box 运行日志 (崩溃原因看这里) ====="
		tail -25 "$HOME/agsbx/sing-box.log" 2>/dev/null
		if grep -q 'operation not supported' "$HOME/agsbx/sing-box.log" 2>/dev/null; then
			echo "⚠️ 该容器不支持 sing-box 网络监控(netlink route 订阅)，故 sing-box 专属协议无法运行。"
			echo "   解决：请勿启用 hypt/tupt/anpt/arpt/sspt；改用 vless-ws/vmess-ws/reality/socks5 等 Xray 协议(不受影响)。"
		fi
	fi
	if [ -f "$HOME/agsbx/xray.log" ]; then
		echo "===== xray 运行日志 (崩溃原因看这里) ====="
		tail -25 "$HOME/agsbx/xray.log" 2>/dev/null
	fi
	if pidof systemd >/dev/null 2>&1; then
		systemctl is-failed sb >/dev/null 2>&1 && echo "sing-box service status:" && systemctl status sb --no-pager 2>&1 | tail -10
		systemctl is-failed xr >/dev/null 2>&1 && echo "xray service status:" && systemctl status xr --no-pager 2>&1 | tail -10
	fi
	exit
	fi
}

if [ -n "$hyjpt" ] && [ -n "$hyp" ]; then
    echo
    echo "设置Hysteria2协议的跳跃端口：$hyjpt"
    iptables -t nat -F PREROUTING >/dev/null 2>&1
    ip6tables -t nat -F PREROUTING >/dev/null 2>&1
    hyport=$(cat "$HOME/agsbx/port_hy2" 2>/dev/null)
    for port in $hyjpt; do
        iptables -t nat -A PREROUTING -p udp --dport "$port" -j DNAT --to-destination :$hyport
        ip6tables -t nat -A PREROUTING -p udp --dport "$port" -j DNAT --to-destination :$hyport
    done
    netfilter-persistent save >/dev/null 2>&1
    if command -v rc-service >/dev/null 2>&1; then
        rc-update show default 2>/dev/null | grep -q 'iptables' || rc-update add iptables >/dev/null 2>&1
        rc-update show default 2>/dev/null | grep -q 'ip6tables' || rc-update add ip6tables >/dev/null 2>&1
        rc-service iptables save >/dev/null 2>&1
        rc-service ip6tables save >/dev/null 2>&1
    fi
fi

# =============================================================================
# SECTION 11.1: cip - 节点信息输出与命名规范化
# =============================================================================
cip(){
echo "=========当前三大内核运行状态========="
procs=$(find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null)
if echo "$procs" | grep -Eq 'agsbx/s' || pgrep -f 'agsbx/s' >/dev/null 2>&1; then
echo "Sing-box (版本V$("$HOME/agsbx/sing-box" version 2>/dev/null | awk '/version/{print $NF}'))：运行中"
else
echo "Sing-box：未启用"
fi
if echo "$procs" | grep -Eq 'agsbx/x' || pgrep -f 'agsbx/x' >/dev/null 2>&1; then
echo "Xray (版本V$("$HOME/agsbx/xray" version 2>/dev/null | awk '/^Xray/{print $2}'))：运行中"
else
echo "Xray：未启用"
fi
if echo "$procs" | grep -Eq 'agsbx/c' || pgrep -f 'agsbx/c' >/dev/null 2>&1; then
echo "Argo (版本V$("$HOME/agsbx/cloudflared" version 2>/dev/null | awk '{print $3}'))：运行中"
else
echo "Argo：未启用"
fi
if pgrep -f 'nezha-agent' >/dev/null 2>&1; then
  echo "哪吒探针：运行中"
else
  echo "哪吒探针：未启用"
fi
}

# =============================================================================
# SECTION 11.2: node_output - 节点链接生成与输出
# =============================================================================
node_output(){
echo
sleep 2
if [ "$ippz" = "4" ]; then
if [ -z "$v4" ]; then
ipbest
else
server_ip="$v4"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
fi
elif [ "$ippz" = "6" ]; then
if [ -z "$v6" ]; then
ipbest6
else
server_ip="[$v6]"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
fi
else
ipbest
fi
# =============================================================================
# SECTION 11.3: ipchange - IP信息显示函数
# 功能:
#   - 显示VPS本地IPv4/IPv6地址
#   - 显示服务器地区
#   - 检测WARP IP
#   - 保存server_ip到日志文件
# =============================================================================
ipchange(){
v4v6
if [ -z "$v4" ]; then
vps_ipv4='无IPV4'
vps_ipv6="$v6"
location="$v6dq"
elif [ -n "$v4" ] && [ -n "$v6" ]; then
vps_ipv4="$v4"
vps_ipv6="$v6"
location="$v4dq"
else
vps_ipv4="$v4"
vps_ipv6='无IPV6'
location="$v4dq"
fi
if echo "$v6" | grep -q '^2a09'; then
w6="【WARP】"
fi
if echo "$v4" | grep -q '^104.28'; then
w4="【WARP】"
fi
echo
echo "=========当前服务器本地IP情况========="
echo "本地IPV4地址：$vps_ipv4 $w4"
echo "本地IPV6地址：$vps_ipv6 $w6"
echo "服务器地区：$location"
echo
sleep 2
if [ "$ippz" = "4" ]; then
if [ -z "$v4" ]; then
ipbest
else
server_ip="$v4"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
fi
elif [ "$ippz" = "6" ]; then
if [ -z "$v6" ]; then
ipbest6
else
server_ip="[$v6]"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
fi
else
ipbest
fi
}

cfip() { echo $((RANDOM % 13 + 1)); }
ipchange
rm -rf "$HOME/agsbx/jh.txt"
uuid=$(cat "$HOME/agsbx/uuid")
server_ip=$(cat "$HOME/agsbx/server_ip.log")
[ -n "$nodeaddr" ] && server_ip="$nodeaddr"
sxname=$(cat "$HOME/agsbx/name" 2>/dev/null | sed 's/-/_/g')
[ -n "$sxname" ] && sxname="${sxname}_"
xvvmcdnym=$(cat "$HOME/agsbx/cdnym" 2>/dev/null)

# 获取国家代码
country=$(curl -sm5 ip-api.com/json/?fields=countryCode 2>/dev/null | sed 's/[{}"]//g; s/countryCode://g')
[ -z "$country" ] && country=""

# 优先使用用户指定的argoip，否则自动获取Argo域名作为备用IP
preferred_ips=""
if [ -n "$argoip" ]; then
  preferred_ips=$(echo "$argoip" | tr ';' ' ' | tr ',' ' ')
else
  _argo_domain=$(cat $HOME/agsbx/sbargoym.log 2>/dev/null || grep -a trycloudflare.com $HOME/agsbx/argo.log 2>/dev/null | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')
  if [ -n "$_argo_domain" ]; then
    resolved_ip=$(getent ahosts "$_argo_domain" 2>/dev/null | grep STREAM | head -1 | awk '{print $1}')
    [ -z "$resolved_ip" ] && resolved_ip=$(nslookup "$_argo_domain" 2>/dev/null | grep Address | tail -1 | awk '{print $2}')
    [ -n "$resolved_ip" ] && preferred_ips="$resolved_ip"
  fi
fi
[ -z "$preferred_ips" ] && preferred_ips="104.28.$(cfip).1"
ip_count=$(echo "$preferred_ips" | wc -w)

echo "*********************************************************"

ym_vl_re=$(cat "$HOME/agsbx/ym_vl_re" 2>/dev/null)
if [ -e "$HOME/agsbx/xray" ]; then
private_key_x=$(cat "$HOME/agsbx/xrk/private_key" 2>/dev/null)
public_key_x=$(cat "$HOME/agsbx/xrk/public_key" 2>/dev/null)
short_id_x=$(cat "$HOME/agsbx/xrk/short_id" 2>/dev/null)
dekey=$(cat "$HOME/agsbx/xrk/dekey" 2>/dev/null)
enkey=$(cat "$HOME/agsbx/xrk/enkey" 2>/dev/null)
fi
if [ -e "$HOME/agsbx/sing-box" ]; then
private_key_s=$(cat "$HOME/agsbx/sbk/private_key" 2>/dev/null)
public_key_s=$(cat "$HOME/agsbx/sbk/public_key" 2>/dev/null)
short_id_s=$(cat "$HOME/agsbx/sbk/short_id" 2>/dev/null)
sskey=$(cat "$HOME/agsbx/sskey" 2>/dev/null)
fi

# Vless-xhttp-reality with ENC
if grep xhttp-reality "$HOME/agsbx/xr.json" >/dev/null 2>&1; then
echo "💣【 Vless-xhttp-reality 】节点信息如下："
port_xh=$(cat "$HOME/agsbx/port_xh")
display_port_xh="${port_xh_ext:-${port_xh}}"
if [ -n "$port_xh_enc" ]; then
vl_xh_link="vless://$uuid@$server_ip:$display_port_xh?encryption=$enkey&security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_x&sid=$short_id_x&type=xhttp&path=/xhttp&mode=auto#${sxname}${country}_vl_xhttp_reality_$hostname"
else
vl_xh_link="vless://$uuid@$server_ip:$display_port_xh?encryption=none&security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_x&sid=$short_id_x&type=xhttp&path=/xhttp&mode=auto#${sxname}${country}_vl_xhttp_reality_$hostname"
fi
echo "$vl_xh_link" >> "$HOME/agsbx/jh.txt"
echo "$vl_xh_link"
echo
fi

# Vless-xhttp with ENC
if grep vless-xhttp "$HOME/agsbx/xr.json" >/dev/null 2>&1; then
echo "💣【 Vless-xhttp 】节点信息如下："
port_vx=$(cat "$HOME/agsbx/port_vx")
display_port_vx="${port_vx_ext:-${port_vx}}"
if [ -n "$port_vx_enc" ]; then
vl_vx_link="vless://$uuid@$server_ip:$display_port_vx?encryption=$enkey&type=xhttp&path=/xhttp&mode=auto#${sxname}${country}_vl_xhttp_$hostname"
else
vl_vx_link="vless://$uuid@$server_ip:$display_port_vx?encryption=none&type=xhttp&path=/xhttp&mode=auto#${sxname}${country}_vl_xhttp_$hostname"
fi
echo "$vl_vx_link" >> "$HOME/agsbx/jh.txt"
echo "$vl_vx_link"
echo
if [ -f "$HOME/agsbx/cdnym" ]; then
echo "💣【 Vless-xhttp-cdn 】节点信息如下："
echo "注：可自行更换优选IP域名，如是回源端口需手动修改443或者80系端口"
idx=1
for ip in $preferred_ips; do
  ip_suffix=""
  [ "$ip_count" -gt 1 ] && ip_suffix="-$idx"
  if [ -n "$port_vx_enc" ]; then
vl_vx_cdn_link="vless://$uuid@$ip:$display_port_vx?encryption=$enkey&type=xhttp&host=$xvvmcdnym&path=/xhttp&mode=auto#${sxname}${country}_vl_xhttp_cdn_${hostname}${ip_suffix}"
else
vl_vx_cdn_link="vless://$uuid@$ip:$display_port_vx?encryption=none&type=xhttp&host=$xvvmcdnym&path=/xhttp&mode=auto#${sxname}${country}_vl_xhttp_cdn_${hostname}${ip_suffix}"
fi
  echo "$vl_vx_cdn_link" >> "$HOME/agsbx/jh.txt"
  echo "$vl_vx_cdn_link"
  idx=$((idx+1))
done
echo
fi
fi

# Vless-ws with ENC
if grep vless-ws "$HOME/agsbx/xr.json" >/dev/null 2>&1 || grep vless-ws-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Vless-ws 】节点信息如下："
port_vw=$(cat "$HOME/agsbx/port_vw")
display_port_vw="${port_vw_ext:-${port_vw}}"
if [ -n "$port_vw_enc" ] || [ "$vwpt_enc" = "y" ]; then
en_vw="$enkey"
else
en_vw="none"
fi
vl_vw_link="vless://$uuid@$server_ip:$display_port_vw?encryption=$en_vw&type=ws&path=%2F${uuid}-vw#${sxname}${country}_vl_ws_$hostname"
echo "$vl_vw_link" >> "$HOME/agsbx/jh.txt"
echo "$vl_vw_link"
echo
if [ -f "$HOME/agsbx/cdnym" ]; then
echo "💣【 Vless-ws-cdn 】节点信息如下："
echo "注：可自行更换优选IP域名，如是回源端口需手动修改443或者80系端口"
idx=1
for ip in $preferred_ips; do
  ip_suffix=""
  [ "$ip_count" -gt 1 ] && ip_suffix="-$idx"
  if [ -n "$port_vw_enc" ] || [ "$vwpt_enc" = "y" ]; then
vl_vw_cdn_link="vless://$uuid@$ip:$display_port_vw?encryption=$en_vw&type=ws&host=$xvvmcdnym&path=%2F${uuid}-vw#${sxname}${country}_vl_ws_cdn_${hostname}${ip_suffix}"
else
vl_vw_cdn_link="vless://$uuid@$ip:$display_port_vw?encryption=none&type=ws&host=$xvvmcdnym&path=%2F${uuid}-vw#${sxname}${country}_vl_ws_cdn_${hostname}${ip_suffix}"
fi
  echo "$vl_vw_cdn_link" >> "$HOME/agsbx/jh.txt"
  echo "$vl_vw_cdn_link"
  idx=$((idx+1))
done
echo
fi
fi

# Vless-tcp-reality-vision
if grep reality-vision "$HOME/agsbx/xr.json" >/dev/null 2>&1; then
echo "💣【 Vless-tcp-reality-vision 】节点信息如下："
port_vl_re=$(cat "$HOME/agsbx/port_vl_re")
display_port_vl_re="${port_vl_re_ext:-${port_vl_re}}"
if [ -n "$port_vl_re_enc" ]; then
vl_link="vless://$uuid@$server_ip:$display_port_vl_re?encryption=$enkey&security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_x&sid=$short_id_x&type=tcp&headerType=none#${sxname}${country}_vl_reality_vision_$hostname"
else
vl_link="vless://$uuid@$server_ip:$display_port_vl_re?encryption=none&security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_x&sid=$short_id_x&type=tcp&headerType=none#${sxname}${country}_vl_reality_vision_$hostname"
fi
echo "$vl_link" >> "$HOME/agsbx/jh.txt"
echo "$vl_link"
echo
fi

# Shadowsocks-2022
if grep ss-2022 "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Shadowsocks-2022 】节点信息如下："
port_ss=$(cat "$HOME/agsbx/port_ss")
	display_port_ss="${port_ss_ext:-${port_ss}}"
	ss_link="ss://$(echo -n "2022-blake3-aes-128-gcm:$sskey@$server_ip:$display_port_ss" | base64 -w0)#${sxname}Shadowsocks-2022_$hostname"
echo "$ss_link" >> "$HOME/agsbx/jh.txt"
echo "$ss_link"
echo
fi

# Vmess-ws
if grep vmess-xr "$HOME/agsbx/xr.json" >/dev/null 2>&1 || grep vmess-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Vmess-ws 】节点信息如下："
port_vm_ws=$(cat "$HOME/agsbx/port_vm_ws")
display_port_vm="${port_vm_ws_ext:-${port_vm_ws}}"
vm_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}${country}_vm_ws_$hostname\", \"add\": \"$server_ip\", \"port\": \"$display_port_vm\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"www.bing.com\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vm_link" >> "$HOME/agsbx/jh.txt"
echo "$vm_link"
echo
if [ -f "$HOME/agsbx/cdnym" ]; then
echo "💣【 Vmess-ws-cdn 】节点信息如下："
echo "注：可自行更换优选IP域名，如是回源端口需手动修改443或者80系端口"
idx=1
for ip in $preferred_ips; do
  ip_suffix=""
  [ "$ip_count" -gt 1 ] && ip_suffix="-$idx"
  vm_cdn_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}${country}_vm_ws_cdn_${hostname}${ip_suffix}\", \"add\": \"$ip\", \"port\": \"$display_port_vm\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$xvvmcdnym\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
  echo "$vm_cdn_link" >> "$HOME/agsbx/jh.txt"
  echo "$vm_cdn_link"
  idx=$((idx+1))
done
echo
fi
fi

# AnyTLS
if grep anytls_sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 AnyTLS 】节点信息如下："
port_an=$(cat "$HOME/agsbx/port_an")
display_port_an="${port_an_ext:-${port_an}}"
an_link="anytls://$uuid@$server_ip:$display_port_an?insecure=1&allowInsecure=1#${sxname}${country}_anytls_$hostname"
echo "$an_link" >> "$HOME/agsbx/jh.txt"
echo "$an_link"
echo
fi

# Any-Reality
if grep anyreality-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Any-Reality 】节点信息如下："
port_ar=$(cat "$HOME/agsbx/port_ar")
display_port_ar="${port_ar_ext:-${port_ar}}"
ar_link="anytls://$uuid@$server_ip:$display_port_ar?security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_s&sid=$short_id_s&type=tcp&headerType=none#${sxname}${country}_any_reality_$hostname"
echo "$ar_link" >> "$HOME/agsbx/jh.txt"
echo "$ar_link"
echo
fi

# Hysteria2
if grep hy2_sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
    echo "💣【 Hysteria2 】节点信息如下："
    port_hy2=$(cat "$HOME/agsbx/port_hy2")
    display_port_hy2="${port_hy2_ext:-${port_hy2}}"
    # 回读 iptables 提取跳跃端口（使用 --line 定位 $8 列，避免 $NF 拿到 to: 字段）
    hy2_ports=$(iptables -t nat -nL 2>/dev/null | grep -w "$port_hy2" | sed 's/.*dpts:\([0-9:-]*\).*/\1/; s/.*dpt:\([0-9]*\).*/\1/' | grep -E '^[0-9]' | tr '\n' ',' | sed 's/,$//')
    if [ -n "$hy2_ports" ] && [ -n "$hyjpt" ]; then
        echo "Hysteria2跳跃端口已开启：$hy2_ports"
        cmhy2pt=$(echo "$hy2_ports" | tr ':' '-')
        hyps="&mport=$cmhy2pt"
    else
        hyps=""
    fi
    hy2_link="hysteria2://$uuid@$server_ip:$display_port_hy2?security=tls&alpn=h3&insecure=1${hyps}&sni=www.bing.com#${sxname}${country}_hy2_$hostname"
    echo "$hy2_link" >> "$HOME/agsbx/jh.txt"
    echo "$hy2_link"
    echo
fi

# Tuic
if grep tuic5-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Tuic 】节点信息如下："
port_tu=$(cat "$HOME/agsbx/port_tu")
display_port_tu="${port_tu_ext:-${port_tu}}"
tuic5_link="tuic://$uuid:$uuid@$server_ip:$display_port_tu?congestion_control=bbr&udp_relay_mode=native&alpn=h3&sni=www.bing.com&allow_insecure=1&allowInsecure=1#${sxname}${country}_tuic_$hostname"
echo "$tuic5_link" >> "$HOME/agsbx/jh.txt"
echo "$tuic5_link"
echo
fi

# Socks5
if grep socks5-xr "$HOME/agsbx/xr.json" >/dev/null 2>&1 || grep socks5-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Socks5 】客户端信息如下："
port_so=$(cat "$HOME/agsbx/port_so")
display_port_so="${port_so_ext:-${port_so}}"
echo "请配合其他应用内置代理使用，勿做节点直接使用"
echo "客户端地址：$server_ip"
echo "客户端端口：$display_port_so"
echo "客户端用户名：$uuid"
echo "客户端密码：$uuid"
echo
fi

# Argo tunnel output
argodomain=$(cat "$HOME/agsbx/sbargoym.log" 2>/dev/null)
[ -z "$argodomain" ] && argodomain=$(grep -a trycloudflare.com "$HOME/agsbx/argo.log" 2>/dev/null | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')

if [ -n "$argodomain" ]; then
vlvm=$(cat $HOME/agsbx/vlvm 2>/dev/null)
if [ -n "$argoip" ]; then
  argo_addrs="$preferred_ips"
  argo_ip_count=$(echo "$argo_addrs" | wc -w)
else
  argo_addrs="$argodomain"
  argo_ip_count=1
fi

sbtk=$(cat "$HOME/agsbx/sbargotoken.log" 2>/dev/null)
if [ -n "$sbtk" ]; then
nametn="Argo固定隧道token：$sbtk"
fi
echo "---------------------------------------------------------"
echo "Argo隧道端口正在使用${vlvm}-ws主协议端口：$(cat $HOME/agsbx/argoport.log 2>/dev/null)"
echo "Argo域名：$argodomain"
echo "$nametn"
echo

if [ "$vlvm" = "Vmess" ]; then
echo "1、💣443端口的Vmess-ws-tls-argo节点"
idx=1
for ip in $argo_addrs; do
  ip_suffix=""
  [ "$argo_ip_count" -gt 1 ] && ip_suffix="-$idx"
  vmatls_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-tls-argo-$hostname-443${ip_suffix}\", \"add\": \"$ip\", \"port\": \"443\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"tls\", \"sni\": \"$argodomain\", \"alpn\": \"\", \"fp\": \"chrome\"}" | base64 -w0)"
  echo "$vmatls_link" >> "$HOME/agsbx/jh.txt"
  echo "$vmatls_link"
  idx=$((idx+1))
done
echo
echo "2、💣80端口的Vmess-ws-argo节点"
idx=1
for ip in $argo_addrs; do
  ip_suffix=""
  [ "$argo_ip_count" -gt 1 ] && ip_suffix="-$idx"
  vma_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-argo-$hostname-80${ip_suffix}\", \"add\": \"$ip\", \"port\": \"80\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
  echo "$vma_link" >> "$HOME/agsbx/jh.txt"
  echo "$vma_link"
  idx=$((idx+1))
done

elif [ "$vlvm" = "Vless" ]; then
if [ -n "$port_vw_enc" ] || [ "$vwpt_enc" = "y" ]; then
en_vw="$enkey"
else
en_vw="none"
fi
echo "1、💣443端口的Vless-ws-tls-argo节点"
idx=1
for ip in $argo_addrs; do
  ip_suffix=""
  [ "$argo_ip_count" -gt 1 ] && ip_suffix="-$idx"
  vwatls_link="vless://$uuid@$ip:443?encryption=$en_vw&type=ws&host=$argodomain&path=%2F${uuid}-vw&security=tls&sni=$argodomain&fp=chrome&insecure=0&allowInsecure=0#${sxname}${country}_vl_ws_tls_argo_${hostname}${ip_suffix}"
  echo "$vwatls_link" >> "$HOME/agsbx/jh.txt"
  echo "$vwatls_link"
  idx=$((idx+1))
done
echo
echo "2、💣80端口的Vless-ws-argo节点"
idx=1
for ip in $argo_addrs; do
  ip_suffix=""
  [ "$argo_ip_count" -gt 1 ] && ip_suffix="-$idx"
  vwa_link="vless://$uuid@$ip:80?encryption=$en_vw&type=ws&host=$argodomain&path=%2F${uuid}-vw&security=none#${sxname}${country}_vl_ws_argo_${hostname}${ip_suffix}"
  echo "$vwa_link" >> "$HOME/agsbx/jh.txt"
  echo "$vwa_link"
  idx=$((idx+1))
done
fi
fi
echo "---------------------------------------------------------"
echo "聚合节点信息，请进入 $HOME/agsbx/jh.txt 文件目录查看或者运行 cat $HOME/agsbx/jh.txt 查看"
echo "========================================================="
}
# =============================================================================
showmode(){
echo "主脚本：bash <(curl -Ls https://raw.githubusercontent.com/zv201413/argosbx-new/main-new/argosbx.sh) 各种变量"
echo "显示节点信息命令：agsbx list"
echo "重置变量组命令：自定义各种协议变量组 agsbx rep"
echo "更新脚本命令：原已安装的自定义各种协议变量组 主脚本 rep"
echo "更新Xray或Singbox内核命令：agsbx upx 或 agsbx ups"
echo "重启脚本命令：agsbx res"
echo "卸载脚本命令：agsbx del"
echo "双栈VPS显示IPv4/IPv6节点配置命令：ippz=4 或 ippz=6 agsbx list"
echo "---------------------------------------------------------"
echo
}

# SECTION 11: cip - 节点信息输出与命名规范化
# 功能:
#   - 统一命名规范: 实现 [prefix]_[country]_[protocol]_[hostname] 格式输出
#   - 动态地址替换: 
#     * argoip: 全局替换 Argo/CDN 节点的优选 IP
#     * nodeaddr: 全局替换所有直连节点的服务器 IP
#   - 地理位置感知: 自动获取出口国家代码并注入节点 Tag
#   - 数据持久化: 汇总所有链接到 $HOME/agsbx/jh.txt
# =============================================================================
# SECTION 9.1: cleandel - 卸载清理函数
# 功能:
#   - 杀掉 agsbx 残留进程
#   - 清理 crontab 定时任务
#   - 删除 systemd/openrc 服务
#   - 清理 bashrc 环境变量
# =============================================================================
cleandel(){
for P in /proc/[0-9]*; do if [ -L "$P/exe" ]; then TARGET=$(readlink -f "$P/exe" 2>/dev/null); if echo "$TARGET" | grep -qE '/agsbx/c|/agsbx/s|/agsbx/x'; then PID=$(basename "$P"); kill "$PID" 2>/dev/null; fi; fi; done
kill -15 $(pgrep -f 'agsbx/s' 2>/dev/null) $(pgrep -f 'agsbx/c' 2>/dev/null) $(pgrep -f 'agsbx/x' 2>/dev/null) >/dev/null 2>&1
sed -i '/agsbx/d' ~/.bashrc 2>/dev/null
sed -i '/export PATH="\$HOME\/bin:\$PATH"/d' ~/.bashrc 2>/dev/null
. ~/.bashrc 2>/dev/null
crontab -l > /tmp/crontab.tmp 2>/dev/null
sed -i '/agsbx\/sing-box/d' /tmp/crontab.tmp 2>/dev/null
sed -i '/agsbx\/xray/d' /tmp/crontab.tmp 2>/dev/null
sed -i '/agsbx\/cloudflared/d' /tmp/crontab.tmp 2>/dev/null
sed -i '/nezha-agent/d' /tmp/crontab.tmp 2>/dev/null
crontab /tmp/crontab.tmp >/dev/null 2>&1
rm /tmp/crontab.tmp 2>/dev/null
rm -rf "$HOME/bin/agsbx" 2>/dev/null
kill -15 $(pgrep -f 'nezha-agent' 2>/dev/null) >/dev/null 2>&1
rm -rf "$HOME/agsbx/nezha" 2>/dev/null
if pidof systemd >/dev/null 2>&1; then
for svc in xr sb argo; do
systemctl stop "$svc" >/dev/null 2>&1
systemctl disable "$svc" >/dev/null 2>&1
done
rm -rf /etc/systemd/system/xr.service /etc/systemd/system/sb.service /etc/systemd/system/argo.service 2>/dev/null
elif command -v rc-service >/dev/null 2>&1; then
for svc in sing-box xray argo; do
rc-service "$svc" stop >/dev/null 2>&1
rc-update del "$svc" default >/dev/null 2>&1
done
rm -rf /etc/init.d/sing-box /etc/init.d/xray /etc/init.d/argo 2>/dev/null
fi
}

# =============================================================================
# SECTION 10.5: xrestart/sbrestart - 内核重启函数
# 功能:
#   - xrestart(): 重启Xray内核
#   - sbrestart(): 重启Sing-box内核
#   - 支持systemd/openrc/直接nohup三种启动方式
# =============================================================================
xrestart(){
kill -15 $(pgrep -f 'agsbx/x' 2>/dev/null) >/dev/null 2>&1
if pidof systemd >/dev/null 2>&1; then
systemctl restart xr >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1; then
rc-service xray restart >/dev/null 2>&1
else
nohup "$HOME/agsbx/xray" run -c "$HOME/agsbx/xr.json" >/dev/null 2>&1 &
fi
}
sbrestart(){
kill -15 $(pgrep -f 'agsbx/s' 2>/dev/null) >/dev/null 2>&1
if pidof systemd >/dev/null 2>&1; then
systemctl restart sb >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1; then
rc-service sing-box restart >/dev/null 2>&1
else
nohup "$HOME/agsbx/sing-box" run -c "$HOME/agsbx/sb.json" >/dev/null 2>&1 &
fi
}

# =============================================================================
# SECTION 10.6: push_gist - 自动化节点订阅推送
# 功能:
#   - 读取 $HOME/agsbx/gh_token 和 $HOME/agsbx/gh_gist_id
#   - 将节点信息推送到GitHub Gist
# =============================================================================
push_gist(){
gh_token=$(cat "$HOME/agsbx/gh_token" 2>/dev/null)
gh_gist_id=$(cat "$HOME/agsbx/gh_gist_id" 2>/dev/null)
if [ -z "$gh_token" ]; then
return 1
fi
node_content=$(cat "$HOME/agsbx/jh.txt" 2>/dev/null)
if [ -z "$node_content" ]; then
return 1
fi
# JSON 内容转义处理 (处理换行和引号)
escaped_content=$(echo "$node_content" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')

# 生成详细的文件名: [prefix]_[country]_[protocol]_[hostname].txt
gist_prefix=$(cat "$HOME/agsbx/name" 2>/dev/null | sed 's/-/_/g')
[ -z "$gist_prefix" ] && gist_prefix="agsbx"
gist_country=$(curl -sm5 ip-api.com/json/?fields=countryCode 2>/dev/null | sed 's/[{}"]//g; s/countryCode://g')
[ -z "$gist_country" ] && gist_country="XX"
# 检测主要内核作为协议标识
if [ -e "$HOME/agsbx/sing-box" ] && [ -e "$HOME/agsbx/xray" ]; then gist_proto="dual"; elif [ -e "$HOME/agsbx/sing-box" ]; then gist_proto="sb"; else gist_proto="xr"; fi
gist_filename="${gist_prefix}_${gist_country}_${gist_proto}_${hostname}.txt"

if [ -n "$gh_gist_id" ]; then
response=$(curl -s -X PATCH "https://api.github.com/gists/$gh_gist_id" \
-H "Authorization: token $gh_token" \
-H "Content-Type: application/json" \
-d "{\"description\": \"Argosbx Nodes\",\"public\": false,\"files\": {\"$gist_filename\": {\"content\": \"$escaped_content\"}}}")
else
response=$(curl -s -X POST "https://api.github.com/gists" \
-H "Authorization: token $gh_token" \
-H "Content-Type: application/json" \
-d "{\"description\": \"Argosbx Nodes\",\"public\": false,\"files\": {\"$gist_filename\": {\"content\": \"$escaped_content\"}}}")
fi

if echo "$response" | grep -q '"id":'; then
  gist_id=$(echo "$response" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
  gh_user=$(echo "$response" | grep -o '"login": "[^"]*"' | head -1 | cut -d'"' -f4)
  [ -z "$gh_gist_id" ] && echo "$gist_id" > "$HOME/agsbx/gh_gist_id"
  # 按照用户指定的格式手动构造订阅链接
  raw_url="https://gist.github.com/${gh_user}/${gist_id}/raw/${gist_filename}"
  echo "Gist 推送成功"
  echo "订阅链接 (Raw): $raw_url"
else
  echo "Gist 推送失败，请检查 Token 权限或网络连接"
fi
}

# =============================================================================
# SECTION 10: 命令行参数路由处理
# 使用: ./argosbx.sh [del|rep|list|upx|ups|res|help]
# =============================================================================
if [ "$1" = "del" ]; then
cleandel
rm -rf sbx_update "$HOME/agsbx" "$HOME/agsb"
echo "卸载完成"
echo "欢迎下次继续使用：https://zv201413.github.io/argosbx-new" && sleep 2
echo
exit
elif [ "$1" = "help" ] || [ "$1" = "-h" ]; then
showmode
exit
elif [ "$1" = "rep" ]; then
cleandel
rm -rf "$HOME/agsbx"/{sb.json,xr.json,sbargoym.log,sbargotoken.log,argo.log,argoport.log,cdnym,name}
echo "Argosbx重置协议完成，开始更新相关协议变量……" && sleep 2
echo
elif [ "$1" = "list" ]; then
cip
node_output
gh_token=$(cat "$HOME/agsbx/gh_token" 2>/dev/null)
gh_gist_id=$(cat "$HOME/agsbx/gh_gist_id" 2>/dev/null)
[ -n "$gh_token" ] && push_gist
exit
elif [ "$1" = "upx" ]; then
for P in /proc/[0-9]*; do [ -L "$P/exe" ] || continue; TARGET=$(readlink -f "$P/exe" 2>/dev/null) || continue; case "$TARGET" in *"/agsbx/x"*) kill "$(basename "$P")" 2>/dev/null ;; esac; done
kill -15 $(pgrep -f 'agsbx/x' 2>/dev/null) >/dev/null 2>&1
upxray && xrestart && echo "Xray内核更新完成" && sleep 2 && cip
exit
elif [ "$1" = "ups" ]; then
for P in /proc/[0-9]*; do [ -L "$P/exe" ] || continue; TARGET=$(readlink -f "$P/exe" 2>/dev/null) || continue; case "$TARGET" in *"/agsbx/s"*) kill "$(basename "$P")" 2>/dev/null ;; esac; done
kill -15 $(pgrep -f 'agsbx/s' 2>/dev/null) >/dev/null 2>&1
upsingbox && sbrestart && echo "Sing-box内核更新完成" && sleep 2 && cip
exit
elif [ "$1" = "res" ]; then
for P in /proc/[0-9]*; do
[ -L "$P/exe" ] || continue
TARGET=$(readlink -f "$P/exe" 2>/dev/null) || continue
case "$TARGET" in
*"/agsbx/s"*)
kill "$(basename "$P")" 2>/dev/null
sbrestart
;;
*"/agsbx/x"*)
kill "$(basename "$P")" 2>/dev/null
xrestart
;;
*"/agsbx/c"*)
kill "$(basename "$P")" 2>/dev/null
kill -15 $(pgrep -f 'agsbx/c' 2>/dev/null) >/dev/null 2>&1
if pidof systemd >/dev/null 2>&1; then
systemctl restart argo >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1; then
rc-service argo restart >/dev/null 2>&1
else
if [ -e "$HOME/agsbx/sbargotoken.log" ]; then
if ! pidof systemd >/dev/null 2>&1 && ! command -v rc-service >/dev/null 2>&1; then
nohup $HOME/agsbx/cloudflared tunnel $(cat $HOME/agsbx/argoproto.log 2>/dev/null) --no-autoupdate --edge-ip-version auto run --token $(cat $HOME/agsbx/sbargotoken.log 2>/dev/null) >/dev/null 2>&1 &
fi
else
nohup $HOME/agsbx/cloudflared tunnel $(cat $HOME/agsbx/argoproto.log 2>/dev/null) --url http://localhost:$(cat $HOME/agsbx/argoport.log 2>/dev/null) --edge-ip-version auto --no-autoupdate > $HOME/agsbx/argo.log 2>&1 &
fi
fi
;;
esac
done
sleep 5 && echo "重启完成" && sleep 3 && cip
exit
fi

# =============================================================================
# SECTION 15: 脚本主执行流程 - 首次安装逻辑
# 功能:
#   - 检测DNS配置,必要时添加IPv6 DNS
#   - 判断WARP IP可用性,设置endpoint
#   - 显示系统信息(CPU架构等)
#   - 执行ins()进行完整安装流程
#   - 执行cip()输出节点信息
#   - 已安装时显示状态和快捷方式
# 条件: 无agsbx进程运行时执行
# =============================================================================
if ! find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -Eq 'agsbx/(s|x)' && ! pgrep -f 'agsbx/(s|x)' >/dev/null 2>&1; then
for P in /proc/[0-9]*; do if [ -L "$P/exe" ]; then TARGET=$(readlink -f "$P/exe" 2>/dev/null); if echo "$TARGET" | grep -qE '/agsbx/c|/agsbx/s|/agsbx/x'; then PID=$(basename "$P"); kill "$PID" 2>/dev/null && echo "Killed $PID ($TARGET)" || echo "Could not kill $PID ($TARGET)"; fi; fi; done
kill -15 $(pgrep -f 'agsbx/s' 2>/dev/null) $(pgrep -f 'agsbx/c' 2>/dev/null) $(pgrep -f 'agsbx/x' 2>/dev/null) >/dev/null 2>&1
if [ -z "$( (command -v curl >/dev/null 2>&1 && curl -s4m5 -k "$v46url" 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -4 -qO- --tries=2 "$v46url" 2>/dev/null) )" ]; then
[ "$(id -u)" -eq 0 ] && { printf 'nameserver %s\n' '2a00:1098:2b::1' '2a00:1098:2c::1'; } > /etc/resolv.conf 2>/dev/null
fi
if [ -n "$( (command -v curl >/dev/null 2>&1 && curl -s6m5 -k "$v46url" 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -6 -qO- --tries=2 "$v46url" 2>/dev/null) )" ]; then
sendip="2606:4700:d0::a29f:c001"
xendip="[2606:4700:d0::a29f:c001]"
else
sendip="162.159.192.1"
xendip="162.159.192.1"
fi
echo "VPS系统：$op"
echo "CPU架构：$cpu"
echo "Argosbx脚本未安装，开始安装…………" && sleep 1
if [ -n "$oap" ]; then
setenforce 0 >/dev/null 2>&1
iptables -P INPUT ACCEPT >/dev/null 2>&1
iptables -P FORWARD ACCEPT >/dev/null 2>&1
iptables -P OUTPUT ACCEPT >/dev/null 2>&1
iptables -F >/dev/null 2>&1
netfilter-persistent save >/dev/null 2>&1
echo
echo "iptables执行开放所有端口"
fi
ins
# 保存gh_token和gh_gist_id供快捷命令使用
[ -n "$gh_token" ] && echo "$gh_token" > "$HOME/agsbx/gh_token"
[ -n "$gh_gist_id" ] && echo "$gh_gist_id" > "$HOME/agsbx/gh_gist_id"
cip
node_output
if [ -n "$gh_token" ]; then
  push_gist
fi
showmode
echo
else
echo "Argosbx脚本已安装"
echo
cip
node_output
showmode
echo
exit
fi

