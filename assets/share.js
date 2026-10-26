(function (root) {
  'use strict';

  function decodeBase64Url(value) {
    if (!/^[A-Za-z0-9_-]*$/.test(value) || value.length > 400000) {
      throw new Error('分享数据格式错误或过长，请重新运行 agsbx list。');
    }
    const binary = atob(value.replace(/-/g, '+').replace(/_/g, '/') + '='.repeat((4 - value.length % 4) % 4));
    return new TextDecoder('utf-8', { fatal: true }).decode(Uint8Array.from(binary, c => c.charCodeAt(0)));
  }

  function parseShare(hash) {
    const params = new URLSearchParams(hash.replace(/^#/, ''));
    const content = decodeBase64Url(params.get('nodes') || '');
    const lines = content.split(/\r?\n/).map(line => line.trim()).filter(Boolean);
    if (lines.length > 256) throw new Error('节点超过 256 个，请使用 Gist 订阅分享。');
    const nodes = lines.filter(line => /^(vless|vmess|ss|trojan|anytls|hysteria2?|hy2|tuic):\/\/\S+/i.test(line));
    function subscriptionUrl(key) {
      if (!params.get(key)) return '';
      const url = new URL(decodeBase64Url(params.get(key)));
      if (url.protocol === 'https:' && ['gist.github.com', 'gist.githubusercontent.com'].includes(url.hostname)
          && !url.username && !url.password) return url.href;
      return '';
    }
    let iosNodes = [];
    if (params.get('ios')) {
      iosNodes = decodeBase64Url(params.get('ios')).split(/\r?\n/).map(line => line.trim()).filter(Boolean);
      if (iosNodes.length !== nodes.length || iosNodes.some(line => !/^(vless|vmess|ss|trojan|anytls|hysteria2?|hy2|tuic):\/\/\S+/i.test(line)))
        throw new Error('兼容版与原版节点不匹配，请重新运行 agsbx list。');
    }
    return { nodes, iosNodes, subscription: subscriptionUrl('sub'),
      iosSubscription: iosNodes.length ? subscriptionUrl('iossub') : '', skipped: lines.length - nodes.length };
  }

  function nodeName(uri, index) {
    const scheme = uri.split(':')[0].toUpperCase();
    const hash = uri.indexOf('#');
    if (hash >= 0) {
      try { return `${index + 1}. ${decodeURIComponent(uri.slice(hash + 1)) || scheme}`; }
      catch (_) { /* 保留合法链接，即使显示名称的转义不完整。 */ }
    }
    if (/^vmess:\/\//i.test(uri)) {
      try {
        const json = JSON.parse(decodeBase64Url(uri.slice(8).replace(/=+$/, '').replace(/\+/g, '-').replace(/\//g, '_')));
        if (json.ps) return `${index + 1}. ${json.ps}`;
      } catch (_) { /* 无名称时显示协议序号。 */ }
    }
    return `${index + 1}. ${scheme}`;
  }

  function makeQrSvg(payload, generator) {
    generator.stringToBytes = generator.stringToBytesFuncs['UTF-8'];
    const qr = generator(0, 'M');
    qr.addData(payload, 'Byte');
    qr.make();
    return qr.createSvgTag({ cellSize: 4, margin: 16, scalable: true });
  }

  const api = { decodeBase64Url, parseShare, nodeName, makeQrSvg };
  if (typeof module === 'object' && module.exports) module.exports = api;
  root.ArgosbxShare = api;
  if (!root.document) return;

  const get = id => document.getElementById(id);
  const status = message => { get('status').textContent = message; };
  let nodes = [];
  let iosNodes = [];
  const svgs = {};
  const prefixes = ['node', 'ios-node', 'subscription', 'ios-subscription'];

  async function copy(value, input) {
    try {
      await navigator.clipboard.writeText(value);
      status('已复制。');
    } catch (_) {
      const field = input || document.createElement('textarea');
      if (!input) { field.value = value; document.body.append(field); }
      field.focus(); field.select();
      const copied = document.execCommand('copy');
      if (!input) field.remove();
      status(copied ? '已复制。' : '请长按或选中链接，手动复制。');
    }
  }

  function save(content, filename, type) {
    const url = URL.createObjectURL(new Blob([content], { type }));
    const link = document.createElement('a');
    link.href = url; link.download = filename;
    document.body.append(link); link.click(); link.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }

  function saveQr(prefix, svgOnly) {
    const svg = svgs[prefix];
    if (!svg) return;
    const suffix = prefix.includes('node') ? `-${Number(get('node-select').value) + 1}` : '';
    const filename = `argosbx-${prefix}${suffix}`;
    if (svgOnly) return save(svg, filename + '.svg', 'image/svg+xml');
    const url = URL.createObjectURL(new Blob([svg], { type: 'image/svg+xml' }));
    const img = new Image();
    img.onload = () => {
      const canvas = document.createElement('canvas');
      canvas.width = canvas.height = 1024;
      const ctx = canvas.getContext('2d');
      ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, 1024, 1024);
      ctx.drawImage(img, 0, 0, 1024, 1024);
      URL.revokeObjectURL(url);
      canvas.toBlob(blob => {
        if (!blob) return status('下载失败，请使用 SVG 下载。');
        const link = document.createElement('a');
        const downloadUrl = URL.createObjectURL(blob);
        link.href = downloadUrl; link.download = filename + '.png';
        document.body.append(link); link.click(); link.remove();
        setTimeout(() => URL.revokeObjectURL(downloadUrl), 1000);
      }, 'image/png');
    };
    img.onerror = () => { URL.revokeObjectURL(url); status('下载失败，请使用 SVG 下载。'); };
    img.src = url;
  }

  function draw(payload, prefix) {
    const container = get(`${prefix}-qr`);
    const error = get(`${prefix}-error`);
    container.replaceChildren();
    error.hidden = true;
    try {
      const svg = makeQrSvg(payload, root.qrcode);
      // SVG 完全由本地二维码库生成；节点名称与 URI 不作为 HTML 拼接。
      container.innerHTML = svg;
      get(`save-${prefix}-qr`).disabled = false;
      get(`save-${prefix}-svg`).disabled = false;
      return svg;
    } catch (_) {
      error.textContent = '此链接超过二维码容量或无法生成二维码，请复制链接导入。';
      error.hidden = false;
      get(`save-${prefix}-qr`).disabled = true;
      get(`save-${prefix}-svg`).disabled = true;
      return '';
    }
  }

  function selectNode() {
    const index = Number(get('node-select').value);
    const uri = nodes[index];
    get('node-url').value = uri;
    svgs.node = draw(uri, 'node');
    get('ios-node-card').hidden = !iosNodes.length;
    if (iosNodes.length) {
      get('ios-node-url').value = iosNodes[index];
      svgs['ios-node'] = draw(iosNodes[index], 'ios-node');
    }
  }

  function load() {
    get('subscription-card').hidden = true;
    get('nodes-card').hidden = true;
    get('all-actions').hidden = true;
    nodes = [];
    iosNodes = [];
    get('node-select').replaceChildren();
    prefixes.forEach(prefix => {
      svgs[prefix] = '';
      get(`${prefix}-qr`).replaceChildren();
      get(`${prefix}-url`).value = '';
      get(`${prefix}-error`).hidden = true;
      get(`save-${prefix}-qr`).disabled = true;
      get(`save-${prefix}-svg`).disabled = true;
    });
    get('ios-node-card').hidden = true;
    get('ios-subscription-card').hidden = true;
    get('original-subscription-card').hidden = true;
    get('copy-ios-all').hidden = true;
    get('save-ios-all').hidden = true;
    status('');
    try {
      const data = parseShare(location.hash);
      nodes = data.nodes;
      iosNodes = data.iosNodes;
      if (!nodes.length) {
        get('summary').textContent = '没有可分享的节点。请打开安装结果或 agsbx list 输出的二维码分享链接。';
        return;
      }
      get('summary').textContent = data.subscription
        ? `共 ${nodes.length} 个节点，选择所需版本的订阅二维码即可导入全部节点。`
        : `共 ${nodes.length} 个节点，请选择节点逐个扫码。启用 Gist 推送后可生成全部节点的订阅二维码。`;
      if (data.skipped) status(`已忽略 ${data.skipped} 行无效节点数据。`);
      nodes.forEach((uri, index) => {
        const option = document.createElement('option');
        option.value = String(index); option.textContent = nodeName(uri, index);
        get('node-select').append(option);
      });
      get('nodes-card').hidden = false;
      get('all-actions').hidden = false;
      get('copy-ios-all').hidden = !iosNodes.length;
      get('save-ios-all').hidden = !iosNodes.length;
      selectNode();
      if (data.subscription) {
        get('subscription-card').hidden = false;
        get('original-subscription-card').hidden = false;
        get('subscription-url').value = data.subscription;
        svgs.subscription = draw(data.subscription, 'subscription');
      }
      if (data.iosSubscription) {
        get('subscription-card').hidden = false;
        get('ios-subscription-card').hidden = false;
        get('ios-subscription-url').value = data.iosSubscription;
        svgs['ios-subscription'] = draw(data.iosSubscription, 'ios-subscription');
      }
    } catch (error) {
      get('summary').textContent = '分享链接无法读取。';
      status(error.message || '请重新运行 agsbx list 获取分享链接。');
    }
  }

  get('node-select').addEventListener('change', selectNode);
  prefixes.forEach(prefix => {
    get(`copy-${prefix}`).addEventListener('click', () => copy(get(`${prefix}-url`).value, get(`${prefix}-url`)));
    get(`save-${prefix}-qr`).addEventListener('click', () => saveQr(prefix, false));
    get(`save-${prefix}-svg`).addEventListener('click', () => saveQr(prefix, true));
  });
  get('copy-all').addEventListener('click', () => copy(nodes.join('\n')));
  get('save-all').addEventListener('click', () => save(nodes.join('\n') + '\n', 'argosbx-nodes.txt', 'text/plain;charset=utf-8'));
  get('copy-ios-all').addEventListener('click', () => copy(iosNodes.join('\n')));
  get('save-ios-all').addEventListener('click', () => save(iosNodes.join('\n') + '\n', 'argosbx-nodes-ios.txt', 'text/plain;charset=utf-8'));
  root.addEventListener('hashchange', load);
  load();
})(typeof globalThis === 'object' ? globalThis : this);
