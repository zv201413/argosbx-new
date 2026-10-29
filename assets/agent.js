(function (root, factory) {
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.ArgosbxAgent = api;
})(typeof globalThis === 'object' ? globalThis : this, function () {
  const tlsPorts = new Set(['443', '8443', '2096', '2087', '2083', '2053']);
  function quote(value) {
    return '"' + String(value).replace(/[\\"$`]/g, '\\$&') + '"';
  }
  function importCommand(text) {
    const value = pattern => {
      const match = text.match(pattern);
      return match ? (match[1] ?? match[2] ?? match[3]) : '';
    };
    const token = '(?:"([^"\\n]*)"|\'([^\'\\n]*)\'|([^\\s"\'|;&)]+))';
    const env = name => value(new RegExp('\\b' + name + '=' + token));
    const flag = names => value(new RegExp('(?:^|\\s)(?:' + names + ')(?:\\s+|=)' + token));
    const nezhaServer = env('NZ_SERVER');
    const komariServer = flag('-e|--endpoint|-server');
    const source = text.match(/https:\/\/raw\.githubusercontent\.com\/([\w.-]+\/[\w.-]+)\//)?.[1];
    const type = nezhaServer || /nezhahq|nezha-agent/.test(text) ? 'nezha'
      : komariServer || /komari/i.test(text) ? 'komari' : '';
    return {
      type,
      server: nezhaServer || komariServer || flag('-s|--server'),
      secret: env('NZ_CLIENT_SECRET') || flag('-t|--token|-secret|-key|-p|--password'),
      installDir: flag('--install-dir'),
      repo: type === 'komari' && source ? source : '',
      tls: env('NZ_TLS') === 'true' || /(?:^|\s)--tls(?:\s|$)/.test(text)
    };
  }
  function parseServer(server) {
    server = server.trim();
    const explicitScheme = /^https?:\/\//i.test(server);
    const url = new URL(explicitScheme ? server : 'https://' + server);
    if (!['http:', 'https:'].includes(url.protocol) || !url.hostname || url.username || url.password) {
      throw new Error('服务器地址须为域名、host:port 或 HTTP(S) URL');
    }
    const port = url.port || (url.protocol === 'https:' ? '443' : '80');
    if (!explicitScheme && !tlsPorts.has(port)) url.protocol = 'http:';
    return {host: url.hostname, port, tls: url.protocol === 'https:', endpoint: url.href};
  }
  function variables({type, server, secret, repo}) {
    if (!server || !secret) return {};
    const address = parseServer(server);
    const vars = {nz_type: type, nz_host: address.host, nz_port: address.port, nz_tls: address.tls ? '--tls' : '', nz_sec: secret};
    if (type === 'komari') {
      vars.nz_endpoint = address.endpoint;
      vars.nz_repo = repo || 'komari-monitor/komari-agent';
    }
    return vars;
  }
  function command({type, server, secret, repo, installDir, logMaxMB = 50, downloader = 'curl', mode = 'std'}) {
    const vars = variables({type, server, secret, repo});
    if (!vars.nz_sec) throw new Error('请先填写服务器地址和密钥，或粘贴安装命令导入');
    const binary = type + '-agent';
    const repository = vars.nz_repo || 'nezhahq/agent';
    if (!/^[\w.-]+\/[\w.-]+$/.test(repository) || repository.split('/').some(p => p === '.' || p === '..')) {
      throw new Error('下载来源须为 GitHub owner/repo');
    }
    const asset = type === 'komari' ? 'komari-agent-linux-$a' : 'nezha-agent_linux_$a.zip';
    const url = '"https://github.com/' + repository + '/releases/latest/download/' + asset + '"';
    const target = type === 'komari' ? binary + '.tmp' : 'nezha.zip';
    const lines = [];
    if (installDir) lines.push('mkdir -p ' + quote(installDir) + ' && cd ' + quote(installDir));
    lines.push('ARCH=$(uname -m) && case $ARCH in x86_64|amd64) a=amd64;; aarch64|arm64) a=arm64;; armv5*|armv6*|armv7*) a=arm;; *) echo "不支持的架构: $ARCH"; exit 1;; esac');
    lines.push(downloader === 'wget' ? 'wget --timeout=30 --tries=2 -O ' + target + ' ' + url
      : 'curl -fL --connect-timeout 10 --max-time 120 --retry 2 ' + url + ' -o ' + target);
    lines.push(type === 'komari' ? 'test -s ' + target + ' && chmod +x ' + target + ' && mv ' + target + ' ' + binary
      : 'unzip -qo nezha.zip && rm -f nezha.zip && chmod +x ' + binary);
    const prefix = mode === 'std' ? 'nohup ' : '';
    const run = type === 'komari'
      ? prefix + './komari-agent -e ' + quote(vars.nz_endpoint) + ' -t ' + quote(secret) + ' --disable-auto-update'
      : 'NZ_SERVER=' + quote(vars.nz_host + ':' + vars.nz_port) + ' NZ_CLIENT_SECRET=' + quote(secret) + ' NZ_TLS=' + (vars.nz_tls ? 'true' : 'false') + ' NZ_DISABLE_AUTO_UPDATE=true ' + prefix + './nezha-agent -c ./config.yml';
    const requestedSize = String(logMaxMB).trim();
    const logSize = /^\d+$/.test(requestedSize) && Number(requestedSize) >= 1 && Number(requestedSize) <= 1024 ? Number(requestedSize) : 50;
    const guard = 'p="$1"; limit="$2"; while kill -0 "$p" 2>/dev/null; do if [ -f agent.log ] && [ ! -L agent.log ] && [ "$(stat -c %h agent.log 2>/dev/null)" = 1 ]; then size=$(stat -c %s agent.log 2>/dev/null); [ "${size:-0}" -lt "$limit" ] || : > agent.log; fi; sleep 10; done';
    lines.push('( ' + run + ' >> agent.log 2>&1 & _agent_log_pid=$!; ' + prefix + 'sh -c ' + quote(guard) + ' _ "$_agent_log_pid" ' + quote(logSize * 1024 * 1024) + ' </dev/null >/dev/null 2>&1 & )');
    return lines.join(' && \\\n');
  }
  return {quote, importCommand, parseServer, variables, command};
});
