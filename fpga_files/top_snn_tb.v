`timescale 1ns / 1ps

module top_snn_tb;

    reg clk, rst, sw_start, sw_0, sw_1, sw_2;
    wire ld_0, ld_1, ld_2;

    top_snn uut(
        .clk(clk), .rst(rst), .sw_start(sw_start),
        .sw_0(sw_0), .sw_1(sw_1), .sw_2(sw_2),
        .ld_0(ld_0), .ld_1(ld_1), .ld_2(ld_2)
    );

    always #5 clk = ~clk;

    // Test data storage: 20 test cases
    // Each test case has input_collect_0, input_collect_1, input_collect_2 (10-bit packed)
    // and expected class (0, 1, or 2)
    reg [9:0] test_ic0 [0:19];
    reg [9:0] test_ic1 [0:19];
    reg [9:0] test_ic2 [0:19];
    reg [1:0] test_expected [0:19];

    integer i;
    integer correct;
    integer predicted;

    initial begin
        // Test 0: expected class 1
        test_ic0[0]  = 10'b1001010010; test_ic1[0]  = 10'b1111110110; test_ic2[0]  = 10'b0101001010; test_expected[0]  = 2'd1;
        // Test 1: expected class 0
        test_ic0[1]  = 10'b1101111101; test_ic1[1]  = 10'b0001111010; test_ic2[1]  = 10'b1111100001; test_expected[1]  = 2'd0;
        // Test 2: expected class 2
        test_ic0[2]  = 10'b1101001101; test_ic1[2]  = 10'b0101111001; test_ic2[2]  = 10'b1111111000; test_expected[2]  = 2'd2;
        // Test 3: expected class 2
        test_ic0[3]  = 10'b0011001010; test_ic1[3]  = 10'b0111011000; test_ic2[3]  = 10'b1111111110; test_expected[3]  = 2'd2;
        // Test 4: expected class 1
        test_ic0[4]  = 10'b1010101010; test_ic1[4]  = 10'b1111100001; test_ic2[4]  = 10'b0010110101; test_expected[4]  = 2'd1;
        // Test 5: expected class 0
        test_ic0[5]  = 10'b0000001111; test_ic1[5]  = 10'b1110000000; test_ic2[5]  = 10'b0000010011; test_expected[5]  = 2'd0;
        // Test 6: expected class 0
        test_ic0[6]  = 10'b0011001100; test_ic1[6]  = 10'b1100010001; test_ic2[6]  = 10'b0100101001; test_expected[6]  = 2'd0;
        // Test 7: expected class 0
        test_ic0[7]  = 10'b0111101111; test_ic1[7]  = 10'b0110011100; test_ic2[7]  = 10'b1000001000; test_expected[7]  = 2'd0;
        // Test 8: expected class 0
        test_ic0[8]  = 10'b1010101101; test_ic1[8]  = 10'b0010110110; test_ic2[8]  = 10'b0110001011; test_expected[8]  = 2'd0;
        // Test 9: expected class 0
        test_ic0[9]  = 10'b0100111111; test_ic1[9]  = 10'b1100000001; test_ic2[9]  = 10'b0100101111; test_expected[9]  = 2'd0;
        // Test 10: expected class 2
        test_ic0[10] = 10'b1111010101; test_ic1[10] = 10'b1100011101; test_ic2[10] = 10'b0111111110; test_expected[10] = 2'd2;
        // Test 11: expected class 2
        test_ic0[11] = 10'b1001000110; test_ic1[11] = 10'b1100000110; test_ic2[11] = 10'b0111110101; test_expected[11] = 2'd2;
        // Test 12: expected class 2
        test_ic0[12] = 10'b0011100100; test_ic1[12] = 10'b0110100000; test_ic2[12] = 10'b1001100111; test_expected[12] = 2'd2;
        // Test 13: expected class 1
        test_ic0[13] = 10'b0001011010; test_ic1[13] = 10'b1101001011; test_ic2[13] = 10'b1110101010; test_expected[13] = 2'd1;
        // Test 14: expected class 1
        test_ic0[14] = 10'b0101110000; test_ic1[14] = 10'b1011010001; test_ic2[14] = 10'b0010001010; test_expected[14] = 2'd1;
        // Test 15: expected class 1
        test_ic0[15] = 10'b1010001100; test_ic1[15] = 10'b1110001111; test_ic2[15] = 10'b1011001110; test_expected[15] = 2'd1;
        // Test 16: expected class 0
        test_ic0[16] = 10'b1111000101; test_ic1[16] = 10'b0011011110; test_ic2[16] = 10'b0011101010; test_expected[16] = 2'd0;
        // Test 17: expected class 0
        test_ic0[17] = 10'b0101011011; test_ic1[17] = 10'b0000010000; test_ic2[17] = 10'b0111100001; test_expected[17] = 2'd0;
        // Test 18: expected class 0
        test_ic0[18] = 10'b1110111011; test_ic1[18] = 10'b0100000010; test_ic2[18] = 10'b0001100010; test_expected[18] = 2'd0;
        // Test 19: expected class 1
        test_ic0[19] = 10'b0100010100; test_ic1[19] = 10'b1111111101; test_ic2[19] = 10'b0000011101; test_expected[19] = 2'd1;
    end

    initial begin
        clk = 0;
        rst = 0;
        sw_start = 0;
        sw_0 = 0;
        sw_1 = 0;
        sw_2 = 0;
        correct = 0;

        $display("=== SNN FPGA Testbench: 20 Test Cases ===");
        $display("");

        for (i = 0; i < 20; i = i + 1) begin
            // Reset the entire design
            rst = 1;
            @(posedge clk); @(posedge clk);
            rst = 0;
            @(posedge clk);

            // Bypass the timer-based input collection by directly loading registers
            // and forcing the state machine to start forward propagation
            force uut.input_collect_0 = test_ic0[i];
            force uut.input_collect_1 = test_ic1[i];
            force uut.input_collect_2 = test_ic2[i];
            @(posedge clk);

            // Release so the state machine can operate normally
            release uut.input_collect_0;
            release uut.input_collect_1;
            release uut.input_collect_2;

            // Force state to begin forward propagation
            force uut.state = 6'd11; // FORWARD_PROP_1_1
            @(posedge clk);
            release uut.state;

            // Wait for the design to reach DECISION and return to IDLE
            // Forward prop takes 30 clock cycles (10 timesteps * 3 states) + 1 for DECISION
            repeat(40) @(posedge clk);

            // Check which LED is on
            if (ld_0 && !ld_1 && !ld_2)
                predicted = 0;
            else if (!ld_0 && ld_1 && !ld_2)
                predicted = 1;
            else if (!ld_0 && !ld_1 && ld_2)
                predicted = 2;
            else
                predicted = -1;

            if (predicted == test_expected[i]) begin
                $display("Test %0d: PASS (predicted=%0d, expected=%0d)", i, predicted, test_expected[i]);
                correct = correct + 1;
            end
            else begin
                $display("Test %0d: FAIL (predicted=%0d, expected=%0d)  pot_t: n2_1=%0d, n2_2=%0d, n2_3=%0d",
                         i, predicted, test_expected[i],
                         $signed(uut.potential_t_2_1),
                         $signed(uut.potential_t_2_2),
                         $signed(uut.potential_t_2_3));
            end
        end

        $display("");
        $display("=== Results: %0d / 20 correct (%0d%% accuracy) ===", correct, (correct * 100) / 20);
        $display("");

        if (correct >= 15)
            $display("FPGA inference is working well.");
        else if (correct >= 10)
            $display("FPGA inference partially working - check behavioral differences.");
        else
            $display("FPGA inference may have a bug - review neuron dynamics.");

        $finish;
    end

endmodule
