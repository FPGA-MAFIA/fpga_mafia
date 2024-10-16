`include "macros.vh"

typedef struct packed {
  //logic [M_width + Q_width - 1:0] Accum;
  logic [31:0] Accum;
  //logic [M_width - 1:0] M;
  logic [23:0] Mu;
  //logic [Q_width - 1:0] Q;
  logic [7:0] Qu;
  logic is_pos;
} stage_mul_inp_t;

module shift_multiplier
#(
  parameter int M_width = 24,
  parameter int Q_width = 8
)
(
  input logic Clock,
  input logic Rst,
  input logic signed [M_width - 1:0] Mu, // Multiplicand 2's complement
  input logic signed [Q_width - 1:0] Qu, // Multiplier 2's complement
  output logic signed [M_width + Q_width - 1:0] product // 2's complement
);

///////////////////////////////////////////////////
// cycle 0: make both numbers positive
logic [M_width - 1:0] abs_M;
logic [Q_width - 1:0] abs_Q;
logic is_pos;
logic signed [M_width + Q_width - 1:0] tmp_product;

always_comb begin // convert to positive
  if(Rst) begin
    abs_M = 0;
    abs_Q = 0;
    is_pos = 0;
  end
  else begin 
    if (Mu < 0) begin
      abs_M = ~Mu + 1;
    end else begin
      abs_M = Mu;
    end
    if (Qu < 0) begin
      abs_Q = ~Qu + 1;
    end else begin
      abs_Q = Qu;
    end
    if ((Qu < 0 && Mu < 0) || (Qu > 0 && Mu > 0)) begin
      is_pos = 1'b1;
    end else begin
      is_pos = 1'b0;
    end
  end
end 

stage_mul_inp_t stage_inputs [0:Q_width];
////////////////////////////////////////////////////////////////////////////
// setting default values to stage_inputs(0)
always_ff @(posedge Clock or posedge Rst) begin
  if (Rst) begin
    stage_inputs[0].Accum <= '0;
    stage_inputs[0].Mu <= '0;
    stage_inputs[0].Qu <= '0;
    stage_inputs[0].is_pos <= 1'b0;
  end else begin
    stage_inputs[0].Accum <= '0;
    stage_inputs[0].Mu <= abs_M;
    stage_inputs[0].Qu <= abs_Q;
    stage_inputs[0].is_pos <= is_pos;
  end
end

////////////////////////////////////////////////////////////////////////////
// cycle i: Total Q_width cycles
always_ff @(posedge Clock or posedge Rst) begin
  if (Rst) begin
    for (int i = 0; i < Q_width; i++) begin
      stage_inputs[i+1].Accum <= '0;
      stage_inputs[i+1].Mu <= '0;
      stage_inputs[i+1].Qu <= '0;
      stage_inputs[i+1].is_pos <= 1'b0;
    end
  end else begin
    for (int i = 0; i < Q_width; i++) begin
      stage_inputs[i+1].Accum <= (stage_inputs[i].Qu[0]) ? stage_inputs[i].Accum + (stage_inputs[i].Mu << i) : stage_inputs[i].Accum;
      stage_inputs[i+1].Mu <= stage_inputs[i].Mu;
      stage_inputs[i+1].Qu <= stage_inputs[i].Qu >> 1;
      stage_inputs[i+1].is_pos <= stage_inputs[i].is_pos;
    end
  end
end

always_comb begin // convert to positive
  if(Rst)
    tmp_product = 0;
  else if (stage_inputs[Q_width].is_pos) begin
    tmp_product = stage_inputs[Q_width].Accum;
  end else begin
    tmp_product = ~(stage_inputs[Q_width].Accum) + 1;
  end
end
assign product = tmp_product;
endmodule