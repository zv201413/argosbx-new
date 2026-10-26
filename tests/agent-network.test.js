const test = require('node:test');
const assert = require('node:assert/strict');
const {execFileSync, spawnSync} = require('node:child_process');
const {mkdtempSync, readFileSync, writeFileSync, mkdirSync, existsSync, statSync, rmSync} = require('node:fs');
const {tmpdir} = require('node:os');
const path = require('node:path');
const vm = require('node:vm');
const agent = require('../assets/agent.js');
const script = readFileSync(path.join(__dirname, '../argosbx.sh'), 'utf8');
const html = readFileSync(path.join(__dirname, '../index.html'), 'utf8');
function fn(name) {
  const start = script.indexOf(name + '(){');
  assert.notEqual(start, -1, name);
  const rest = script.slice(start);
  const next = rest.slice(1).search(/\n[a-zA-Z_][a-zA-Z_0-9]*\(\)\s*\{/);
  return next < 0 ? rest : rest.slice(0, next + 1);
}
const networkFunctions = ['_public_ip_valid', '_public_ip', 'v4v6', 'warpsx'].map(fn).join('\n');
const agentFunctions = ['_agent_quote', '_agent_running', '_agent_stop', '_agent_download', '_agent_start', 'insnezha'].map(fn).join('\n');
const importText = '(command -v curl >/dev/null 2>&1 && curl -sL https://raw.githubusercontent.com/zv201413/komari-agent_new/refs/heads/main/install.sh || wget -qO- https://raw.githubusercontent.com/zv201413/komari-agent_new/refs/heads/main/install.sh) | bash -s -- -e https://p02--komari--example.code.run -t fixture-secret --install-dir /var/www';

test('Komari import preserves type, fork, full HTTPS endpoint and install directory in both commands', () => {
  const imported = agent.importCommand(importText);
  assert.deepEqual(imported, {type: 'komari', server: 'https://p02--komari--example.code.run', secret: 'fixture-secret', installDir: '/var/www', repo: 'zv201413/komari-agent_new', tls: false});
  const elements = {};
  const element = id => elements[id] ||= {value: '', addEventListener(event, handler) {this[event] = handler;}};
  element('nz_type').value = 'komari';
  const document = {getElementById: element, querySelector: selector => ({value: selector.includes('nzEnvMode') ? 'std' : 'curl'})};
  const varsCode = html.slice(html.indexOf('  function toBashVars('), html.indexOf('  function render(){'));
  const importCode = html.slice(html.indexOf('  // 导入时保留探针类型'), html.indexOf("  document.getElementById('generateNzBtn')"));
  const context = vm.createContext({ArgosbxAgent: agent, document, protoKeys: [], showToast() {}});
  vm.runInContext(varsCode + '\nfunction render(){globalThis.main = toBashVars({AGSBX_DIR: document.getElementById("AGSBX_DIR").value, nz_server: document.getElementById("nz_server").value, nz_sec: document.getElementById("nz_sec").value}).join(" ");}\n' + importCode, context);
  element('nezhaImportInput').value = importText;
  element('nezhaImportInput').input();
  assert.equal(element('AGSBX_DIR').value, '/var/www');
  assert.match(context.main, /AGSBX_DIR="\/var\/www"/);
  assert.match(context.main, /nz_type="komari"/);
  assert.match(context.main, /nz_repo="zv201413\/komari-agent_new"/);
  assert.match(context.main, /nz_endpoint="https:\/\/p02--komari--example.code.run\/"/);
  assert.match(element('nzOutput').value, /mkdir -p "\/var\/www" && cd "\/var\/www"/);
  assert.match(element('nzOutput').value, /zv201413\/komari-agent_new\/releases\/latest\/download/);
  assert.doesNotMatch(element('nzOutput').value, /nezha-agent/);
});

test('server parser keeps explicit HTTP/TLS, URL paths and bracketed IPv6', () => {
  assert.deepEqual(agent.parseServer('http://host.test:443/monitor'), {host: 'host.test', port: '443', tls: false, endpoint: 'http://host.test:443/monitor'});
  assert.deepEqual(agent.parseServer('https://[2001:db8::1]:8443/monitor/'), {host: '[2001:db8::1]', port: '8443', tls: true, endpoint: 'https://[2001:db8::1]:8443/monitor/'});
  assert.equal(agent.parseServer('host.test:8080').endpoint, 'http://host.test:8080/');
  assert.equal(agent.parseServer('host.test').port, '443');
  assert.throws(() => agent.parseServer('https://'));
});

test('Nezha imports use modern environment configuration and the actual release filename', () => {
  const imported = agent.importCommand('NZ_SERVER="host.test:5555" NZ_CLIENT_SECRET="test secret" NZ_TLS=true bash agent.sh');
  assert.equal(imported.type, 'nezha');
  assert.equal(imported.tls, true);
  const command = agent.command({...imported, server: 'https://' + imported.server});
  assert.match(command, /nezha-agent_linux_\$a.zip/);
  assert.match(command, /NZ_SERVER="host.test:5555" NZ_CLIENT_SECRET="test secret" NZ_TLS=true/);
  assert.doesNotMatch(command, /komari-agent| -s | -p |--tls/);
});

test('shell credentials remain literal, including quotes and shell substitutions', () => {
  const secret = 'a"b\'c $HOME `uname` $(uname) \\ end';
  assert.equal(execFileSync('sh', ['-c', 'printf %s ' + agent.quote(secret)], {encoding: 'utf8'}), secret);
  assert.equal(execFileSync('sh', ['-c', fn('_agent_quote') + '\nquoted=$(_agent_quote "$1"); eval "printf %s $quoted"', 'test', secret], {encoding: 'utf8'}), secret);
});

test('failed primary IP endpoint uses validated alternate IPv6 and retains IPv6 preferences', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-network-'));
  try {
    const output = execFileSync('sh', ['-c', `
      curl(){ case "$*" in *warp.xijp*) return 1;; *ip.fm*) return 0;; *icanhazip*) printf '<html>503</html>'; return 0;; *api64.ipify*) case "$*" in *' -6 '*) printf '2a14:dc81:6112:e800::1';; *) printf '46.243.53.17';; esac;; esac; }
      wget(){ return 1; }
      timeout(){ shift; "$@"; }
      ${networkFunctions}
      warpsx
      printf 'RESULT=%s|%s|%s|%s|%s' "$v4" "$v6" "$ippz" "$ippref" "$sbyx"
    `], {env: {...process.env, AGSBX: dir, v46url: 'https://icanhazip.com', ippz: '6', ippref: 'prefer_ipv6', name: '', wap: '', warp: '', v4: '', v6: ''}, encoding: 'utf8'});
    assert.match(output, /RESULT=46\.243\.53\.17\|2a14:dc81:6112:e800::1\|6\|prefer_ipv6\|prefer_ipv6/);
    assert.doesNotMatch(output, /未取得 IPv6/);
    assert.equal(readFileSync(path.join(dir, 'cf_ipv.txt'), 'utf8').trim(), 'auto');
  } finally {rmSync(dir, {recursive: true, force: true});}
});

