`timescale 1ns / 1ps
module async_fifo_tb;

    parameter data_width = 8;
    parameter addr_width = 4;

    logic wr_clk, rd_clk, rst;
    logic wr_en, rd_en;
    logic signed [data_width-1:0] din;
    logic [data_width-1:0] dout;
    logic full, empty;


   
    // dut
    async_fifo_top #(
        .data_width(data_width),
        .addr_width(addr_width)
    ) dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),   // active high reset
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // -----------------------------
    // clock generation (async)
    // -----------------------------
    initial wr_clk = 0;
    always #5 wr_clk = ~wr_clk;

    initial rd_clk = 0;
    always #7 rd_clk = ~rd_clk;

    // -----------------------------
    // reference model
    // -----------------------------
    logic [data_width-1:0] ref_q[$];

    // -----------------------------
    // reset sequence (active high)
    // -----------------------------
    initial begin
        rst   = 1;   // assert reset
        wr_en = 0;
        rd_en = 0;
        din   = 0;

        #20;
        rst = 0;     // deassert reset
    end

    // -----------------------------
    // write logic
    // -----------------------------
   always @(posedge wr_clk) begin
    if (rst) begin
        wr_en <= 0;
        din   <= 0;
    end else begin
        int wr_en_rand;
        wr_en_rand = $urandom_range(0,1);
        wr_en <= wr_en_rand;

        if (wr_en_rand && !full) begin
            int temp;
            temp = $urandom;
            din  <= temp;
            ref_q.push_back(temp);
        end
    end
end

    // -----------------------------
    // read + check logic
    // -----------------------------
    always @(posedge rd_clk) begin
        if (rst) begin
            rd_en <= 0;
        end else begin
            rd_en <= $urandom_range(0,1);

            if (rd_en && !empty) begin
                if (ref_q.size() == 0) begin
                    $error("underflow error!");
                end else begin
                    logic [data_width-1:0] expected;
                    expected = ref_q.pop_front();

                    if (dout !== expected) begin
                        $error("data mismatch! expected=%0h got=%0h", expected, dout);
                    end
                end
            end
        end
    end

    // -----------------------------
    // status monitoring
    // -----------------------------
    always @(posedge wr_clk) begin
        if (!rst && full && wr_en)
            $display("info: write attempted when fifo full");
    end

    always @(posedge rd_clk) begin
        if (!rst && empty && rd_en)
            $display("info: read attempted when fifo empty");
    end


endmodule
