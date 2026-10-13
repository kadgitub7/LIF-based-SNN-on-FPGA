/* 
What I intend to do is have a two stage system
1) there is in input collection system -> this is a 20 second window where every 2 seconds the inputs on 3 LEDs ddetermine the input signal
2) these 10 timestep lsits of 3 inputs is fed into the processor with the parameters extracted by the .mem file


For this to occur we need a master FSM for input collection which has 10 cycles which accumulated the input signal as a binary value of 1 and 0 for each bit. It will be 10 bits long
Then the second stage of the FSM performs inference(forward propogation of the snn network)
*/