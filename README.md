# Bug
verdaccio `6.1.2` unable to unpublish package version `1.0.0` when `1.0.1` published (bug: https://github.com/verdaccio/verdaccio/issues/5214).

# Debug logs and tcp dump
* [Debug logs](./verdaccio_debug.log)
* [TCP dump](./tcp_dump_decoded.pcapng) betwen `npm` and `verdaccio` (decode as `HTTP`)

# HowTo run
```sh
$> node --version
v23.10.0

$> $ npm --version
10.9.2

$> docker compose up -d

$> ./do_test.sh

---cleanup verdaccio storage for test package---

---create 1.0.0---
npm notice
npm notice 📦  test@1.0.0
npm notice Tarball Contents
npm notice 218B package.json
npm notice Tarball Details
npm notice name: test
npm notice version: 1.0.0
npm notice filename: test-1.0.0.tgz
npm notice package size: 245 B
npm notice unpacked size: 218 B
npm notice shasum: 3d79dafa3dead8b50787de5b820dbafeff97ed78
npm notice integrity: sha512-FS8raVjjiIgRM[...]9CR8n92qUG+qw==
npm notice total files: 1
npm notice
npm notice Publishing to http://localhost:5010/ with tag latest and default access
+ test@1.0.0

---create 1.0.1---
npm notice
npm notice 📦  test@1.0.1
npm notice Tarball Contents
npm notice 218B package.json
npm notice Tarball Details
npm notice name: test
npm notice version: 1.0.1
npm notice filename: test-1.0.1.tgz
npm notice package size: 245 B
npm notice unpacked size: 218 B
npm notice shasum: ecf5572a661a9f3630a2897c188110d216a23fe4
npm notice integrity: sha512-eV9x1reislG1s[...]r9RXCg3qGaXKQ==
npm notice total files: 1
npm notice
npm notice Publishing to http://localhost:5010/ with tag latest and default access
+ test@1.0.1

---ensure dist-tag link to 1.0.1---
latest: 1.0.1

---unpublish 1.0.0---
npm verbose cli /home/user/.asdf/installs/nodejs/23.10.0/bin/node /home/user/.asdf/installs/nodejs/23.10.0/bin/npm
npm info using npm@10.9.2
npm info using node@v23.10.0
npm silly config load:file:/home/user/.asdf/installs/nodejs/23.10.0/lib/node_modules/npm/npmrc
npm silly config load:file:/home/user/w/PoC/verdaccio-6.1.2_unpublish_bug/.npmrc
npm silly config load:file:/home/user/.npmrc
npm silly config load:file:/home/user/.asdf/installs/nodejs/23.10.0/etc/npmrc
npm verbose title npm unpublish test@1.0.0
npm verbose argv "unpublish" "--loglevel" "silly" "--registry" "http://localhost:5010" "--force" "test@1.0.0"
npm verbose logfile logs-max:10 dir:/home/user/.npm/_logs/2025-04-29T12_28_26_195Z-
npm verbose logfile /home/user/.npm/_logs/2025-04-29T12_28_26_195Z-debug-0.log
npm warn using --force Recommended protections disabled.
npm silly logfile start cleaning logs, removing 1 files
npm silly unpublish args[0] test@1.0.0
npm silly unpublish spec Result {
npm silly unpublish   type: 'version',
npm silly unpublish   registry: true,
npm silly unpublish   where: undefined,
npm silly unpublish   raw: 'test@1.0.0',
npm silly unpublish   name: 'test',
npm silly unpublish   escapedName: 'test',
npm silly unpublish   scope: undefined,
npm silly unpublish   rawSpec: '1.0.0',
npm silly unpublish   saveSpec: null,
npm silly unpublish   fetchSpec: '1.0.0',
npm silly unpublish   gitRange: undefined,
npm silly unpublish   gitCommittish: undefined,
npm silly unpublish   gitSubdir: undefined,
npm silly unpublish   hosted: undefined
npm silly unpublish }
npm silly logfile done cleaning log files
npm http fetch GET 200 http://localhost:5010/test?write=true 33ms (cache updated)
npm http fetch GET 200 http://localhost:5010/test?write=true 9ms (cache updated)

>>>>>>> npm http fetch PUT 404 http://localhost:5010/test/-rev/6-a8507947796ed0db 4ms <<<<<<<<<<< THIS IS UNEXPECTED <<<<<<

- test@1.0.0
npm verbose cwd /home/user/w/PoC/verdaccio-6.1.2_unpublish_bug
npm verbose os Linux 6.11.0-24-generic
npm verbose node v23.10.0
npm verbose npm  v10.9.2
npm verbose exit 0
npm info ok

---final check---
total 20
drwxr-xr-x    2 verdaccio nogroup       4096 Apr 29 12:28 .
drwxrwxrwt    1 root     root          4096 Apr 29 12:28 ..
-rw-r--r--    1 verdaccio nogroup       1782 Apr 29 12:28 package.json
-rw-r--r--    1 verdaccio nogroup        245 Apr 29 12:28 test-1.0.0.tgz   <<<<<<<<<<< still present <<<<<<<<<
-rw-r--r--    1 verdaccio nogroup        245 Apr 29 12:28 test-1.0.1.tgz
```


verdaccio log:
```
verdaccio  | trace--- [middleware/allow][access] allow for undefined
verdaccio  | trace--- [auth/allow_action]: user: undefined
verdaccio  | trace--- [auth/allow_action]: hasPermission? true for user: undefined, package: test
verdaccio  | trace--- auth/allow_action: access granted to: undefined
verdaccio  | trace--- [middleware/allow][access] allowed for undefined
verdaccio  | http <-- 200, user: null(172.19.0.1), req: 'GET /test?write=true', bytes: 0/0
verdaccio  | http <-- 200, user: null(172.19.0.1), req: 'GET /test?write=true', bytes: 0/686
verdaccio  | info <-- 172.19.0.1 requested 'PUT /test/-rev/6-037fb88c5bc29ae7'
verdaccio  | http <-- 200, user: null(172.19.0.1), req: 'PUT /test/-rev/6-037fb88c5bc29ae7', bytes: 784/0
>>>>>> verdaccio  | http <-- 404, user: null(172.19.0.1), req: 'PUT /test/-rev/6-037fb88c5bc29ae7', bytes: 784/167 <<<<<<
```
