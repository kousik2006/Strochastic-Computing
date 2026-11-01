Vivado comparison graphs
========================

PNG files:
- area_lut_comparison.png
- area_registers_comparison.png
- power_total_comparison.png
- power_components_comparison.png
- resource_counts_comparison.png

CSV:
- area_data.csv
- power_data.csv

Important interpretation notes:
1. Values were transcribed from the uploaded Vivado screenshots.
2. The screenshots show LUT counts: Wallace=100, Booth=47, Dadda=90.
3. The Booth screenshot shows 36 slice registers and 43 bonded IOBs; Wallace and Dadda screenshots show 32 bonded IOBs, but their register counts were not visible.
4. The power screenshots show total on-chip power of 14.021 W, 9.963 W, and 13.699 W, but they are not all clearly mapped to identical architectures/configurations. They are labeled as report runs rather than asserting a design identity.
5. Vivado's power reports show unusually high I/O power (about 9-12 W) and low confidence in one screenshot. This often indicates unconstrained or unrealistic I/O switching/loads/activity assumptions. Do not treat these values as reliable architecture-level power comparisons until clocks, I/O constraints, and switching activity are made comparable.
6. Missing values are intentionally left blank; no measurements were invented.
