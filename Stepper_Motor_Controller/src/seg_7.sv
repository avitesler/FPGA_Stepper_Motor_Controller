module seg_7 (
		input logic [3:0] current_digit,
		output logic [6:0] seg_out

);

// mapping out the numbers to the relevant pins on the DE10 
		always_comb begin
			case (current_digit)	
			4'b0: seg_out = ~(7'b0111111);
			4'b0001: seg_out = ~(7'b0000110);
			4'b0010: seg_out = ~(7'b1011011);
			4'b0011: seg_out = ~(7'b1001111);
			4'b0100: seg_out = ~(7'b1100110);
			4'b0101: seg_out = ~(7'b1101101);
			4'b0110: seg_out = ~(7'b1111101);
			4'b0111: seg_out = ~(7'b0000111);
			4'b1000: seg_out = ~(7'b1111111);
			4'b1001: seg_out = ~(7'b1101111);
			default: seg_out = ~(7'b0111111);
			endcase
		end

endmodule