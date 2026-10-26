const test = require('node:test');
const assert = require('node:assert/strict');
const {execFileSync, spawnSync} = require('node:child_process');
const {mkdtempSync, writeFileSync, readFileSync, rmSync, readdirSync, statSync} = require('node:fs');
const {tmpdir} = require('node:os');
const path = require('node:path');
const script = readFileSync(path.join(__dirname, '../argosbx.sh'), 'utf8');
const fixture = 'tuic://11111111-1111-1111-1111-111111111111:test@[2001:db8::1]:20002?sni=example.com#中文节点';
const iosFixture = fixture + '-iOS';
const fn = name => {
  const start = script.indexOf(`${name}(){`);
  assert.notEqual(start, -1, name);
  return script.slice(start, script.indexOf('\n}\n', start) + 3);
};
const outputFunctions = ['_qr_terminal_print', '_qr_terminal_nodes', 'qr_terminal_output'].map(fn).join('\n');
const encoderFunctions = ['_qrencode_run', '_qrencode_apt', '_qrencode_apt_refresh', '_qrencode_local_install', '_qrencode_ensure'].map(fn).join('\n');
const temporary = action => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-terminal-'));
  try { return action(dir); } finally { rmSync(dir, {recursive: true, force: true}); }
};
const run = (dir, code, env = {}, shell = 'sh') => execFileSync(shell, ['-c', code], {
  env: {...process.env, AGSBX: dir, QR_TERM: '1', IOS_SHARE: '1', QR_SUBSCRIPTION_URL: '', QR_IOS_SUBSCRIPTION_URL: '', ...env}, encoding: 'utf8'
});
// This encoder double records exactly what the phone will receive, including stdin/flags.
const recordEncoder = `
_qrencode_ensure(){ printf 'ensure\\n' >> "$AGSBX/calls"; }
_qrencode_run(){ printf 'flags:%s\\n' "$*" >> "$AGSBX/calls"; cat >> "$AGSBX/payloads"; printf '\\n' >> "$AGSBX/payloads"; printf 'QR\\n'; }
`;

test('terminal choice defaults on, persists off, and explicit on overrides the saved value', () => temporary(dir => {
  const sync = (explicit, value) => run(dir, fn('_agsbx_qr_term_sync') + '\n_agsbx_qr_term_sync\nprintf %s "$QR_TERM"', {_qr_term_explicit: explicit, QR_TERM: value});
  assert.equal(sync('0', '1'), '1');
  assert.equal(sync('1', '0'), '0');
  assert.equal(sync('0', '1'), '0');
  assert.equal(sync('1', '1'), '1');
  assert.equal(readFileSync(path.join(dir, 'qr_term'), 'utf8'), '1\n');
}));

test('disabled terminal QR and missing nodes never attempt installation', () => temporary(dir => {
  const code = outputFunctions + '\n_qrencode_ensure(){ echo unexpected; return 1; }\nqr_terminal_output';
  assert.equal(run(dir, code), '');
  writeFileSync(path.join(dir, 'jh.txt'), fixture);
  assert.equal(run(dir, code, {QR_TERM: '0'}), '');
}));

test('current Gist subscriptions encode both versions, independent of webpage sharing', () => temporary(dir => {
  writeFileSync(path.join(dir, 'jh.txt'), fixture);
  writeFileSync(path.join(dir, 'jh-ios.txt'), iosFixture);
  const original = 'https://gist.github.com/example/123/raw/nodes.txt';
  const ios = 'https://gist.github.com/example/123/raw/nodes-ios.txt';
  const output = run(dir, outputFunctions + recordEncoder + '\nqr_terminal_output', {QR_SHARE: '0', QR_SUBSCRIPTION_URL: original, QR_IOS_SUBSCRIPTION_URL: ios});
  assert.match(output, /原版 · 全部节点订阅/);
  assert.match(output, /iOS 兼容版 · 全部节点订阅/);
  assert.equal(readFileSync(path.join(dir, 'payloads'), 'utf8'), original + '\n' + ios + '\n');
  assert.equal(readFileSync(path.join(dir, 'calls'), 'utf8'), 'ensure\nflags:-t UTF8 -l L -m 4\nflags:-t UTF8 -l L -m 4\n');
}));

test('absent Gist encodes separate UTF-8/IPv6 nodes, ignores blanks and keeps a final unterminated line', () => temporary(dir => {
  writeFileSync(path.join(dir, 'jh.txt'), '\n \t\n' + fixture + '\n' + fixture + '-2');
  writeFileSync(path.join(dir, 'jh-ios.txt'), iosFixture);
  const output = run(dir, outputFunctions + recordEncoder + '\nqr_terminal_output');
  assert.match(output, /原版 · 节点 2/);
  assert.match(output, /iOS 兼容版 · 节点 1/);
  assert.equal(readFileSync(path.join(dir, 'payloads'), 'utf8'), fixture + '\n' + fixture + '-2\n' + iosFixture + '\n');
}));

