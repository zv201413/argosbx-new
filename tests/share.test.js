const test = require('node:test');
const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');
const { mkdtempSync, writeFileSync, readFileSync } = require('node:fs');
const { tmpdir } = require('node:os');
const path = require('node:path');
const share = require('../assets/share.js');
const qrcode = require('../assets/vendor/qrcode.js');
const script = readFileSync(path.join(__dirname, '../argosbx.sh'), 'utf8');
const fixture = 'tuic://11111111-1111-1111-1111-111111111111:test@[2001:db8::1]:20002?sni=example.com&alpn=h3#中文节点';
const encode = text => Buffer.from(text).toString('base64url');
const shellFunction = name => {
  const start = script.indexOf(`${name}(){`);
  assert.notEqual(start, -1);
  return script.slice(start, script.indexOf('\n}\n', start) + 3);
};

test('shell output opens as the original UTF-8/IPv6 node and a compact Gist subscription', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-share-'));
  writeFileSync(path.join(dir, 'jh.txt'), fixture + '\n\n');
  const subscription = 'https://gist.github.com/example/123/raw/nodes.txt';
  execFileSync('sh', ['-c', `${shellFunction('qr_share_output')}\nqr_share_output`], {
    env: { ...process.env, AGSBX: dir, QR_SHARE: '1', QR_SUBSCRIPTION_URL: subscription }
  });
  const url = new URL(readFileSync(path.join(dir, 'qr-share-url.txt'), 'utf8').trim());
  assert.equal(url.search, '');
  assert.equal(url.pathname, '/argosbx-new/share.html');
  assert.deepEqual(share.parseShare(url.hash), { nodes: [fixture], iosNodes: [], subscription, iosSubscription: '', skipped: 0 });
  assert.equal(share.nodeName(fixture, 0), '1. 中文节点');
});

test('absent subscription falls back to nodes, disabled sharing prints nothing', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-share-'));
  writeFileSync(path.join(dir, 'jh.txt'), fixture);
  const run = enabled => execFileSync('sh', ['-c', `${shellFunction('qr_share_output')}\nqr_share_output`], {
    env: { ...process.env, AGSBX: dir, QR_SHARE: enabled, QR_SUBSCRIPTION_URL: '' }, encoding: 'utf8'
  });
  assert.equal(run('0'), '');
  assert.match(run('1'), /逐节点二维码/);
  const data = share.parseShare(new URL(readFileSync(path.join(dir, 'qr-share-url.txt'), 'utf8').trim()).hash);
  assert.equal(data.subscription, '');
  assert.deepEqual(data.nodes, [fixture]);
});

test('off remains off on list, explicit on overrides the saved switch', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-share-'));
  const run = (explicit, enabled) => execFileSync('sh', ['-c', `${shellFunction('_agsbx_qr_sync')}\n_agsbx_qr_sync\nprintf '%s' "$QR_SHARE"`], {
    env: { ...process.env, AGSBX: dir, _qr_share_explicit: explicit, QR_SHARE: enabled }, encoding: 'utf8'
  });
  assert.equal(run('0', '1'), '1');
  assert.equal(run('1', '0'), '0');
  assert.equal(run('0', '1'), '0');
  assert.equal(run('1', '1'), '1');
});

test('failed Gist push cannot retain an older aggregation URL', () => {
  const dir = mkdtempSync(path.join(tmpdir(), 'argosbx-share-'));
  writeFileSync(path.join(dir, 'gh_token'), 'test-token');
  writeFileSync(path.join(dir, 'jh.txt'), fixture);
  const code = `curl(){ printf '%s' '{"message":"test failure"}'; }\n${shellFunction('push_gist')}\npush_gist\nprintf '\\nSUB=%s\\nIOS_SUB=%s' "$QR_SUBSCRIPTION_URL" "$QR_IOS_SUBSCRIPTION_URL"`;
  const output = execFileSync('sh', ['-c', code], {
    env: { ...process.env, AGSBX: dir, QR_SUBSCRIPTION_URL: 'https://gist.github.com/stale/id/raw/nodes.txt', QR_IOS_SUBSCRIPTION_URL: 'https://gist.github.com/stale/id/raw/nodes-ios.txt' }, encoding: 'utf8'
  });
  assert.match(output, /Gist 推送失败/);
  assert.match(output, /\nSUB=\nIOS_SUB=$/);
});

test('share payload ignores executable schemes and rejects invalid base64 or malformed UTF-8', () => {
  const data = share.parseShare('#nodes=' + encode(fixture + '\njavascript:alert(1)\nhttps://example.com'));
  assert.deepEqual(data.nodes, [fixture]);
  assert.equal(data.skipped, 2);
  assert.throws(() => share.parseShare('#nodes=!!!'));
  assert.throws(() => share.decodeBase64Url('_w'));
  const unsafeSub = share.parseShare('#nodes=' + encode(fixture) + '&sub=' + encode('https://example.com/nodes'));
  assert.equal(unsafeSub.subscription, '');
});

test('VMess JSON names and percent-encoded labels display correctly', () => {
  const uri = 'vmess://' + Buffer.from(JSON.stringify({ ps: '测试 VMess' })).toString('base64');
  assert.equal(share.nodeName(uri, 2), '3. 测试 VMess');
  assert.equal(share.nodeName(fixture.replace('中文节点', '%E4%B8%AD%E6%96%87'), 0), '1. 中文');
});

test('actual QR generator supports UTF-8 and reports payload overflow', () => {
  const svg = share.makeQrSvg(fixture, qrcode);
  assert.match(svg, /<svg/);
  assert.match(svg, /viewBox=/);
  assert.throws(() => share.makeQrSvg('x'.repeat(4000), qrcode));
});
