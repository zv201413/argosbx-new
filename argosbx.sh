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
#   - 定义可选隐蔽功能变量(KNOCK/KNOCK_PORT/IDLE_TIMEOUT/STEALTH_NAME/CLASH_API_PORT,默认全关)
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
# ───── 可选功能(默认全关,不传则与原行为一字不差)─────
export KNOCK=${KNOCK:-''}                       # =1 启用「敲门+空闲自关」子系统
export KNOCK_PORT=${KNOCK_PORT:-''}             # 敲门端口(KNOCK=1 且为空时自动分配)
export IDLE_TIMEOUT=${IDLE_TIMEOUT:-'300'}      # 空闲多少秒无连接后关闭代理进程
export STEALTH_NAME=${STEALTH_NAME:-''}         # 进程伪装名(空=不伪装,代理按原名启动)
export CLASH_API_PORT=${CLASH_API_PORT:-'9090'} # sing-box 本地 clash_api 端口(仅 KNOCK 时注入,供活跃检测)
v46url="https://icanhazip.com"
agsbxurl="https://raw.githubusercontent.com/zv201413/argosbx-new/main-new/argosbx.sh"

# =============================================================================
# 工作目录解析(zv修改):支持 AGSBX_DIR 自定义安装目录 + $HOME 不可写时智能回退
#   - 目录名恒以 /agsbx 结尾(全脚本进程检测靠字面 'agsbx/' 路径匹配,不可改名)
#   - 解析为绝对路径(systemd/init.d service 重启后需字面绝对路径)
#   - 优先复用已存在的 agsbx 目录,保证重装/卸载定位到同一处
#   - 智能回退不使用 /tmp(常 noexec,二进制无法执行)
# =============================================================================
export AGSBX_DIR=${AGSBX_DIR:-''}
_agsbx_norm(){ case "$1" in */agsbx) echo "${1%/}";; *) echo "${1%/}/agsbx";; esac; }                 # 规范化为 <父>/agsbx(幂等)
_agsbx_abs(){ case "$1" in /*) echo "$1";; *) ( CDPATH= cd -- "$1" 2>/dev/null && pwd );; esac; }      # 转绝对路径
_agsbx_try(){ [ -z "$1" ] && return 1; _t=$(_agsbx_norm "$1"); mkdir -p "$_t" 2>/dev/null && [ -w "$_t" ] && _agsbx_abs "$_t"; }
_agsbx_resolve(){
	if [ -n "$AGSBX_DIR" ]; then                       # 1) 用户显式指定(填什么都规范化到 .../agsbx)
		_agsbx_try "$AGSBX_DIR" && return 0
		echo "❌ 指定的 AGSBX_DIR=$AGSBX_DIR 无法创建或不可写" >&2; return 1
	fi
	for _c in "$HOME/agsbx" "$PWD/agsbx"; do            # 2) 优先复用已存在且可写的 agsbx(装/卸一致)
		[ -d "$_c" ] && [ -w "$_c" ] && { _agsbx_abs "$_c"; return 0; }
	done
	_agsbx_try "$HOME" && return 0                      # 3) 智能回退:$HOME 不可写则用脚本运行目录
	_agsbx_try "$PWD"  && return 0
	return 1
}
AGSBX=$(_agsbx_resolve) || {
	echo "❌ 未找到可写的安装目录($HOME 与当前目录 $PWD 均不可写)"
	echo "👉 请用一个可写目录重试,例如: AGSBX_DIR=/www bash <(curl -Ls $agsbxurl)"
	exit 1
}
export AGSBX
echo "📁 安装目录:$AGSBX"

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
# OS 兼容性检测: 只支持 Linux(System V ELF), FreeBSD 等 BSD 系无对应二进制
_os=$(uname -s 2>/dev/null)
case "$_os" in
Linux) ;;
FreeBSD|OpenBSD|NetBSD|DragonFly) echo "❌ 不支持 $_os 系统。xray/sing-box/cloudflared 官方仅提供 Linux 二进制，本脚本无法在 BSD 上运行。"; exit 1 ;;
*) ;;
esac
case $(uname -m) in
arm64|aarch64) cpu=arm64;;
amd64|x86_64) cpu=amd64;;
*) echo "目前脚本不支持$(uname -m)架构" && exit
esac
mkdir -p "$AGSBX"
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
    if ! command -v python3 >/dev/null 2>&1; then
        if [ -t 0 ]; then
            echo "======================================"
            echo "⚠️ 检测到缺少 python3，无法精确验证内核路由权限。"
            echo "请选择应对策略："
            echo " 1) 强行安装 Sing-box (默认)"
            echo " 2) 安装 python3 并进行精确检测 "
            echo " 3) 安全降级，切换到 Xray 模式"
            echo "======================================"
            read -r -t 30 -p "请输入选项 [1/2/3] (30秒后自动选1): " user_choice
            case "${user_choice}" in
                2)
                    echo "正在安装 python3..."
                    if command -v apk >/dev/null 2>&1; then apk add python3 >/dev/null 2>&1;
                    elif command -v apt >/dev/null 2>&1; then apt update >/dev/null 2>&1 && apt install python3 -y >/dev/null 2>&1;
                    fi
                    ;;
                3)
                    return 1 ;;
                *)
                    return 0 ;;
            esac
        else
            # 非交互环境默认放行
            return 0
        fi
    fi
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
case "$1" in
    del|list|upx|ups|res|help|-h|rep)
        # 运维指令无需进行环境兼容性检测，直接跳过
        ;;
    *)
        check_netlink_full_support || SB_SUPPORTED=0
        ;;
esac

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
echo "$sxname" > "$AGSBX/name"
echo
echo "所有节点名称前缀：$name"
fi
v4v6
# IPv4-only 兼容：v6 为空时自动降级 ippz/ippref/cloudflared edge-ip-version
CF_IPV="auto"
if [ -z "$v6" ]; then
	CF_IPV="4"
	[ "$ippz" = "6" ] && { echo "⚠️ IPv6 不可用，ippz 将自动回退为 IPv4 优先"; ippz=""; }
	[ "$ippref" = "prefer_ipv6" ] && { echo "⚠️ IPv6 不可用，ippref 将自动回退为 prefer_ipv4"; ippref="prefer_ipv4"; }
fi
echo "$CF_IPV" > "$AGSBX/cf_ipv.txt"
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
echo "$server_ip" > "$AGSBX/server_ip.log"
else
server_ip="$serip"
echo "$server_ip" > "$AGSBX/server_ip.log"
fi
}
ipbest6(){
serip=$( (command -v curl >/dev/null 2>&1 && (curl -s6m5 -k "$v46url" 2>/dev/null || curl -s4m5 -k "$v46url" 2>/dev/null) ) || (command -v wget >/dev/null 2>&1 && (timeout 3 wget -6 -qO- --tries=2 "$v46url" 2>/dev/null || timeout 3 wget -4 -qO- --tries=2 "$v46url" 2>/dev/null) ) )
if echo "$serip" | grep -q ':'; then
server_ip="[$serip]"
echo "$server_ip" > "$AGSBX/server_ip.log"
else
server_ip="$serip"
echo "$server_ip" > "$AGSBX/server_ip.log"
fi
}

# =============================================================================
# SECTION 3: 内核下载与UUID管理
# 功能:
#   - upxray(): 下载Xray内核二进制文件,设置执行权限,显示版本
#   - upsingbox(): 下载Sing-box内核二进制文件,设置执行权限,显示版本
#   - insuuid(): 生成或读取UUID,持久化到$AGSBX/uuid
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
out="$AGSBX/xray"
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
out="$AGSBX/sing-box"
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
if [ -z "$uuid" ] && [ ! -e "$AGSBX/uuid" ]; then
if [ -e "$AGSBX/sing-box" ]; then
uuid=$("$AGSBX/sing-box" generate uuid)
else
uuid=$("$AGSBX/xray" uuid)
fi
echo "$uuid" > "$AGSBX/uuid"
elif [ -n "$uuid" ]; then
echo "$uuid" > "$AGSBX/uuid"
fi
uuid=$(cat "$AGSBX/uuid")
echo "UUID密码：$uuid"
}

# =============================================================================
# SECTION 4: installxray - Xray内核配置生成(仅Xray协议)
# 功能:
#   - 生成Xray配置文件$AGSBX/xr.json
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
mkdir -p "$AGSBX/xrk"
if [ ! -e "$AGSBX/xray" ] || ! head -c 4 "$AGSBX/xray" 2>/dev/null | grep -q "ELF"; then
upxray || { echo "Xray内核获取失败，安装中止"; exit 1; }
fi
cat > "$AGSBX/xr.json" <<EOF
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
echo "$ym_vl_re" > "$AGSBX/ym_vl_re"
echo "Reality域名：$ym_vl_re"
if [ ! -e "$AGSBX/xrk/private_key" ]; then
key_pair=$("$AGSBX/xray" x25519)
private_key=$(echo "$key_pair" | awk -F':' '/PrivateKey/ {print $2}' | xargs)
public_key=$(echo "$key_pair" | awk -F':' '/Password/ {print $2}' | xargs)
short_id=$(date +%s%N | sha256sum | cut -c 1-8)
echo "$private_key" > "$AGSBX/xrk/private_key"
echo "$public_key" > "$AGSBX/xrk/public_key"
echo "$short_id" > "$AGSBX/xrk/short_id"
fi
private_key_x=$(cat "$AGSBX/xrk/private_key")
public_key_x=$(cat "$AGSBX/xrk/public_key")
short_id_x=$(cat "$AGSBX/xrk/short_id")
fi

if [ -n "$port_vl_re_enc" ] || [ -n "$port_xh_enc" ] || [ -n "$port_vx_enc" ] || [ -n "$port_vw_enc" ] || [ "$vlpt_enc" = "y" ] || [ "$xhpt_enc" = "y" ] || [ "$vxpt_enc" = "y" ] || [ "$vwpt_enc" = "y" ]; then
if [ ! -e "$AGSBX/xrk/dekey" ]; then
vlkey=$("$AGSBX/xray" vlessenc)
dekey=$(echo "$vlkey" | grep '"decryption":' | sed -n '2p' | cut -d' ' -f2- | tr -d '"')
enkey=$(echo "$vlkey" | grep '"encryption":' | sed -n '2p' | cut -d' ' -f2- | tr -d '"')
echo "$dekey" > "$AGSBX/xrk/dekey"
echo "$enkey" > "$AGSBX/xrk/enkey"
fi
dekey=$(cat "$AGSBX/xrk/dekey")
enkey=$(cat "$AGSBX/xrk/enkey")
fi

if [ -n "$xhp" ]; then
xhp=xhpt
if [ -z "$port_xh" ] && [ ! -e "$AGSBX/port_xh" ]; then
port_xh=$(shuf -i 10000-65535 -n 1)
echo "$port_xh" > "$AGSBX/port_xh"
elif [ -n "$port_xh" ]; then
echo "$port_xh" > "$AGSBX/port_xh"
fi
port_xh=$(cat "$AGSBX/port_xh")
echo "Vless-xhttp-reality端口：$port_xh"
if [ -n "$port_xh_enc" ]; then
dec_xh="$dekey"
else
dec_xh="none"
fi
cat >> "$AGSBX/xr.json" <<EOF
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
if [ -z "$port_vx" ] && [ ! -e "$AGSBX/port_vx" ]; then
port_vx=$(shuf -i 10000-65535 -n 1)
echo "$port_vx" > "$AGSBX/port_vx"
elif [ -n "$port_vx" ]; then
echo "$port_vx" > "$AGSBX/port_vx"
fi
port_vx=$(cat "$AGSBX/port_vx")
echo "Vless-xhttp端口：$port_vx"
if [ -n "$cdnym" ]; then
echo "$cdnym" > "$AGSBX/cdnym"
echo "80系CDN或者回源CDN的host域名 (确保IP已解析在CF域名)：$cdnym"
fi
if [ -n "$port_vx_enc" ]; then
dec_vx="$dekey"
else
dec_vx="none"
fi
cat >> "$AGSBX/xr.json" <<EOF
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
if [ -z "$port_vl_re" ] && [ ! -e "$AGSBX/port_vl_re" ]; then
port_vl_re=$(shuf -i 10000-65535 -n 1)
echo "$port_vl_re" > "$AGSBX/port_vl_re"
elif [ -n "$port_vl_re" ]; then
echo "$port_vl_re" > "$AGSBX/port_vl_re"
fi
port_vl_re=$(cat "$AGSBX/port_vl_re")
echo "Vless-tcp-reality-v端口：$port_vl_re"
if [ -n "$port_vl_re_enc" ]; then
dec_vl="$dekey"
else
dec_vl="none"
fi
cat >> "$AGSBX/xr.json" <<EOF
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
#   - 生成Sing-box配置文件$AGSBX/sb.json
#   - 配置Hysteria2协议(port_hy2)
#   - 配置Tuic协议(port_tu)
#   - 配置AnyTLS协议(port_an)
#   - 配置Any-Reality协议(port_ar)
#   - 配置Shadowsocks协议(port_ss)
#   - 生成自签名证书用于TLS(多发行版自动装openssl + PEM内容校验兜底)
#   - 可选: KNOCK 模式下注入 localhost clash_api(供 watchdog 活跃连接检测)
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
if [ ! -e "$AGSBX/sing-box" ] || ! head -c 4 "$AGSBX/sing-box" 2>/dev/null | grep -q "ELF"; then
upsingbox || { echo "Sing-box内核获取失败，安装中止"; exit 1; }
fi
cat > "$AGSBX/sb.json" <<EOF
{
"log": {
    "disabled": false,
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
EOF
insuuid
# 证书去重：SHA256.txt 存在则跳过生成（保证客户端 pinSHA256 指纹稳定不变）
# 确保 openssl 存在（多发行版，apk 需先 update）
if [ ! -f "$AGSBX/SHA256.txt" ]; then
	if ! command -v openssl >/dev/null 2>&1; then
		command -v apk     >/dev/null 2>&1 && { apk update >/dev/null 2>&1; apk add --no-cache openssl >/dev/null 2>&1; }
		command -v apt-get >/dev/null 2>&1 && { apt-get update >/dev/null 2>&1; DEBIAN_FRONTEND=noninteractive apt-get install -y openssl >/dev/null 2>&1; }
		command -v dnf     >/dev/null 2>&1 && dnf install -y openssl >/dev/null 2>&1
		command -v yum     >/dev/null 2>&1 && yum install -y openssl >/dev/null 2>&1
	fi
	# 一步生成匹配的 key+cert (ECC P-256)
	if command -v openssl >/dev/null 2>&1; then
		openssl ecparam -genkey -name prime256v1 -out "$AGSBX/private.key" >/dev/null 2>&1
		openssl req -new -x509 -days 36500 -key "$AGSBX/private.key" -out "$AGSBX/cert.crt" -subj "/CN=www.bing.com" -addext "subjectAltName=DNS:www.bing.com" >/dev/null 2>&1
	fi
	# 内容校验 + SHA256 指纹计算
	if ! grep -q "BEGIN CERTIFICATE" "$AGSBX/cert.crt" 2>/dev/null; then
		echo "ERROR: 自签证书生成失败（openssl 不可用？）。请在 VPS 手动安装 openssl 后重装。"
		exit 1
	fi
	SHA256=$(openssl x509 -in "$AGSBX/cert.crt" -outform DER | sha256sum | awk '{print $1}')
	echo "$SHA256" > "$AGSBX/SHA256.txt"
	# sing-box certificate_public_key_sha256: 公钥 SHA256 base64 (兼容 NekoBox/sing-box GUI 等客户端)
	PUBKEY_SHA256_B64=$(openssl x509 -in "$AGSBX/cert.crt" -pubkey -noout 2>/dev/null | openssl pkey -pubin -outform der 2>/dev/null | openssl dgst -sha256 -binary | openssl enc -base64)
	echo "$PUBKEY_SHA256_B64" > "$AGSBX/PUBKEY_SHA256_B64.txt"
fi
if [ -n "$hyp" ]; then
hyp=hypt
if [ -z "$port_hy2" ] && [ ! -e "$AGSBX/port_hy2" ]; then
port_hy2=$(shuf -i 10000-65535 -n 1)
echo "$port_hy2" > "$AGSBX/port_hy2"
elif [ -n "$port_hy2" ]; then
echo "$port_hy2" > "$AGSBX/port_hy2"
fi
port_hy2=$(cat "$AGSBX/port_hy2")
echo "Hysteria2端口：$port_hy2"
cat >> "$AGSBX/sb.json" <<EOF
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
            "certificate_path": "$AGSBX/cert.crt",
            "key_path": "$AGSBX/private.key"
        }
    },
EOF
else
hyp=hyptargo
fi
if [ -n "$tup" ]; then
tup=tupt
if [ -z "$port_tu" ] && [ ! -e "$AGSBX/port_tu" ]; then
port_tu=$(shuf -i 10000-65535 -n 1)
echo "$port_tu" > "$AGSBX/port_tu"
elif [ -n "$port_tu" ]; then
echo "$port_tu" > "$AGSBX/port_tu"
fi
port_tu=$(cat "$AGSBX/port_tu")
echo "Tuic端口：$port_tu"
cat >> "$AGSBX/sb.json" <<EOF
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
                "certificate_path": "$AGSBX/cert.crt",
                "key_path": "$AGSBX/private.key"
            }
        },
EOF
else
tup=tuptargo
fi
if [ -n "$anp" ]; then
anp=anpt
if [ -z "$port_an" ] && [ ! -e "$AGSBX/port_an" ]; then
port_an=$(shuf -i 10000-65535 -n 1)
echo "$port_an" > "$AGSBX/port_an"
elif [ -n "$port_an" ]; then
echo "$port_an" > "$AGSBX/port_an"
fi
port_an=$(cat "$AGSBX/port_an")
echo "Anytls端口：$port_an"
cat >> "$AGSBX/sb.json" <<EOF
        {
            "type":"anytls",
            "tag":"anytls-sb",
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
                "certificate_path": "$AGSBX/cert.crt",
                "key_path": "$AGSBX/private.key"
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
echo "$ym_vl_re" > "$AGSBX/ym_vl_re"
echo "Reality域名：$ym_vl_re"
mkdir -p "$AGSBX/sbk"
if [ ! -e "$AGSBX/sbk/private_key" ]; then
key_pair=$("$AGSBX/sing-box" generate reality-keypair)
private_key=$(echo "$key_pair" | awk '/PrivateKey/ {print $2}' | tr -d '"')
public_key=$(echo "$key_pair" | awk '/PublicKey/ {print $2}' | tr -d '"')
short_id=$("$AGSBX/sing-box" generate rand --hex 4)
echo "$private_key" > "$AGSBX/sbk/private_key"
echo "$public_key" > "$AGSBX/sbk/public_key"
echo "$short_id" > "$AGSBX/sbk/short_id"
fi
private_key_s=$(cat "$AGSBX/sbk/private_key")
public_key_s=$(cat "$AGSBX/sbk/public_key")
short_id_s=$(cat "$AGSBX/sbk/short_id")
if [ -z "$port_ar" ] && [ ! -e "$AGSBX/port_ar" ]; then
port_ar=$(shuf -i 10000-65535 -n 1)
echo "$port_ar" > "$AGSBX/port_ar"
elif [ -n "$port_ar" ]; then
echo "$port_ar" > "$AGSBX/port_ar"
fi
port_ar=$(cat "$AGSBX/port_ar")
echo "Any-Reality端口：$port_ar"
cat >> "$AGSBX/sb.json" <<EOF
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
if [ ! -e "$AGSBX/sskey" ]; then
sskey=$("$AGSBX/sing-box" generate rand 16 --base64)
echo "$sskey" > "$AGSBX/sskey"
fi
if [ -z "$port_ss" ] && [ ! -e "$AGSBX/port_ss" ]; then
port_ss=$(shuf -i 10000-65535 -n 1)
echo "$port_ss" > "$AGSBX/port_ss"
elif [ -n "$port_ss" ]; then
echo "$port_ss" > "$AGSBX/port_ss"
fi
sskey=$(cat "$AGSBX/sskey")
port_ss=$(cat "$AGSBX/port_ss")
echo "Shadowsocks-2022端口：$port_ss"
cat >> "$AGSBX/sb.json" <<EOF
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
if [ -z "$port_vm_ws" ] && [ ! -e "$AGSBX/port_vm_ws" ]; then
port_vm_ws=$(shuf -i 10000-65535 -n 1)
echo "$port_vm_ws" > "$AGSBX/port_vm_ws"
elif [ -n "$port_vm_ws" ]; then
echo "$port_vm_ws" > "$AGSBX/port_vm_ws"
fi
port_vm_ws=$(cat "$AGSBX/port_vm_ws")
echo "Vmess-ws端口：$port_vm_ws"
if [ -n "$cdnym" ]; then
echo "$cdnym" > "$AGSBX/cdnym"
echo "80系CDN或者回源CDN的host域名 (确保IP已解析在CF域名)：$cdnym"
fi
if [ -e "$AGSBX/xr.json" ]; then
cat >> "$AGSBX/xr.json" <<EOF
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
cat >> "$AGSBX/sb.json" <<EOF
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
if [ -z "$port_vw" ] && [ ! -e "$AGSBX/port_vw" ]; then
port_vw=$(shuf -i 10000-65535 -n 1)
echo "$port_vw" > "$AGSBX/port_vw"
elif [ -n "$port_vw" ]; then
echo "$port_vw" > "$AGSBX/port_vw"
fi
port_vw=$(cat "$AGSBX/port_vw")
echo "Vless-ws端口：$port_vw"
if [ -n "$cdnym" ]; then
echo "$cdnym" > "$AGSBX/cdnym"
echo "80系CDN或者回源CDN的host域名 (确保IP已解析在CF域名)：$cdnym"
fi
if [ -n "$port_vw_enc" ] && [ ! -e "$AGSBX/xr.json" ]; then
installxray
fi
if [ -e "$AGSBX/xr.json" ]; then
if [ -n "$port_vw_enc" ]; then
dec_vw="$dekey"
else
dec_vw="none"
fi
cat >> "$AGSBX/xr.json" <<EOF
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
cat >> "$AGSBX/sb.json" <<EOF
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
if [ -z "$port_so" ] && [ ! -e "$AGSBX/port_so" ]; then
port_so=$(shuf -i 10000-65535 -n 1)
echo "$port_so" > "$AGSBX/port_so"
elif [ -n "$port_so" ]; then
echo "$port_so" > "$AGSBX/port_so"
fi
port_so=$(cat "$AGSBX/port_so")
echo "Socks5端口：$port_so"
if [ -e "$AGSBX/xr.json" ]; then
cat >> "$AGSBX/xr.json" <<EOF
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
cat >> "$AGSBX/sb.json" <<EOF
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
if [ -e "$AGSBX/xr.json" ]; then
sed -i '${s/,[[:space:]]*$//}' "$AGSBX/xr.json"
cat >> "$AGSBX/xr.json" <<EOF
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
ExecStart=$AGSBX/xray run -c $AGSBX/xr.json
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
command="$AGSBX/xray"
command_args="run -c $AGSBX/xr.json"
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
	elif command -v supervisorctl >/dev/null 2>&1; then
	SUPER_AGSBX="${SUPER_CONF_DIR:-$AGSBX/supervisor}"
	mkdir -p "$SUPER_AGSBX"
	cat > "$SUPER_AGSBX/xray.conf" <<EOFBAS
	[program:xray]
	command=$AGSBX/xray run -c $AGSBX/xr.json
	autostart=true
	autorestart=true
	startsecs=3
	stdout_logfile=$AGSBX/xray.out.log
	stderr_logfile=$AGSBX/xray.err.log
EOFBAS
	supervisorctl update >/dev/null 2>&1 || true
	else
	nohup "$AGSBX/xray" run -c "$AGSBX/xr.json" > "$AGSBX/xray.log" 2>&1 &
fi
fi
if [ -e "$AGSBX/sb.json" ]; then
sed -i '${s/,[[:space:]]*$//}' "$AGSBX/sb.json"
cat >> "$AGSBX/sb.json" <<EOF
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
# ───── 可选:KNOCK 模式给 sing-box 注入 localhost clash_api(供 watchdog 活跃检测;非 KNOCK 不改)─────
if [ -n "$KNOCK" ] && [ -f "$AGSBX/sb.json" ]; then
	grep -q '"clash_api"' "$AGSBX/sb.json" || sed -i 's#"experimental": {#"experimental": {\n    "clash_api": { "external_controller": "127.0.0.1:'"$CLASH_API_PORT"'" },#' "$AGSBX/sb.json"
fi
if pidof systemd >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
cat > /etc/systemd/system/sb.service <<EOF
[Unit]
Description=sb service
After=network.target
[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=$AGSBX/sing-box run -c $AGSBX/sb.json
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
command="$AGSBX/sing-box"
command_args="run -c $AGSBX/sb.json"
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
elif command -v supervisorctl >/dev/null 2>&1; then
SUPER_AGSBX="${SUPER_CONF_DIR:-$AGSBX/supervisor}"
mkdir -p "$SUPER_AGSBX"
cat > "$SUPER_AGSBX/sing-box.conf" <<EOFBAS
[program:sing-box]
command=$AGSBX/sing-box run -c $AGSBX/sb.json
autostart=true
autorestart=true
startsecs=3
stdout_logfile=$AGSBX/sing-box.out.log
stderr_logfile=$AGSBX/sing-box.err.log
EOFBAS
supervisorctl update >/dev/null 2>&1 || true
else
nohup "$AGSBX/sing-box" run -c "$AGSBX/sb.json" > "$AGSBX/sing-box.log" 2>&1 &
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
#   - Argo隧道: 启动 cloudflared(可选 exec -a 进程伪装);固定隧道域名稳定、临时隧道每次换域名
#   - 可选敲门子系统(KNOCK=1): 生成 watchdog.sh + conf,空闲自关代理/敲门唤醒,固定隧道下 cloudflared 一并按需启停,watchdog 独占生命周期 + 保活cron
# =============================================================================

insnezha(){
  if [ -n "$nz_host" ] && [ -n "$nz_sec" ]; then
    echo "=========启用 哪吒探针 (Nezha Agent)========="
    
    NEZHA_DIR="$AGSBX/nezha"
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
if [ -f "$AGSBX/xr.json" ]; then
if ! find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/x' && ! pgrep -f 'agsbx/x' >/dev/null 2>&1; then
if pidof systemd >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
systemctl start xr >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
rc-service xray start >/dev/null 2>&1
else
nohup "$AGSBX/xray" run -c "$AGSBX/xr.json" >/dev/null 2>&1 &
fi
fi
fi
if [ -n "$argo" ] && [ -n "$vmag" ]; then
echo
echo "=========启用Cloudflared-argo内核========="
if [ ! -e "$AGSBX/cloudflared" ]; then
argocore=$({ command -v curl >/dev/null 2>&1 && curl -Ls https://data.jsdelivr.com/v1/package/gh/cloudflare/cloudflared || wget -qO- https://data.jsdelivr.com/v1/package/gh/cloudflare/cloudflared; } | grep -Eo '"[0-9.]+"' | sed -n 1p | tr -d '",')
echo "下载Cloudflared-argo最新正式版内核：$argocore"
url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$cpu"; out="$AGSBX/cloudflared"; (command -v curl>/dev/null 2>&1 && curl -Lo "$out" -# --retry 2 "$url") || (command -v wget>/dev/null 2>&1 && timeout 3 wget -O "$out" --tries=2 "$url")
chmod +x "$AGSBX/cloudflared"
fi
if [ "$argo" = "vmpt" ]; then argoport=$(cat "$AGSBX/port_vm_ws" 2>/dev/null); echo "Vmess" > "$AGSBX/vlvm"; elif [ "$argo" = "vwpt" ]; then argoport=$(cat "$AGSBX/port_vw" 2>/dev/null); echo "Vless" > "$AGSBX/vlvm"; fi; echo "$argoport" > "$AGSBX/argoport.log"

# 智能选择传输协议 (UDP受限时自动切换为HTTP2)
if command -v nc >/dev/null 2>&1 && nc -z -w 2 -u 1.1.1.1 443 >/dev/null 2>&1; then
  argoproto="--protocol quic"
else
  argoproto="--protocol http2"
fi
echo "$argoproto" > "$AGSBX/argoproto.log"

# 可选:cloudflared 进程伪装名(取 STEALTH_NAME 第3段,缺省回退第1段;首次启动即 exec -a,临时/固定隧道都适用)
cfn=""; [ -n "$KNOCK" ] && [ -n "$STEALTH_NAME" ] && { cfn=$(printf '%s' "$STEALTH_NAME" | cut -d, -f3); [ -z "$cfn" ] && cfn=$(printf '%s' "$STEALTH_NAME" | cut -d, -f1); }
if [ -n "${ARGO_DOMAIN}" ] && [ -n "${ARGO_AUTH}" ]; then
argoname='固定'
if [ -n "$cfn" ] && command -v bash >/dev/null 2>&1; then
nohup bash -c 'exec -a "$1" "$AGSBX/cloudflared" "${@:2}"' _ "$cfn" tunnel ${argoproto} --no-autoupdate --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) run --token "${ARGO_AUTH}" >/dev/null 2>&1 &
elif pidof systemd >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
cat > /etc/systemd/system/argo.service <<EOF
[Unit]
Description=argo service
After=network.target
[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=$AGSBX/cloudflared tunnel ${argoproto} --no-autoupdate --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) run --token "${ARGO_AUTH}"
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
command="$AGSBX/cloudflared tunnel"
command_args="${argoproto} --no-autoupdate --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) run --token ${ARGO_AUTH}"
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
nohup "$AGSBX/cloudflared" tunnel ${argoproto} --no-autoupdate --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) run --token "${ARGO_AUTH}" >/dev/null 2>&1 &
fi
echo "${ARGO_DOMAIN}" > "$AGSBX/sbargoym.log"
echo "${ARGO_AUTH}" > "$AGSBX/sbargotoken.log"
else
argoname='临时'
if [ -n "$cfn" ] && command -v bash >/dev/null 2>&1; then
nohup bash -c 'exec -a "$1" "$AGSBX/cloudflared" "${@:2}"' _ "$cfn" tunnel ${argoproto} --url "http://localhost:$(cat $AGSBX/argoport.log)" --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) --no-autoupdate > $AGSBX/argo.log 2>&1 &
else
nohup "$AGSBX/cloudflared" tunnel ${argoproto} --url http://localhost:$(cat $AGSBX/argoport.log) --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) --no-autoupdate > $AGSBX/argo.log 2>&1 &
fi
fi
echo "申请Argo$argoname隧道中……请稍等"
if [ -n "${ARGO_DOMAIN}" ] && [ -n "${ARGO_AUTH}" ]; then
sleep 3
argodomain=$(cat "$AGSBX/sbargoym.log" 2>/dev/null)
else
argodomain=""
for i in 1 2 3 4 5 6 7 8 9 10; do
sleep 2
argodomain=$(grep -a trycloudflare.com "$AGSBX/argo.log" 2>/dev/null | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')
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
	[ -f "$AGSBX/sb.json" ] && _sb_need=1
	[ -f "$AGSBX/xr.json" ] && _xr_need=1
	for i in 1 2 3 4 5 6 7; do
		[ "$_sb_need" = 1 ] && [ "$_sb_up" = 0 ] && \
			( find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/s' || pgrep -f 'agsbx/s' >/dev/null 2>&1 ) && _sb_up=1
		[ "$_xr_need" = 1 ] && [ "$_xr_up" = 0 ] && \
			( find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/x' || pgrep -f 'agsbx/x' >/dev/null 2>&1 ) && _xr_up=1
		[ "$_sb_up" = "$_sb_need" ] && [ "$_xr_up" = "$_xr_need" ] && break
		sleep 2
	done
	# 通用兜底：systemd/OpenRC 失败或无服务管理器 → nohup 直启
	if [ "$_sb_need" = 1 ] && [ "$_sb_up" = 0 ]; then
		echo "WARNING: sing-box 进程未检测到，尝试 nohup 直接启动..."
		systemctl reset-failed sb >/dev/null 2>&1
		nohup "$AGSBX/sing-box" run -c "$AGSBX/sb.json" > "$AGSBX/sing-box.log" 2>&1 &
		sleep 3
		( find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/s' || pgrep -f 'agsbx/s' >/dev/null 2>&1 ) && _sb_up=1
	fi
	if [ "$_xr_need" = 1 ] && [ "$_xr_up" = 0 ]; then
		echo "WARNING: xray 进程未检测到，尝试 nohup 直接启动..."
		systemctl reset-failed xr >/dev/null 2>&1
		nohup "$AGSBX/xray" run -c "$AGSBX/xr.json" > "$AGSBX/xray.log" 2>&1 &
		sleep 3
		( find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/x' || pgrep -f 'agsbx/x' >/dev/null 2>&1 ) && _xr_up=1
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
if ! pidof systemd >/dev/null 2>&1 && ! command -v rc-service >/dev/null 2>&1 && ! command -v supervisorctl >/dev/null 2>&1; then
sed -i '/agsbx\/sing-box/d' /tmp/crontab.tmp
sed -i '/agsbx\/xray/d' /tmp/crontab.tmp
if find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/s' || pgrep -f 'agsbx/s' >/dev/null 2>&1 ; then
echo '@reboot sleep 10 && /bin/sh -c "nohup $AGSBX/sing-box run -c $AGSBX/sb.json >/dev/null 2>&1 &"' >> /tmp/crontab.tmp
fi
if find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -q 'agsbx/x' || pgrep -f 'agsbx/x' >/dev/null 2>&1 ; then
echo '@reboot sleep 10 && /bin/sh -c "nohup $AGSBX/xray run -c $AGSBX/xr.json >/dev/null 2>&1 &"' >> /tmp/crontab.tmp
fi
fi
sed -i '/agsbx\/cloudflared/d' /tmp/crontab.tmp
if [ -n "$argo" ] && [ -n "$vmag" ]; then
if [ -n "${ARGO_DOMAIN}" ] && [ -n "${ARGO_AUTH}" ]; then
if ! pidof systemd >/dev/null 2>&1 && ! command -v rc-service >/dev/null 2>&1; then
echo '@reboot sleep 10 && /bin/sh -c "nohup $AGSBX/cloudflared tunnel $(cat $AGSBX/argoproto.log 2>/dev/null) --no-autoupdate --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) run --token $(cat $AGSBX/sbargotoken.log 2>/dev/null) >/dev/null 2>&1 &"' >> /tmp/crontab.tmp
fi
else
echo '@reboot sleep 10 && /bin/sh -c "nohup $AGSBX/cloudflared tunnel $(cat $AGSBX/argoproto.log 2>/dev/null) --url http://localhost:$(cat $AGSBX/argoport.log) --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) --no-autoupdate > $AGSBX/argo.log 2>&1 &"' >> /tmp/crontab.tmp
fi
fi
# ═════════ 可选:敲门 + 空闲自关子系统(仅 KNOCK=1 启用;非 KNOCK 完全跳过,以下 cron 照旧)═════════
if [ -n "$KNOCK" ]; then
	[ -z "$KNOCK_PORT" ] && KNOCK_PORT=$(shuf -i 20000-60000 -n 1 2>/dev/null || echo 38000)
	command -v socat >/dev/null 2>&1 || { command -v apk >/dev/null 2>&1 && apk add --no-cache socat >/dev/null 2>&1; command -v apt-get >/dev/null 2>&1 && apt-get install -y socat >/dev/null 2>&1; }
	cat > "$AGSBX/watchdog.conf" <<EOF
KNOCK_PORT="$KNOCK_PORT"
IDLE_TIMEOUT="$IDLE_TIMEOUT"
STEALTH_NAME="$STEALTH_NAME"
CLASH_API_PORT="$CLASH_API_PORT"
EOF
	cat > "$AGSBX/watchdog.sh" <<'WDEOF'
#!/bin/sh
# argosbx 敲门守护(仅 KNOCK 模式生成):空闲关代理、敲门拉起代理。纯 POSIX;进程伪装需 bash。
# 自定位:watchdog.sh 恒在 <安装目录>/ 下,且总以绝对路径被 cron/socat/nc 拉起,故 dirname "$0" 即安装目录
# (watchdog 是独立进程,运行时无主脚本的 AGSBX/HOME 环境变量,不能靠展开,必须自定位)
AGSBX=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd)
[ -f "$AGSBX/watchdog.conf" ] && . "$AGSBX/watchdog.conf"
GRACE=60
# STEALTH_NAME 逗号分隔 → sing-box / xray / cloudflared 各自伪装名(单个则共用)
SB_NAME=$(printf '%s' "$STEALTH_NAME" | cut -d, -f1)
XR_NAME=$(printf '%s' "$STEALTH_NAME" | cut -d, -f2); [ -z "$XR_NAME" ] && XR_NAME="$SB_NAME"
CF_NAME=$(printf '%s' "$STEALTH_NAME" | cut -d, -f3); [ -z "$CF_NAME" ] && CF_NAME="$SB_NAME"
IS_FIXED=""; [ -s "$AGSBX/sbargotoken.log" ] && IS_FIXED=1   # 固定隧道:cloudflared 也按需启停;临时隧道:常驻
_pids() {
	for e in /proc/[0-9]*/exe; do
		case "$(readlink "$e" 2>/dev/null)" in
			*/agsbx/sing-box|*/agsbx/xray) basename "$(dirname "$e")" ;;
		esac
	done
}
proxy_up() { [ -n "$(_pids)" ]; }
_run() {
	[ -f "$AGSBX/$2" ] || return 0
	if [ -n "$3" ] && command -v bash >/dev/null 2>&1; then
		nohup bash -c 'exec -a "$1" "$2" run -c "$3"' _ "$3" "$AGSBX/$1" "$AGSBX/$2" >/dev/null 2>&1 &
	else
		nohup "$AGSBX/$1" run -c "$AGSBX/$2" >/dev/null 2>&1 &
	fi
}
start_proxy() {
	date +%s > "$AGSBX/.last_knock" 2>/dev/null
	proxy_up || { _run sing-box sb.json "$SB_NAME"; _run xray xr.json "$XR_NAME"; }
	[ -n "$IS_FIXED" ] && start_cloudflared
}
stop_proxy() {
	pidof systemd >/dev/null 2>&1 && systemctl stop sb xr >/dev/null 2>&1
	command -v rc-service    >/dev/null 2>&1 && { rc-service sing-box stop; rc-service xray stop; } >/dev/null 2>&1
	command -v supervisorctl >/dev/null 2>&1 && supervisorctl stop sing-box xray >/dev/null 2>&1
	for p in $(_pids); do kill -15 "$p" 2>/dev/null; done
	[ -n "$IS_FIXED" ] && stop_cloudflared
}
_tcp_active() {
	_p=$(_pids); [ -z "$_p" ] && return 1
	_o=$( { ss -tnp 2>/dev/null; netstat -tnp 2>/dev/null; } )
	[ -z "$_o" ] && return 1
	for x in $_p; do
		printf '%s\n' "$_o" | grep -i estab | grep -Eq "pid=$x,|[ /]$x/" && return 0
	done
	return 1
}
is_active() {
	c=$(wget -qO- "http://127.0.0.1:$CLASH_API_PORT/connections" 2>/dev/null) || c=$(curl -s "http://127.0.0.1:$CLASH_API_PORT/connections" 2>/dev/null)
	printf '%s' "$c" | grep -q '"id"' && return 0
	_tcp_active
}
recently_knocked() {
	[ -f "$AGSBX/.last_knock" ] || return 1
	now=$(date +%s); last=$(cat "$AGSBX/.last_knock" 2>/dev/null || echo 0)
	[ $((now - last)) -lt "$GRACE" ]
}
knock_listener() {
	while :; do
		if command -v socat >/dev/null 2>&1; then
			socat TCP-LISTEN:"$KNOCK_PORT",reuseaddr,fork EXEC:"$AGSBX/watchdog.sh knock" 2>/dev/null
			sleep 1
		elif nc -l -p "$KNOCK_PORT" >/dev/null 2>&1 || nc -l "$KNOCK_PORT" >/dev/null 2>&1; then
			"$AGSBX/watchdog.sh" knock
		else
			sleep 1
		fi
	done
}
_cfrun() {  # 伪装启动 cloudflared(无 CF_NAME/无 bash 则原名)
	if [ -n "$CF_NAME" ] && command -v bash >/dev/null 2>&1; then
		nohup bash -c 'exec -a "$1" "$AGSBX/cloudflared" "${@:2}"' _ "$CF_NAME" "$@" >/dev/null 2>&1 &
	else
		nohup "$AGSBX/cloudflared" "$@" >/dev/null 2>&1 &
	fi
}
cf_up() {
	for e in /proc/[0-9]*/exe; do
		case "$(readlink "$e" 2>/dev/null)" in */agsbx/cloudflared) return 0 ;; esac
	done
	return 1
}
start_cloudflared() {  # 开机/重启后伪装拉起 argo;临时隧道域名会变(仅固定隧道支持重启,见 README)
	[ -f "$AGSBX/cloudflared" ] || return 0
	cf_up && return 0
	proto=$(cat "$AGSBX/argoproto.log" 2>/dev/null)
	if [ -s "$AGSBX/sbargotoken.log" ]; then
		_cfrun tunnel $proto --no-autoupdate --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) run --token "$(cat "$AGSBX/sbargotoken.log")"
	elif [ -f "$AGSBX/argoport.log" ]; then
		_cfrun tunnel $proto --url "http://localhost:$(cat "$AGSBX/argoport.log")" --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) --no-autoupdate
	fi
}
stop_cloudflared() {
	pidof systemd >/dev/null 2>&1 && systemctl stop argo >/dev/null 2>&1
	command -v rc-service >/dev/null 2>&1 && rc-service argo stop >/dev/null 2>&1
	for e in /proc/[0-9]*/exe; do
		case "$(readlink "$e" 2>/dev/null)" in */agsbx/cloudflared) kill -15 "$(basename "$(dirname "$e")")" 2>/dev/null ;; esac
	done
}
main() {
	echo $$ > "$AGSBX/watchdog.pid" 2>/dev/null
	[ -z "$IS_FIXED" ] && start_cloudflared
	knock_listener &
	idle=0
	while :; do
		sleep 30
		if is_active || recently_knocked; then
			idle=0
		elif proxy_up; then
			idle=$((idle + 30))
			[ "$idle" -ge "$IDLE_TIMEOUT" ] && { stop_proxy; idle=0; }
		fi
	done
}
case "$1" in
	knock) start_proxy ;;
	stop)  stop_proxy ;;
	*)     main ;;
