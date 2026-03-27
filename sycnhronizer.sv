module sync_2ff #(
parameter width = 5) (
input logic clk,
input logic rst ,
input logic [width-1 :0] din,
output logic [width -1 :0] dout );

 logic [width -1 :0] sync1;
 always_ff @(posedge clk or posedge rst) begin
 if(rst) begin 
 sync1 <= '0;
 dout <= '0;
 end 
 else begin 
 sync1 <= din;
 dout<= sync1;
 end
 end
 endmodule
 