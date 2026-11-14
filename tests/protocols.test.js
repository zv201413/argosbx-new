const test = require('node:test');
const assert = require('node:assert/strict');
const {execFileSync} = require('node:child_process');
const {mkdtempSync, readFileSync, writeFileSync, symlinkSync} = require('node:fs');
const {tmpdir} = require('node:os');
const path = require('node:path');
const vm = require('node:vm');
const script = readFileSync(path.join(__dirname, '../argosbx.sh'), 'utf8');
const html = readFileSync(path.join(__dirname, '../index.html'), 'utf8');
const uuid = '11111111-1111-4111-8111-111111111111';
const defaults = Object.fromEntries(['vlp','xhp','vxp','xup','xcp','vwp','vmp','sop','hyp','tup','anp','arp','ssp','XRAY_FORCE_MODE','port_vw_enc','tls_cert','tls_key','tls_sni','port_xu','port_xc','port_hy2','port_vl_re_enc','port_xh_enc','port_vx_enc'].map(k => [k, '']));
function fn(name) {
  const start = script.indexOf(`${name}(){`);
  assert.notEqual(start, -1, name);
  const end = script.slice(start).search(name === '_agsbx_ext_sync' ? /\n}\n/ : /\n}\n(?=\n|$)/);
  assert.notEqual(end, -1, name);
  return script.slice(start, start + end + 3);
}
const defs = (...names) => names.map(fn).join('\n');
const fixture = () => mkdtempSync(path.join(tmpdir(), 'argosbx-protocol-'));
function shell(code, env = {}, interpreter = 'sh') {
  return execFileSync(interpreter, ['-c', code], {env: {...process.env, ...defaults, ...env}, encoding: 'utf8'});
}

test('automatic protocols use one core, with ENC and container fallback represented in the core choice', () => {
  const cases = [
    [{hyp:'yes'}, '0/1'], [{vwp:'yes'}, '0/1'], [{vmp:'yes',sop:'yes'}, '0/1'],
    [{vwp:'yes',port_vw_enc:'y'}, '1/0'], [{vwp:'yes',port_vw_enc:'0'}, '0/1'],
    [{vlp:'yes',hyp:'yes'}, '1/0'], [{xup:'yes',hyp:'yes'}, '1/0'],
    [{xcp:'yes',tup:'yes'}, '1/1'], [{tup:'yes',vwp:'yes',port_vw_enc:'1'}, '1/1'],
    [{XRAY_FORCE_MODE:'1',hyp:'yes'}, '1/0']
  ];
  for (const [env, expected] of cases) {
    assert.equal(shell(`${defs('_agsbx_enc_enabled','_agsbx_core_plan')}\n_agsbx_core_plan\nprintf '%s/%s' "$NEED_XRAY" "$NEED_SB"`, env), expected);
  }
});

test('installed ENC survives a new shell without flags, including compact JSON and quoted braces', () => {
  const dir = fixture();
  execFileSync('mkdir', ['-p', path.join(dir, 'xrk')]);
  writeFileSync(path.join(dir, 'xrk/enkey'), 'mlkem768x25519plus.native.0rtt.test-client-key\n');
  const tags = ['xhttp-reality','vless-xhttp','reality-vision','vless-ws-xr'];
  for (let mask = 0; mask < 16; mask++) {
    const config = {log: {note: 'quoted braces { } and escaped "'}, inbounds: tags.map((tag,i) => ({settings: {clients: [{id:uuid}], decryption: mask & (1<<i) ? 'server-key' : 'none'}, tag})), outbounds: []};
    for (const indent of [undefined, 2]) {
      writeFileSync(path.join(dir, 'xr.json'), JSON.stringify(config, null, indent));
      for (let i=0; i<tags.length; i++) {
        const result = shell(`${defs('_agsbx_inbound_field','_agsbx_vless_encryption')}\n_agsbx_vless_encryption '${tags[i]}'`, {AGSBX:dir});
        assert.equal(result.trim(), mask & (1<<i) ? 'mlkem768x25519plus.native.0rtt.test-client-key' : 'none');
      }
    }
  }
});

