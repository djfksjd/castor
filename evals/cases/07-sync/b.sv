// `btn_n` is the output of an external debouncer IC; it is asynchronous to clk.
module start_ctrl (
  input  logic clk,
  input  logic rst_n,
  input  logic btn_n,
  output logic start
);
  typedef enum logic [1:0] {IDLE, ARMED, FIRE} state_t;
  state_t state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else begin
      unique case (state)
        IDLE:  if (btn_n)  state <= ARMED;
        ARMED: if (!btn_n) state <= FIRE;
        FIRE:              state <= IDLE;
        default:           state <= IDLE;
      endcase
    end
  end

  assign start = (state == FIRE);
endmodule
