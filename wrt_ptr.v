module wr_ptr #(
  parameter addr_width = 4
)(
  input  logic wr_clk,
  input  logic rst,
  input  logic wr_en,
  input  logic full,

  output logic [addr_width:0] wr_ptr_bin,
  output logic [addr_width:0] wr_ptr_gray,
  output logic [addr_width:0] wr_ptr_gray_next
);

  logic [addr_width:0] wr_ptr_bin_next;

  // ✅ correct increment
  assign wr_ptr_bin_next = wr_ptr_bin + (wr_en && !full);

  // ✅ correct gray conversion
  assign wr_ptr_gray_next = (wr_ptr_bin_next >> 1) ^ wr_ptr_bin_next;

  always_ff @(posedge wr_clk or posedge rst) begin
    if (rst) begin
      wr_ptr_bin  <= '0;
      wr_ptr_gray <= '0;
    end else begin
      wr_ptr_bin  <= wr_ptr_bin_next;
      wr_ptr_gray <= wr_ptr_gray_next;
    end
  end

endmodule