test('IPv4-only first probe does not erase requested IPv6 preferences before IPv6 recovers', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-network-'));
  try {
    const output = execFileSync('sh', ['-c', `
      curl(){ case "$*" in *warp.xijp*) return 1;; *ip.fm*) return 0;; *) case "$*" in *' -6 '*) [ -f "$AGSBX/recovered" ] && printf '2a14:dc81:6112:e800::1';; *) printf '46.243.53.17';; esac;; esac; }
      wget(){ return 1; }
      timeout(){ shift; "$@"; }
      ${networkFunctions}
      warpsx
      printf 'FIRST=%s|%s|%s\n' "$ippz" "$ippref" "$sbyx"
      touch "$AGSBX/recovered"
      v4v6
      printf 'RECOVERED=%s|%s\n' "$ippz" "$v6"
      ${fn('ipchange')}
      sleep(){ :; }
      ipchange
      printf 'NODE=%s\n' "$(cat "$AGSBX/server_ip.log")"
      rm "$AGSBX/recovered"
      v4v6
      printf 'CACHED=%s' "$v6"
    `], {env: {...process.env, AGSBX: dir, v46url: 'https://icanhazip.com', ippz: '6', ippref: 'prefer_ipv6', name: '', wap: '', warp: '', v4: '', v6: ''}, encoding: 'utf8'});
    assert.match(output, /FIRST=6\|prefer_ipv6\|prefer_ipv6/);
    assert.match(output, /RECOVERED=6\|2a14:dc81:6112:e800::1/);
    assert.match(output, /NODE=\[2a14:dc81:6112:e800::1\]/);
    assert.match(output, /CACHED=2a14:dc81:6112:e800::1/);
    assert.equal(readFileSync(path.join(dir, 'cf_ipv.txt'), 'utf8').trim(), '4');
  } finally {rmSync(dir, {recursive: true, force: true});}
});

