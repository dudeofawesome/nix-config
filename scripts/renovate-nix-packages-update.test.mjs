import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import {
  mkdtempSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const updater = fileURLToPath(
  new URL('./renovate-nix-packages-update.mjs', import.meta.url),
);

function fixture(
  t,
  {
    name = 'example',
    field = 'version',
    custom = false,
    actual = '2.0',
    fail = false,
    packageFile,
  } = {},
) {
  const dir = mkdtempSync(join(tmpdir(), 'renovate-update-test-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  mkdirSync(join(dir, 'bin'));
  mkdirSync(join(dir, 'packages', name), { recursive: true });
  const file = `packages/${name}/package.nix`;
  const original = `${field} = "2.0";\nhash = "old";\n${custom ? '# writeShellApplication\n' : ''}`;
  writeFileSync(join(dir, file), original);
  writeFileSync(
    join(dir, 'data.json'),
    JSON.stringify({
      depName: name,
      packageFile: packageFile ?? file,
      newValue: '2.0',
      newDigest: field === 'rev' ? actual : undefined,
    }),
  );
  const mock = `#!${process.execPath}
const fs = require('node:fs');
const args = process.argv.slice(2);
fs.appendFileSync('commands.jsonl', JSON.stringify(args) + '\\n');
if (args[0] === 'eval') {
  console.log(args.includes('--expr') ? 'aarch64-linux' : process.cwd() + '/bin/vendor-updater');
} else if (args[0] === 'run' || process.argv[1].endsWith('vendor-updater')) {
  let text = fs.readFileSync(${JSON.stringify(file)}, 'utf8');
  text = text.replace('hash = "old"', 'hash = "new"');
  text = text.replace(/${field} = "[^"]+"/, ${JSON.stringify(`${field} = "${actual}"`)});
  fs.writeFileSync(${JSON.stringify(file)}, text);
  if (${fail}) process.exit(1);
}
`;
  for (const command of ['nix', 'vendor-updater']) {
    writeFileSync(join(dir, 'bin', command), mock, { mode: 0o755 });
  }
  const result = spawnSync(process.execPath, [updater], {
    cwd: dir,
    encoding: 'utf8',
    env: {
      ...process.env,
      PATH: `${join(dir, 'bin')}:${process.env.PATH}`,
      RENOVATE_POST_UPGRADE_COMMAND_DATA_FILE: join(dir, 'data.json'),
    },
  });
  return { result, original, text: readFileSync(join(dir, file), 'utf8'), dir };
}

test('refreshes hashes without changing Renovate’s selected version', (t) => {
  const { result, text, dir } = fixture(t);
  assert.equal(result.status, 0, result.stderr);
  assert.match(text, /hash = "new"/);
  const commands = readFileSync(join(dir, 'commands.jsonl'), 'utf8');
  assert.match(commands, /--version=skip/);
  assert.match(commands, /nixpkgs-linux-stable#nix-update/);
});

test('uses native vendor updaters and validates build numbers', (t) => {
  const { result, text } = fixture(t, {
    name: 'postico',
    field: 'build',
    custom: true,
  });
  assert.equal(result.status, 0, result.stderr);
  assert.match(text, /hash = "new"/);
});

test('validates branch updates against the requested digest', (t) => {
  const { result } = fixture(t, {
    name: 'overcast',
    field: 'rev',
    custom: true,
    actual: 'abcdef',
  });
  assert.equal(result.status, 0, result.stderr);
});

test('restores the package if the vendor feed advances past Renovate’s selection', (t) => {
  const { result, text, original } = fixture(t, {
    custom: true,
    actual: '3.0',
  });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Renovate requested 2.0/);
  assert.equal(text, original);
});

test('restores the package after an updater failure', (t) => {
  const { result, text, original } = fixture(t, { fail: true });
  assert.notEqual(result.status, 0);
  assert.equal(text, original);
});

test('rejects a package path outside the dependency’s directory', (t) => {
  const { result, text, original } = fixture(t, {
    packageFile: '../other.nix',
  });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /matching package.nix/);
  assert.equal(text, original);
});
