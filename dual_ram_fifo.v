module fifo_mem #( 
parameter data_width = 8,
parameter addr_width = 4 )
( input logic  wr_clk,
  input logic wr_en ,
  input logic [addr_width -1: 0] wr_addr,
  input logic  [ data_width -1 :0] din,
  
  input logic rd_clk,
  input logic rd_en,
  input logic [addr_width -1 :0 ] rd_addr,
  output logic [data_width -1 :0] dout );
  
localparam depth = 1 << addr_width;

logic [data_width-1:0] mem [0:depth-1];

// write
always_ff @(posedge wr_clk) begin
  if (wr_en)
    mem[wr_addr] <= din;
end

// read
always_ff @(posedge rd_clk) begin
  if (rd_en)
    dout <= mem[rd_addr];
end

endmodule