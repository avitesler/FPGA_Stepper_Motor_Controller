// This module manages continuous run and single quarter-turn modes for the stepper motor.
module mode (
		input logic clk,
		input logic resetb,
		input logic quarter,		
		input logic on,
		input logic quarter_done, // Signal from quarter counter
		input logic freq_out, // Pulses from the clock divider
		
		output logic quarter_active, // Flag: currently doing a quarter turn
		output logic driver_enable, // Output pulses to the motor controller
		output logic quarter_count_en // Allow quarter counter to start counting

);

    logic previous_q_btn_mode;   // Remembers the previous button state
    logic quarter_trigger; // High for exactly 1 clock cycle on press
    
	 // Edge Detector for the quarter button
    always_ff @(posedge clk or negedge resetb) begin
        if (!resetb) begin
            previous_q_btn_mode <= 1'b0;
        end
		  else begin
            previous_q_btn_mode <= ~quarter; // Save the current state for the next clock cycle
        end
    end
    
    // Trigger is 1 ONLY when currently pressed AND not pressed before
    assign quarter_trigger = ~quarter & ~previous_q_btn_mode;


    // Quarter-Turn State Flag (make sure that another press on quarter button when already doing quarter turn)
    always_ff @(posedge clk or negedge resetb) begin
        if (!resetb) begin
            quarter_active <= 1'b0;
        end
		  else begin
            // Turn on flag if button is pressed, continuous mode is off (on=0), and not already active
           if (quarter_trigger && !on && !quarter_active) begin
               quarter_active <= 1'b1;
           end 
            // Turn off flag if 100 steps are done OR if user turns on continuous mode
           else if (quarter_done) begin
               quarter_active <= 1'b0;
           end
        end
    end
	 
	 assign quarter_count_en = quarter_active & freq_out;
	 
    // Pass the speed pulses only if continuous mode is on or quarter flag is on.
    // otherwise, output 0 (stop the motor).
    assign driver_enable = (on || quarter_active) ? freq_out : 1'b0;

endmodule

