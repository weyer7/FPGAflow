`default_nettype none
module logicelement #(
  parameter
    LUT_SIZE = 16 //number of look up table values
)(
  input logic clk, en, nrst,
  input logic [$clog2(LUT_SIZE):0] select, //select lines of the LE's LUT
  input logic [(LUT_SIZE + 1) - 1:0] config_data, //LUT data + operation mode
  output logic le_out
);
// The logic element, or LE of an FPGA is what defines the FPGA's behavior.
// It contains both combinational logic in the form of a look-up table, or
// LUT, as well as a single D type flip-flop. These two elements, combined
// with configurable connectons with the switch boxes and connecton boxes,
// can form any combinational or sequential circuit so long as the FPGA
// is large enough.

//Configuration data:
//MSB [ MODE | LUT data ] LSB

//D type flip-flop
logic dff_out;
always_ff @(posedge clk, negedge nrst) begin
  if (!nrst) begin
    dff_out <= 0;
  end else if (en) begin
    dff_out <= mux_out;
  end else begin
    dff_out <= dff_out;
  end
end

//multiplexer
logic mux_out;
assign mux_out = config_data[select];

//mode multiplexer
logic mode;
assign mode = config_data[LUT_SIZE];
assign le_out = mode ? dff_out : mux_out;

endmodule