test('new public ports persist and read back under sh/dash/bash without changing listener ports', () => {
  for (const interpreter of ['sh','dash','bash']) {
    const dir = fixture();
    const code = `${fn('_agsbx_ext_sync')}\n_agsbx_ext_sync port_xu_ext "$AGSBX/port_xu_ext"\n_agsbx_ext_sync port_xc_ext "$AGSBX/port_xc_ext"\nprintf '%s/%s/%s/%s' "$port_xu" "$port_xc" "$port_xu_ext" "$port_xc_ext"`;
    assert.equal(shell(code, {AGSBX:dir,port_xu:'10443',port_xc:'10444',port_xu_ext:'22443',port_xc_ext:'8443'}, interpreter), '10443/10444/22443/8443');
    assert.equal(shell(code, {AGSBX:dir,port_xu:'10443',port_xc:'10444',port_xu_ext:'',port_xc_ext:''}, interpreter), '10443/10444/22443/8443');
  }
});

test('TLS links preserve IPv6, public ports, paths and the correct certificate pin format', () => {
  const dir = fixture();
  const hex = 'ab'.repeat(32);
  const result = shell(`${defs('_share_urlencode','share_xhttp_tls_link')}\nshare_xhttp_tls_link '${uuid}' '[2001:db8::1]' 22443 example.com xu h3 '${hex}' '中文 UDP'`);
  const uri = new URL(result.trim());
  assert.equal(uri.port, '22443');
  assert.equal(uri.hostname, '[2001:db8::1]');
  assert.equal(uri.searchParams.get('path'), `/${uuid}-xu`);
  assert.equal(uri.searchParams.get('encryption'), 'none');
  assert.equal(uri.searchParams.get('alpn'), 'h3');
  assert.equal(uri.searchParams.get('pcs'), hex);
  assert.equal(decodeURIComponent(uri.hash), '#中文 UDP');
  shell(`${fn('_share_append')}\n_share_append "$TEST_LINK"`, {AGSBX:dir,IOS_SHARE:'1',TEST_LINK:uri.href});
  assert.equal(readFileSync(path.join(dir,'jh.txt'),'utf8'), readFileSync(path.join(dir,'jh-ios.txt'),'utf8'));
});

test('browser command collection includes new port pairs and only selected protocol ENC switches', () => {
  const elements = new Map();
  for (const k of ['vlpt','xhpt','vxpt','vwpt','xupt','xcpt']) {
    elements.set(`[data-proto="${k}"]`, {checked:['xupt','xcpt','vwpt'].includes(k)});
    elements.set(`[data-port="${k}"]`, {value:k==='xupt'?'10443':k==='xcpt'?'10444':''});
    elements.set(`[data-extport="${k}"]`, {value:k==='xupt'?'22443':k==='xcpt'?'8443':''});
    elements.set(`[data-enc="${k}"]`, {checked:true});
  }
  const context = vm.createContext({protoKeys:['vlpt','xhpt','vxpt','vwpt','xupt','xcpt'], optIds:['tls_cert'], document:{querySelector:s => elements.get(s), getElementById:() => ({value:'/cert.pem'})}, argoSelect:{value:''}});
  const body = html.slice(html.indexOf('  function collectVars(){'), html.indexOf('  function toBashVars(m){'));
  vm.runInContext(body, context);
  const vars = JSON.parse(JSON.stringify(context.collectVars()));
  assert.deepEqual(vars, {vwpt:'',vwpt_ext:'',xupt:'10443',xupt_ext:'22443',xcpt:'10444',xcpt_ext:'8443',vwpt_enc:'y',tls_cert:'/cert.pem'});
});