esac
WDEOF
	chmod +x "$AGSBX/watchdog.sh"
	# B方案:watchdog 独占代理生命周期 —— 关服务管理器自启 + 删代理 @reboot(watchdog 会空闲伪装接管)
	pidof systemd >/dev/null 2>&1 && systemctl disable sb xr argo >/dev/null 2>&1
	command -v rc-update >/dev/null 2>&1 && { rc-update del sing-box default; rc-update del xray default; rc-update del argo default; } >/dev/null 2>&1
	sed -i '/agsbx\/sing-box/d;/agsbx\/xray/d;/agsbx\/cloudflared/d' /tmp/crontab.tmp 2>/dev/null
	grep -q 'agsbx/watchdog.sh' /tmp/crontab.tmp 2>/dev/null || echo "@reboot sleep 10 && /bin/sh -c \"nohup $AGSBX/watchdog.sh >/dev/null 2>&1 &\"" >> /tmp/crontab.tmp
	grep -q 'wd-keepalive' /tmp/crontab.tmp 2>/dev/null || echo "*/5 * * * * kill -0 \$(cat $AGSBX/watchdog.pid 2>/dev/null) 2>/dev/null || nohup $AGSBX/watchdog.sh >/dev/null 2>&1 & # wd-keepalive" >> /tmp/crontab.tmp
	if ! pgrep -f 'agsbx/watchdog.sh' >/dev/null 2>&1; then nohup "$AGSBX/watchdog.sh" >/dev/null 2>&1 & fi
	echo "═════ 敲门模式已启用 ═════"
	echo "  敲门端口:$KNOCK_PORT  |  空闲 ${IDLE_TIMEOUT}s 无连接自动关闭代理"
	echo "  连接前先敲门:nc -w1 <服务器IP> $KNOCK_PORT   (代理随后自动拉起)"
