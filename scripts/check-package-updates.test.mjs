import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import {
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const script = fileURLToPath(
  new URL('./check-package-updates.mjs', import.meta.url),
);

function matrix(t, changedFiles) {
  const dir = mkdtempSync(join(tmpdir(), 'package-update-matrix-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const git = (...args) =>
    execFileSync('git', args, { cwd: dir, encoding: 'utf8' }).trim();
  function write(file, content) {
    mkdirSync(dirname(join(dir, file)), { recursive: true });
    writeFileSync(join(dir, file), content);
  }
  git('init', '--quiet');
  git('config', 'user.name', 'Test');
  git('config', 'user.email', 'test@example.com');
  git('config', 'commit.gpgSign', 'false');
  for (const name of ['alpha', 'beta', 'no-updater']) {
    write(`packages/${name}/package.nix`, '# package\n');
  }
  git('add', '.');
  git('-c', 'core.hooksPath=/dev/null', 'commit', '--quiet', '-m', 'Base');
  const base = git('rev-parse', 'HEAD');
  for (const file of changedFiles) write(file, '# changed\n');
  git('add', '.');
  git('-c', 'core.hooksPath=/dev/null', 'commit', '--quiet', '-m', 'Changes');
  write(
    'bin/nix',
    `#!${process.execPath}
console.log(!process.argv.includes('.#packages.x86_64-linux.no-updater'));
`,
  );
  execFileSync('chmod', ['+x', join(dir, 'bin/nix')]);
  const output = join(dir, 'output');
  const result = spawnSync(
    process.execPath,
    [script, '--matrix', base, 'HEAD'],
    {
      cwd: dir,
      encoding: 'utf8',
      env: {
        ...process.env,
        PATH: `${join(dir, 'bin')}:${process.env.PATH}`,
        GITHUB_OUTPUT: output,
      },
    },
  );
  assert.equal(result.status, 0, result.stderr);
  const include = JSON.parse(result.stdout).include;
  assert.equal(
    readFileSync(output, 'utf8'),
    `matrix=${JSON.stringify({ include })}\nhas-updates=${include.length > 0}\n`,
  );
  return include.map((entry) => entry.package);
}

test('workflow dependency updates do not select package updaters', (t) => {
  assert.deepEqual(
    matrix(t, [
      '.github/workflows/check.yaml',
      '.github/workflows/test-updatescript.yaml',
    ]),
    [],
  );
});

test('workflow changes alongside a package select only that package', (t) => {
  assert.deepEqual(
    matrix(t, [
      '.github/workflows/test-updatescript.yaml',
      'packages/alpha/package.nix',
    ]),
    ['alpha'],
  );
});

for (const file of [
  'scripts/check-package-updates.mjs',
  'packages/default.nix',
]) {
  test(`${file} changes select all packages with updaters`, (t) => {
    assert.deepEqual(matrix(t, [file]), ['alpha', 'beta']);
  });
}