test('original-only choice excludes all iOS terminal payloads', () => temporary(dir => {
  writeFileSync(path.join(dir, 'jh.txt'), fixture);
  writeFileSync(path.join(dir, 'jh-ios.txt'), iosFixture);
  const output = run(dir, outputFunctions + recordEncoder + '\nqr_terminal_output', {IOS_SHARE: '0'});
  assert.doesNotMatch(output, /iOS/);
  assert.equal(readFileSync(path.join(dir, 'payloads'), 'utf8'), fixture + '\n');
}));

test('unavailable encoder is nonfatal, and an overflowing node does not stop later nodes', () => temporary(dir => {
  writeFileSync(path.join(dir, 'jh.txt'), 'overflow\n' + fixture);
  const unavailable = run(dir, outputFunctions + '\n_qrencode_ensure(){ echo unavailable; return 1; }\nqr_terminal_output');
  assert.equal(unavailable, 'unavailable\n');
  const output = run(dir, outputFunctions + `
    _qrencode_ensure(){ :; }
    _qrencode_run(){ payload=$(cat); [ "$payload" != overflow ] || return 1; printf 'OK:%s\\n' "$payload"; }
    qr_terminal_output
  `);
  assert.match(output, /节点过长/);
  assert.match(output, /原版 · 节点 2/);
  assert.ok(output.includes('OK:' + fixture));
}));

test('available system qrencode is reused without downloading anything', () => temporary(dir => {
  const output = run(dir, encoderFunctions + `
    qrencode(){ [ "$1" = -V ]; }
    _qrencode_local_install(){ echo unexpected-download; return 1; }
    _qrencode_ensure
    printf 'BIN:%s|LIB:%s' "$_qrencode_bin" "$_qrencode_libpath"
  `);
  assert.equal(output, 'BIN:qrencode|LIB:');
}));

test('nonroot Debian/Ubuntu installation extracts packages locally and reuses its cache', () => temporary(dir => {
  const output = run(dir, encoderFunctions + `
    apt-get(){ printf 'download\\n' >> "$AGSBX/downloads"; touch ./qrencode_test.deb ./libqrencode4_test.deb; }
    dpkg-deb(){
      mkdir -p "$3/usr/bin"
      printf '#!/bin/sh\\n[ "$1" = -V ] && exit 0\\nprintf "LOCAL_QR\\\\n"\\n' > "$3/usr/bin/qrencode"
      chmod +x "$3/usr/bin/qrencode"
    }
    qrencode(){ return 1; }
    _qrencode_ensure || exit 1
    _qrencode_run -t UTF8
    _qrencode_ensure || exit 1
  `, {}, 'bash');
  assert.match(output, /LOCAL_QR/);
  assert.equal(readFileSync(path.join(dir, 'downloads'), 'utf8'), 'download\n');
  assert.ok(readdirSync(dir).every(name => !name.startsWith('.qrencode-')));
}));