fi
crontab /tmp/crontab.tmp >/dev/null 2>&1
rm /tmp/crontab.tmp
insnezha
echo "Argosbx脚本进程启动成功，安装完毕" && sleep 2
else
	echo "ERROR: Argosbx script process not started, installation failed"
	# Output diagnostic info
	if [ -f "$AGSBX/sb.json" ]; then
		echo "sb.json last 20 lines:"
		tail -20 "$AGSBX/sb.json" 2>/dev/null
	fi
	if [ -f "$AGSBX/xr.json" ]; then
		echo "xr.json last 20 lines:"
		tail -20 "$AGSBX/xr.json" 2>/dev/null
	fi
	if [ -f "$AGSBX/sing-box.log" ]; then
		echo "===== sing-box 运行日志 (崩溃原因看这里) ====="
		tail -25 "$AGSBX/sing-box.log" 2>/dev/null
		if grep -q 'operation not supported' "$AGSBX/sing-box.log" 2>/dev/null; then
			echo "⚠️ 该容器不支持 sing-box 网络监控(netlink route 订阅)，故 sing-box 专属协议无法运行。"
			echo "   解决：请勿启用 hypt/tupt/anpt/arpt/sspt；改用 vless-ws/vmess-ws/reality/socks5 等 Xray 协议(不受影响)。"
		fi
	fi
	if [ -f "$AGSBX/xray.log" ]; then
		echo "===== xray 运行日志 (崩溃原因看这里) ====="
		tail -25 "$AGSBX/xray.log" 2>/dev/null
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
    hyport=$(cat "$AGSBX/port_hy2" 2>/dev/null)
    # iptables 自定义链 ARGOSBX_PRE（不污染其他服务的 PREROUTING 规则）
    iptables -t nat -N ARGOSBX_PRE 2>/dev/null
    iptables -t nat -F ARGOSBX_PRE >/dev/null 2>&1
    iptables -t nat -C PREROUTING -j ARGOSBX_PRE 2>/dev/null || iptables -t nat -A PREROUTING -j ARGOSBX_PRE
    ip6tables -t nat -N ARGOSBX_PRE 2>/dev/null
    ip6tables -t nat -F ARGOSBX_PRE >/dev/null 2>&1
    ip6tables -t nat -C PREROUTING -j ARGOSBX_PRE 2>/dev/null || ip6tables -t nat -A PREROUTING -j ARGOSBX_PRE
    for port in $hyjpt; do
        iptables -t nat -A ARGOSBX_PRE -p udp --dport "$port" -j DNAT --to-destination :$hyport
        ip6tables -t nat -A ARGOSBX_PRE -p udp --dport "$port" -j DNAT --to-destination :$hyport
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
# SECTION 10: cip - 节点信息输出与命名规范化
# =============================================================================
cip(){
echo "=========当前三大内核运行状态========="
procs=$(find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null)
if echo "$procs" | grep -Eq 'agsbx/s' || pgrep -f 'agsbx/s' >/dev/null 2>&1; then
echo "Sing-box (版本V$("$AGSBX/sing-box" version 2>/dev/null | awk '/version/{print $NF}'))：运行中"
else
echo "Sing-box：未启用"
fi
if echo "$procs" | grep -Eq 'agsbx/x' || pgrep -f 'agsbx/x' >/dev/null 2>&1; then
echo "Xray (版本V$("$AGSBX/xray" version 2>/dev/null | awk '/^Xray/{print $2}'))：运行中"
else
echo "Xray：未启用"
fi
if echo "$procs" | grep -Eq 'agsbx/c' || pgrep -f 'agsbx/c' >/dev/null 2>&1; then
echo "Argo (版本V$("$AGSBX/cloudflared" version 2>/dev/null | awk '{print $3}'))：运行中"
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
# SECTION 11: node_output - 节点链接生成与输出
# =============================================================================
node_output(){
echo
sleep 2
if [ "$ippz" = "4" ]; then
if [ -z "$v4" ]; then
ipbest
else
server_ip="$v4"
echo "$server_ip" > "$AGSBX/server_ip.log"
fi
elif [ "$ippz" = "6" ]; then
if [ -z "$v6" ]; then
# IPv6 不可用,直接回退 v4 (不调 ipbest6 浪费时间)
[ -z "$v4" ] && ipbest || { server_ip="$v4"; echo "$server_ip" > "$AGSBX/server_ip.log"; }
else
server_ip="[$v6]"
echo "$server_ip" > "$AGSBX/server_ip.log"
fi
else
ipbest
fi
# =============================================================================
# SECTION 12: ipchange - IP信息显示函数
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
echo "$server_ip" > "$AGSBX/server_ip.log"
fi
elif [ "$ippz" = "6" ]; then
if [ -z "$v6" ]; then
# IPv6 不可用,直接回退 v4
[ -z "$v4" ] && ipbest || { server_ip="$v4"; echo "$server_ip" > "$AGSBX/server_ip.log"; }
else
server_ip="[$v6]"
echo "$server_ip" > "$AGSBX/server_ip.log"
fi
else
ipbest
fi
}

cfip() { echo $((RANDOM % 13 + 1)); }
ipchange
rm -rf "$AGSBX/jh.txt"
uuid=$(cat "$AGSBX/uuid")
server_ip=$(cat "$AGSBX/server_ip.log")
[ -n "$nodeaddr" ] && server_ip="$nodeaddr"
sxname=$(cat "$AGSBX/name" 2>/dev/null | sed 's/-/_/g')
[ -n "$sxname" ] && sxname="${sxname}_"
xvvmcdnym=$(cat "$AGSBX/cdnym" 2>/dev/null)

# 获取国家代码
country=$(curl -sm5 ip-api.com/json/?fields=countryCode 2>/dev/null | sed 's/[{}"]//g; s/countryCode://g')
[ -z "$country" ] && country=""

# 优先使用用户指定的argoip，否则自动获取Argo域名作为备用IP
preferred_ips=""
if [ -n "$argoip" ]; then
  preferred_ips=$(echo "$argoip" | tr ';' ' ' | tr ',' ' ')
else
  _argo_domain=$(cat $AGSBX/sbargoym.log 2>/dev/null || grep -a trycloudflare.com $AGSBX/argo.log 2>/dev/null | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')
  if [ -n "$_argo_domain" ]; then
    resolved_ip=$(getent ahosts "$_argo_domain" 2>/dev/null | grep STREAM | head -1 | awk '{print $1}')
    [ -z "$resolved_ip" ] && resolved_ip=$(nslookup "$_argo_domain" 2>/dev/null | grep Address | tail -1 | awk '{print $2}')
    [ -n "$resolved_ip" ] && preferred_ips="$resolved_ip"
  fi
fi
[ -z "$preferred_ips" ] && preferred_ips="104.28.$(cfip).1"
ip_count=$(echo "$preferred_ips" | wc -w)

echo "*********************************************************"

ym_vl_re=$(cat "$AGSBX/ym_vl_re" 2>/dev/null)
if [ -e "$AGSBX/xray" ]; then
private_key_x=$(cat "$AGSBX/xrk/private_key" 2>/dev/null)
public_key_x=$(cat "$AGSBX/xrk/public_key" 2>/dev/null)
short_id_x=$(cat "$AGSBX/xrk/short_id" 2>/dev/null)
dekey=$(cat "$AGSBX/xrk/dekey" 2>/dev/null)
enkey=$(cat "$AGSBX/xrk/enkey" 2>/dev/null)
fi
if [ -e "$AGSBX/sing-box" ]; then
private_key_s=$(cat "$AGSBX/sbk/private_key" 2>/dev/null)
public_key_s=$(cat "$AGSBX/sbk/public_key" 2>/dev/null)
short_id_s=$(cat "$AGSBX/sbk/short_id" 2>/dev/null)
sskey=$(cat "$AGSBX/sskey" 2>/dev/null)
fi

# Vless-xhttp-reality with ENC
if grep xhttp-reality "$AGSBX/xr.json" >/dev/null 2>&1; then
echo "💣【 Vless-xhttp-reality 】节点信息如下："
port_xh=$(cat "$AGSBX/port_xh")
display_port_xh="${port_xh_ext:-${port_xh}}"
if [ -n "$port_xh_enc" ]; then
vl_xh_link="vless://$uuid@$server_ip:$display_port_xh?encryption=$enkey&security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_x&sid=$short_id_x&type=xhttp&path=/xhttp&mode=auto#${sxname}${country}_vl_xhttp_reality_$hostname"
else
vl_xh_link="vless://$uuid@$server_ip:$display_port_xh?encryption=none&security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_x&sid=$short_id_x&type=xhttp&path=/xhttp&mode=auto#${sxname}${country}_vl_xhttp_reality_$hostname"
fi
echo "$vl_xh_link" >> "$AGSBX/jh.txt"
echo "$vl_xh_link"
echo
fi

# Vless-xhttp with ENC
if grep vless-xhttp "$AGSBX/xr.json" >/dev/null 2>&1; then
echo "💣【 Vless-xhttp 】节点信息如下："
port_vx=$(cat "$AGSBX/port_vx")
display_port_vx="${port_vx_ext:-${port_vx}}"
if [ -n "$port_vx_enc" ]; then
vl_vx_link="vless://$uuid@$server_ip:$display_port_vx?encryption=$enkey&type=xhttp&path=/xhttp&mode=auto#${sxname}${country}_vl_xhttp_$hostname"
else
vl_vx_link="vless://$uuid@$server_ip:$display_port_vx?encryption=none&type=xhttp&path=/xhttp&mode=auto#${sxname}${country}_vl_xhttp_$hostname"
fi
echo "$vl_vx_link" >> "$AGSBX/jh.txt"
echo "$vl_vx_link"
echo
if [ -f "$AGSBX/cdnym" ]; then
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
  echo "$vl_vx_cdn_link" >> "$AGSBX/jh.txt"
  echo "$vl_vx_cdn_link"
  idx=$((idx+1))
done
echo
fi
fi

# Vless-ws with ENC
if grep vless-ws "$AGSBX/xr.json" >/dev/null 2>&1 || grep vless-ws-sb "$AGSBX/sb.json" >/dev/null 2>&1; then
echo "💣【 Vless-ws 】节点信息如下："
port_vw=$(cat "$AGSBX/port_vw")
display_port_vw="${port_vw_ext:-${port_vw}}"
if [ -n "$port_vw_enc" ] || [ "$vwpt_enc" = "y" ]; then
en_vw="$enkey"
else
en_vw="none"
fi
vl_vw_link="vless://$uuid@$server_ip:$display_port_vw?encryption=$en_vw&type=ws&path=%2F${uuid}-vw#${sxname}${country}_vl_ws_$hostname"
echo "$vl_vw_link" >> "$AGSBX/jh.txt"
echo "$vl_vw_link"
echo
if [ -f "$AGSBX/cdnym" ]; then
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
  echo "$vl_vw_cdn_link" >> "$AGSBX/jh.txt"
  echo "$vl_vw_cdn_link"
  idx=$((idx+1))
done
echo
fi
fi

# Vless-tcp-reality-vision
if grep reality-vision "$AGSBX/xr.json" >/dev/null 2>&1; then
echo "💣【 Vless-tcp-reality-vision 】节点信息如下："
port_vl_re=$(cat "$AGSBX/port_vl_re")
display_port_vl_re="${port_vl_re_ext:-${port_vl_re}}"
if [ -n "$port_vl_re_enc" ]; then
vl_link="vless://$uuid@$server_ip:$display_port_vl_re?encryption=$enkey&security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_x&sid=$short_id_x&type=tcp&headerType=none#${sxname}${country}_vl_reality_vision_$hostname"
else
vl_link="vless://$uuid@$server_ip:$display_port_vl_re?encryption=none&security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_x&sid=$short_id_x&type=tcp&headerType=none#${sxname}${country}_vl_reality_vision_$hostname"
fi
echo "$vl_link" >> "$AGSBX/jh.txt"
echo "$vl_link"
echo
fi

# Shadowsocks-2022
if grep ss-2022 "$AGSBX/sb.json" >/dev/null 2>&1; then
echo "💣【 Shadowsocks-2022 】节点信息如下："
port_ss=$(cat "$AGSBX/port_ss")
	display_port_ss="${port_ss_ext:-${port_ss}}"
	ss_link="ss://$(echo -n "2022-blake3-aes-128-gcm:$sskey@$server_ip:$display_port_ss" | base64 -w0)#${sxname}Shadowsocks-2022_$hostname"
echo "$ss_link" >> "$AGSBX/jh.txt"
echo "$ss_link"
echo
fi

# Vmess-ws
if grep vmess-xr "$AGSBX/xr.json" >/dev/null 2>&1 || grep vmess-sb "$AGSBX/sb.json" >/dev/null 2>&1; then
echo "💣【 Vmess-ws 】节点信息如下："
port_vm_ws=$(cat "$AGSBX/port_vm_ws")
display_port_vm="${port_vm_ws_ext:-${port_vm_ws}}"
vm_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}${country}_vm_ws_$hostname\", \"add\": \"$server_ip\", \"port\": \"$display_port_vm\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"www.bing.com\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vm_link" >> "$AGSBX/jh.txt"
echo "$vm_link"
echo
if [ -f "$AGSBX/cdnym" ]; then
echo "💣【 Vmess-ws-cdn 】节点信息如下："
echo "注：可自行更换优选IP域名，如是回源端口需手动修改443或者80系端口"
idx=1
for ip in $preferred_ips; do
  ip_suffix=""
  [ "$ip_count" -gt 1 ] && ip_suffix="-$idx"
  vm_cdn_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}${country}_vm_ws_cdn_${hostname}${ip_suffix}\", \"add\": \"$ip\", \"port\": \"$display_port_vm\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$xvvmcdnym\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
  echo "$vm_cdn_link" >> "$AGSBX/jh.txt"
  echo "$vm_cdn_link"
  idx=$((idx+1))
