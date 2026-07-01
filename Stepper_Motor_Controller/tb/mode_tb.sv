`timescale 1ns/1ps

module mode_tb ();
		logic clk;
		logic resetb;
		logic quarter;
		logic on;
		logic quarter_done;
		logic freq_out;
		
		logic quarter_active;
		logic driver_enable;
		logic quarter_count_en;

		mode uut (
			.clk(clk),
			.resetb(resetb),
			.quarter(quarter),
			.on(on),
			.quarter_done(quarter_done),
			.freq_out(freq_out),
			.quarter_active(quarter_active),
			.driver_enable(driver_enable),
			.quarter_count_en(quarter_count_en)
		);

		// Clock generation (50MHz)
		always begin
			#10 clk = ~clk;
		end

		// Simulate the pulses coming from the frequency divider
		always begin
			#25 freq_out = ~freq_out; 
		end

		initial begin
			clk = 1'b0;
			freq_out = 1'b0;
			resetb = 1'b0;
			quarter = 1'b1;
			on = 1'b0;
			quarter_done = 1'b0;
			
			@(posedge clk);
			#3 resetb = 1'b1;

			// Test 4.1: Quarter-turn activation and lockout mechanism
			// Press the quarter button for one clock cycle
			#10 quarter = 1'b0;
			@(posedge clk);
			#3 quarter = 1'b1;
			
			// Wait to observe quarter_active goes high
			repeat(4) @(posedge clk);
			
			// Try pressing the button again while already active (Lockout test)
			quarter = 1'b0;
			@(posedge clk);
			#3 quarter = 1'b1;
			
			// Wait to verify the second press was ignored
			repeat(25) @(posedge clk);
			
			// Test 4.3: Quarter-turn completion sequence
			// Simulate the counter reaching 100 steps
			quarter_done = 1'b1;
			@(posedge clk);
			#3 quarter_done = 1'b0; // Flag clears the active state
			
			repeat(5) @(posedge clk);
			
			// Test 4.5: Continuous mode override priority
			// Start a new quarter-turn
			quarter = 1'b0;
			@(posedge clk);
			#3 quarter = 1'b1;
			
			repeat(3) @(posedge clk);
			
			// Turn ON continuous mode mid-turn
			on = 1'b1; 
			// Expected: quarter_active STAYS 1, driver_enable follows freq_out
			repeat(6) @(posedge clk); 
			
			// Simulate the counter reaching 100 steps while ON is still active
			quarter_done = 1'b1;
			@(posedge clk);
			#3 quarter_done = 1'b0; 
			// Expected: quarter_active drops to 0, but driver_enable CONTINUES because on=1
			
			repeat(5) @(posedge clk);

			// Turn off continuous mode
			on = 1'b0;
			repeat(5) @(posedge clk);
			
			// Test 4.2: Transient ON interruption
			// Start another quarter-turn
			quarter = 1'b0;
			@(posedge clk);
			#3 quarter = 1'b1;
			
			repeat(3) @(posedge clk);
			
			// Turn ON continuous mode briefly mid-turn
			on = 1'b1;
			repeat(3) @(posedge clk);
			// Turn it OFF before completion
			on = 1'b0;
			// Expected: quarter_active remains 1 undisturbed
			repeat(3) @(posedge clk);
			
			// Finish the quarter turn
			quarter_done = 1'b1;
			@(posedge clk);
			#3 quarter_done = 1'b0; 
			
			repeat(5) @(posedge clk);
			
			// Test 4.4: Asynchronous reset mid-turn
			// Start another quarter-turn
			quarter = 1'b0;
			@(posedge clk);
			#3 quarter = 1'b1;
			
			repeat(3) @(posedge clk);
			
			// Assert reset in the middle of the operation
			resetb = 1'b0;
			repeat(3) @(posedge clk);
			
			// Release reset to verify system is clean and ready
			#3 resetb = 1'b1;
			
			repeat(5) @(posedge clk);

			$stop;
		end

endmodule