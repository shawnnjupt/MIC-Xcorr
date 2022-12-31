//////////////////////////////////////////////////////////////////////////////////
// Engineer: shawn
// Create Date:2022.9.2
// Module Name:Btn_Sample_Clk

/** @brief 按键消抖模块
 @param input clk 对应输入信号clk
 @param input [BTN_WIDTH-1:0] btn_in 对应输入按键 一次一个
 @param output reg [BTN_WIDTH-1:0] btn_out  对应输出消抖之后的按键值
 */
//////////////////////////////////////////////////////////////////////////////////


module Btn_Sample_Clk #(parameter BTN_WIDTH = 4'd1)
                       (input clk,
                        input rst_n,
                        input [BTN_WIDTH-1:0] Btn_In,
                        output reg [BTN_WIDTH-1:0] Btn_Out);
    
    reg [19:0]clk_cnt = 20'd0;//默认频率为50M，因为按键检测大致为20ms 所以50M/50 = 1,000,000 所以采用20位计数器 1,000,000 hex = F4240
    
    // ==  ==  ==  ==  ==  ==  = clk_cnt ==  ==  ==  ==  ==  ==  ==  == //
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            clk_cnt <= 20'd0;
        else
            clk_cnt <= clk_cnt+20'd1;
        
    end
    
    // ==  ==  ==  ==  ==  == btn_out ==  ==  ==  ==  ==  == //
    always @(posedge clk) begin
        
        if (clk_cnt == 20'd0)
            Btn_Out <= Btn_In;
            end
        
        
        
        endmodule
 