done
echo
fi
fi

# AnyTLS
if grep anytls-sb "$AGSBX/sb.json" >/dev/null 2>&1; then
echo "💣【 AnyTLS 】节点信息如下："
port_an=$(cat "$AGSBX/port_an")
display_port_an="${port_an_ext:-${port_an}}"
an_link="anytls://$uuid@$server_ip:$display_port_an?insecure=1&allowInsecure=1#${sxname}${country}_anytls_$hostname"
echo "$an_link" >> "$AGSBX/jh.txt"
echo "$an_link"
echo
fi

# Any-Reality
if grep anyreality-sb "$AGSBX/sb.json" >/dev/null 2>&1; then
echo "💣【 Any-Reality 】节点信息如下："
port_ar=$(cat "$AGSBX/port_ar")
display_port_ar="${port_ar_ext:-${port_ar}}"
ar_link="anytls://$uuid@$server_ip:$display_port_ar?security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_s&sid=$short_id_s&type=tcp&headerType=none#${sxname}${country}_any_reality_$hostname"
echo "$ar_link" >> "$AGSBX/jh.txt"
echo "$ar_link"
echo
fi

# Hysteria2
if grep hy2_sb "$AGSBX/sb.json" >/dev/null 2>&1; then
    echo "💣【 Hysteria2 】节点信息如下："
    port_hy2=$(cat "$AGSBX/port_hy2")
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
    hy2_link="hysteria2://$uuid@$server_ip:$display_port_hy2?security=tls&alpn=h3&insecure=0&allowInsecure=0${hyps}&sni=www.bing.com&pinSHA256=$(cat "$AGSBX/PUBKEY_SHA256_B64.txt")#${sxname}${country}_hy2_$hostname"
    echo "$hy2_link" >> "$AGSBX/jh.txt"
    echo "$hy2_link"
    echo
