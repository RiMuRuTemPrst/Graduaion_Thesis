# latexmk configuration for the HiFiC GAN thesis
# Usage:  latexmk -pvc        (watch + auto-rebuild on save, auto-open Evince)
#         latexmk             (single build)
#         latexmk -c          (clean aux files)   /  latexmk -C (clean all + pdf)

# Build a PDF with pdflatex (document uses [T5]{fontenc}, mathptmx -> pdflatex)
$pdf_mode = 1;

# pdflatex options: keep going on errors, enable SyncTeX (click-to-source), clearer error lines
$pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 -file-line-error %O %S';

# Run bibtex when needed (references use \bibliographystyle{IEEEtran})
$bibtex_use = 2;

# PDF viewer that auto-reloads on file change; 'start' launches it detached
$pdf_previewer = 'start evince';

# So you can just run `latexmk` / `latexmk -pvc` without naming the file
@default_files = ('main.tex');

# In -pvc mode, keep watching even if a compile errors out
$pvc_timeout = 0;
$max_repeat = 5;
