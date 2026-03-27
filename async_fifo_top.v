module async_fifo_top #(
  parameter data_width = 8,
  parameter addr_width = 4
)(
  input  logic wr_clk,
  input  logic rd_clk,
  input  logic rst,

  input  logic wr_en,
  input  logic rd_en,
  input  logic [data_width-1:0] din,

  output logic [data_width-1:0] dout,
  output logic full,
  output logic empty
);

  // ================================
  // Internal signals
  // ================================
  logic [addr_width:0] wr_ptr_bin, wr_ptr_gray, wr_ptr_gray_next;
  logic [addr_width:0] rd_ptr_bin, rd_ptr_gray, rd_ptr_gray_next;

  logic [addr_width:0] wr_ptr_gray_sync;
  logic [addr_width:0] rd_ptr_gray_sync;

  logic wr_en_int, rd_en_int;

  // ================================
  // Enable gating
  // ================================
  assign wr_en_int = wr_en & ~full;
  assign rd_en_int = rd_en & ~empty;

  // ================================
  // Write Pointer
  // ================================
  wr_ptr #(.addr_width(addr_width)) u_wr_ptr (
    .wr_clk(wr_clk),
    .rst(rst),
    .wr_en(wr_en_int),
    .full(full),
    .wr_ptr_bin(wr_ptr_bin),
    .wr_ptr_gray(wr_ptr_gray),
    .wr_ptr_gray_next(wr_ptr_gray_next)
  );

  // ================================
  // Read Pointer
  // ================================
  rd_ptr #(.addr_width(addr_width)) u_rd_ptr (
    .rd_clk(rd_clk),
    .rst(rst),
    .rd_en(rd_en_int),
    .empty(empty),
    .rd_ptr_bin(rd_ptr_bin),
    .rd_ptr_gray(rd_ptr_gray),
    .rd_ptr_gray_next(rd_ptr_gray_next)
  );

  // ================================
  // Synchronization
  // ================================

  // Read pointer → Write clock domain
  sync_2ff #(.width(addr_width+1)) u_sync_rd_to_wr (
    .clk (wr_clk),                 // ✅ correct domain
    .rst (rst),
    .din (rd_ptr_gray),
    .dout(rd_ptr_gray_sync)        // ✅ correct signal
  );

  // Write pointer → Read clock domain
  sync_2ff #(.width(addr_width+1)) u_sync_wr_to_rd (
    .clk (rd_clk),
    .rst (rst),
    .din (wr_ptr_gray),
    .dout(wr_ptr_gray_sync)
  );

  // ================================
  // Full Logic
  // ================================
  fifo_full #(.addr_width(addr_width)) u_full (
    .wr_gray_next (wr_ptr_gray_next),
    .rd_gray_sync (rd_ptr_gray_sync),
    .full         (full)
  );

  // ================================
  // Empty Logic
  // ================================
  fifo_empty #(.addr_width(addr_width)) u_empty (
    .rd_gray      (rd_ptr_gray),
    .wr_gray_sync (wr_ptr_gray_sync),
    .empty        (empty)
  );

  // ================================
  // Memory
  // ================================
  fifo_mem #(
    .data_width(data_width),
    .addr_width(addr_width)
  ) u_mem (
    .wr_clk (wr_clk),
    .wr_en  (wr_en_int),
    .wr_addr(wr_ptr_bin[addr_width-1:0]),
    .din    (din),

    .rd_clk (rd_clk),
    .rd_en  (rd_en_int),
    .rd_addr(rd_ptr_bin[addr_width-1:0]),
    .dout   (dout)
  );

endmodule