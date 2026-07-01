// This module sends control signals to the driver through a 4-bit bus
// according to the step size, direction, and enable inputs.
module driver_control (
		input logic enb,
		input logic resetb,
		input logic clk,
		input logic step_size,
		input logic direction,
		
		output logic [3:0] pulses_out	

);
		logic skip_toggle; // Internal signal to skip every second enable pulse
		
		typedef enum logic [2:0] {st_0, st_1, st_2, st_3, st_4, st_5, st_6, st_7} sm_type;
		
		sm_type current_state;
		sm_type next_state;
		
		always_ff @(posedge clk or negedge resetb) begin
			  if (!resetb) begin
					current_state <= st_1;
					skip_toggle  <= 1'b0;
			  end
			  else if (enb) begin
					if (step_size == 1'b0) begin // Half Step Mode: advance on every enable pulse
					
						 current_state <= next_state;
						 skip_toggle  <= 1'b0; // Reset toggle if user changes the switch
					end
					else begin // Full Step Mode: advance once every 2 pulses
						 skip_toggle <= ~skip_toggle;
						 if (~skip_toggle) begin // Execute state change every second pulse
							  current_state <= next_state;
						 end
					end
			  end
		 end
		
		always_comb begin	
			case (current_state)
			
			// Next-state transition logic
			// Selects the next FSM state according to direction and step size
				st_0: next_state = ~direction ? st_1 : st_7;
				st_1: next_state = step_size ? (~direction ? st_3 : st_7) : (~direction ? st_2 : st_0);
				st_2: next_state = ~direction ? st_3 : st_1;
				st_3: next_state = step_size ? (~direction ? st_5 : st_1) : (~direction ? st_4 : st_2);
				st_4: next_state = ~direction ? st_5 : st_3;
				st_5: next_state = step_size ? (~direction ? st_7 : st_3) : (~direction ? st_6 : st_4);
				st_6: next_state = ~direction ? st_7 : st_5;
				st_7: next_state = step_size ? (~direction ? st_1 : st_5) : (~direction ? st_0 : st_6);
				default: next_state =st_1;
			endcase
		end
		
		always_comb begin
			case (current_state)
			// Output decoding logic
			// Maps each FSM state to the corresponding motor pulse pattern
			// For coils A,B: Pulses_out[0] = A, Pulses_out[1] = ~A, Pulses_out[2] = B, Pulses_out[3] = ~B
				st_0: pulses_out = 4'b1000; // IN1=1 (Coil A Forward)
				st_1: pulses_out = 4'b1010; // IN1=1, IN3=1 (Coil A Fwd + Coil B Fwd)
				st_2: pulses_out = 4'b0010; // IN3=1 (Coil B Forward)
				st_3: pulses_out = 4'b0110; // IN2=1, IN3=1 (Coil A Reverse + Coil B Fwd)
				st_4: pulses_out = 4'b0100; // IN2=1 (Coil A Reverse)
				st_5: pulses_out = 4'b0101; // IN2=1, IN4=1 (Coil A Rev + Coil B Rev)
				st_6: pulses_out = 4'b0001; // IN4=1 (Coil B Reverse)
				st_7: pulses_out = 4'b1001; // IN1=1, IN4=1 (Coil A Fwd + Coil B Rev)
				default: pulses_out = 4'b0000;
			endcase
		end
		
endmodule
