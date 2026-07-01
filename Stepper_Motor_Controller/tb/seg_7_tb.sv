`timescale 1ns/1ps

module seg_7_tb ();
    logic [3:0] current_digit;
    logic [6:0] seg_out;

    seg_7 utt (
        .current_digit (current_digit),
        .seg_out (seg_out)
    );

    initial begin
        $display("--- Starting seg_7 Decoder Test ---");
        
        // Loop through all 16 possible values of a 4-bit input (from 0 to 15)
        for (int i = 0; i < 16; i++) begin
            
            current_digit = i;
            
            #10;
            
            // Print the input (in decimal and binary) and the resulting output to the Transcript window
            $display("Input: %0d (Binary: %4b) -> Output seg_out: %7b", current_digit, current_digit, seg_out);
        end
        
        $display("--- Test Finished ---");

        $stop;
    end
endmodule