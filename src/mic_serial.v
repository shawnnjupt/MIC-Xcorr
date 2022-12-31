module mic_serial (input clk,                 // Clock
                   input rst_n,
                   input rst_dsp,
                   output reg [1:0] led,
                   output mic_clk,
                   output mic_ws,
                   input mic_so1,
                   input mic_so2,
                   input mic_so3,
                //    input mic_so4,
                   output signed[23:0] mic_0,
                   output signed[23:0] mic_1,
                   output signed[23:0] mic_2,
                   output signed[23:0] mic_3,
                   output signed[23:0] mic_4,
                   output signed[23:0] mic_5,
                //    output signed[23:0] mic_6,
                //    output signed[23:0] mic_7,
                   output finished_left1,
                   output finished_right1,
                   output reg start);
    


    wire signed[23:0] mic_data_left1;
    wire signed[23:0] mic_data_right1;
    wire signed[23:0] mic_data_left2;
    wire signed[23:0] mic_data_right2;
    wire signed[23:0] mic_data_left3;
    wire signed[23:0] mic_data_right3;
    // wire signed[23:0] mic_data_left4;
    // wire signed[23:0] mic_data_right4;
    
    
    
    reg  signed[23:0] mic_data_left1_d0;
    reg  signed[23:0] mic_data_right1_d0;
    reg  signed[23:0] mic_data_left2_d0;
    reg  signed[23:0] mic_data_right2_d0;
    reg  signed[23:0] mic_data_left3_d0;
    reg  signed[23:0] mic_data_right3_d0;
    // reg  signed[23:0] mic_data_left4_d0;
    // reg  signed[23:0] mic_data_right4_d0; 
    
    
    reg  signed[23:0] mic_data_left1_d1;
    reg  signed[23:0] mic_data_right1_d1;
    reg  signed[23:0] mic_data_left2_d1;
    reg  signed[23:0] mic_data_right2_d1;
    reg  signed[23:0] mic_data_left3_d1;
    reg  signed[23:0] mic_data_right3_d1;
    // reg  signed[23:0] mic_data_left4_d1;
    // reg  signed[23:0] mic_data_right4_d1;  
    
    
    
    reg  signed[23:0] mic_data_left1_d2;
    reg  signed[23:0] mic_data_right1_d2;
    reg  signed[23:0] mic_data_left2_d2;
    reg  signed[23:0] mic_data_right2_d2;
    reg  signed[23:0] mic_data_left3_d2;
    reg  signed[23:0] mic_data_right3_d2;
    // reg  signed[23:0] mic_data_left4_d2;
    // reg  signed[23:0] mic_data_right4_d2; 
    
    
    // wire finished_left1;
    // wire finished_right1;
    wire finished_left2;
    wire finished_right2;
    wire finished_left3;
    wire finished_right3;
    // wire finished_left4;
    // wire finished_right4;
  
    
    assign mic_0 = mic_data_right1_d2;
    assign mic_1 = mic_data_left1_d2;
    assign mic_2 = mic_data_right2_d2;
    assign mic_3 = mic_data_left2_d2;
    assign mic_4 = mic_data_right3_d2;
    assign mic_5 = mic_data_left3_d2;
    // assign mic_6 = mic_data_right4_d2;
    // assign mic_7 = mic_data_left4_d2;

    
    reg [10:0] cnt_start;
    
    
    //判断声道变化点亮LED
    parameter 	MIC_GAP = 100000;
    
    
    always @(posedge clk or negedge rst_dsp)
    begin
        if (!rst_dsp)
        begin
            mic_data_left1_d0  <= 0;
            mic_data_right1_d0 <= 0;
            mic_data_left1_d1  <= 0;
            mic_data_right1_d1 <= 0;
            mic_data_left1_d2  <= 0;
            mic_data_right1_d2 <= 0;
            mic_data_left2_d0  <= 0;
            mic_data_left2_d1  <= 0;
            mic_data_left2_d2  <= 0;
            mic_data_right2_d0 <= 0;
            mic_data_left3_d0  <= 0;
            mic_data_right3_d0 <= 0;
            mic_data_right2_d1 <= 0;
            mic_data_left3_d1  <= 0;
            mic_data_right3_d1 <= 0;
            mic_data_right2_d2 <= 0;
            mic_data_left3_d2  <= 0;
            mic_data_right3_d2 <= 0;
            // mic_data_left4_d0  <= 0;
            // mic_data_right4_d0 <= 0;
            // mic_data_left4_d1  <= 0;
            // mic_data_right4_d1 <= 0;
            // mic_data_left4_d2  <= 0;
            // mic_data_right4_d2 <= 0; 
            
            
            cnt_start <= 0;
        end
        else if (finished_left1)
        begin
            cnt_start         <= cnt_start+11'd1;
            mic_data_left1_d0 <= mic_data_left1;
            mic_data_left1_d1 <= mic_data_left1_d0;
            mic_data_left1_d2 <= mic_data_left1_d1;
            
            mic_data_left2_d0 <= mic_data_left2;
            mic_data_left2_d1 <= mic_data_left2_d0;
            mic_data_left2_d2 <= mic_data_left2_d1;
            
            
            mic_data_left3_d0 <= mic_data_left3;
            mic_data_left3_d1 <= mic_data_left3_d0;
            mic_data_left3_d2 <= mic_data_left3_d1;
            
            // mic_data_left4_d0 <= mic_data_left4;
            // mic_data_left4_d1 <= mic_data_left4_d0;
            // mic_data_left4_d2 <= mic_data_left4_d1;
            
            
            
        end
            else if (finished_right1)
            begin
            
            
            mic_data_right1_d0 <= mic_data_right1;
            mic_data_right1_d1 <= mic_data_right1_d0;
            mic_data_right1_d2 <= mic_data_right1_d1;
            
            
            mic_data_right2_d0 <= mic_data_right2;
            mic_data_right2_d1 <= mic_data_right2_d0;
            mic_data_right2_d2 <= mic_data_right2_d1;
            
            
            mic_data_right3_d0 <= mic_data_right3;
            mic_data_right3_d1 <= mic_data_right3_d0;
            mic_data_right3_d2 <= mic_data_right3_d1;
           

            // mic_data_right4_d0 <= mic_data_right4;
            // mic_data_right4_d1 <= mic_data_right4_d0;
            // mic_data_right4_d2 <= mic_data_right4_d1;
 
            
            
            end
            
            
            end
            
            
            
            always@(posedge clk or negedge rst_dsp)
            begin
                if (!rst_dsp)
                begin
                    start <= 0;
                end
                else if (finished_left1)
                begin
                    if (cnt_start == 11'd3)
                        start <= 1;
                        end
                    
                    
                end
                    
                    
                    always@(posedge clk)
                    begin
                        if ($signed(mic_data_left3) > $signed(mic_data_left3_d2) + MIC_GAP)
                            led <= 2'b01;
                        else if ($signed(mic_data_right3) >$signed(mic_data_right3_d2) + MIC_GAP)
                            led <= 2'b10;
                        else
                            led <= 2'b11; //差距过小 判定无
                        
                    end
                    
                    
                    
                    
                    mic_sample mic_sample_inst1 (
                    .clk(clk),                   // Clock
                    .rst_n(rst_n),
                    .mic_clk(mic_clk),
                    .mic_ws(mic_ws),
                    .mic_so(mic_so1),
                    .mic_data_left(mic_data_left1),
                    .mic_data_right(mic_data_right1),
                    .finished_left(finished_left1),
                    .finished_right(finished_right1));
                    
                    
                    mic_sample mic_sample_inst2 (
                    .clk(clk),                   // Clock
                    .rst_n(rst_n),
                    .mic_clk(),
                    .mic_ws(),
                    .mic_so(mic_so2),
                    .mic_data_left(mic_data_left2),
                    .mic_data_right(mic_data_right2),
                    .finished_left(finished_left2),
                    .finished_right(finished_right2));
                    
                    
                    mic_sample mic_sample_inst3 (
                    .clk(clk),                   // Clock
                    .rst_n(rst_n),
                    .mic_clk(),
                    .mic_ws(),
                    .mic_so(mic_so3),
                    .mic_data_left(mic_data_left3),
                    .mic_data_right(mic_data_right3),
                    .finished_left(finished_left3),
                    .finished_right(finished_right3));
                    
             
                    
                    
                    endmodule
