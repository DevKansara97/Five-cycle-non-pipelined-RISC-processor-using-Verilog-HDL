`timescale 1ns / 1ps

module RISCprocessor_tb;

    // --- Clock and Reset ---
    reg clk;
    reg Reset;

    // --- Input Signals ---
    reg [7:0] InpExtWorld1;
    reg [7:0] InpExtWorld2;
    reg [7:0] InpExtWorld3;
    reg [7:0] InpExtWorld4;

    // --- Output Signals (Monitored) ---
    wire [7:0] OutExtWorld1;
    wire [7:0] OutExtWorld2;
    wire [7:0] OutExtWorld3;
    wire [7:0] OutExtWorld4;

    // --- Instantiate the RISC Processor ---
    RISCprocessor DUT (
        .clk(clk),
        .Reset(Reset),
        .InpExtWorld1(InpExtWorld1),
        .InpExtWorld2(InpExtWorld2),
        .InpExtWorld3(InpExtWorld3),
        .InpExtWorld4(InpExtWorld4),
        .OutExtWorld1(OutExtWorld1),
        .OutExtWorld2(OutExtWorld2),
        .OutExtWorld3(OutExtWorld3),
        .OutExtWorld4(OutExtWorld4)
    );

    // --- Clock Generation ---
    always #5 clk = ~clk;  // Toggle clock every 5 ns (100 MHz)

    // --- Initial Block for Simulation Control ---
    initial begin
      
      $dumpfile("dump.vcd");
        $dumpvars(0, RISCprocessor_tb);
        // Initialize signals
        clk = 0;
        Reset = 1;
        InpExtWorld1 = 8'h00;
        InpExtWorld2 = 8'h00;
        InpExtWorld3 = 8'h00;
        InpExtWorld4 = 8'h00;

        // Hold reset for a few cycles
        #20;
        Reset = 0;

        // Stimulus: Set input values
        #10;
        InpExtWorld1 = 8'h11;
        InpExtWorld2 = 8'h22;
        InpExtWorld3 = 8'h33;
        InpExtWorld4 = 8'h44;

        // Wait and observe outputs
        #1000;

        // End simulation
        $finish;
    end

    // --- Monitor Output Changes ---
    initial begin
        $monitor("Time=%0t | Out1=%h Out2=%h Out3=%h Out4=%h", 
                  $time, OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4);
    end

endmodule