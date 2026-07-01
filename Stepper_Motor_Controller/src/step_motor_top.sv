// Top-level module connecting all sub-modules for the stepper motor control system.
module step_motor_top (
		input logic resetb,
		input logic clk,
		input logic speed_sel,
		input logic direction,
		input logic on,
		input logic quarter,
		input logic step_size,
		
		output logic [6:0] sev_seg_o,
		output logic [6:0] sev_seg_t,
		output logic [3:0] pulses_out	
		);
		
		logic quarter_carry_out; // High when 100 steps are reached
		logic quarter_count_en;  // Gated enable for the quarter counter
		logic freq_out;          // Pulse output from the clock divider
		logic [27:0] speed_out;  // Dynamic countdown goal for speed control
		logic quarter_active;    // Status flag for quarter-turn execution
		logic driver_enable;     // Gated pulses sent to the motor driver
		logic [3:0] state;       // Current FSM speed state (1 to 6)

		
		// Speed selection finite state machine
		speed_control_fsm speed_controller (
			.clk(clk),
			.resetb(resetb),
			.speed_sel(speed_sel),
			.state(state),
			.out (speed_out)
		);
		
		// Clock divider generating speed pulses based on selected RPM
		counter #(.WIDTH(28)) freq_divider (
        .clk(clk),
        .resetb(resetb),
        .count_enb(1'b1),
        .count_goal(speed_out),
        .carry_out(freq_out),
        .count()
		);
		
		// Counter tracking 100 steps for a precise quarter-turn rotation
	   counter #(.WIDTH(7)) quarter_counter (
        .clk(clk),
        .resetb(resetb),
        .count_enb(quarter_count_en),
        .count_goal(7'd99),
        .carry_out(quarter_carry_out),
        .count()
		);
		
		// Operation mode controller managing continuous run and quarter-turn states
		mode mode_controller (
			.clk(clk),
			.resetb(resetb),
			.quarter(quarter),
			.on(on),
			.quarter_done(quarter_carry_out),
			.freq_out(freq_out),
			.quarter_active(quarter_active),
			.driver_enable(driver_enable),
			.quarter_count_en(quarter_count_en)
		);
		
		// 7-Segment decoder for the units digit (fixed to 0)
		seg_7 seg_units (
		.current_digit (4'b0),
		.seg_out (sev_seg_o)
		);
		
		// 7-Segment decoder for the tens digit (shows speed state 1-6)
		seg_7 seg_tens (
		.current_digit (state),
		.seg_out (sev_seg_t)
		);
		
		// Motor driver generating the 4-bit output sequence for the coils of the step motor
		driver_control motor_driver(
		.clk(clk),
		.resetb(resetb),
		.enb(driver_enable),
		.step_size(step_size),
		.direction(direction),
		.pulses_out(pulses_out)
		);
			
endmodule 