test('missing Ubuntu indexes retries with private signed main/universe sources and no update hooks', () => temporary(dir => {
  writeFileSync(path.join(dir, 'os-release'), 'ID=ubuntu\nVERSION_CODENAME=jammy\n');
  const code = encoderFunctions.replace('. /etc/os-release', '. "$AGSBX/os-release"') + `
    dpkg(){ printf 'amd64\\n'; }
    apt-get(){
      printf '%s\\n' "$*" >> "$AGSBX/apt-calls"
      case " $* " in
        *' update ')
          cp "$_qr_stage/sources.list" "$AGSBX/retry-sources"
          cp "$_qr_stage/apt.conf" "$AGSBX/retry-config"
          [ -d "$_qr_stage/lists/partial" ] && [ -d "$_qr_stage/cache/archives/partial" ]
          ;;
        *' download '*)
          if [ "$_qr_apt_private" = 0 ]; then
            echo 'E: Unable to locate package qrencode' >&2
            return 100
          fi
          touch ./qrencode_test.deb ./libqrencode4_test.deb
          ;;
        *) return 1 ;;
      esac
    }
    dpkg-deb(){
      mkdir -p "$3/usr/bin"
      printf '#!/bin/sh\\nexit 0\\n' > "$3/usr/bin/qrencode"
      chmod +x "$3/usr/bin/qrencode"
    }
    qrencode(){ return 1; }
    _qrencode_ensure || exit 1
    _qrencode_ensure || exit 1
  `;
  const output = run(dir, code, {}, 'bash');
  assert.match(output, /刷新独立 APT 索引/);
  assert.doesNotMatch(output, /安装不可用/);
  assert.equal(readFileSync(path.join(dir, 'retry-sources'), 'utf8'), 'deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://archive.ubuntu.com/ubuntu jammy main universe\n');
  assert.match(readFileSync(path.join(dir, 'retry-config'), 'utf8'), /#clear APT::Update::Post-Invoke-Success;/);
  assert.match(readFileSync(path.join(dir, 'retry-config'), 'utf8'), /#clear APT::Update::Pre-Invoke;/);
  assert.match(readFileSync(path.join(dir, 'retry-config'), 'utf8'), /#clear Acquire::IndexTargets;/);
  const calls = readFileSync(path.join(dir, 'apt-calls'), 'utf8').trim().split('\n');
  assert.equal(calls.length, 3);
  assert.ok(calls.slice(1).every(call => call.includes(`Dir::State::lists=${dir}/.qrencode-`) && call.includes('Dir::State::status=/dev/null') && call.includes('Dir::Etc::sourceparts=-')));
  assert.match(readFileSync(path.join(dir, 'qrencode-install.log'), 'utf8'), /Unable to locate package/);
  assert.equal(statSync(path.join(dir, 'qrencode-install.log')).mode & 0o777, 0o600);
  assert.ok(readdirSync(dir).every(name => !name.startsWith('.qrencode-')));
}));

test('APT download and refresh failures retain diagnostics and leave node output usable', () => temporary(dir => {
  writeFileSync(path.join(dir, 'jh.txt'), fixture);
  const output = run(dir, encoderFunctions + outputFunctions + `
    qrencode(){ return 1; }
    apt-get(){ echo 'E: temporary download failure' >&2; return 100; }
    _qrencode_apt_refresh(){ echo 'E: mirror unreachable' >> "$_qr_install_log"; return 1; }
    qr_terminal_output
    printf 'NODES:'; cat "$AGSBX/jh.txt"
  `, {}, 'bash');
  assert.match(output, /终端二维码已跳过/);
  assert.ok(output.includes(`安装失败详情：${dir}/qrencode-install.log`));
  assert.ok(output.includes('NODES:' + fixture));
  assert.match(readFileSync(path.join(dir, 'qrencode-install.log'), 'utf8'), /temporary download failure[\s\S]*mirror unreachable/);
  assert.ok(readdirSync(dir).every(name => !name.startsWith('.qrencode-')));
}));

test('minimal Ubuntu retries libpng from the same private APT metadata', () => temporary(dir => {
  const output = run(dir, encoderFunctions + `
    qrencode(){ return 1; }
    _qrencode_apt_refresh(){ _qr_apt_private=1; }
    apt-cache(){
      [ "$_qr_apt_private" = 1 ] || return 1
      printf 'qrencode\\n  Depends: libpng16-16\\n'
    }
    apt-get(){
      [ "$_qr_apt_private" = 1 ] || return 100
      case " $* " in
        *' download libpng16-16 '*) touch ./libpng16-16_test.deb ;;
        *' download qrencode libqrencode4 '*) touch ./qrencode_test.deb ./libqrencode4_test.deb ;;
        *) return 1 ;;
      esac
    }
    dpkg-deb(){
      mkdir -p "$3/usr/bin"
      case "$2" in
        *libpng*) touch "$3/png-ready" ;;
        *)
          printf '#!/bin/sh\\n[ -f "$AGSBX/qrencode-runtime/png-ready" ]\\n' > "$3/usr/bin/qrencode"
          chmod +x "$3/usr/bin/qrencode"
          ;;
      esac
    }
    _qrencode_ensure || exit 1
    printf 'READY\\n'
  `, {}, 'bash');
  assert.match(output, /READY/);
  assert.ok(readdirSync(dir).every(name => !name.startsWith('.qrencode-')));
}));

test('large Gist responses produce subscription URLs without broken pipes under bash pipefail', () => temporary(dir => {
  writeFileSync(path.join(dir, 'jh.txt'), fixture);
  writeFileSync(path.join(dir, 'gh_token'), 'test-token');
  writeFileSync(path.join(dir, 'name'), 'test');
  const response = '{\n  "id": "gist-first",\n' + '  "content": "' + 'x'.repeat(1024 * 1024) + '",\n' +
    '  "login": "example",\n' + '  "id": "other-id",\n  "login": "other-user",\n'.repeat(4096) + '}';
  writeFileSync(path.join(dir, 'response.json'), response);
  const result = spawnSync('bash', ['-c', fn('push_gist') + `
    curl(){
      case "$*" in
        *ip-api.com*) printf '{"countryCode":"XX"}' ;;
        *) cat "$AGSBX/response.json" ;;
      esac
    }
    set -o pipefail
    push_gist
    printf 'SUB:%s\\n' "$QR_SUBSCRIPTION_URL"
  `], {env: {...process.env, AGSBX: dir, hostname: 'test-host', IOS_SHARE: '0', gh_gist_id: ''}, encoding: 'utf8'});
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.stderr, '');
  assert.match(result.stdout, /Gist 推送成功/);
  assert.ok(result.stdout.includes('SUB:https://gist.github.com/example/gist-first/raw/test_XX_xr_test-host.txt'));
  assert.equal(readFileSync(path.join(dir, 'gh_gist_id'), 'utf8'), 'gist-first\n');
}));
