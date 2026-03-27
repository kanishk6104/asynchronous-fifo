module rd_ptr #(
parameter addr_width =4 )
( input logic rd_clk,
  input logic rst,
  input logic rd_en,
  input logic empty,
  
  output logic [addr_width:0] rd_ptr_bin,
  output logic  [addr_width :0] rd_ptr_gray,
  output logic  [ addr_width : 0] rd_ptr_gray_next );

logic [addr_width :0] rd_ptr_bin_next;
// increment only if not empty 
assign rd_ptr_bin_next = rd_ptr_bin + (rd_en && !empty);

// binary to gray 
assign rd_ptr_gray_next = ( rd_ptr_bin_next >> 1) ^ rd_ptr_bin_next;

always_ff @(posedge rd_clk or posedge rst ) begin

if (rst) begin
rd_ptr_bin <= '0;
rd_ptr_gray <= '0;

end
else begin

rd_ptr_bin <= rd_ptr_bin_next;
rd_ptr_gray <= rd_ptr_gray_next;
end
end


endmodule