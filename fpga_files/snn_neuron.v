`timescale 1ns / 1ps

module snn_neuron(
    clk, rst, enable, in_spike, w0, w1, w2, d_c, thresh, o_spike, potential_t_o
    );
    // weights for inputs, decay constant, threshold for spike
    // all inputs come from pre-trained software sim
    input clk, rst, enable;
    input[2:0] in_spike;
    input signed [15:0] w0, w1, w2, d_c, thresh;
    output wire o_spike;
    output wire signed [25:0] potential_t_o;
        
    // Increased potential width to prevent overflow during accumulation and multiplication
    reg signed [23:0] potential;
    reg spike;
    reg signed [25:0] potential_t;
    // Intermediate wire for signed fixed-point decay scaling product
    wire signed [37:0] decay_product;
    
    // Multiply potential by decay constant
    assign decay_product = potential * d_c;
    assign potential_t_o = potential_t;
    assign o_spike = spike;
    
    wire signed [23:0] new_potential;
    assign new_potential = potential +
                       ((in_spike[0] ? $signed(w0) : 16'sd0) +
                        (in_spike[1] ? $signed(w1) : 16'sd0) +
                        (in_spike[2] ? $signed(w2) : 16'sd0)) -
                       (decay_product >>> 12);
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            potential <= 24'sd0;
            spike <= 1'b0;
            potential_t <= 26'sd0;
        end
        else if(enable) begin
            if(new_potential >= thresh) begin
                spike <= 1'b1;
                potential <= 24'sd0;
            end
            else begin
                potential <= new_potential;
                spike <= 1'b0;
            end
            potential_t <= potential_t + new_potential;
        end
    end
endmodule
