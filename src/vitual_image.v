module vitual_image (input clk,
                       input hsync,              // 行同步信号
                       input vsync,              // 场同步信号
                       input lcd_de,
                       input [5:0]mic1,
                       input [5:0]mic2,
                       input [5:0]mic3,
                       input [5:0]mic4,
                       input [9:0]active_x,     //video x position
                       input [9:0]active_y,
                       input [4:0]base_r,
                       input [5:0]base_g,
                       input [4:0]base_b,
                       input [7:0]coeff_overlay, // overlay的叠加强度, 0~255
                       input [31:0]reg1,
                       output [4:0]output_r,
                       output [5:0]output_g,
                       output [4:0]output_b,
                       input [8:0]sound_band,
                       output reg signed [7:0]mic_cal_x,
                       output reg signed [7:0]mic_cal_y
                       );
    
    //摄像头为1024x768 输入点阵大致为40 x40 首先对输入点阵进行处理  
    
    wire signed [6:0]mic_cal_1;
    wire signed [6:0]mic_cal_2;
    wire signed [6:0]mic_cal_3;
    wire signed [6:0]mic_cal_4;
    
    wire signed [7:0]mic_cal_x1;
    wire signed [7:0]mic_cal_y1;
    
    // reg signed [7:0]mic_cal_x;
    // reg signed [7:0]mic_cal_y;
    
    assign mic_cal_1 = $signed({1'd0,mic1})>30 ?$signed({1'd0,mic1})-30:(0-$signed({1'd0,mic1}));
    assign mic_cal_2 = $signed({1'd0,mic2})>30 ?$signed({1'd0,mic2})-30:(0-$signed({1'd0,mic2}));
    assign mic_cal_3 = $signed({1'd0,mic3})>30 ?$signed({1'd0,mic3})-30:(0-$signed({1'd0,mic3}));
    assign mic_cal_4 = $signed({1'd0,mic4})>30 ?$signed({1'd0,mic4})-30:(0-$signed({1'd0,mic4}));
    
    assign mic_cal_x1  = (mic_cal_1+mic_cal_2)/2;
    assign mic_cal_y1  = (mic_cal_3+mic_cal_4)/(-2);
    //assign mic_cal_x = mic_cal_x1[6:1];
    //assign mic_cal_y = mic_cal_y1[6:1];
    
    
    wire [7:0]coeff_base; // base的叠加强度
    assign coeff_base = 8'd255 - coeff_overlay;
    
    reg [15:0]tmp_r;
    reg [15:0]tmp_g;
    reg [15:0]tmp_b;
    assign output_r = tmp_r[12:8];
    assign output_g = tmp_g[13:8];
    assign output_b = tmp_b[12:8];
    
    wire [4:0]lcd_r_ov;
    wire [5:0]lcd_g_ov;
    wire [4:0]lcd_b_ov;
    
    reg [10:0]lcd_x;
    reg [10:0]lcd_y;
    
    reg last_hsync;
    reg last_vsync;
    
    reg [14:0] prom_address;
    reg [23:0] fake_color_data;
    reg [7:0]distance;
    reg signed [22:0]dis_sq;
    reg [21:0]circle_r;
    reg [8:0] sound_band_temp;

    
    always@(posedge clk) begin
        if(active_x==0&&active_y==0)
            begin
             

                
                sound_band_temp=sound_band;
                
                if(sound_band_temp==0)
                    begin
                        mic_cal_x<=0;
                        mic_cal_y<=0;
                    end
                    else 
                    begin
                         mic_cal_x <= mic_cal_x1;
                        mic_cal_y <= mic_cal_y1;
                    end
               
                
            end
        // if (lcd_de == 0) begin
        //     last_hsync <= 0;
        //     last_vsync <= 0;
            
            
        // end
        // else begin
        //     if (last_vsync == 0 && vsync == 1) begin // vsync上升沿
        //         lcd_x     <= 1'd0;
        //         lcd_y     <= 1'd0;
        //         mic_cal_x <= mic_cal_x1;
        //         mic_cal_y <= mic_cal_y1;
        //         sound_band_temp=sound_band;
        //     end
        //     else
        //         if (last_hsync == 1 && hsync == 0) begin // hsync上升沿
        //             lcd_x <= 1'd0;
        //             lcd_y <= lcd_y + 1'd1;
        //         end
        //         else begin
        //             lcd_x <= lcd_x + 1'd1;
        //         end
        //         last_hsync = hsync;
        //         last_vsync = vsync;
        // end
    end
    
    parameter PIXEL_NUM                 = 32'd1024;
    assign {lcd_r_ov,lcd_g_ov,lcd_b_ov} = lcd_de? {fake_color_data[23:19],fake_color_data[15:10],fake_color_data[7:3]}: 16'H0000;
    
   
    always@(posedge clk) begin
  
        if ($signed({1'd0,active_x})>(512+70*mic_cal_x))
        begin
            if ($signed({1'd0,active_y})>(384+40*mic_cal_y))
            begin
                dis_sq = ($signed({1'd0,active_x})-(512+70*mic_cal_x))*($signed({1'd0,active_x})-(512+70*mic_cal_x))+($signed({1'd0,active_y})-(384+40*mic_cal_y))*($signed({1'd0,active_y})-(384+40*mic_cal_y));
            end
            else
            begin
                dis_sq = ($signed({1'd0,active_x})-(512+70*mic_cal_x))*($signed({1'd0,active_x})-(512+70*mic_cal_x))+((384+40*mic_cal_y)-$signed({1'd0,active_y}))*((384+40*mic_cal_y)-$signed({1'd0,active_y}));
            end
        end
        else
        begin
            if ($signed({1'd0,active_y})>(384+40*mic_cal_y))
            begin
                dis_sq = ((512+70*mic_cal_x)-$signed({1'd0,active_x}))*((512+70*mic_cal_x)-$signed({1'd0,active_x}))+($signed({1'd0,active_y})-(384+40*mic_cal_y))*($signed({1'd0,active_y})-(384+40*mic_cal_y));
            end
            else
            begin
                dis_sq = ((512+70*mic_cal_x)-$signed({1'd0,active_x}))*((512+70*mic_cal_x)-$signed({1'd0,active_x}))+((384+40*mic_cal_y)-$signed({1'd0,active_y}))*((384+40*mic_cal_y)-$signed({1'd0,active_y}));
            end
        end

        // if(sound_band_temp>30)
        // begin
        //     circle_r=30000;
        // end
        // else
        // begin
        //     circle_r=sound_band_temp*sound_band_temp*33;
        // end


        if(sound_band_temp==0)
        begin
            distance = 0;
        end
        else if (dis_sq>10000||(512+70*mic_cal_x)<0||(512+70*mic_cal_x)>1024||(384+40*mic_cal_y)<0||(384+40*mic_cal_y)>768)
        begin
            distance = 0;
        end
        else
        begin
            distance = 255-$unsigned(dis_sq)*255/(10000);
        end
            
            case(reg1)
                32'd0://原图
                begin
                    tmp_r = base_r*8'd255;
                    tmp_g = base_g*8'd255;
                    tmp_b = base_b*8'd255;
                end
                32'd1://gray
                begin
                    fake_color_data[23:16] = distance;
                    fake_color_data[15:8]  = distance;
                    fake_color_data[7:0]   = distance;
                    tmp_r                  = coeff_base * base_r + coeff_overlay * lcd_r_ov;
                    tmp_g                  = coeff_base * base_g + coeff_overlay * lcd_g_ov;
                    tmp_b                  = coeff_base * base_b + coeff_overlay * lcd_b_ov;
                end
                32'd2://GCM_Metal2
                begin
                    if ((distance>= 0) && (distance<= 16))
                        fake_color_data[23:16] = 0;
                    else if ((distance>= 17) && (distance<= 140))
                        fake_color_data[23:16] = ((distance-16)*255/(140-16));
                    else if ((distance>= 141) && (distance<= 255))
                        fake_color_data[23:16] = 255;
                        if ((distance>= 0) && (distance<= 101))
                            fake_color_data[15:8] = 0;
                        else if ((distance>= 102) && (distance<= 218))
                            fake_color_data[15:8] = ((distance-101)*255/(218-101));
                        else if ((distance>= 219) && (distance<= 255))
                            fake_color_data[15:8] = 255;
                            if ((distance>= 0) && (distance<= 91))
                                fake_color_data[7:0] = 28+((distance-0)*100/(91-0));
                            else if ((distance>= 92) && (distance<= 120))
                                fake_color_data[7:0] = ((120-distance)*128/(120-91));
                            else if ((distance>= 129) && (distance<= 214))
                                fake_color_data[7:0] = 0;
                            else if ((distance>= 215) && (distance<= 255))
                                fake_color_data[7:0] = ((distance-214)*255/(255-214));
                    
                    tmp_r = coeff_base * base_r + coeff_overlay * lcd_r_ov;
                    tmp_g = coeff_base * base_g + coeff_overlay * lcd_g_ov;
                    tmp_b = coeff_base * base_b + coeff_overlay * lcd_b_ov;
                end
                32'd3://GCM_Pseudo2
                begin
                    if (distance <= 63)
                    begin
                        fake_color_data[23:16] = 0;
                        fake_color_data[15:8]  = 0;
                        fake_color_data[7:0]   = (distance*255/64);
                    end
                    else if ((distance>= 64) && (distance<= 127))
                    begin
                        fake_color_data[23:16] = 0;
                        fake_color_data[15:8]  = ((distance-64)*255/64);
                        fake_color_data[7:0]   = ((127-distance)*255/64);
                    end
                        else if ((distance>= 128) && (distance<= 191))
                        begin
                        fake_color_data[23:16] = ((distance-128)*255/64);
                        fake_color_data[15:8]  = 255;
                        fake_color_data[7:0]   = 0;
                        end
                        else if ((distance>= 192) && (distance<= 255))
                        begin
                        fake_color_data[23:16] = 255;
                        fake_color_data[15:8]  = ((255-distance)*255/64);
                        fake_color_data[7:0]   = 0;
                        end
                        tmp_r = coeff_base * base_r + coeff_overlay * lcd_r_ov;
                        tmp_g = coeff_base * base_g + coeff_overlay * lcd_g_ov;
                        tmp_b = coeff_base * base_b + coeff_overlay * lcd_b_ov;
                        end
                        //32'd4:
                        endcase
                        
                  
                        end
                        
       
                        
                        endmodule
