import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync } from 'node:fs';

// Renovate passes data through a file so release values never become shell code.
const update = JSON.parse(
  readFileSync(process.env.RENOVATE_POST_UPGRADE_COMMAND_DATA_FILE, 'utf8'),
);
const { depName, packageFile, newValue, newDigest } = update;
if (
  !/^[a-z0-9][a-z0-9-]*$/.test(depName) ||
  packageFile !== `packages/${depName}/package.nix`
) {
  throw new Error('Expected a custom package and its matching package.nix');
}

function run(command, args, capture = false) {
  return execFileSync(command, args, {
    encoding: 'utf8',
    stdio: capture ? ['ignore', 'pipe', 'inherit'] : 'inherit',
  })?.trim();
}

const original = readFileSync(packageFile, 'utf8');
const field =
  depName === 'overcast'
    ? 'rev'
    : depName === 'postico'
      ? 'build'
      : depName === 'sdh-pause-games'
        ? 'releaseTag'
        : 'version';
const expected = depName === 'overcast' ? newDigest : newValue;
if (typeof expected !== 'string' || !/^[a-zA-Z0-9.+_-]+$/.test(expected)) {
  throw new Error('Missing or invalid target release');
}

try {
  const system = run(
    'nix',
    ['eval', '--impure', '--raw', '--expr', 'builtins.currentSystem'],
    true,
  );
  if (original.includes('writeShellApplication')) {
    // Build only the updater with native tools, including for macOS-only apps.
    // Evaluating the app's src here would reject macOS sources on Linux.
    const attr = `.#packages.${system}.${depName}.updateScript`;
    const script = run('nix', ['eval', '--raw', attr], true);
    run('nix', [
      'build',
      '--no-link',
      '--impure',
      '--expr',
      `let flake = builtins.getFlake (toString ./.); in builtins.dirOf (builtins.dirOf flake.packages.${system}.${depName}.updateScript)`,
    ]);
    run(script, []);
  } else {
    // Renovate has already changed the version; refresh source and dependency hashes.
    run('nix', [
      'run',
      '--inputs-from',
      '.',
      'nixpkgs-linux-stable#nix-update',
      '--',
      '--flake',
      '--system',
      system,
      '--version=skip',
      depName,
    ]);
  }

  const actual = readFileSync(packageFile, 'utf8').match(
    new RegExp(`^\\s*${field} = "([^"]+)";`, 'm'),
  )?.[1];
  if (actual !== expected) {
    throw new Error(
      `Updater selected ${actual}; Renovate requested ${expected}`,
    );
  }
  run('nix', ['fmt', packageFile]);
} catch (error) {
  // A failed or racing vendor feed must not leave a partially refreshed package.
  writeFileSync(packageFile, original);
  throw error;
}
