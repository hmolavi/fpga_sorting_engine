//////////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Author: Hossein Molavi
// 
// Create Date: 06/24/2024 19:13:46 PM
// Design Name: Hossein's Even Odd Sorting Machine
// Module Name(s): SE, Comparator
// Project Name: Project 3
// Additional Comments:
// This design was compiled and tested in Icarus Verilog.
//
//////////////////////////////////////////////////////////////////////////////////

// Comparator module
module comparator #(parameter DATAWIDTH = 8) (
    input wire [DATAWIDTH-1:0] a, b, // Inputs
    output wire [DATAWIDTH-1:0] max, min // Outputs
);
    assign max = (a > b) ? a : b; // Max of a and b
    assign min = (a > b) ? b : a; // Min of a and b
endmodule

// Sorting Engine (SE) module
// Overall runtime: n/2 + 2 cycles, where n represents the ARRAYLENGTH 
module SE #(parameter ARRAYLENGTH = 10, parameter DATAWIDTH = 8) (
    input wire clk, valid_in,
    input wire [0:ARRAYLENGTH*DATAWIDTH-1] array_in, // Input array
    output reg [0:ARRAYLENGTH*DATAWIDTH-1] array_out, // Output array
    output reg valid_out
);

    reg [7:0] cycle_count;
    reg output_sent;

    // Wires for comparator results
    wire [DATAWIDTH-1:0] comp_begin [0:ARRAYLENGTH-1];
    wire [DATAWIDTH-1:0] comp_middle [0:ARRAYLENGTH-1];
    wire [DATAWIDTH-1:0] comp_output [0:ARRAYLENGTH-1];

    // Instantiate comparators
    genvar i;
    generate
        for (i = 0; i < ARRAYLENGTH-1; i = i + 1) begin : cl
            if (i == 0) begin
                comparator #(DATAWIDTH) TOP_FIRST (.a(comp_begin[0]), .b(comp_begin[1]), .max(comp_output[0]), .min(comp_middle[1]));
            end else if (ARRAYLENGTH % 2 == 0 && i == ARRAYLENGTH - 2) begin
                comparator #(DATAWIDTH) TOP_LAST (.a(comp_begin[i]), .b(comp_begin[i+1]), .max(comp_middle[i]), .min(comp_output[i+1]));
            end else if (ARRAYLENGTH % 2 == 1 && i == ARRAYLENGTH - 2) begin
                comparator #(DATAWIDTH) BOTTOM_LAST (.a(comp_middle[i]), .b(comp_begin[i+1]), .max(comp_output[i]), .min(comp_output[i+1]));
            end else if (i % 2 == 0) begin
                comparator #(DATAWIDTH) TOP (.a(comp_begin[i]), .b(comp_begin[i+1]), .max(comp_middle[i]), .min(comp_middle[i+1]));
            end else begin
                comparator #(DATAWIDTH) BOTTOM (.a(comp_middle[i]), .b(comp_middle[i+1]), .max(comp_output[i]), .min(comp_output[i+1]));
            end
        end
    endgenerate

    genvar j;
    generate
        for (j = 0; j < ARRAYLENGTH; j = j + 1) begin
            assign comp_begin[j] = array_out[j*DATAWIDTH +: DATAWIDTH];
        end
    endgenerate

    integer l;
    always @(posedge clk) begin
        if (valid_in) begin
            array_out <= array_in; // Load input array
            cycle_count <= 1'b1;
            valid_out <= 1'b0;
            output_sent <= 1'b0;
        end else begin
            for (l = 0; l < ARRAYLENGTH; l = l + 1) begin
                array_out[l*DATAWIDTH +: DATAWIDTH] <= comp_output[l]; // Update array
            end
            if (cycle_count == ((ARRAYLENGTH >> 1) + (ARRAYLENGTH % 2)) && output_sent == 1'b0) begin
                valid_out <= 1'b1; // Indicate sorted array
                cycle_count <= 1'b0;
                output_sent <= 1'b1;
            end else begin
                valid_out <= 1'b0;
                cycle_count <= cycle_count + 1;
            end
        end
    end
endmodule
