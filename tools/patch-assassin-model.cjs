#!/usr/bin/env node
// Builds models/schwarzkruppzo/player/assassin_cellar.* from the Combine Assassin
// Workshop pack (id 2805031251), so one rig carries both animation sets:
//
//   player/assassin.mdl   includes models/f_anm.mdl  -> stock weapon/prone anims,
//                         plus a "proportions" delta that adapts them to the
//                         modified skeleton, flagged AUTOPLAY (applied to everything)
//   assassin.mdl          includes assassin_anims.mdl -> the 50 custom sequences,
//                         authored for the modified skeleton, no proportions
//
// Patch: take player/assassin.mdl, add assassin_anims.mdl as a second $includemodel,
// and clear AUTOPLAY on "proportions" so it no longer double-applies to the custom
// sequences. The zz_assassin plugin re-applies it as a gesture layer only while a
// stock sequence is playing. Companion .vvd/.vtx/.phy files are byte-identical
// copies (they are keyed by the header checksum, which is unchanged).
//
// Usage: node tools/patch-assassin-model.cjs <extracted-gma-root> <output-root>
//   <extracted-gma-root>/models/schwarzkruppzo/player/assassin.{mdl,vvd,dx80.vtx,dx90.vtx,sw.vtx,phy}
//   -> <output-root>/models/schwarzkruppzo/player/assassin_cellar.*

const fs = require('fs');
const path = require('path');

const STUDIO_AUTOPLAY = 0x0008;
const SEQDESC_SIZE = 212;
const NEW_NAME = 'schwarzkruppzo/player/assassin_cellar.mdl';
const INCLUDES = ['models/f_anm.mdl', 'models/schwarzkruppzo/assassin_anims.mdl'];

const [srcRoot, outRoot] = process.argv.slice(2);
if (!srcRoot || !outRoot) {
  console.error('usage: node patch-assassin-model.cjs <extracted-gma-root> <output-root>');
  process.exit(2);
}

const srcDir = path.join(srcRoot, 'models', 'schwarzkruppzo', 'player');
const outDir = path.join(outRoot, 'models', 'schwarzkruppzo', 'player');
fs.mkdirSync(outDir, {recursive: true});

const cstr = (b, off) => { let e = off; while (e < b.length && b[e] !== 0) e++; return b.toString('latin1', off, e); };

const src = fs.readFileSync(path.join(srcDir, 'assassin.mdl'));
if (src.toString('latin1', 0, 4) !== 'IDST' || src.readInt32LE(4) !== 48) throw new Error('expected an IDST v48 model');
if (src.readInt32LE(76) !== src.length) throw new Error('header length does not match file size; refusing to patch');

const numInclude = src.readInt32LE(336), includeIndex = src.readInt32LE(340);
const existing = [];
for (let i = 0; i < numInclude; i++) {
  const off = includeIndex + i * 8;
  existing.push(cstr(src, off + src.readInt32LE(off + 4)));
}
if (existing.length !== 1 || existing[0] !== INCLUDES[0]) {
  throw new Error(`unexpected include list ${JSON.stringify(existing)}; this patcher targets the stock player variant`);
}

// New include table + strings appended at the end, 4-byte aligned.
let tail = src.length; while (tail % 4) tail++;
const tableOff = tail;
const tableSize = INCLUDES.length * 8;
let strOff = tableOff + tableSize;
const entries = [];
for (const name of INCLUDES) { entries.push({name, off: strOff}); strOff += Buffer.byteLength(name, 'latin1') + 1; }
let total = strOff; while (total % 4) total++;

const out = Buffer.alloc(total);
src.copy(out, 0);
for (let i = 0; i < INCLUDES.length; i++) {
  const entryOff = tableOff + i * 8;
  out.writeInt32LE(0, entryOff);                              // szlabelindex: none, as studiomdl writes it
  out.writeInt32LE(entries[i].off - entryOff, entryOff + 4);  // sznameindex, relative to the entry
  out.write(entries[i].name + '\0', entries[i].off, 'latin1');
}
out.writeInt32LE(INCLUDES.length, 336);
out.writeInt32LE(tableOff, 340);
out.writeInt32LE(total, 76);

// Internal name, 64-byte field at offset 12.
out.fill(0, 12, 76);
out.write(NEW_NAME, 12, 'latin1');

// Clear AUTOPLAY on the proportions delta.
const numSeq = out.readInt32LE(188), seqIndex = out.readInt32LE(192);
let patchedSeq = null;
for (let i = 0; i < numSeq; i++) {
  const off = seqIndex + i * SEQDESC_SIZE;
  if (cstr(out, off + out.readInt32LE(off + 4)) === 'proportions') {
    const flags = out.readInt32LE(off + 12);
    out.writeInt32LE(flags & ~STUDIO_AUTOPLAY, off + 12);
    patchedSeq = {before: flags, after: flags & ~STUDIO_AUTOPLAY};
  }
}
if (!patchedSeq) throw new Error('no "proportions" sequence found');

fs.writeFileSync(path.join(outDir, 'assassin_cellar.mdl'), out);
for (const ext of ['vvd', 'dx80.vtx', 'dx90.vtx', 'sw.vtx', 'phy']) {
  const from = path.join(srcDir, 'assassin.' + ext);
  if (fs.existsSync(from)) fs.copyFileSync(from, path.join(outDir, 'assassin_cellar.' + ext));
}

console.log(`wrote ${path.join(outDir, 'assassin_cellar.mdl')} (${total} bytes, was ${src.length})`);
console.log(`includes: ${INCLUDES.join(', ')}`);
console.log(`proportions flags 0x${patchedSeq.before.toString(16)} -> 0x${patchedSeq.after.toString(16)}`);
