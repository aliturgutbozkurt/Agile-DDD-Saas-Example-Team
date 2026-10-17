#!/usr/bin/env bash
set -euo pipefail

echo "=========================================================="
echo "Compiling NexusCloud SaaS Enterprise Books with Typst"
echo "=========================================================="

mkdir -p dist_pdf

echo ">> Compiling Turkish Edition (Kitap TR)..."
typst compile book_typst/book_tr.typ dist_pdf/NexusCloud_SaaS_DDD_Agile_Kitap_TR.pdf
echo "   [SUCCESS] dist_pdf/NexusCloud_SaaS_DDD_Agile_Kitap_TR.pdf"

echo ">> Compiling English Edition (Playbook EN)..."
typst compile book_typst/book_en.typ dist_pdf/NexusCloud_SaaS_DDD_Agile_Playbook_EN.pdf
echo "   [SUCCESS] dist_pdf/NexusCloud_SaaS_DDD_Agile_Playbook_EN.pdf"

echo "=========================================================="
echo "All PDF books compiled successfully!"
echo "=========================================================="
ls -lh dist_pdf/
