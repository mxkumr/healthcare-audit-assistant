#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const root = path.join(__dirname, '..');
const mbtPkgDir = path.join(root, 'node_modules', 'mbt');
const binDir = path.join(mbtPkgDir, 'unpacked_bin');
const binPath = path.join(binDir, process.platform === 'win32' ? 'mbt.exe' : 'mbt');

function findMbtOnPath() {
  try {
    const resolved = execSync('command -v mbt', { encoding: 'utf8' }).trim();
    if (resolved && fs.existsSync(resolved)) return resolved;
  } catch {
    // not on PATH
  }
  return null;
}

function downloadMbt() {
  const installJs = path.join(mbtPkgDir, 'install.js');
  if (!fs.existsSync(installJs)) {
    console.warn('[ensure-mbt] mbt package not installed — run npm ci first');
    return false;
  }

  try {
    console.log('[ensure-mbt] downloading mbt binary via npm package install script...');
    execSync('node install.js cloud-mta-build-tool', {
      cwd: mbtPkgDir,
      stdio: 'inherit'
    });
    return fs.existsSync(binPath);
  } catch (err) {
    console.warn(`[ensure-mbt] download failed: ${err.message}`);
    return false;
  }
}

function linkFrom(source) {
  fs.mkdirSync(binDir, { recursive: true });
  try {
    if (fs.existsSync(binPath)) fs.unlinkSync(binPath);
  } catch {
    // ignore
  }
  try {
    fs.symlinkSync(source, binPath);
  } catch {
    fs.copyFileSync(source, binPath);
    fs.chmodSync(binPath, 0o755);
  }
  console.log(`[ensure-mbt] linked ${source} -> ${binPath}`);
}

function ensureBinary() {
  if (!fs.existsSync(mbtPkgDir)) {
    // e.g. gen/srv production install — mbt devDependency not present
    return;
  }

  if (fs.existsSync(binPath)) {
    return;
  }

  if (downloadMbt()) {
    console.log('[ensure-mbt] mbt binary ready');
    return;
  }

  const source = findMbtOnPath();
  if (source) {
    linkFrom(source);
    return;
  }

  console.error(
    '[ensure-mbt] mbt binary missing at node_modules/mbt/unpacked_bin/mbt\n' +
      '  Fix on BAS: npm rebuild mbt  OR  npm install -g mbt && npm run ensure-mbt'
  );
  process.exit(1);
}

ensureBinary();
