const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const { spawn, execFileSync } = require('node:child_process');
const { once } = require('node:events');
const agent = require('../assets/agent');

const source = fs.readFileSync(path.join(__dirname, '../argosbx.sh'), 'utf8');
const worker = source.match(/cat <<'LOG_GUARD'\n([\s\S]+?)\nLOG_GUARD/)[1];
const sync = source.match(/_agsbx_log_sync\(\)\{[\s\S]+?\n\}/)[0];
const MiB = 1024 * 1024;
function fixture(t) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'argosbx-logs-'));
  t.after(() => fs.rmSync(dir, {recursive: true, force: true}));
  fs.writeFileSync(path.join(dir, 'log-limit.sh'), worker);
  fs.writeFileSync(path.join(dir, 'log_max_mb'), '1\n');
  return dir;
}

test('log size persists, reloads and rejects invalid values without shell evaluation', t => {
  const dir = fixture(t);
  function configure(value, explicit = '1') {
    execFileSync('sh', ['-c', sync + '\n_agsbx_log_sync'], {env: {...process.env, AGSBX: dir, LOG_MAX_MB: value, _log_max_explicit: explicit}});
    return fs.readFileSync(path.join(dir, 'log_max_mb'), 'utf8').trim();
  }
  assert.equal(configure('100'), '100');
  assert.equal(configure('50', '0'), '100');
  assert.equal(configure('00010'), '10');
  for (const value of ['', '0', '-1', '1025', '1.5', '1e2', '50;touch bad']) assert.equal(configure(value), '50');
});

test('guard caps runtime logs and preserves tunnel discovery, metadata and append descriptors', t => {
  const dir = fixture(t);
  fs.mkdirSync(path.join(dir, 'komari'));
  for (const name of ['xray.log', 'sing-box.log', 'komari/agent.log', 'argo.log', 'sbargotoken.log', 'server_ip.log', 'argoport.log']) {
    fs.writeFileSync(path.join(dir, name), name === 'argo.log' ? 'Requesting tunnel at trycloudflare.com\nhttps://fixture.trycloudflare.com\n' : 'metadata');
    fs.truncateSync(path.join(dir, name), MiB + 100);
  }
  const appendFd = fs.openSync(path.join(dir, 'xray.log'), 'a');
  t.after(() => fs.closeSync(appendFd));
  execFileSync('sh', [path.join(dir, 'log-limit.sh'), '--once']);
  for (const name of ['xray.log', 'sing-box.log', 'komari/agent.log']) assert.equal(fs.statSync(path.join(dir, name)).size, 0);
  fs.writeSync(appendFd, 'new log\n');
  assert.equal(fs.statSync(path.join(dir, 'xray.log')).size, 8);
  const domain = execFileSync('sh', ['-c', 'grep -a trycloudflare.com "$1" | awk \'NR==2{print}\' | awk -F// \'{print $2}\' | awk \'{print $1}\'', 'test', path.join(dir, 'argo.log')], {encoding: 'utf8'}).trim();
  assert.equal(domain, 'fixture.trycloudflare.com');
  assert.ok(fs.statSync(path.join(dir, 'argo.log')).size < MiB);
  for (const name of ['sbargotoken.log', 'server_ip.log', 'argoport.log']) assert.equal(fs.statSync(path.join(dir, name)).size, MiB + 100);
});

test('guard does not truncate symlinks, hardlinks or an external probe directory', t => {
  const dir = fixture(t);
  const outside = fs.mkdtempSync(path.join(os.tmpdir(), 'argosbx-outside-'));
  t.after(() => fs.rmSync(outside, {recursive: true, force: true}));
  fs.writeFileSync(path.join(outside, 'agent.log'), 'keep');
  fs.truncateSync(path.join(outside, 'agent.log'), 2 * MiB);
  fs.symlinkSync(outside, path.join(dir, 'komari'));
  fs.symlinkSync(path.join(outside, 'agent.log'), path.join(dir, 'argo.log'));
  fs.linkSync(path.join(outside, 'agent.log'), path.join(dir, 'xray.log'));
  execFileSync('sh', [path.join(dir, 'log-limit.sh'), '--once']);
  assert.equal(fs.statSync(path.join(outside, 'agent.log')).size, 2 * MiB);
});

test('guard runs as one instance and exits promptly on stop', async t => {
  const dir = fixture(t);
  const child = spawn('sh', [path.join(dir, 'log-limit.sh')], {stdio: 'ignore'});
  const exited = once(child, 'exit');
  t.after(() => child.kill());
  for (let i = 0; i < 50 && !fs.existsSync(path.join(dir, 'log-limit.pid')); i++) await new Promise(resolve => setTimeout(resolve, 20));
  assert.equal(fs.readFileSync(path.join(dir, 'log-limit.pid'), 'utf8').trim(), String(child.pid));
  execFileSync('sh', [path.join(dir, 'log-limit.sh')], {timeout: 2000});
  child.kill('SIGTERM');
  await Promise.race([exited, new Promise((_, reject) => { const timer = setTimeout(() => reject(new Error('guard failed to stop')), 2000); timer.unref(); })]);
  assert.equal(fs.existsSync(path.join(dir, 'log-limit.pid')), false);
});

test('standalone probe commands apply the requested size in both modes with valid shell syntax', () => {
  for (const mode of ['std', 'res']) {
    const command = agent.command({type: 'komari', server: 'https://example.test', secret: 'fixture-token', logMaxMB: 100, mode});
    execFileSync('sh', ['-n', '-c', command]);
    assert.ok(command.includes('"104857600"'));
    assert.match(command, />> agent\.log/);
  }
  const fallback = agent.command({type: 'nezha', server: 'https://example.test', secret: 'fixture-token', logMaxMB: '0'});
  assert.ok(fallback.includes('"52428800"'));
});
