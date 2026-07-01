`timescale 1ns/1ps

module counter_tb ();
		parameter int WIDTH = 4;
 		logic clk;
		logic resetb;
		logic count_enb;
		logic [WIDTH-1:0] count_goal;
		logic carry_out;
		logic [WIDTH-1:0] count;

		counter #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .resetb(resetb),
        .count_enb(count_enb),
        .count_goal(count_goal),
        .carry_out(carry_out),
        .count(count)
		);

		always begin
			#10 clk = ~clk;
		end

		initial begin
			clk = 1'b0;
			resetb = 1'b0;
			count_enb = 1'b0;
			count_goal = 4'd9;
			
			@ (posedge clk);
			#3 resetb = 1'b1;
			count_enb = 1'b1;
			
			//Wait 12 cycles to verify reaching the goal (9) and carry_out generation
			repeat(12) begin
				@(posedge clk);
			end
			
			//Test reset functionality mid-count
			#50 resetb = 1'b0;
			
			// Release reset to resume normal operation
			#60 resetb = 1'b1;
			
			//Wait enough cycles to verify rollover and carry_out generation
			repeat(13) begin
				@(posedge clk);
			end
			
			$stop;
		end	
endmodule