fi

# Tuic
if grep tuic5-sb "$AGSBX/sb.json" >/dev/null 2>&1; then
echo "💣【 Tuic 】节点信息如下："
port_tu=$(cat "$AGSBX/port_tu")
display_port_tu="${port_tu_ext:-${port_tu}}"
tuic5_link="tuic://$uuid:$uuid@$server_ip:$display_port_tu?congestion_control=bbr&udp_relay_mode=native&alpn=h3&sni=www.bing.com&insecure=1&allowInsecure=1#${sxname}${country}_tuic_$hostname"
echo "$tuic5_link" >> "$AGSBX/jh.txt"
echo "$tuic5_link"
echo
fi

# Socks5
if grep socks5-xr "$AGSBX/xr.json" >/dev/null 2>&1 || grep socks5-sb "$AGSBX/sb.json" >/dev/null 2>&1; then
echo "💣【 Socks5 】客户端信息如下："
port_so=$(cat "$AGSBX/port_so")
display_port_so="${port_so_ext:-${port_so}}"
echo "请配合其他应用内置代理使用，勿做节点直接使用"
echo "客户端地址：$server_ip"
echo "客户端端口：$display_port_so"
echo "客户端用户名：$uuid"
echo "客户端密码：$uuid"
echo
fi

# Argo tunnel output
argodomain=$(cat "$AGSBX/sbargoym.log" 2>/dev/null)
[ -z "$argodomain" ] && argodomain=$(grep -a trycloudflare.com "$AGSBX/argo.log" 2>/dev/null | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')

if [ -n "$argodomain" ]; then
vlvm=$(cat $AGSBX/vlvm 2>/dev/null)
if [ -n "$argoip" ]; then
  argo_addrs="$preferred_ips"
  argo_ip_count=$(echo "$argo_addrs" | wc -w)
else
  argo_addrs="$argodomain"
  argo_ip_count=1
fi

sbtk=$(cat "$AGSBX/sbargotoken.log" 2>/dev/null)
if [ -n "$sbtk" ]; then
nametn="Argo固定隧道token：$sbtk"
fi
echo "---------------------------------------------------------"
echo "Argo隧道端口正在使用${vlvm}-ws主协议端口：$(cat $AGSBX/argoport.log 2>/dev/null)"
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
  echo "$vmatls_link" >> "$AGSBX/jh.txt"
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
  echo "$vma_link" >> "$AGSBX/jh.txt"
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
  echo "$vwatls_link" >> "$AGSBX/jh.txt"
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
  echo "$vwa_link" >> "$AGSBX/jh.txt"
  echo "$vwa_link"
  idx=$((idx+1))
done
fi
fi
echo "---------------------------------------------------------"
echo "聚合节点信息，请进入 $AGSBX/jh.txt 文件目录查看或者运行 cat $AGSBX/jh.txt 查看"
echo "========================================================="
}
# =============================================================================
# SECTION 13: showmode - 命令帮助与用法说明(list/rep/upx/ups/res/del 等)
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