test('self-signed certificate is reused and malformed custom TLS pairs are rejected', () => {
  const dir = fixture();
  shell(`${defs('_agsbx_cert_ensure','_agsbx_tls_setup')}\n_agsbx_tls_setup`, {AGSBX:dir});
  const cert = readFileSync(path.join(dir,'cert.crt'));
  const pin = readFileSync(path.join(dir,'PUBKEY_SHA256_B64.txt'),'utf8');
  shell(`${fn('_agsbx_cert_ensure')}\n_agsbx_cert_ensure`, {AGSBX:dir});
  assert.deepEqual(readFileSync(path.join(dir,'cert.crt')), cert);
  assert.equal(Buffer.from(pin.trim(),'base64').length,32);
  assert.throws(() => shell(`${defs('_agsbx_cert_ensure','_agsbx_tls_setup')}\n_agsbx_tls_setup`, {AGSBX:dir,tls_cert:path.join(dir,'cert.crt')}));
  assert.throws(() => shell(`${defs('_agsbx_cert_ensure','_agsbx_tls_setup')}\n_agsbx_tls_setup`, {AGSBX:dir,tls_cert:path.join(dir,'cert.crt'),tls_key:path.join(dir,'private.key'),tls_sni:'wrong.example'}));
});

test('Hy2 and both XHTTP TLS inbounds pass the actual Xray core config check', {skip: !process.env.ARGOSBX_TEST_XRAY}, () => {
  const dir = fixture();
  symlinkSync(process.env.ARGOSBX_TEST_XRAY, path.join(dir,'xray'));
  shell(`${defs('_agsbx_cert_ensure','_agsbx_tls_setup','_agsbx_json_string','_agsbx_xhttp_tls','xrsbhy2')}\n_agsbx_tls_setup\nprintf '{"inbounds":[' > "$AGSBX/xr.json"\n_agsbx_xhttp_tls xu 10443 '\"h3\"'\n_agsbx_xhttp_tls xc 10444 '\"h2\",\"http/1.1\"'\nxrsbhy2\nsed -i '\${s/,[[:space:]]*$//}' "$AGSBX/xr.json"\nprintf '],"outbounds":[{"protocol":"freedom"}]}' >> "$AGSBX/xr.json"\n"$AGSBX/xray" run -test -c "$AGSBX/xr.json"`, {AGSBX:dir,uuid,hyp:'yes',port_hy2:'10445'});
  const config = JSON.parse(readFileSync(path.join(dir,'xr.json'),'utf8'));
  assert.deepEqual(config.inbounds.map(i=>i.port), [10443,10444,10445]);
  assert.deepEqual(config.inbounds.map(i=>i.streamSettings.tlsSettings.alpn), [['h3'],['h2','http/1.1'],['h3']]);
});

test('Hy2 follows Sing-box when no Xray config exists and passes its core check', {skip: !process.env.ARGOSBX_TEST_SINGBOX}, () => {
  const dir = fixture();
  shell(`${defs('_agsbx_cert_ensure','_agsbx_json_string','xrsbhy2')}\nprintf '{"inbounds":[' > "$AGSBX/sb.json"\nxrsbhy2\nsed -i '\${s/,[[:space:]]*$//}' "$AGSBX/sb.json"\nprintf '],"outbounds":[{"type":"direct","tag":"direct"}]}' >> "$AGSBX/sb.json"`, {AGSBX:dir,uuid,hyp:'yes',port_hy2:'10445'});
  execFileSync(process.env.ARGOSBX_TEST_SINGBOX, ['check','-c',path.join(dir,'sb.json')]);
  assert.equal(JSON.parse(readFileSync(path.join(dir,'sb.json'),'utf8')).inbounds[0].listen_port, 10445);
});

