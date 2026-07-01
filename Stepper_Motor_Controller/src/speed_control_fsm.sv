module speed_control_fsm (
    input logic clk,
    input logic resetb,
    input logic speed_sel,

    output logic [3:0] state,
    output logic [27:0] out
);

    // Edge Detector for active-low button
    logic prev_speed;
    logic speed_pulse;

    always_ff @(posedge clk or negedge resetb) begin
        if (!resetb) begin
            prev_speed <= 1'b0;
        end
        else begin
            prev_speed <= ~speed_sel;
        end
    end
	 
    assign speed_pulse = ~speed_sel & ~prev_speed; // Generates a '1' only on the exact clock cycle the button is pressed

    // FSM States
    typedef enum logic [3:0] {
        S1_UP   = 4'd1,
        S2_UP   = 4'd2,
        S3_UP   = 4'd3,
        S4_UP   = 4'd4,
        S5_UP   = 4'd5,
        S6_DOWN = 4'd6,
        S5_DOWN = 4'd7,
        S4_DOWN = 4'd8,
        S3_DOWN = 4'd9,
        S2_DOWN = 4'd10
    } sm_type;

    sm_type current_state, next_state;

    always_ff @(posedge clk or negedge resetb) begin
        if (!resetb)
            current_state <= S1_UP;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = current_state;

        if (speed_pulse) begin
            case (current_state)
                S1_UP:   next_state = S2_UP;
                S2_UP:   next_state = S3_UP;
                S3_UP:   next_state = S4_UP;
                S4_UP:   next_state = S5_UP;
                S5_UP:   next_state = S6_DOWN;

                S6_DOWN: next_state = S5_DOWN;
                S5_DOWN: next_state = S4_DOWN;
                S4_DOWN: next_state = S3_DOWN;
                S3_DOWN: next_state = S2_DOWN;
                S2_DOWN: next_state = S1_UP;

                default: next_state = S1_UP;
            endcase
        end
    end

    // Output speed state number: 1 to 6
    always_comb begin
        case (current_state)
            S1_UP:   state = 4'd1;
            S2_UP:   state = 4'd2;
            S3_UP:   state = 4'd3;
            S4_UP:   state = 4'd4;
            S5_UP:   state = 4'd5;

            S6_DOWN: state = 4'd6;
            S5_DOWN: state = 4'd5;
            S4_DOWN: state = 4'd4;
            S3_DOWN: state = 4'd3;
            S2_DOWN: state = 4'd2;

            default: state = 4'd1;
        endcase
    end

    // Output logic
    always_comb begin
        case (state)
            4'd1: out = 28'd749999; // 10 RPM
            4'd2: out = 28'd374999; // 20 RPM
            4'd3: out = 28'd249999; // 30 RPM
            4'd4: out = 28'd187499; // 40 RPM
            4'd5: out = 28'd149999; // 50 RPM
            4'd6: out = 28'd124999; // 60 RPM
            default: out = 28'd749999;
        endcase
    end

	 
	 // For simulation only
//    always_comb begin
//       case (state)
//          4'd1: out = 28'd60; // S1: Slowest (counts to 600 before pulse)
//          4'd2: out = 28'd50;
//          4'd3: out = 28'd40;
//          4'd4: out = 28'd30;
//          4'd5: out = 28'd20;
//          4'd6: out = 28'd10; // S6: Fastest (counts to 100 before pulse)
//          default: out = 28'd60;
//       endcase
//    end
endmodule