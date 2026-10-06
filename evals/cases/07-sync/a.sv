// `btn_n` is the output of an external debouncer IC; it is asynchronous to clk.
module start_ctrl (
  input  logic clk,
  input  logic rst_n,
  input  logic btn_n,
  output logic start
);
  logic [1:0] sync;
  logic       prev;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sync <= 2'b11;
      prev <= 1'b1;
    end else begin
      sync <= {sync[0], btn_n};
      prev <= sync[1];
    end
  end

  assign start = prev & ~sync[1]; // one-cycle pulse on a synchronized falling edge
endmodule