# =============================================================================
# SECTION 14: cleandel - 卸载清理函数
# 功能:
#   - 杀掉 agsbx 残留进程(含敲门 watchdog / socat 监听)
#   - 清理 crontab 定时任务(含 watchdog 开机自启与保活)
#   - 删除 systemd/openrc 服务
#   - 清理 bashrc 环境变量
# =============================================================================
cleandel(){
for P in /proc/[0-9]*; do if [ -L "$P/exe" ]; then TARGET=$(readlink -f "$P/exe" 2>/dev/null); if echo "$TARGET" | grep -qE '/agsbx/c|/agsbx/s|/agsbx/x'; then PID=$(basename "$P"); kill "$PID" 2>/dev/null; fi; fi; done
kill -15 $(pgrep -f 'agsbx/s' 2>/dev/null) $(pgrep -f 'agsbx/c' 2>/dev/null) $(pgrep -f 'agsbx/x' 2>/dev/null) $(pgrep -f 'agsbx/watchdog.sh' 2>/dev/null) >/dev/null 2>&1
sed -i '/agsbx/d' ~/.bashrc 2>/dev/null
sed -i '/export PATH="\$HOME\/bin:\$PATH"/d' ~/.bashrc 2>/dev/null
. ~/.bashrc 2>/dev/null
crontab -l > /tmp/crontab.tmp 2>/dev/null
sed -i '/agsbx\/sing-box/d' /tmp/crontab.tmp 2>/dev/null
sed -i '/agsbx\/xray/d' /tmp/crontab.tmp 2>/dev/null
sed -i '/agsbx\/cloudflared/d' /tmp/crontab.tmp 2>/dev/null
sed -i '/nezha-agent/d' /tmp/crontab.tmp 2>/dev/null
sed -i '/agsbx\/watchdog/d' /tmp/crontab.tmp 2>/dev/null
crontab /tmp/crontab.tmp >/dev/null 2>&1
rm /tmp/crontab.tmp 2>/dev/null
rm -rf "$HOME/bin/agsbx" 2>/dev/null
kill -15 $(pgrep -f 'nezha-agent' 2>/dev/null) >/dev/null 2>&1
rm -rf "$AGSBX/nezha" 2>/dev/null
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
elif command -v supervisorctl >/dev/null 2>&1; then
for svc in sing-box xray; do
supervisorctl stop "$svc" >/dev/null 2>&1 || true
done
supervisorctl reread >/dev/null 2>&1 || true
supervisorctl update >/dev/null 2>&1 || true
fi
# 清理 Hysteria2 端口跳跃自定义 iptables 链
iptables -t nat -D PREROUTING -j ARGOSBX_PRE 2>/dev/null
iptables -t nat -F ARGOSBX_PRE 2>/dev/null
iptables -t nat -X ARGOSBX_PRE 2>/dev/null
ip6tables -t nat -D PREROUTING -j ARGOSBX_PRE 2>/dev/null
ip6tables -t nat -F ARGOSBX_PRE 2>/dev/null
ip6tables -t nat -X ARGOSBX_PRE 2>/dev/null
netfilter-persistent save >/dev/null 2>&1
if command -v rc-service >/dev/null 2>&1; then
    rc-service iptables save >/dev/null 2>&1
    rc-service ip6tables save >/dev/null 2>&1
fi
}