test('full Xray installation preserves each independent ENC choice and generates new TLS listeners', {skip: !process.env.ARGOSBX_TEST_XRAY}, () => {
  const dir = fixture();
  symlinkSync(process.env.ARGOSBX_TEST_XRAY, path.join(dir,'xray'));
  for (let mask=0; mask<16; mask++) {
    const env = {AGSBX:dir,uuid,vlp:'yes',xhp:'yes',vxp:'yes',vwp:'yes',xup:'yes',xcp:'yes',port_vl_re:'10441',port_xh:'10442',port_vx:'10443',port_vw:'10444',port_xu:'10445',port_xc:'10446'};
    for (const [i,k] of ['port_vl_re_enc','port_xh_enc','port_vx_enc','port_vw_enc'].entries()) env[k]=mask & (1<<i) ? 'y' : '0';
    const helpers=defs('insuuid','_agsbx_cert_ensure','_agsbx_enc_enabled','_agsbx_json_string','_agsbx_tls_setup','_agsbx_xhttp_tls','installxray','xrsbvm');
    shell(`${helpers}\ninstallxray\nxrsbvm\nsed -i '\${s/,[[:space:]]*$//}' "$AGSBX/xr.json"\nprintf '],"outbounds":[{"protocol":"freedom"}]}' >> "$AGSBX/xr.json"\n"$AGSBX/xray" run -test -c "$AGSBX/xr.json"`, env);
    const config=JSON.parse(readFileSync(path.join(dir,'xr.json'),'utf8'));
    for (const [i,tag] of ['reality-vision','xhttp-reality','vless-xhttp','vless-ws-xr'].entries()) {
      const dec=config.inbounds.find(b=>b.tag===tag).settings.decryption;
      assert.equal(dec==='none', !(mask & (1<<i)), `${mask}/${tag}`);
      assert.ok(dec.length > 0);
    }
    assert.equal(config.inbounds.find(b=>b.tag==='xhttp-tls-xu').settings.decryption,'none');
    assert.equal(config.inbounds.find(b=>b.tag==='xhttp-tls-xc').settings.decryption,'none');
  }
});

test('list exports effective ENC and both new public ports from installed state without flag variables', () => {
  const dir=fixture();
  execFileSync('mkdir',['-p',path.join(dir,'xrk')]);
  writeFileSync(path.join(dir,'xray'),'fixture');
  writeFileSync(path.join(dir,'uuid'),uuid);
  writeFileSync(path.join(dir,'xrk/enkey'),'mlkem768x25519plus.native.0rtt.client-key');
  for (const [k,v] of Object.entries({vl_re:10441,xh:10442,vx:10443,vw:10444,xu:10445,xc:10446,hy2:10447})) writeFileSync(path.join(dir,`port_${k}`),String(v));
  const tags=['reality-vision','xhttp-reality','vless-xhttp','vless-ws-xr'];
  writeFileSync(path.join(dir,'xr.json'),JSON.stringify({inbounds:[...tags.map((tag,i)=>({tag,settings:{decryption:i%2?'none':'server-key'}})),{tag:'xhttp-tls-xu'},{tag:'xhttp-tls-xc'},{tag:'hy2-xr'}]}));
  shell(`${defs('_agsbx_cert_ensure','_agsbx_tls_setup')}\n_agsbx_tls_setup`, {AGSBX:dir});
  const start=script.indexOf('node_output(){');
  const end=script.indexOf('\nshowmode(){',start);
  const helpers=defs('_share_urlencode','_share_append','share_xhttp_tls_link','share_hy2_link','_agsbx_inbound_field','_agsbx_vless_encryption');
  const code=`${helpers}\n${script.slice(start,end)}\nv4v6(){ :; }\nsleep(){ :; }\niptables(){ :; }\ncurl(){ printf '%s' '{"countryCode":"ZZ"}'; }\nnode_output`;
  shell(code,{AGSBX:dir,IOS_SHARE:'1',ippz:'4',v4:'203.0.113.1',argoip:'cdn.example.com',hostname:'test',port_xu_ext:'22445',port_xc_ext:'22446',port_hy2_ext:'22447'});
  const nodes=readFileSync(path.join(dir,'jh.txt'),'utf8').trim().split('\n').map(s=>new URL(s));
  assert.equal(nodes.find(u=>u.searchParams.get('path')===`/${uuid}-xu`).port,'22445');
  assert.equal(nodes.find(u=>u.searchParams.get('path')===`/${uuid}-xc`).port,'22446');
  assert.equal(nodes.find(u=>u.protocol==='hysteria2:').port,'22447');
  for (const [port,enabled] of [['10441',true],['10442',false],['10443',true],['10444',false]]) {
    assert.equal(nodes.find(u=>u.port===port).searchParams.get('encryption'),enabled?'mlkem768x25519plus.native.0rtt.client-key':'none');
  }
  assert.equal(readFileSync(path.join(dir,'jh-ios.txt'),'utf8').trim().split('\n').length,nodes.length);
});
