`timescale 1ns/1ps

module step_motor_top_tb ();
		logic resetb;
		logic clk;
		logic speed_sel;
		logic direction;
		logic on;
		logic quarter;
		logic step_size;

		logic [6:0] sev_seg_o;
		logic [6:0] sev_seg_t;
		logic [3:0] pulses_out;

		step_motor_top uut (
			.resetb(resetb),
			.clk(clk),
			.speed_sel(speed_sel),
			.direction(direction),
			.on(on),
			.quarter(quarter),
			.step_size(step_size),
			.sev_seg_o(sev_seg_o),
			.sev_seg_t(sev_seg_t),
			.pulses_out(pulses_out)
		);

		// Clock generation (50MHz)
		always begin
			#10 clk = ~clk;
		end

		initial begin
			clk = 1'b0;
			resetb = 1'b0;
			speed_sel = 1'b1;
			direction = 1'b0; // Forward
			on = 1'b0;
			quarter = 1'b1;
			step_size = 1'b0; // Half-step
			
			@(posedge clk);
			#11 resetb = 1'b1;
			
			// Test 6.1: Quarter-turn execution
			repeat(2) @(posedge uut.freq_out);
			quarter = 1'b0;
			repeat(500) @(posedge clk);
			#3 quarter = 1'b1;
			
			// Smart wait: pause the testbench until the internal counter reaches 100
			wait (uut.quarter_carry_out == 1'b1);
			repeat(20) @(posedge uut.freq_out); // Give it a few clocks to settle back to idle
			
			// Test 6.2: Continuous mode & Live parameter changes
			on = 1'b1;
			
			// STEP UP: Pulse speed_sel 5 times (S1 -> S6)
			repeat(5) begin
				 repeat(20) @(posedge uut.freq_out); 
				 speed_sel = 1'b0; repeat(5) @(posedge clk); #11 speed_sel = 1'b1;
			end

			// STEP DOWN: Pulse speed_sel 5 times (S6 -> S1)
			#50
			repeat(5) begin
				 repeat(20) @(posedge uut.freq_out); 
				 speed_sel = 1'b0; repeat(5) @(posedge clk); #11 speed_sel = 1'b1;
			end

			repeat(4) @(posedge uut.freq_out);
			on = 1'b0; 
			repeat(4) @(posedge uut.freq_out);
			
			// Direction and Step Size toggles
			on = 1'b1; 

			// Get to a comfortable baseline speed (e.g., Speed 3)
			repeat(2) begin
				 speed_sel = 1'b0;
				 repeat(2) @(posedge clk);
				 #3 speed_sel = 1'b1;
				 repeat(100) @(posedge clk);
			end

			// Spin forward in half-step
			repeat(4) @(posedge uut.freq_out); 

			// Test 1: Change Direction to Backward
			#11 direction = 1'b1; 
			repeat(4) @(posedge uut.freq_out); 

			// Test 2: Change Step Size to Full-step (while backward)
			#20 step_size = 1'b1; 
			repeat(6) @(posedge uut.freq_out); 

			// Test 3: Change Direction back to Forward (while full-step)
			#20 direction = 1'b0; 
			repeat(6) @(posedge uut.freq_out); 

			#50 on = 1'b0; 
			repeat(5) @(posedge uut.freq_out);
						
			// Test 6.3: Simultaneous input collision (Priority test)
			// Assert both commands at the exact same clock edge
			#50
			quarter = 1'b0;
			on = 1'b1;
			
			// Expected: Continuous mode wins, quarter is ignored.
			repeat(500) @(posedge clk);
			quarter = 1'b1;
			
			repeat(110) @(posedge uut.freq_out); // We want to see that even after 100 steps on is the one who control
			
			on = 1'b0;
			repeat(20) @(posedge uut.freq_out);
			
			// Test 6.4: Parameter change mid-operation (Quarter turn)
			#50
			direction = 1'b0;
			quarter = 1'b0;
			repeat(500) @(posedge clk);
			#3 quarter = 1'b1;
			
			// Wait exactly 50 steps (halfway through the quarter turn)
			repeat(50) @(posedge uut.freq_out);
			
			// Dynamically bump the speed up by one state
			speed_sel = 1'b0; @(posedge clk); #3 speed_sel = 1'b1;
			
			// Wait for the remaining 50 steps to finish naturally
			wait (uut.quarter_carry_out == 1'b1);
			repeat(5) @(posedge uut.freq_out);
			
			// Test 6.5: Reset priority exactly at step 100
			quarter = 1'b0;
			repeat(500) @(posedge clk);
			#3 quarter = 1'b1;
			
			// Wait exactly until the carry_out fires
			wait (uut.quarter_carry_out == 1'b1);
			
			// IMMEDIATELY assert reset to test race condition
			#1 resetb = 1'b0;
			repeat(100) @(posedge clk);
			#3 resetb = 1'b1;
			
			// Test 6.6: Global mid-operation reset
			on = 1'b1;
			
			// Pulse speed_sel 3 times to get to Speed State 4
			repeat(3) begin
				speed_sel = 1'b0; @(posedge clk); #11 speed_sel = 1'b1;
				repeat(20) @(posedge clk);
			end
			
			repeat(4) @(posedge uut.freq_out);
			
			// Yank the reset down mid-spin
			#3 resetb = 1'b0;
			repeat(100) @(posedge clk);
			#3 resetb = 1'b1;
			repeat(100) @(posedge clk);
			on = 1'b0;
			
			repeat(10) @(posedge clk);

			$stop;
		end
		
endmodule