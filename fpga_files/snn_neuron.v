`timescale 1ns / 1ps

module snn_neuron(
    clk, rst, in_spike, w0, w1, w2, d_c, thresh, spike
    );
    // weights for inputs, decay constant, threshold for spike
    // all inputs come from pre-trained software sim
    input clk, rst;
    input[2:0] in_spike;
    input [13:0] w0, w1, w2, d_c, thresh;
    output reg spike;
    
    reg [14:0] potential;
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            potential <= 14'b0;
            spike <= 1'b0;
        end
        else begin
            if(potential >= thresh) begin
                spike <= 1'b1;
                potential <= 14'b0;
            end
            else begin
                potential <= potential + (in_spike[0] * w0 + in_spike[1] * w1 + in_spike[2] * w2) - potential*d_c;
                spike <= 1'b0;
            end
        end
    end
endmodule
