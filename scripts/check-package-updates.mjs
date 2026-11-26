import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import {
  appendFileSync,
  existsSync,
  mkdtempSync,
  readFileSync,
  readdirSync,
  rmSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

// Run package checks in disposable checkouts: updaters may select a newer release.
function run(command, args, capture = false, env = process.env) {
  return execFileSync(command, args, {
    encoding: 'utf8',
    stdio: capture ? ['ignore', 'pipe', 'inherit'] : 'inherit',
    env,
  });
}

function evaluate(attribute, expression) {
  return JSON.parse(
    run('nix', ['eval', '--json', attribute, '--apply', expression], true),
  );
}

function matrix(base, head) {
  if (!base || !head) throw new Error('Expected base and head Git revisions');
  const files = run(
    'git',
    ['diff', '--name-only', '-z', '--diff-filter=ACMRT', base, head],
    true,
  ).split('\0');
  const checkAll = files.some((file) =>
    ['scripts/check-package-updates.mjs', 'packages/default.nix'].includes(
      file,
    ),
  );
  const names = checkAll
    ? readdirSync('packages', { withFileTypes: true })
        .filter((entry) => entry.isDirectory())
        .map((entry) => entry.name)
    : files.flatMap((file) => {
        const match = file.match(/^packages\/([a-z0-9][a-z0-9-]*)\//);
        return match ? [match[1]] : [];
      });
  const include = [];
  for (const name of [...new Set(names)].sort()) {
    validateName(name);
    if (!existsSync(`packages/${name}/package.nix`)) continue;
    const hasUpdater = evaluate(
      `.#packages.x86_64-linux.${name}`,
      'package: package ? updateScript',
    );
    if (hasUpdater) include.push({ package: name });
  }
  const result = JSON.stringify({ include });
  console.log(result);
  if (process.env.GITHUB_OUTPUT) {
    appendFileSync(process.env.GITHUB_OUTPUT, `matrix=${result}\n`);
    appendFileSync(
      process.env.GITHUB_OUTPUT,
      `has-updates=${include.length > 0}\n`,
    );
  }
}

function validateName(name) {
  if (!/^[a-z0-9][a-z0-9-]*$/.test(name ?? '')) {
    throw new Error('Expected a custom package name');
  }
}

function snapshot() {
  const hash = createHash('sha256');
  hash.update(run('git', ['diff', '--no-ext-diff', '--binary', 'HEAD'], true));
  const untracked = run(
    'git',
    ['ls-files', '--others', '--exclude-standard', '-z'],
    true,
  )
    .split('\0')
    .filter(Boolean)
    .sort();
  for (const file of untracked) {
    hash.update(file);
    hash.update('\0');
    hash.update(readFileSync(file));
  }
  return hash.digest('hex');
}

function checkSource(name, system) {
  const platforms = evaluate(
    `.#packages.${system}.${name}`,
    'package: package.meta.platforms or []',
  );
  // Source selection can depend on the app's platform. Only evaluate it there;
  // downloading the URL does not need that platform's builder or dependencies.
  const sourceSystem = [
    system,
    'x86_64-linux',
    'aarch64-linux',
    'aarch64-darwin',
    'x86_64-darwin',
  ].find((candidate) => platforms.includes(candidate));
  if (!sourceSystem)
    throw new Error(`No supported source platform for ${name}`);
  const { urls, url, rev } = evaluate(
    `.#packages.${sourceSystem}.${name}.src`,
    'src: { urls = src.urls or []; url = src.url or null; rev = src.rev or null; }',
  );
  if (urls.length === 0 && url && rev) {
    const repository = mkdtempSync(join(tmpdir(), 'update-source-'));
    try {
      run('git', ['init', '--bare', '--quiet', repository]);
      run('git', [
        '--git-dir',
        repository,
        'fetch',
        '--depth=1',
        '--no-tags',
        '--',
        url,
        rev,
      ]);
    } finally {
      rmSync(repository, { recursive: true, force: true });
    }
    return;
  }
  const candidates = urls.length > 0 ? urls : url ? [url] : [];
  if (candidates.length === 0) throw new Error(`No source URL for ${name}`);
  // Try mirrors in order, as a source fetcher would. Download the complete file
  // to catch transfer failures; this check does not verify hashes or unpack it.
  for (const candidate of candidates) {
    console.log(`Checking ${name} source download: ${candidate}`);
    try {
      run('curl', [
        '--fail',
        '--location',
        '--silent',
        '--show-error',
        '--connect-timeout',
        '30',
        '--max-time',
        '600',
        '--output',
        '/dev/null',
        '--',
        candidate,
      ]);
      return;
    } catch (error) {
      if (candidate === candidates.at(-1)) throw error;
    }
  }
}

function check(name) {
  validateName(name);
  const system = run(
    'nix',
    ['eval', '--impure', '--raw', '--expr', 'builtins.currentSystem'],
    true,
  ).trim();
  const attribute = `.#packages.${system}.${name}`;

  function update() {
    const { command, pname, version } = evaluate(
      attribute,
      `package: {
        command = if builtins.isList package.updateScript then package.updateScript else [ package.updateScript ];
        inherit (package) pname version;
      }`,
    );
    // Realize the executable's store path without building the application.
    run('nix', [
      'build',
      '--no-link',
      '--impure',
      '--expr',
      `let
        flake = builtins.getFlake (toString ./.);
        script = flake.packages.${system}.${name}.updateScript;
        command = if builtins.isList script then script else [ script ];
      in builtins.dirOf (builtins.dirOf (builtins.head command))`,
    ]);
    run(command[0], command.slice(1), false, {
      ...process.env,
      UPDATE_NIX_NAME: `${pname}-${version}`,
      UPDATE_NIX_PNAME: pname,
      UPDATE_NIX_OLD_VERSION: version,
      UPDATE_NIX_ATTR_PATH: name,
    });
  }

  console.log(`Running ${name} updater on ${system}`);
  update();
  checkSource(name, system);
  const first = snapshot();
  console.log(`Checking ${name} updater convergence`);
  update();
  if (snapshot() !== first) {
    run('git', ['diff', '--no-ext-diff']);
    throw new Error(`${name} updater changed the checkout on its second run`);
  }
  console.log(
    `${name} updater converged and its source downloaded successfully`,
  );
}

const [mode, ...args] = process.argv.slice(2);
if (mode === '--matrix') matrix(...args);
else if (mode === '--package') check(args[0]);
else throw new Error('Usage: --matrix <base> <head> | --package <name>');
