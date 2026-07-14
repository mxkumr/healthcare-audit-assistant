#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const binDir = path.join(__dirname, '..', 'node_modules', 'mbt', 'unpacked_bin');
const binPath = path.join(binDir, 'mbt');

function findMbtOnPath() {
  const candidates = ['mbt'];
  for (const cmd of candidates) {
    try {
      const resolved = execSync(`command -v ${cmd}`, { encoding: 'utf8' }).trim();
      if (resolved && fs.existsSync(resolved)) return resolved;
    } catch {
      // try next candidate
    }
  }
  return null;
}

function ensureBinary() {
  if (fs.existsSync(binPath)) {
    return;
  }

  const source = findMbtOnPath();
  if (!source) {
    console.warn(
      '[ensure-mbt] mbt binary missing. Run: npm install -g mbt && npm run ensure-mbt'
    );
    process.exit(1);
  }

  fs.mkdirSync(binDir, { recursive: true });
  try {
    fs.symlinkSync(source, binPath);
  } catch {
    fs.copyFileSync(source, binPath);
    fs.chmodSync(binPath, 0o755);
  }

  console.log(`[ensure-mbt] linked ${source} -> ${binPath}`);
}

ensureBinary();
