module max_sample(input clk,
                  input rst_n,
                  input finish_left_or_right,
                  input [24-1:0]mic_data,
                  output reg [9-1:0] sound_band,
                  output reg max_finish
                  );
    
    
    wire [22:0]mic_data_am;
    assign mic_data_am = mic_data[23]?23'd0:mic_data[22:0];
    // assign sound_band = mic_max[]
    
    reg [22:0]mic_max;
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            
            mic_max       = 0;
            // sound_band = 12;
             max_finish = 1;
        end
        else
        begin
            
            if (mic_data_am>= mic_max)
            begin
                mic_max = mic_data_am;
                 if (mic_max[22:14]>300)
                 sound_band = 300;
                 else
                sound_band = mic_max[22:14];
                
            end
             max_finish = 0;
        end
        
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
endmodule
