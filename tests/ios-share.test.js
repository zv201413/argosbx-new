const test = require('node:test');
const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');
const { mkdtempSync, readFileSync, writeFileSync } = require('node:fs');
const path = require('node:path');
const { tmpdir } = require('node:os');
const share = require('../assets/share.js');
const script = readFileSync(path.join(__dirname, '../argosbx.sh'), 'utf8');
const uuid = '11111111-1111-4111-8111-111111111111';
const pin = 'a%2Bb%2Fc%3D';
const host = '[2001:db8::1]';
function fn(name) {
  const start = script.indexOf(`${name}(){`);
  assert.notEqual(start, -1);
  return script.slice(start, script.indexOf('\n}\n', start) + 3);
}
function link(protocol, mode, password = uuid) {
  const name = protocol === 'hy2' ? 'share_hy2_link' : 'share_tuic_link';
  const args = protocol === 'hy2'
    ? [password, host, '20001', pin, '&mport=20001-20010', '中文 Hy2']
    : [uuid, password, host, '20002', pin, '中文 TUIC'];
  return execFileSync('sh', ['-c', `${fn('_share_urlencode')}\n${fn(name)}\n${name} "$@"`, 'test', ...args], {
    env: { ...process.env, IOS_SHARE: mode }, encoding: 'utf8'
  }).trim();
}

test('default desktop exports retain exactly the existing pin and TLS parameters', () => {
  assert.equal(link('hy2', '0'), `hysteria2://${uuid}@${host}:20001?security=tls&alpn=h3&insecure=0&allowInsecure=0&mport=20001-20010&sni=www.bing.com&pinSHA256=${pin}#中文 Hy2`);
  assert.equal(link('tuic', '0'), `tuic://${uuid}:${uuid}@${host}:20002?congestion_control=bbr&udp_relay_mode=native&alpn=h3&sni=www.bing.com&insecure=1&allowInsecure=1&pinSHA256=${pin}#中文 TUIC`);
});

test('iOS links select TUIC5, remove pins and set the phone-specific insecure flags', () => {
  const hy2 = new URL(link('hy2', '1'));
  const tuic = new URL(link('tuic', '1'));
  for (const uri of [hy2, tuic]) {
    assert.equal(uri.searchParams.has('pinSHA256'), false);
    assert.equal(uri.searchParams.has('allowInsecure'), false);
    assert.equal(uri.hostname, host);
    assert.equal(uri.searchParams.get('sni'), 'www.bing.com');
  }
  assert.equal(hy2.searchParams.get('insecure'), '1');
  assert.equal(hy2.searchParams.get('peer'), 'www.bing.com');
  assert.equal(hy2.searchParams.get('mport'), '20001-20010');
  assert.equal(tuic.searchParams.get('version'), '5');
  assert.equal(tuic.searchParams.get('allow_insecure'), '1');
  assert.equal(tuic.username, uuid);
  assert.equal(tuic.password, uuid);
  assert.match(link('tuic', '1'), new RegExp(`^tuic://${uuid}:`));
});

test('reserved characters and literal encoded-looking text survive one credential decode', () => {
  for (const password of ['a:b@c/?#&=+% 中文', '%3A%253A', '+plus space']) {
    const tuic = new URL(link('tuic', '1', password));
    assert.equal(decodeURIComponent(tuic.password), password);
    assert.equal(tuic.username, uuid);
    const hy2 = new URL(link('hy2', '1', password));
    assert.equal(decodeURIComponent(hy2.username), password);
  }
});

test('iOS variant defaults on, remembers manual off, and can be enabled again', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-ios-'));
  const run = (explicit, value) => execFileSync('sh', ['-c', `${fn('_agsbx_ios_sync')}\n_agsbx_ios_sync\nprintf '%s' "$IOS_SHARE"`], {
    env: { ...process.env, AGSBX: dir, _ios_share_explicit: explicit, IOS_SHARE: value }, encoding: 'utf8'
  });
  assert.equal(run('0', '1'), '1');
  assert.equal(run('1', '0'), '0');
  assert.equal(run('0', '1'), '0');
  assert.equal(run('1', '1'), '1');
  assert.equal(run('0', '1'), '1');
  assert.equal(run('1', 'invalid'), '1');
});

