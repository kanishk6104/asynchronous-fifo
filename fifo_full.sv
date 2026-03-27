


module fifo_full #(
parameter addr_width =4 ) (
input logic [addr_width:0] wr_gray_next,
input logic [addr_width:0] rd_gray_sync,
output logic               full
    );
    
    assign full = (wr_gray_next == { ~rd_gray_sync[addr_width : addr_width-1],
                   rd_gray_sync[addr_width-2:0]});
endmodule
