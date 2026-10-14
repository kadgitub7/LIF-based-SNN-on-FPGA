`timescale 1ns / 1ps

module top_snn(
    clk_100, rst, sw_start, sw_0, sw_1, sw_2, ld_0, ld_1, ld_2
    );
    
    input clk_100, rst, sw_start, sw_0, sw_1, sw_2;
    output reg ld_0, ld_1, ld_2;
    
    wire clk;
    wire locked;
    
    wire internal_rst;
    assign internal_rst = rst | ~locked;

    // Instantiate the generated Clocking Wizard IP
    clk_wiz_0 clk_wizard_inst (
        // Clock out ports
        .clk_out1(clk),     // This output is now 50 MHz
        // Status and Control signals
        .reset(rst),        // Active high reset input
        .locked(locked),          // Goes high when output clock stabilizes
        // Clock in ports
        .clk_in1(clk_100)   // 100 MHz board clock input
    );
    
    localparam [5:0] IDLE = 6'd0,
                     LOAD_INPUT_1 = 6'd1,
                     LOAD_INPUT_2 = 6'd2,
                     LOAD_INPUT_3 = 6'd3,
                     LOAD_INPUT_4 = 6'd4,
                     LOAD_INPUT_5 = 6'd5,
                     LOAD_INPUT_6 = 6'd6,
                     LOAD_INPUT_7 = 6'd7,
                     LOAD_INPUT_8 = 6'd8,
                     LOAD_INPUT_9 = 6'd9,
                     LOAD_INPUT_10 = 6'd10,
                     FORWARD_PROP_1_1 = 6'd11,
                     FORWARD_PROP_1_2 = 6'd12,
                     FORWARD_PROP_1_3 = 6'd13,
                     FORWARD_PROP_2_1 = 6'd14,
                     FORWARD_PROP_2_2 = 6'd15,
                     FORWARD_PROP_2_3 = 6'd16,
                     FORWARD_PROP_3_1 = 6'd17,
                     FORWARD_PROP_3_2 = 6'd18,
                     FORWARD_PROP_3_3 = 6'd19,
                     FORWARD_PROP_4_1 = 6'd20,
                     FORWARD_PROP_4_2 = 6'd21,
                     FORWARD_PROP_4_3 = 6'd22,
                     FORWARD_PROP_5_1 = 6'd23,
                     FORWARD_PROP_5_2 = 6'd24,
                     FORWARD_PROP_5_3 = 6'd25,
                     FORWARD_PROP_6_1 = 6'd26,
                     FORWARD_PROP_6_2 = 6'd27,
                     FORWARD_PROP_6_3 = 6'd28,
                     FORWARD_PROP_7_1 = 6'd29,
                     FORWARD_PROP_7_2 = 6'd30,
                     FORWARD_PROP_7_3 = 6'd31,
                     FORWARD_PROP_8_1 = 6'd32,
                     FORWARD_PROP_8_2 = 6'd33,
                     FORWARD_PROP_8_3 = 6'd34,
                     FORWARD_PROP_9_1 = 6'd35,
                     FORWARD_PROP_9_2 = 6'd36,
                     FORWARD_PROP_9_3 = 6'd37,
                     FORWARD_PROP_10_1 = 6'd38,
                     FORWARD_PROP_10_2 = 6'd39,
                     FORWARD_PROP_10_3 = 6'd40,
                     DECISION = 6'd41;
    reg[5:0] state = 6'b0;
    
    // input collecters, stores the input from user
    reg[9:0] input_collect_0 = 10'b0;
    reg[9:0] input_collect_1 = 10'b0;
    reg[9:0] input_collect_2 = 10'b0;
    
    reg[27:0] timer; // assuming 100 MHz clock frequency
    
    // reading value from mem file
    
    reg[15:0] w0_1_1, w1_1_1, w2_1_1, d_c_1_1, thresh_1_1,
              w0_1_2, w1_1_2, w2_1_2, d_c_1_2, thresh_1_2,
              w0_1_3, w1_1_3, w2_1_3, d_c_1_3, thresh_1_3,
              
              w0_2_1, w1_2_1, w2_2_1, d_c_2_1, thresh_2_1,
              w0_2_2, w1_2_2, w2_2_2, d_c_2_2, thresh_2_2,
              w0_2_3, w1_2_3, w2_2_3, d_c_2_3, thresh_2_3;
    
    reg[15:0] neuron_params[29:0];
    
    initial begin
        $readmemh("neuron_parameters.mem", neuron_params);
        w0_1_1 = neuron_params[0]; w1_1_1 = neuron_params[1]; w2_1_1 = neuron_params[2]; d_c_1_1 = neuron_params[3]; thresh_1_1 = neuron_params[4];
        w0_1_2 = neuron_params[5]; w1_1_2 = neuron_params[6]; w2_1_2 = neuron_params[7]; d_c_1_2 = neuron_params[8]; thresh_1_2 = neuron_params[9];
        w0_1_3 = neuron_params[10]; w1_1_3 = neuron_params[11]; w2_1_3 = neuron_params[12]; d_c_1_3 = neuron_params[13]; thresh_1_3 = neuron_params[14];
        
        w0_2_1 = neuron_params[15]; w1_2_1 = neuron_params[16]; w2_2_1 = neuron_params[17]; d_c_2_1 = neuron_params[18]; thresh_2_1 = neuron_params[19];
        w0_2_2 = neuron_params[20]; w1_2_2 = neuron_params[21]; w2_2_2 = neuron_params[22]; d_c_2_2 = neuron_params[23]; thresh_2_2 = neuron_params[24];
        w0_2_3 = neuron_params[25]; w1_2_3 = neuron_params[26]; w2_2_3 = neuron_params[27]; d_c_2_3 = neuron_params[28]; thresh_2_3 = neuron_params[29];
    end
    
    // inputs and output registers for the network neurons, rest come from memory file
    reg[2:0] n1_1_input, n1_2_input, n1_3_input;
    
    wire n1_1_output, n1_2_output, n1_3_output,
        n2_1_output, n2_2_output, n2_3_output;
    
    wire signed [25:0] potential_t_1_1, potential_t_1_2, potential_t_1_3, 
                       potential_t_2_1, potential_t_2_2, potential_t_2_3; 
    
    reg en1_1, en1_2, en1_3, en2_1, en2_2, en2_3;
    
    // instantiating and connecting neurons for forward prop
    snn_neuron n1_1(clk, internal_rst, en1_1, n1_1_input, w0_1_1, w1_1_1, w2_1_1, d_c_1_1, thresh_1_1, n1_1_output, potential_t_1_1);
    snn_neuron n1_2(clk, internal_rst, en1_2, n1_2_input, w0_1_2, w1_1_2, w2_1_2, d_c_1_2, thresh_1_2, n1_2_output, potential_t_1_2);
    snn_neuron n1_3(clk, internal_rst, en1_3, n1_3_input, w0_1_3, w1_1_3, w2_1_3, d_c_1_3, thresh_1_3, n1_3_output, potential_t_1_3);
    
    snn_neuron n2_1(clk, internal_rst, en2_1, {n1_3_output, n1_2_output, n1_1_output}, w0_2_1, w1_2_1, w2_2_1, d_c_2_1, thresh_2_1, n2_1_output, potential_t_2_1);
    snn_neuron n2_2(clk, internal_rst, en2_2, {n1_3_output, n1_2_output, n1_1_output}, w0_2_2, w1_2_2, w2_2_2, d_c_2_2, thresh_2_2, n2_2_output, potential_t_2_2);
    snn_neuron n2_3(clk, internal_rst, en2_3, {n1_3_output, n1_2_output, n1_1_output}, w0_2_3, w1_2_3, w2_2_3, d_c_2_3, thresh_2_3, n2_3_output, potential_t_2_3);
    
    always@(posedge clk or posedge internal_rst) begin
        if(internal_rst) begin
            state <= IDLE;
            ld_0 <= 0;
            ld_1 <= 0;
            ld_2 <= 0;
            en1_1 <=0; en1_2 <=0; en1_3<=0; en2_1<=0; en2_2<=0; en2_3 <= 0;
            input_collect_0 <= 10'b0;
            input_collect_1 <= 10'b0;
            input_collect_2 <= 10'b0;
        end
        else begin
            case(state)
                
                IDLE: begin
                    timer <= 28'b0;
                    if(sw_start == 1)begin
                        ld_0 <= 0;
                        ld_1 <= 0;
                        ld_2 <= 0;
                        en1_1 <=0; en1_2 <=0; en1_3<=0; en2_1<=0; en2_2<=0; en2_3 <= 0;
                        state <= LOAD_INPUT_1;
                    end
                end
                
                LOAD_INPUT_1: begin
                    if(timer[27] == 1)begin
                        state <= LOAD_INPUT_2;
                        timer <= 28'b0;
                    end
                    else begin
                        timer <= timer + 1'b1;
                        if(sw_0 == 1) begin
                            input_collect_0[0] <= 1'b1;
                        end 
                        if(sw_1 == 1) begin
                            input_collect_1[0] <= 1'b1;
                        end 
                        if(sw_2 == 1) begin
                            input_collect_2[0] <= 1'b1;
                        end
                    end
                end
                
                LOAD_INPUT_2: begin
                    if(timer[27] == 1)begin
                        state <= LOAD_INPUT_3;
                        timer <= 28'b0;
                    end
                    else begin
                        timer <= timer + 1'b1;
                        if(sw_0 == 1) begin
                            input_collect_0[1] <= 1'b1;
                        end
                        if(sw_1 == 1) begin
                            input_collect_1[1] <= 1'b1;
                        end 
                        if(sw_2 == 1) begin
                            input_collect_2[1] <= 1'b1;
                        end
                    end
                end
                
                LOAD_INPUT_3: begin
                    if(timer[27] == 1)begin
                        state <= LOAD_INPUT_4;
                        timer <= 28'b0;
                    end
                    else begin
                        timer <= timer + 1'b1;
                        if(sw_0 == 1) begin
                            input_collect_0[2] <= 1'b1;
                        end 
                        if(sw_1 == 1) begin
                            input_collect_1[2] <= 1'b1;
                        end 
                        if(sw_2 == 1) begin
                            input_collect_2[2] <= 1'b1;
                        end
                    end
                end
                
                LOAD_INPUT_4: begin
                    if(timer[27] == 1)begin
                        state <= LOAD_INPUT_5;
                        timer <= 28'b0;
                    end
                    else begin
                        timer <= timer + 1'b1;
                        if(sw_0 == 1) begin
                            input_collect_0[3] <= 1'b1;
                        end 
                        if(sw_1 == 1) begin
                            input_collect_1[3] <= 1'b1;
                        end
                        if(sw_2 == 1) begin
                            input_collect_2[3] <= 1'b1;
                        end
                    end
                end
                
                LOAD_INPUT_5: begin
                    if(timer[27] == 1)begin
                        state <= LOAD_INPUT_6;
                        timer <= 28'b0;
                    end
                    else begin
                        timer <= timer + 1'b1;
                        if(sw_0 == 1) begin
                            input_collect_0[4] <= 1'b1;
                        end 
                        if(sw_1 == 1) begin
                            input_collect_1[4] <= 1'b1;
                        end 
                        if(sw_2 == 1) begin
                            input_collect_2[4] <= 1'b1;
                        end
                    end
                end
                
                LOAD_INPUT_6: begin
                    if(timer[27] == 1)begin
                        state <= LOAD_INPUT_7;
                        timer <= 28'b0;
                    end
                    else begin
                        timer <= timer + 1'b1;
                        if(sw_0 == 1) begin
                            input_collect_0[5] <= 1'b1;
                        end 
                        if(sw_1 == 1) begin
                            input_collect_1[5] <= 1'b1;
                        end 
                        if(sw_2 == 1) begin
                            input_collect_2[5] <= 1'b1;
                        end
                    end
                end
                
                LOAD_INPUT_7: begin
                    if(timer[27] == 1)begin
                        state <= LOAD_INPUT_8;
                        timer <= 28'b0;
                    end
                    else begin
                        timer <= timer + 1'b1;
                        if(sw_0 == 1) begin
                            input_collect_0[6] <= 1'b1;
                        end 
                        if(sw_1 == 1) begin
                            input_collect_1[6] <= 1'b1;
                        end 
                        if(sw_2 == 1) begin
                            input_collect_2[6] <= 1'b1;
                        end
                    end
                end
                
                LOAD_INPUT_8: begin
                    if(timer[27] == 1)begin
                        state <= LOAD_INPUT_9;
                        timer <= 28'b0;
                    end
                    else begin
                        timer <= timer + 1'b1;
                        if(sw_0 == 1) begin
                            input_collect_0[7] <= 1'b1;
                        end 
                        if(sw_1 == 1) begin
                            input_collect_1[7] <= 1'b1;
                        end 
                        if(sw_2 == 1) begin
                            input_collect_2[7] <= 1'b1;
                        end
                    end
                end
                
                LOAD_INPUT_9: begin
                    if(timer[27] == 1)begin
                        state <= LOAD_INPUT_10;
                        timer <= 28'b0;
                    end
                    else begin
                        timer <= timer + 1'b1;
                        if(sw_0 == 1) begin
                            input_collect_0[8] <= 1'b1;
                        end 
                        if(sw_1 == 1) begin
                            input_collect_1[8] <= 1'b1;
                        end 
                        if(sw_2 == 1) begin
                            input_collect_2[8] <= 1'b1;
                        end
                    end
                end
                
                LOAD_INPUT_10: begin
                    if(timer[27] == 1)begin
                        state <= FORWARD_PROP_1_1;
                        timer <= 28'b0;
                    end
                    else begin
                        timer <= timer + 1'b1;
                        if(sw_0 == 1) begin
                            input_collect_0[9] <= 1'b1;
                        end 
                        if(sw_1 == 1) begin
                            input_collect_1[9] <= 1'b1;
                        end 
                        if(sw_2 == 1) begin
                            input_collect_2[9] <= 1'b1;
                        end
                    end
                end
                
                FORWARD_PROP_1_1: begin
                    n1_1_input <= {input_collect_2[0], input_collect_1[0], input_collect_0[0]};
                    n1_2_input <= {input_collect_2[0], input_collect_1[0], input_collect_0[0]};
                    n1_3_input <= {input_collect_2[0], input_collect_1[0], input_collect_0[0]};
                    state <= FORWARD_PROP_1_2;
                    en1_1 <=1; en1_2<=1; en1_3 <=1;
                end
                
                FORWARD_PROP_1_2: begin
                    state <= FORWARD_PROP_1_3;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=1; en2_2<=1; en2_3 <=1;
                end
                
                FORWARD_PROP_1_3: begin
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=0; en2_2<=0; en2_3 <=0;
                    state <= FORWARD_PROP_2_1;
                end
                
                FORWARD_PROP_2_1: begin
                    n1_1_input <= {input_collect_2[1], input_collect_1[1], input_collect_0[1]};
                    n1_2_input <= {input_collect_2[1], input_collect_1[1], input_collect_0[1]};
                    n1_3_input <= {input_collect_2[1], input_collect_1[1], input_collect_0[1]};
                    state <= FORWARD_PROP_2_2;
                    en1_1 <=1; en1_2<=1; en1_3 <=1;
                end
                
                FORWARD_PROP_2_2: begin
                    state <= FORWARD_PROP_2_3;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=1; en2_2<=1; en2_3 <=1;
                end
                
                FORWARD_PROP_2_3: begin
                    state <= FORWARD_PROP_3_1;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=0; en2_2<=0; en2_3 <=0;
                end
                
                FORWARD_PROP_3_1: begin
                    n1_1_input <= {input_collect_2[2], input_collect_1[2], input_collect_0[2]};
                    n1_2_input <= {input_collect_2[2], input_collect_1[2], input_collect_0[2]};
                    n1_3_input <= {input_collect_2[2], input_collect_1[2], input_collect_0[2]};
                    state <= FORWARD_PROP_3_2;
                    en1_1 <=1; en1_2<=1; en1_3 <=1;
                end
                
                FORWARD_PROP_3_2: begin
                    state <= FORWARD_PROP_3_3;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=1; en2_2<=1; en2_3 <=1;
                end
                
                FORWARD_PROP_3_3: begin
                    state <= FORWARD_PROP_4_1;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=0; en2_2<=0; en2_3 <=0;
                end
                
                FORWARD_PROP_4_1: begin
                    n1_1_input <= {input_collect_2[3], input_collect_1[3], input_collect_0[3]};
                    n1_2_input <= {input_collect_2[3], input_collect_1[3], input_collect_0[3]};
                    n1_3_input <= {input_collect_2[3], input_collect_1[3], input_collect_0[3]};
                    state <= FORWARD_PROP_4_2;
                    en1_1 <=1; en1_2<=1; en1_3 <=1;
                end
                
                FORWARD_PROP_4_2: begin
                    state <= FORWARD_PROP_4_3;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=1; en2_2<=1; en2_3 <=1;
                end
                
                FORWARD_PROP_4_3: begin
                    state <= FORWARD_PROP_5_1;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=0; en2_2<=0; en2_3 <=0;
                end
                
                FORWARD_PROP_5_1: begin
                    n1_1_input <= {input_collect_2[4], input_collect_1[4], input_collect_0[4]};
                    n1_2_input <= {input_collect_2[4], input_collect_1[4], input_collect_0[4]};
                    n1_3_input <= {input_collect_2[4], input_collect_1[4], input_collect_0[4]};
                    state <= FORWARD_PROP_5_2;
                    en1_1 <=1; en1_2<=1; en1_3 <=1;
                end
                
                FORWARD_PROP_5_2: begin
                    state <= FORWARD_PROP_5_3;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=1; en2_2<=1; en2_3 <=1;
                end
                
                FORWARD_PROP_5_3: begin
                    state <= FORWARD_PROP_6_1;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=0; en2_2<=0; en2_3 <=0;
                end
                
                FORWARD_PROP_6_1: begin
                    n1_1_input <= {input_collect_2[5], input_collect_1[5], input_collect_0[5]};
                    n1_2_input <= {input_collect_2[5], input_collect_1[5], input_collect_0[5]};
                    n1_3_input <= {input_collect_2[5], input_collect_1[5], input_collect_0[5]};
                    state <= FORWARD_PROP_6_2;
                    en1_1 <=1; en1_2<=1; en1_3 <=1;
                end
                
                FORWARD_PROP_6_2: begin
                    state <= FORWARD_PROP_6_3;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=1; en2_2<=1; en2_3 <=1;
                end
                
                FORWARD_PROP_6_3: begin
                    state <= FORWARD_PROP_7_1;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=0; en2_2<=0; en2_3 <=0;
                end
                
                FORWARD_PROP_7_1: begin
                    n1_1_input <= {input_collect_2[6], input_collect_1[6], input_collect_0[6]};
                    n1_2_input <= {input_collect_2[6], input_collect_1[6], input_collect_0[6]};
                    n1_3_input <= {input_collect_2[6], input_collect_1[6], input_collect_0[6]};
                    state <= FORWARD_PROP_7_2;
                    en1_1 <=1; en1_2<=1; en1_3 <=1;
                end
                
                FORWARD_PROP_7_2: begin
                    state <= FORWARD_PROP_7_3;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=1; en2_2<=1; en2_3 <=1;
                end
                
                FORWARD_PROP_7_3: begin
                    state <= FORWARD_PROP_8_1;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=0; en2_2<=0; en2_3 <=0;
                end
                
                FORWARD_PROP_8_1: begin
                    n1_1_input <= {input_collect_2[7], input_collect_1[7], input_collect_0[7]};
                    n1_2_input <= {input_collect_2[7], input_collect_1[7], input_collect_0[7]};
                    n1_3_input <= {input_collect_2[7], input_collect_1[7], input_collect_0[7]};
                    state <= FORWARD_PROP_8_2;
                    en1_1 <=1; en1_2<=1; en1_3 <=1;
                end
                
                FORWARD_PROP_8_2: begin
                    state <= FORWARD_PROP_8_3;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=1; en2_2<=1; en2_3 <=1;
                end
                
                FORWARD_PROP_8_3: begin
                    state <= FORWARD_PROP_9_1;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=0; en2_2<=0; en2_3 <=0;
                end
                
                FORWARD_PROP_9_1: begin
                    n1_1_input <= {input_collect_2[8], input_collect_1[8], input_collect_0[8]};
                    n1_2_input <= {input_collect_2[8], input_collect_1[8], input_collect_0[8]};
                    n1_3_input <= {input_collect_2[8], input_collect_1[8], input_collect_0[8]};
                    state <= FORWARD_PROP_9_2;
                    en1_1 <=1; en1_2<=1; en1_3 <=1;
                end
                
                FORWARD_PROP_9_2: begin
                    state <= FORWARD_PROP_9_3;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=1; en2_2<=1; en2_3 <=1;
                end
                
                FORWARD_PROP_9_3: begin
                    state <= FORWARD_PROP_10_1;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=0; en2_2<=0; en2_3 <=0;
                end
                
                FORWARD_PROP_10_1: begin
                    n1_1_input <= {input_collect_2[9], input_collect_1[9], input_collect_0[9]};
                    n1_2_input <= {input_collect_2[9], input_collect_1[9], input_collect_0[9]};
                    n1_3_input <= {input_collect_2[9], input_collect_1[9], input_collect_0[9]};
                    state <= FORWARD_PROP_10_2;
                    en1_1 <=1; en1_2<=1; en1_3 <=1;
                end
                
                FORWARD_PROP_10_2: begin
                    state <= FORWARD_PROP_10_3;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=1; en2_2<=1; en2_3 <=1;
                end
                
                FORWARD_PROP_10_3: begin
                    state <= DECISION;
                    en1_1 <=0; en1_2<=0; en1_3 <=0;
                    en2_1 <=0; en2_2<=0; en2_3 <=0;
                end
                
                DECISION: begin
                    if(potential_t_2_1 > potential_t_2_2 && potential_t_2_1 > potential_t_2_3) begin
                        ld_0 <= 1;
                    end else if(potential_t_2_2 > potential_t_2_1 && potential_t_2_2 > potential_t_2_3) begin
                        ld_1 <= 1;
                    end else begin
                        ld_2 <= 1;
                    end
                    state <= IDLE;
                end
            endcase
        end
    end
    
endmodule
