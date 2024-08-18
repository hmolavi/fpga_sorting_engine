//////////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author: Hossein Molavi
// 
// Create Date: 06/24/2024 19:13:46 PM
// Design Name: Hossein's Even Odd Sorting Machine Testbench
// Module Name: top_module
// Project Name: Project 3
// Additional Comments:
// This design was compiled and tested in Icarus Verilog.
//
//////////////////////////////////////////////////////////////////////////////////

module top_module;
    // Parameters
    parameter DATAWIDTH = 8;
    parameter ARRAYLENGTH_ODD = 11;
    parameter ARRAYLENGTH_EVEN = 6; // For the new test case

    // Inputs
    reg clk = 1'b0;
    reg [(DATAWIDTH*ARRAYLENGTH_ODD)-1:0] array_in_odd;
    reg [(DATAWIDTH*ARRAYLENGTH_EVEN)-1:0] array_in_even;
    reg valid_in_odd;
    reg valid_in_even;

    // Outputs
    wire [(DATAWIDTH*ARRAYLENGTH_ODD)-1:0] array_out_odd;
    wire [(DATAWIDTH*ARRAYLENGTH_EVEN)-1:0] array_out_even;
    wire valid_out_odd;
    wire valid_out_even;

    // Instantiate the SE module for ARRAYLENGTH_ODD
    SE #(ARRAYLENGTH_ODD, DATAWIDTH) uut_odd (
        .clk(clk),
        .array_in(array_in_odd),
        .valid_in(valid_in_odd),
        .array_out(array_out_odd),
        .valid_out(valid_out_odd)
    );

    // Instantiate the SE module for ARRAYLENGTH_EVEN
    SE #(ARRAYLENGTH_EVEN, DATAWIDTH) uut_even (
        .clk(clk),
        .array_in(array_in_even),
        .valid_in(valid_in_even),
        .array_out(array_out_even),
        .valid_out(valid_out_even)
    );

    // Clock generation
    always #5 clk = ~clk;  // 100 MHz clock

    // Test vectors
    initial begin
        $dumpvars; // Used for in EDAplayground
        $display("Starting simulation...");

        // Initial values
        array_in_odd = 0;
        array_in_even = 0;
        valid_in_odd = 0;
        valid_in_even = 0;
        #20    

        // Test case 1: Random array (length 11)
        array_in_odd = {8'h00, 8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 8'h88, 8'h99, 8'hbb};
        valid_in_odd = 1;
        #10 valid_in_odd = 0;

        // Wait for "n/2 + 1 for odd sorts" clock cycles + 1 extra cycle to see the valid out signal 
        #(10 * ((ARRAYLENGTH_ODD/2)+(ARRAYLENGTH_ODD%2)+1));

        // Display the result
        $display("Given array (length 11):  %h", array_in_odd);
        $display("Sorted array (length 11): %h", array_out_odd);

        // Test case 2: Specific array with length 6
        array_in_even = {8'h00, 8'h11, 8'h22, 8'h33, 8'h44, 8'h55};
        valid_in_even = 1;
        #10 valid_in_even = 0;

        // Wait for "n/2 + 1 for even sorts" clock cycles + 1 extra cycle to see the valid out signal 
        #(10 * ((ARRAYLENGTH_EVEN/2)+(ARRAYLENGTH_EVEN%2)+1));

        // Display the result
        $display("Given array (length 6):  %h", array_in_even);
        $display("Sorted array (length 6): %h", array_out_even);
		
        // Finish simulation
        #30 // makes the EPWave look nice and symmetrical
      	$display("Simulation complete.");
        $finish;
    end
endmodule