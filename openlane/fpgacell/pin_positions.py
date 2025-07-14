import os

# === USER-CONFIGURABLE VARIABLES ===
BUS_WIDTH = 16         # number of signals per direction
PIN_SPACING = 10       # microns between adjacent pins
OUTPUT_DIR = "/home/ajweyer/socet_openlane_flow/openlane/fpgacell"  # change as needed
FILENAME = "pin_placement.cfg"

# ===================================
OUTPUT_PATH = os.path.join(OUTPUT_DIR, FILENAME)

with open(OUTPUT_PATH, "w") as f:
    #north (left to right): index 0 on the left
    for i in range(BUS_WIDTH):
        f.write(f"CBnorth_in[{i}]  top  {i * PIN_SPACING}  metal3\n")
    for i in range(BUS_WIDTH):
        f.write(f"CBnorth_out[{i}] top  {(i + BUS_WIDTH) * PIN_SPACING}  metal3\n")

    #south (left to right): index 0 on the left
    for i in range(BUS_WIDTH):
        f.write(f"SBsouth_in[{i}]  bottom  {i * PIN_SPACING}  metal3\n")
    for i in range(BUS_WIDTH):
        f.write(f"SBsouth_out[{i}] bottom  {(i + BUS_WIDTH) * PIN_SPACING}  metal3\n")

    #east (bottom to top): index 0 on the bottom
    for i in range(BUS_WIDTH):
        f.write(f"CBeast_in[{i}]  right  {i * PIN_SPACING}  metal3\n")
    for i in range(BUS_WIDTH):
        f.write(f"CBeast_out[{i}] right  {(i + BUS_WIDTH) * PIN_SPACING}  metal3\n")

    #west (bottom to top): index 0 on the bottom
    for i in range(BUS_WIDTH):
        f.write(f"SBwest_in[{i}]  left  {i * PIN_SPACING}  metal3\n")
    for i in range(BUS_WIDTH):
        f.write(f"SBwest_out[{i}] left  {(i + BUS_WIDTH) * PIN_SPACING}  metal3\n")

    #control + config signals (top right)
    offset = 2 * BUS_WIDTH * PIN_SPACING
    signals = [
        "clk", "en", "nrst", "config_en",
        "config_data_in", "config_data_out",
        "le_clk", "le_en", "le_nrst"
    ]
    for i, sig in enumerate(signals):
        f.write(f"{sig} top {offset + i * PIN_SPACING} metal3\n")

    #power pins (edges)
    f.write(f"vccd1 left 0 metal3\n")
    f.write(f"vssd1 right {3 * BUS_WIDTH * PIN_SPACING} metal3\n")

print(f"Pin placement file written to: {OUTPUT_PATH}")
