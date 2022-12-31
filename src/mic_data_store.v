module mic_data_store(input clk,
                      input rst_n,
                      input signed [17:0]mic_1,
                      input start,
                      input output_flag,
                      input finish_left_or_right,
                      input [9:0]adb_cnt,
                      output signed [17:0]out_data,
                      output output_start_flag);
    
    
    reg start_temp;
    reg signed [17:0] mic_1_temp;
    reg start_flag;
    reg start_flag_temp;
    
    
    // reg output_flag;
    
    reg [9:0]ada_cnt;
    // reg [9:0]adb_cnt;
    
    assign output_start_flag = start_flag;
    
    // ==  ==  = start_temp/mic_1_temp ==  ==  ==  ==  ==  = 
    always @(posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            start_temp      <= 0;
            mic_1_temp      <= 18'd0;
            start_flag_temp <= 0;
        end
        else
        begin
            start_temp      <= start;
            mic_1_temp      <= mic_1;
            start_flag_temp <= start_flag;
        end
    end
    
    
    // ==  ==  ==  == start_flag ==  ==  ==  == 
    always @(posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            start_flag <= 0;
        end
        else if (!start_temp&start)//检测start的上升沿
            start_flag <= 1'b1;
        else if (ada_cnt == 10'd1023)
            start_flag <= 1'b0;
            end
        
        // ==  ==  ==  ==  ==  = ada_cnt ==  ==  ==  ==  ==  ==  ==  = 
        always @(posedge clk or negedge rst_n)begin
            if (!rst_n)begin
                ada_cnt <= 10'd0;
            end
            else if (start_flag)
            begin
                if(finish_left_or_right)
                ada_cnt <= ada_cnt+10'd1;
                
            end
                
            else
                ada_cnt <= 10'd0;
        end
        
        
        Gowin_SDPB Gowin_SDPB_inst2(
        .dout(out_data), //output [17:0] dout
        .clka(clk), //input clka
        .cea(start_flag), //input cea
        .reseta(!rst_n), //input reseta
        .clkb(clk), //input clkb
        .ceb(output_flag), //input ceb
        .resetb(!rst_n), //input resetb
        .oce(), //input oce
        .ada(ada_cnt), //input [9:0] ada
        .din(mic_1), //input [17:0] din
        .adb(adb_cnt) //input [9:0] adb
        );
        
        
        
        endmodule
