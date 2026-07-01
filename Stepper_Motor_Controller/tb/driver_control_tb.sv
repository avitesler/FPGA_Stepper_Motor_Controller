`timescale 1ns/1ps

module driver_control_tb ();
		logic enb;
		logic resetb;
		logic clk;
		logic step_size;
		logic direction;
		logic [3:0] pulses_out;

		driver_control uut (
			.enb(enb),
			.resetb(resetb),
			.clk(clk),
			.step_size(step_size),
			.direction(direction),
			.pulses_out(pulses_out)
		);

		// Clock generation (50MHz)
		always begin
			#10 clk = ~clk;
		end

		initial begin
			clk = 1'b0;
			resetb = 1'b0;
			enb = 1'b0;
			step_size = 1'b0; // Default to half-step
			direction = 1'b0; // Default to forward
			
			@(posedge clk);
			#3 resetb = 1'b1;
			
			repeat(4) @(posedge clk);

			// Test 5.1: Half-step sequence progression (Forward)
			#3 enb = 1'b1; // Turn on enable continuously to fast-forward the sequence
			step_size = 1'b0; //
			direction = 1'b0; //
			
			// Expected: Transitions through all 8 states (st_1 -> st_2 -> ... -> st_7 -> st_0)
			// advancing exactly one state per clock cycle.
			repeat(10) @(posedge clk);
			
			// Test 5.3: Real-time direction reversal mid-operation
			// Change direction
			#3 direction = 1'b1; 
			
			// Expected: The FSM immediately reverses its counting order
			repeat(5) @(posedge clk);
			
			// Test 5.2: Full-step pulse skipping and timing
			#3 direction = 1'b0; // Back to Forward
			step_size = 1'b1;    // Switch to Full Step Mode (1)
			
			// Expected: skip_toggle will start alternating. 
			// State will change only once every TWO clock cycles,
			// skipping intermediate states to maintain motor RPM.
			repeat(12) @(posedge clk);
			
			// Test 5.4: Asynchronous reset mid-operation
			// Wait for the FSM to be mid-sequence with skip_toggle active
			repeat(3) @(posedge clk);
			
			#3 resetb = 1'b0; // Assert reset mid-operation
			
			// Expected: current_state reverts to st_1, skip_toggle clears to 0, 
			// and pulses_out resets to 4'b1010 instantly.
			repeat(3) @(posedge clk);
			
			#3 resetb = 1'b1;	// Release reset
			
			// Allow normal operation to resume for a few cycles
			repeat(6) @(posedge clk);
			
			$stop;
		end

endmodule