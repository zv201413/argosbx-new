const os = require('os');
const http = require('http');
const fs = require('fs');
const net = require('net');
const { exec, execSync } = require('child_process');
function ensureModule(name) {
    try {
        require.resolve(name);
    } catch (e) {
        console.log(`Module '${name}' not found. Installing...`);
        execSync(`npm install ${name}`, { stdio: 'inherit' });
    }
}
const { WebSocket, createWebSocketStream } = require('ws');
const subtxt = `${process.env.HOME}/agsbx/jh.txt`;
const NAME = process.env.NAME || os.hostname();
const PORT = process.env.PORT || 3000;
const uuid = process.env.uuid || '79411d85-b0dc-4cd2-b46c-01789a18c650';
const DOMAIN = process.env.DOMAIN || 'YOUR.DOMAIN';
const vlessInfo = `vless://${uuid}@${DOMAIN}:443?encryption=none&security=tls&sni=${DOMAIN}&fp=chrome&type=ws&host=${DOMAIN}&path=%2F#Vl-ws-tls-${NAME}`;
console.log(`vless-ws-tls节点分享: ${vlessInfo}`);

fs.chmod("start.sh", 0o777, (err) => {
    if (err) {
        console.error(`start.sh empowerment failed: ${err}`);
        return;
    }
    console.log(`start.sh empowerment successful`);
    const child = exec('bash start.sh');
    child.stdout.on('data', (data) => console.log(data));
    child.stderr.on('data', (data) => console.error(data));
    child.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
        console.clear();
        console.log(`App is running`);
    });
});

const server = http.createServer((req, res) => {
    if (req.url === '/') {
        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end('🟢恭喜！Argosbx小钢炮脚本-nodejs版部署成功！\n\n查看节点信息路径：/你的uuid');
        return;
    }

    if (req.url === `/${uuid}`) {
        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        if (fs.existsSync(subtxt)) {
            fs.readFile(subtxt, 'utf8', (err, data) => {
                if (err) {
                    console.error(err);
                    res.end(`${vlessInfo}`);
                } else {
                    res.end(`${vlessInfo}\n${data}`);
                }
            });
        } else {
            res.end(`${vlessInfo}`);
        }
        return;
    }

    res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('404 Not Found');
});

server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

const wss = new (require('ws').Server)({ server });
const uuidkey = uuid.replace(/-/g, "");
wss.on('connection', ws => {
    ws.once('message', msg => {
        const [VERSION] = msg;
        const id = msg.slice(1, 17);
        if (!id.every((v, i) => v == parseInt(uuidkey.substr(i * 2, 2), 16))) return;
        let i = msg.slice(17, 18).readUInt8() + 19;
        const port = msg.slice(i, i += 2).readUInt16BE(0);
        const ATYP = msg.slice(i, i += 1).readUInt8();
        const host = ATYP == 1 ? msg.slice(i, i += 4).join('.') :
            (ATYP == 2 ? new TextDecoder().decode(msg.slice(i + 1, i += 1 + msg.slice(i, i + 1).readUInt8())) :
                (ATYP == 3 ? msg.slice(i, i += 16)
                    .reduce((s, b, i, a) => (i % 2 ? s.concat(a.slice(i - 1, i + 1)) : s), [])
                    .map(b => b.readUInt16BE(0).toString(16)).join(':') : ''));
        ws.send(new Uint8Array([VERSION, 0]));
        const duplex = createWebSocketStream(ws);
        net.connect({ host, port }, function () {
            this.write(msg.slice(i));
            duplex.on('error', () => { }).pipe(this).on('error', () => { }).pipe(duplex);
        }).on('error', () => { });
    }).on('error', () => { });
});
