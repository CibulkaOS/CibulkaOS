#!/usr/bin/env python3
"""Vygeneruje komprimovanou databázi Cibulkových seznamů ze souboru seznam.xls."""
import gzip
import os
import re
import sys
import unicodedata
import xlrd

INPUT_XLS = sys.argv[1] if len(sys.argv) > 1 else "seznam.xls"
OUTPUT_GZ = (
    sys.argv[2]
    if len(sys.argv) > 2
    else "pkgbuilds/cibulkaos-base/rootfs/usr/share/cibulkaos/cibulkovy-seznamy.tsv.gz"
)

def norm(s):
    s = str(s or "").strip()
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode("ascii")
    return re.sub(r"[^a-z0-9]", "", s.lower())

def clean_cell(v):
    if isinstance(v, float) and v.is_integer():
        return str(int(v))
    return re.sub(r"[\t\r\n]+", " ", str(v or "")).strip()

wb = xlrd.open_workbook(INPUT_XLS)
seen = set()
rows = []

def add_rec(fullname, druh, regno, codename, source):
    fn = clean_cell(fullname)
    if not fn or re.match(r"^[\d(\[]", fn) or ";" in fn:
        return
    clean = re.sub(r"\s*\([^)]*\)", "", fn).strip()
    parts = clean.split()
    if len(parts) < 2:
        return
    sur = norm(parts[0])
    giv = norm(parts[1])
    if len(sur) < 2 or len(giv) < 2:
        return
    full1 = sur + giv
    full2 = giv + sur
    cn_raw = clean_cell(codename)
    cns = []
    for c in re.split(r"[;,/]", cn_raw):
        nc = norm(c)
        if len(nc) >= 3 and not nc.isdigit():
            cns.append(nc)
    druh_s = clean_cell(druh)
    reg_s = clean_cell(regno)
    key = (full1, sur, "|".join(cns), druh_s, reg_s, source)
    if key in seen:
        return
    seen.add(key)
    # Sloupce: full_sur_giv, full_giv_sur, surname, |codenames|, orig_name, druh, regno, orig_codename, source
    cn_field = ("|" + "|".join(cns) + "|") if cns else ""
    rows.append("\t".join([full1, full2, sur, cn_field, fn, druh_s, reg_s, cn_raw, source]))

for sname in ["Registrační protokol A-O", "Registrační protokol P-Ž", "Archivní protokol"]:
    sh = wb.sheet_by_name(sname)
    for r in range(1, sh.nrows):
        add_rec(sh.cell_value(r, 0), sh.cell_value(r, 2), sh.cell_value(r, 3), sh.cell_value(r, 4), sname)

sh = wb.sheet_by_name("I.správa")
for r in range(1, sh.nrows):
    add_rec(sh.cell_value(r, 3), sh.cell_value(r, 5), sh.cell_value(r, 0), sh.cell_value(r, 2), "I.správa")

sh = wb.sheet_by_name("Person. spisy")
for r in range(1, sh.nrows):
    fn = clean_cell(sh.cell_value(r, 0))
    if fn:
        add_rec(fn, "Příslušník StB", sh.cell_value(r, 1), "", "Person. spisy")

os.makedirs(os.path.dirname(OUTPUT_GZ), exist_ok=True)
with gzip.open(OUTPUT_GZ, "wt", encoding="utf-8", compresslevel=9) as f:
    for line in rows:
        f.write(line + "\n")

size_kb = os.path.getsize(OUTPUT_GZ) / 1024
print(f"Vygenerováno {len(rows)} unikátních reálných záznamů do {OUTPUT_GZ} ({size_kb:.1f} KiB)")
