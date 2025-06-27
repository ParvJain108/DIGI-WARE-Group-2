module Parking(
  input wire entrance_sensor,
  input wire exit_sensor,
  input wire clock,
  input wire reset,
  input wire [3:0] password_input,
  output wire entrance_gate,
  output wire exit_gate,
  output reg [6:0] display
);

  reg [2:0] state;
  parameter IDLE = 3'b000, PASSWORD_ENTRY = 3'b001, GATE_OPEN = 3'b010, GATE_LOCKED = 3'b011;

  reg [3:0] password;
  initial password = 4'b1101;

  parameter TIMEOUT_LIMIT = 16'd10000; 
  reg [15:0] timeout_counter;

  reg car_inside;
  reg car_request;

  // Output logic for gates
  assign entrance_gate = (state == GATE_OPEN && car_request);
  assign exit_gate = (state == GATE_OPEN && !car_inside);

  // Display logic
  always @(*) begin
    case (state)
      PASSWORD_ENTRY: display = {3'b000, password_input};  // basic hex representation
      default: display = 7'b1111111;
    endcase
  end

  always @(posedge clock or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      car_inside <= 0;
      car_request <= 0;
      timeout_counter <= 0;
    end else begin
      case (state)
        IDLE: begin
          if (entrance_sensor && !car_inside) begin
            state <= PASSWORD_ENTRY;
            car_request <= 1;
            timeout_counter <= 0;
          end
        end

        PASSWORD_ENTRY: begin
          if (password_input == password) begin
            state <= GATE_OPEN;
          end else if (timeout_counter >= TIMEOUT_LIMIT) begin
            state <= IDLE;
            car_request <= 0;
          end else begin
            timeout_counter <= timeout_counter + 1;
          end
        end

        GATE_OPEN: begin
          if (car_request) begin
            car_inside <= 1;
            car_request <= 0;
            state <= GATE_LOCKED;
          end else if (exit_sensor && car_inside) begin
            car_inside <= 0;
            state <= IDLE;
          end
        end

        GATE_LOCKED: begin
          if (!car_inside)
            state <= IDLE;
        end
      endcase
    end
  end

endmodule