test('the QR page carries both intact originals and the separate iOS subscription contents', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-ios-'));
  const nodes = [link('hy2', '0').replaceAll(' ', '%20'), link('tuic', '0').replaceAll(' ', '%20')];
  const iosNodes = [link('hy2', '1').replaceAll(' ', '%20'), link('tuic', '1').replaceAll(' ', '%20')];
  writeFileSync(path.join(dir, 'jh.txt'), nodes.join('\n') + '\n');
  writeFileSync(path.join(dir, 'jh-ios.txt'), iosNodes.join('\n') + '\n');
  const subscription = 'https://gist.github.com/example/123/raw/nodes.txt';
  const iosSubscription = 'https://gist.github.com/example/123/raw/nodes-ios.txt';
  execFileSync('sh', ['-c', `${fn('qr_share_output')}\nqr_share_output`], {
    env: { ...process.env, AGSBX: dir, QR_SHARE: '1', IOS_SHARE: '1', QR_SUBSCRIPTION_URL: subscription, QR_IOS_SUBSCRIPTION_URL: iosSubscription }
  });
  const url = new URL(readFileSync(path.join(dir, 'qr-share-url.txt'), 'utf8').trim());
  assert.deepEqual(share.parseShare(url.hash), { nodes, iosNodes, subscription, iosSubscription, skipped: 0 });
  execFileSync('sh', ['-c', `${fn('qr_share_output')}\nqr_share_output`], {
    env: { ...process.env, AGSBX: dir, QR_SHARE: '1', IOS_SHARE: '0', QR_SUBSCRIPTION_URL: subscription, QR_IOS_SUBSCRIPTION_URL: iosSubscription }
  });
  const disabled = share.parseShare(new URL(readFileSync(path.join(dir, 'qr-share-url.txt'), 'utf8').trim()).hash);
  assert.deepEqual(disabled.nodes, nodes);
  assert.deepEqual(disabled.iosNodes, []);
  assert.equal(disabled.iosSubscription, '');
});

test('appending compatible output never replaces the original and preserves other protocols', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-ios-'));
  const original = link('tuic', '0');
  const compatible = link('tuic', '1');
  const other = 'vless://test@127.0.0.1:1234?security=none';
  const run = mode => execFileSync('sh', ['-c', `${fn('_share_append')}\n_share_append "$1" "$2"\n_share_append "$3"`, 'test', original, compatible, other], {
    env: { ...process.env, AGSBX: dir, IOS_SHARE: mode }
  });
  run('1');
  assert.equal(readFileSync(path.join(dir, 'jh.txt'), 'utf8'), original + '\n' + other + '\n');
  assert.equal(readFileSync(path.join(dir, 'jh-ios.txt'), 'utf8'), compatible + '\n' + other + '\n');
  writeFileSync(path.join(dir, 'jh-ios.txt'), '');
  run('0');
  assert.equal(readFileSync(path.join(dir, 'jh-ios.txt'), 'utf8'), '');
});

test('Gist publishes separate original and compatible files, with original-only output when disabled', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-ios-'));
  const original = link('tuic', '0');
  const compatible = link('tuic', '1');
  writeFileSync(path.join(dir, 'gh_token'), 'test-token');
  writeFileSync(path.join(dir, 'jh.txt'), original + '\n');
  writeFileSync(path.join(dir, 'jh-ios.txt'), compatible + '\n');
  const code = `curl(){ case "$*" in *ip-api.com*) printf '%s' '{"countryCode":"XX"}'; return;; esac; while [ "$#" -gt 0 ]; do if [ "$1" = -d ]; then shift; printf '%s' "$1" > "$AGSBX/payload.json"; break; fi; shift; done; printf '%s' '{"id": "123", "owner": {"login": "example"}}'; }\n${fn('push_gist')}\npush_gist`;
  const run = mode => execFileSync('sh', ['-c', code], { env: { ...process.env, AGSBX: dir, hostname: 'fixture', IOS_SHARE: mode }, encoding: 'utf8' });
  const enabled = run('1');
  let files = JSON.parse(readFileSync(path.join(dir, 'payload.json'), 'utf8')).files;
  assert.equal(files['agsbx_XX_xr_fixture.txt'].content, original);
  assert.equal(files['agsbx_XX_xr_fixture_ios.txt'].content, compatible);
  assert.match(enabled, /iOS 兼容版订阅链接/);
  const disabled = run('0');
  files = JSON.parse(readFileSync(path.join(dir, 'payload.json'), 'utf8')).files;
  assert.deepEqual(Object.keys(files), ['agsbx_XX_xr_fixture.txt']);
  assert.equal(files['agsbx_XX_xr_fixture.txt'].content, original);
  assert.doesNotMatch(disabled, /iOS 兼容版订阅链接/);
});

test('mismatched and executable compatibility payloads are rejected', () => {
  const encode = value => Buffer.from(value).toString('base64url');
  const original = link('tuic', '0');
  assert.throws(() => share.parseShare('#nodes=' + encode(original) + '&ios=' + encode('javascript:alert(1)')));
  assert.throws(() => share.parseShare('#nodes=' + encode(original) + '&ios=' + encode(original + '\n' + original)));
});
