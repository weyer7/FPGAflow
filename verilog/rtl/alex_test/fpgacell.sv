`default_nettype none
module fpgacell #(
  parameter int LE_LUT_SIZE = 16,
  parameter int LE_INPUTS   = 4,
  parameter int LE_OUTPUTS  = 1,
  parameter int BUS_WIDTH   = 32
)(
  // CRAM signals
  input  logic clk, en, nrst,
  input  logic config_data_in,
  output logic config_data_out,

  // Configurable logic signals
  input  logic le_clk, le_en, le_nrst,

  // NORTH
  (* keep *) inout wire  [BUS_WIDTH-1:0] CBnorth,
  (* keep *) output logic [LE_OUTPUTS-1:0] LEoutnorth,
  (* keep *) input  logic [LE_INPUTS-1:0] LEinnorth,

  // SOUTH
  (* keep *) inout wire  [BUS_WIDTH-1:0] SBsouth,
  (* keep *) output logic [LE_INPUTS-1:0] CBoutsouth,
  (* keep *) input  logic [LE_OUTPUTS-1:0] CBinsouth,

  // EAST
  (* keep *) inout wire  [BUS_WIDTH-1:0] CBeast,
  (* keep *) output logic [LE_OUTPUTS-1:0] LEouteast,
  (* keep *) input  logic [LE_INPUTS-1:0] LEineast,

  // WEST
  (* keep *) inout wire  [BUS_WIDTH-1:0] SBwest,
  (* keep *) output logic [LE_INPUTS-1:0] CBoutwest,
  (* keep *) input  logic [LE_OUTPUTS-1:0] CBinwest
);

  // Internal buses (preserved)
  (* keep *) wire [BUS_WIDTH-1:0] bus_south;
  (* keep *) wire [BUS_WIDTH-1:0] bus_west;

  // Logic element input/output
  logic [LE_OUTPUTS-1:0] leout;
  logic [LE_INPUTS-1:0]  lein;

  // Configuration chain signals
  logic le_cram_out, cb0A_cram_out, cb0B_cram_out;
  logic cb1A_cram_out, cb1B_cram_out, sb_cram_out;

  assign LEouteast   = leout;
  assign LEoutnorth  = leout;

  // Optional dummy output to preserve full bus width in synthesis
  (* keep *) wire [BUS_WIDTH-1:0] preserve_all_bus_bits = 
      CBnorth ^ SBsouth ^ CBeast ^ SBwest ^ bus_south ^ bus_west;

  // Logic Element (LE)
  LE #(LE_LUT_SIZE) LE_northeast (
    .config_data_in(config_data_in),
    .config_data_out(le_cram_out),
    .clk(clk), .en(en), .nrst(nrst),
    .le_clk(le_clk), .le_en(le_en), .le_nrst(le_nrst),
    .select(lein), .le_out(leout)
  );

  // Connection Block North-West
  CB #(BUS_WIDTH, LE_OUTPUTS, LE_INPUTS) CB_northwest (
    .config_data_inA(le_cram_out),
    .config_data_outA(cb0A_cram_out),
    .config_data_inB(cb0A_cram_out),
    .config_data_outB(cb0B_cram_out),
    .clk(clk), .en(en), .nrst(nrst),
    .sb_busA(bus_west), .le_outA(leout), .le_inA(lein),
    .sb_busB(CBnorth), .le_outB(CBinwest), .le_inB(CBoutwest)
  );

  // Connection Block South-East
  CB #(BUS_WIDTH, LE_OUTPUTS, LE_INPUTS) CB_southeast (
    .config_data_inA(cb0B_cram_out),
    .config_data_outA(cb1A_cram_out),
    .config_data_inB(cb1A_cram_out),
    .config_data_outB(cb1B_cram_out),
    .clk(clk), .en(en), .nrst(nrst),
    .sb_busA(bus_south), .le_outA(leout), .le_inA(),
    .sb_busB(CBeast), .le_outB(CBinsouth), .le_inB(CBoutsouth)
  );

  // Switchbox South-West
  SB #(BUS_WIDTH) SB_southwest (
    .config_data_in(cb1B_cram_out),
    .config_data_out(sb_cram_out),
    .clk(clk), .en(en), .nrst(nrst),
    .north(bus_west), .south(SBsouth), .east(bus_south), .west(SBwest)
  );

  assign config_data_out = sb_cram_out;

endmodule
