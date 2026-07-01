`timescale 1ns/1ps

module speed_control_fsm_tb ();

    logic clk;
    logic resetb;
    logic speed_sel;

    logic [3:0]  state;
    logic [27:0] out;

    speed_control_fsm dut (
        .clk       (clk),
        .resetb    (resetb),
        .speed_sel (speed_sel),
        .state     (state),
        .out       (out)
    );

    always #5 clk = ~clk;

    task press_speed_button;
        begin
            @(negedge clk);
            speed_sel = 1'b0;

            @(negedge clk);
            speed_sel = 1'b1;

            @(posedge clk);
        end
    endtask

    task check_state;
        input logic [3:0] expected_state;
        input logic [27:0] expected_out;
        begin
            // Test 2.4 is implicitly checked here for every state transition
            if (state !== expected_state || out !== expected_out) begin
                $display("ERROR Time=%0t | state=%0d | out=%0d | expected_state=%0d | expected_out=%0d",
                         $time, state, out, expected_state, expected_out);
            end
            else begin
                $display("PASS  Time=%0t | state=%0d | out=%0d",
                         $time, state, out);
            end
        end
    endtask

    initial begin
        $monitor(
            "Time=%0t | resetb=%b | speed_sel=%b | state=%0d | out=%0d",
            $time,
            resetb,
            speed_sel,
            state,
            out
        );
    end

    initial begin
        $display("--- Starting Speed Control FSM Simulation ---");

        // Initialization 
        clk       = 1'b0;
        resetb    = 1'b0;
        speed_sel = 1'b1;

        repeat (2) @(posedge clk);
        resetb = 1'b1;

        repeat (2) @(posedge clk);
        check_state(4'd1, 28'd749999);

        // Test 2.1: Sequential progression from S1 to maximum speed S6 ---
        press_speed_button();
        check_state(4'd2, 28'd374999);

        press_speed_button();
        check_state(4'd3, 28'd249999);

        press_speed_button();
        check_state(4'd4, 28'd187499);

        press_speed_button();
        check_state(4'd5, 28'd149999);

        press_speed_button();
        check_state(4'd6, 28'd124999);

        // Test 2.2: Ping-pong logic at maximum boundary (S6 down to S5) ---
        press_speed_button();
        check_state(4'd5, 28'd149999);

        // Continuing sequential progression down
        press_speed_button();
        check_state(4'd4, 28'd187499);

        press_speed_button();
        check_state(4'd3, 28'd249999);

        press_speed_button();
        check_state(4'd2, 28'd374999);

        // --- Test 2.2: Ping-pong logic at minimum boundary (down to S1) ---
        press_speed_button();
        check_state(4'd1, 28'd749999);

        // Test 2.3: Edge detector / Long press collision ---
        @(negedge clk);
        speed_sel = 1'b0; // Holding the button down

        repeat (4) @(posedge clk);
        // Verify state changed ONLY ONCE (S1 -> S2) despite holding the button
        check_state(4'd2, 28'd374999);

        @(negedge clk);
        speed_sel = 1'b1; // Releasing the button

        @(posedge clk);
        check_state(4'd2, 28'd374999); // State remains the same after release

        // Move to S3 to prepare for the reset test
        press_speed_button();
        check_state(4'd3, 28'd249999);

        // Test 2.5: Asynchronous reset mid-operation ---
        #2;
        resetb = 1'b0; // Assert reset asynchronously

        #3;
        // Verify immediate return to initial state S1
        check_state(4'd1, 28'd749999);

        resetb = 1'b1;

        repeat (3) @(posedge clk);
        check_state(4'd1, 28'd749999);

        $display("--- Simulation Finished ---");
        $stop;
    end

endmodule