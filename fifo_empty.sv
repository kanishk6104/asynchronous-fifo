


module fifo_empty  #( 
parameter addr_width =4 ) (
input logic [addr_width :0] rd_gray,
input logic [addr_width :0] wr_gray_sync,
output logic               empty );

assign empty = (rd_gray == wr_gray_sync);

    
endmodule
