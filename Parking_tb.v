`timescale 1ns / 1ps
module Parking_tb;

  reg entrance_sensor;
  reg exit_sensor;
  reg clock;
  reg reset;
  reg [3:0] password_input;

  wire entrance_gate;
  wire exit_gate;
  wire [6:0] display;

  Parking uut (
    .entrance_sensor(entrance_sensor),
    .exit_sensor(exit_sensor),
    .clock(clock),
    .reset(reset),
    .password_input(password_input),
    .entrance_gate(entrance_gate),
    .exit_gate(exit_gate),
    .display(display)
  );

  // Clock generator
  always #5 clock = ~clock;

  initial begin
    // Initial values
    clock = 0;
    reset = 1;
    entrance_sensor = 0;
    exit_sensor = 0;
    password_input = 4'b0000;

    #10 reset = 0;

    // Car arrives at entrance
    #10 entrance_sensor = 1;
    #10 entrance_sensor = 0;

    // Start entering password
    #10 password_input = 4'b1101;  // correct password

    // Wait for gate to open and car to enter
    #50;

    // Car wants to exit
    #10 exit_sensor = 1;
    #10 exit_sensor = 0;

    #100;

    $stop;
  end

endmodule
