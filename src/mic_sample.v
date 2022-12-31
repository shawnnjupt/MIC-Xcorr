module mic_sample (input clk,                       // Clock
                   input rst_n,
                   output mic_clk,
                   output mic_ws,
                   input mic_so,
                   output reg signed [23:0]mic_data_left,
                   output reg signed [23:0]mic_data_right,
                   output reg finished_left,
                   output reg finished_right);
    
    
    
    
    
    reg mic_ws_d0;
    
    //设置采样时钟
    reg [15:0] clk_cnt;
    //更新左右声道
    
    
    reg signed [23:0] data_r_r;
    reg signed [23:0] data_l_r;
    
    
    
    assign mic_clk = clk_cnt[1];
    assign mic_ws  = clk_cnt[7];
    
    
    
    
    always@(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            clk_cnt <= 16'd0;
        else
            clk_cnt <= clk_cnt + 16'd1;
    end
    
    
    
    always@(posedge mic_clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            data_r_r <= 24'd0;
            data_l_r <= 24'd0;
        end
        else if (clk_cnt[6:2] > 0 && clk_cnt[6:2] < 25)
        begin
            data_r_r <= mic_ws? {data_r_r[22:0],mic_so} : data_r_r;
            data_l_r <= !mic_ws? {data_l_r[22:0],mic_so} : data_l_r;
        end
            end
            
            
            
            
            
            always @(posedge clk or negedge rst_n)
            begin
                if (!rst_n)
                    mic_ws_d0 <= 1'd0;
                else
                    mic_ws_d0 <= mic_ws;
            end
            
            
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n)
                begin
                    finished_right <= 0;
                    finished_left  <= 0;
                end
                else if (!mic_ws_d0 & mic_ws)
                begin
                    finished_right <= 1;
                    mic_data_right <= data_l_r;
                    
                end
                    else if (mic_ws_d0 &!mic_ws)
                    begin
                    mic_data_left <= data_r_r;
                    finished_left <= 1;
                    end
                else
                begin
                    finished_left  <= 0;
                    finished_right <= 0;
                end
            end
            
            
            
            
            
            endmodule
