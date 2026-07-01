module counter #(
		parameter int WIDTH = 28
) 		(input logic clk,
		input logic resetb,
		input logic count_enb,
		input logic [WIDTH-1:0] count_goal,
		output logic carry_out,
		output logic [WIDTH-1:0] count

);

// Every Positive edge the counter add 1 until count_goal and then it adds 1 to carry out and resets the
// count to 0.		

		
		assign carry_out = (count >= count_goal) && count_enb;
		
		always_ff @(posedge clk or negedge resetb) begin
			if (~resetb) begin
				count <= '0;
			end
			else begin
				if (count_enb) begin
					if (count >= count_goal) begin
						count <= '0;
					end
					else begin
						count <= count + 1;
					end
				end
			end
		end

endmodule