test('IP responses reject HTTP bodies, malformed IPs, multiple lines and the wrong family', () => {
  for (const [family, address, valid] of [[4, '46.243.53.17', true], [6, '2a14:dc81:6112:e800::1', true], [6, '2001:db8:1:2:3:4:5:6', true], [4, '999.0.0.1', false], [6, '503', false], [6, '2001:db8:::1', false], [6, '2001:db8:1:2:3:4:5:6:', false], [6, '::1\n::2', false], [4, '<html>error</html>', false], [6, '46.243.53.17', false]]) {
    const result = spawnSync('sh', ['-c', fn('_public_ip_valid') + '\n_public_ip_valid "$1" "$2"', 'test', family.toString(), address]);
    assert.equal(result.status === 0, valid, address);
  }
});

test('HTTP download failure returns early without creating a runnable agent or startup file', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-agent-'));
  try {
    const result = spawnSync('sh', ['-c', `curl(){ return 22; }; wget(){ return 1; }; ${agentFunctions}\ninsnezha`], {
      env: {...process.env, AGSBX: dir, nz_type: 'komari', nz_repo: 'zv201413/komari-agent_new', nz_host: 'host.test', nz_port: '443', nz_tls: '--tls', nz_endpoint: '', nz_sec: 'fixture-secret'}, encoding: 'utf8'
    });
    assert.equal(result.status, 1);
    assert.match(result.stdout, /探针下载失败/);
    assert.equal(existsSync(path.join(dir, 'komari/komari-agent')), false);
    assert.equal(existsSync(path.join(dir, 'komari/start.sh')), false);
  } finally {rmSync(dir, {recursive: true, force: true});}
});

test('integrated Komari and Nezha start from the chosen directory with their own arguments and logs', () => {
  for (const type of ['komari', 'nezha']) {
    const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-agent-'));
    const root = path.join(dir, 'agsbx');
    const target = path.join(root, type);
    mkdirSync(target, {recursive: true});
    const repo = 'zv201413/komari-agent_new';
    const source = type === 'komari' ? `https://github.com/${repo}/releases/latest/download/komari-agent-linux-amd64` : 'https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip';
    writeFileSync(path.join(target, 'source'), source);
    writeFileSync(path.join(target, type + '-agent'), '#!/bin/sh\nprintf "%s\\n" "$PWD" "$@" "$NZ_SERVER" "$NZ_CLIENT_SECRET" "$NZ_TLS" > args.txt\nwhile :; do sleep 1; done\n', {mode: 0o700});
    const secret = 'fixture $HOME "quote" \' $(uname)';
    const env = {...process.env, AGSBX: root, nz_type: type, nz_repo: repo, nz_host: 'host.test', nz_port: '443', nz_tls: '--tls', nz_endpoint: type === 'komari' ? 'https://host.test/monitor/' : '', nz_sec: secret};
    try {
      const result = execFileSync('sh', ['-c', `id(){ printf 1000; }; crontab(){ return 1; }; ${agentFunctions}\ninsnezha`], {env, encoding: 'utf8'});
      assert.match(result, /探针进程已启动/);
      const args = readFileSync(path.join(target, 'args.txt'), 'utf8').trim().split('\n');
      assert.equal(args[0], target);
      if (type === 'komari') {
        assert.deepEqual(args.slice(1, 6), ['-e', 'https://host.test/monitor/', '-t', secret, '--disable-auto-update']);
      } else {
        assert.deepEqual(args.slice(1), ['-c', path.join(target, 'config.yml'), 'host.test:443', secret, 'true']);
      }
      assert.equal(statSync(path.join(target, 'start.sh')).mode & 0o777, 0o700);
      assert.equal(existsSync(path.join(target, 'agent.log')), true);
    } finally {
      execFileSync('sh', ['-c', agentFunctions + '\n_agent_stop'], {env});
      rmSync(dir, {recursive: true, force: true});
    }
  }
});