# =============================================================================
# SECTION 15: xrestart/sbrestart - 内核重启函数
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
elif command -v supervisorctl >/dev/null 2>&1; then
supervisorctl restart xray >/dev/null 2>&1 || nohup "$AGSBX/xray" run -c "$AGSBX/xr.json" >/dev/null 2>&1 &
else
nohup "$AGSBX/xray" run -c "$AGSBX/xr.json" >/dev/null 2>&1 &
fi
}
sbrestart(){
kill -15 $(pgrep -f 'agsbx/s' 2>/dev/null) >/dev/null 2>&1
if pidof systemd >/dev/null 2>&1; then
systemctl restart sb >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1; then
rc-service sing-box restart >/dev/null 2>&1
elif command -v supervisorctl >/dev/null 2>&1; then
supervisorctl restart sing-box >/dev/null 2>&1 || nohup "$AGSBX/sing-box" run -c "$AGSBX/sb.json" >/dev/null 2>&1 &
else
nohup "$AGSBX/sing-box" run -c "$AGSBX/sb.json" >/dev/null 2>&1 &
fi
}

# =============================================================================
# SECTION 16: push_gist - 自动化节点订阅推送
# 功能:
#   - 读取 $AGSBX/gh_token 和 $AGSBX/gh_gist_id
#   - 将节点信息推送到GitHub Gist
# =============================================================================
push_gist(){
gh_token=$(cat "$AGSBX/gh_token" 2>/dev/null)
gh_gist_id=$(cat "$AGSBX/gh_gist_id" 2>/dev/null)
if [ -z "$gh_token" ]; then
return 1
fi
node_content=$(cat "$AGSBX/jh.txt" 2>/dev/null)
if [ -z "$node_content" ]; then
return 1
fi
# JSON 内容转义处理 (处理换行和引号)
escaped_content=$(echo "$node_content" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')

# 生成详细的文件名: [prefix]_[country]_[protocol]_[hostname].txt
gist_prefix=$(cat "$AGSBX/name" 2>/dev/null | sed 's/-/_/g')
[ -z "$gist_prefix" ] && gist_prefix="agsbx"
gist_country=$(curl -sm5 ip-api.com/json/?fields=countryCode 2>/dev/null | sed 's/[{}"]//g; s/countryCode://g')
[ -z "$gist_country" ] && gist_country="XX"
# 检测主要内核作为协议标识
if [ -e "$AGSBX/sing-box" ] && [ -e "$AGSBX/xray" ]; then gist_proto="dual"; elif [ -e "$AGSBX/sing-box" ]; then gist_proto="sb"; else gist_proto="xr"; fi
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
  [ -z "$gh_gist_id" ] && echo "$gist_id" > "$AGSBX/gh_gist_id"
  # 按照用户指定的格式手动构造订阅链接
  raw_url="https://gist.github.com/${gh_user}/${gist_id}/raw/${gist_filename}"
  echo "Gist 推送成功"
  echo "订阅链接 (Raw): $raw_url"
else
  echo "Gist 推送失败，请检查 Token 权限或网络连接"
fi
}

# =============================================================================
# SECTION 17: 命令行参数路由处理
# 使用: ./argosbx.sh [del|rep|list|upx|ups|res|help]
# =============================================================================
if [ "$1" = "del" ]; then
cleandel
rm -rf sbx_update "$AGSBX" "$HOME/agsb"
echo "卸载完成"
echo "欢迎下次继续使用：https://zv201413.github.io/argosbx-new" && sleep 2
echo
exit
elif [ "$1" = "help" ] || [ "$1" = "-h" ]; then
showmode
exit
elif [ "$1" = "rep" ]; then
cleandel
rm -rf "$AGSBX"/{sb.json,xr.json,sbargoym.log,sbargotoken.log,argo.log,argoport.log,cdnym,name}
echo "Argosbx重置协议完成，开始更新相关协议变量……" && sleep 2
echo
elif [ "$1" = "list" ]; then
cip
node_output
gh_token=$(cat "$AGSBX/gh_token" 2>/dev/null)
gh_gist_id=$(cat "$AGSBX/gh_gist_id" 2>/dev/null)
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
if [ -e "$AGSBX/sbargotoken.log" ]; then
if ! pidof systemd >/dev/null 2>&1 && ! command -v rc-service >/dev/null 2>&1; then
nohup $AGSBX/cloudflared tunnel $(cat $AGSBX/argoproto.log 2>/dev/null) --no-autoupdate --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) run --token $(cat $AGSBX/sbargotoken.log 2>/dev/null) >/dev/null 2>&1 &
fi
else
nohup $AGSBX/cloudflared tunnel $(cat $AGSBX/argoproto.log 2>/dev/null) --url http://localhost:$(cat $AGSBX/argoport.log 2>/dev/null) --edge-ip-version $(cat "$AGSBX/cf_ipv.txt" 2>/dev/null || echo auto) --no-autoupdate > $AGSBX/argo.log 2>&1 &
fi
fi
;;
esac
done
sleep 5 && echo "重启完成" && sleep 3 && cip
exit
fi

# =============================================================================
# SECTION 18: 脚本主执行流程 - 首次安装逻辑
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
[ -n "$gh_token" ] && echo "$gh_token" > "$AGSBX/gh_token"
[ -n "$gh_gist_id" ] && echo "$gh_gist_id" > "$AGSBX/gh_gist_id"
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

