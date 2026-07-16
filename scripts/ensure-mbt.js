#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const root = path.join(__dirname, '..');
const mbtPkgDir = path.join(root, 'node_modules', 'mbt');
const binDir = path.join(mbtPkgDir, 'unpacked_bin');
const binPath = path.join(binDir, process.platform === 'win32' ? 'mbt.exe' : 'mbt');
const isMtaRoot = fs.existsSync(path.join(root, 'mta.yaml'));

function isWrapperScript(filePath) {
  try {
    const resolved = fs.realpathSync(filePath);
    if (resolved.includes(`${path.sep}mbt${path.sep}bin${path.sep}mbt`)) return true;
    const head = fs.readFileSync(resolved, 'utf8', { start: 0, end: 40 });
    return head.startsWith('#!') && head.includes('node');
  } catch {
    return true;
  }
}

function findMbtOnPath() {
  const candidates = [];
  try {
    candidates.push(execSync('command -v mbt', { encoding: 'utf8' }).trim());
  } catch {
    // not on PATH
  }

  const home = process.env.HOME || process.env.USERPROFILE || '';
  if (home) {
    candidates.push(
      path.join(home, '.npm-global', 'bin', 'mbt'),
      path.join(home, '.local', 'bin', 'mbt')
    );
  }
  candidates.push('/usr/local/bin/mbt');

  for (const candidate of candidates) {
    if (!candidate || !fs.existsSync(candidate) || isWrapperScript(candidate)) continue;
    return candidate;
  }
  return null;
}

function installMbtPackage() {
  try {
    console.log('[ensure-mbt] installing mbt npm package...');
    execSync('npm install mbt@^1.2.49 --no-save --ignore-scripts', {
      cwd: root,
      stdio: 'inherit'
    });
    return fs.existsSync(mbtPkgDir);
  } catch (err) {
    console.warn(`[ensure-mbt] npm install mbt failed: ${err.message}`);
    return false;
  }
}

function downloadMbt() {
  const installJs = path.join(mbtPkgDir, 'install.js');
  if (!fs.existsSync(installJs)) {
    return false;
  }

  try {
    console.log('[ensure-mbt] downloading mbt binary...');
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

function installGlobalMbt() {
  try {
    console.log('[ensure-mbt] installing global mbt...');
    execSync('npm install -g mbt@^1.2.49', { stdio: 'inherit' });
    return findMbtOnPath();
  } catch (err) {
    console.warn(`[ensure-mbt] global install failed: ${err.message}`);
    return null;
  }
}

function ensureBinary() {
  if (fs.existsSync(binPath)) {
    console.log('[ensure-mbt] mbt binary already present');
    return;
  }

  if (!fs.existsSync(mbtPkgDir)) {
    installMbtPackage();
  }

  if (downloadMbt()) {
    console.log('[ensure-mbt] mbt binary ready');
    return;
  }

  let source = findMbtOnPath();
  if (!source) {
    source = installGlobalMbt();
  }
  if (source) {
    linkFrom(source);
    return;
  }

  if (!isMtaRoot) {
    return;
  }

  console.error(
    '[ensure-mbt] mbt binary missing at node_modules/mbt/unpacked_bin/mbt\n' +
      '  BAS fix: npm install -g mbt && npm run ensure-mbt'
  );
  process.exit(1);
}

ensureBinary();
