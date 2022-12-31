//////////////////////////////////////////////////////////////////////////////////
// Engineer: shawn
// Create Date:2022.9.2
// Module Name:Btn_Control

/** @brief 按键检测模块
 @param input clk 对应输入信号clk
 @param input Btn 对应输入按键 一次一个
 @param output reg  [1:0] Push_Cnt  对应输出按下的计数值，最大为4
 */
//////////////////////////////////////////////////////////////////////////////////


module Btn_Control (input clk_50M,
                    input Btn,
                    input rst_n,
                    output reg btton_flag,
                    output reg [1:0] Push_Cnt,
                    output reg led);
    
    wire btn_out;
    reg btn_out_last_value;
    //    wire clk_50M;
    
    //例化btn_sample_clk模块
    Btn_Sample_Clk#(
    .BTN_WIDTH (4'd1)
    )Btn_Sample_Clk_inst
    (
    .clk (clk_50M),
    .rst_n(rst_n),
    .Btn_In (Btn),
    .Btn_Out (btn_out)
    );
    
    
    // ==  ==  ==  ==  ==  == btn_out_last_value ==  ==  ==  ==  ==  = //
    always @(posedge clk_50M)begin
        btn_out_last_value <= btn_out;
    end
    
    // ==  ==  ==  ==  ==  ==  = push_cnt ==  ==  ==  ==  ==  == //
    //假如不按高电平，按下低电平 那每按下一次Push_Signal都加1 ，最大计数值为4,检测方法为btn_out为0并且btn_out_last_value为1
    always @(posedge clk_50M or negedge rst_n) begin
        if (!rst_n)
        begin
            btton_flag <= 1'd0;
            Push_Cnt   <= 2'd0;
        end
        else if (~btn_out&&btn_out_last_value)
        begin
            Push_Cnt   <= Push_Cnt+2'd1;
            btton_flag <= 1'd1;
        end
        else
            btton_flag <= 1'd0;
    end
    
    
    // ==  ==  ==  ==  ==  ==  = led ==  ==  ==  ==  ==  == //
    always @(posedge clk_50M) begin
        case(Push_Cnt)
            2'd1:led    <= 'd1;
            2'd2:led    <= 'd0;
            2'd3:led    <= 'd1;
            default:led <= 'd0;
        endcase
    end
    
    
    
endmodule
