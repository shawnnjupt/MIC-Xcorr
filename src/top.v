module top(input clk,
           input rst_n,
           inout cmos_scl,             //cmos i2c clock
           inout cmos_sda,             //cmos i2c data
           input cmos_vsync,           //cmos vsync
           input cmos_href,            //cmos hsync refrence, data valid
           input cmos_pclk,            //cmos pxiel clock
           output cmos_xclk,           //cmos externl clock
           input [7:0] cmos_db,        //cmos data
           output cmos_rst_n,          //cmos reset
           output cmos_pwdn,           //cmos power down
           output [14-1:0] ddr_addr,   //ROW_WIDTH = 14
           output [3-1:0] ddr_bank,    //BANK_WIDTH = 3
           output ddr_cs,
           output ddr_ras,
           output ddr_cas,
           output ddr_we,
           output ddr_ck,
           output ddr_ck_n,
           output ddr_cke,
           output ddr_odt,
           output ddr_reset_n,
           output [2-1:0] ddr_dm,      //DM_WIDTH = 2
           inout [16-1:0] ddr_dq,      //DQ_WIDTH = 16
           inout [2-1:0] ddr_dqs,      //DQS_WIDTH = 2
           inout [2-1:0] ddr_dqs_n,    //DQS_WIDTH = 2
           output O_tmds_clk_p,
           output O_tmds_clk_n,
           output [2:0] O_tmds_data_p, //{r, g, b}
           output [2:0] O_tmds_data_n,
           output mic_clk,
           output mic_ws,
           input mic_so1,
           input mic_so2,
           input mic_so3,
        //    input mic_so4,
           output [1:0]led,
           output wbuart_tx,
           input wbuart_rx,
           output steer_x,
           output steer_y,
           input [3:0]btn
           );
    
  
    wire                   memory_clk         ;
    wire                   dma_clk         	  ;
    wire                   DDR_pll_lock           ;
    wire                   cmd_ready          ;
    wire[2:0]              cmd                ;
    wire                   cmd_en             ;
    wire[5:0]              app_burst_number   ;
    wire[ADDR_WIDTH-1:0]   addr               ;
    wire                   wr_data_rdy        ;
    wire                   wr_data_en         ;//
    wire                   wr_data_end        ;//
    wire[DATA_WIDTH-1:0]   wr_data            ;
    wire[DATA_WIDTH/8-1:0] wr_data_mask       ;
    wire                   rd_data_valid      ;
    wire                   rd_data_end        ;//unused
    wire[DATA_WIDTH-1:0]   rd_data            ;
    wire                   init_calib_complete;
    
    //According to IP parameters to choose
    // 根据IP核选择
    `define	    WR_VIDEO_WIDTH_16
    `define	DEF_WR_VIDEO_WIDTH 16
    
    `define	    RD_VIDEO_WIDTH_16
    `define	DEF_RD_VIDEO_WIDTH 16
    
    `define	USE_THREE_FRAME_BUFFER
    
    `define	DEF_ADDR_WIDTH 28
    `define	DEF_SRAM_DATA_WIDTH 128
 

    parameter ADDR_WIDTH     = `DEF_ADDR_WIDTH;    //存储单元是byte，总容量     = 2^27*16bit     = 2Gbit,增加1位rank地址，{rank[0],bank[2:0],row[13:0],cloumn[9:0]}
    parameter DATA_WIDTH     = `DEF_SRAM_DATA_WIDTH;   //与生成DDR3IP有关，此ddr3 2Gbit, x16， 时钟比例1:4 ，则固定128bit
    parameter WR_VIDEO_WIDTH = `DEF_WR_VIDEO_WIDTH;
    parameter RD_VIDEO_WIDTH = `DEF_RD_VIDEO_WIDTH;
    
    wire                            video_clk;         //video pixel clock

    wire                      syn_off0_re;  // ofifo read enable signal
    wire                      syn_off0_vs;
    wire                      syn_off0_hs;
    
    wire                      off0_syn_de  ;
    wire [RD_VIDEO_WIDTH-1:0] off0_syn_data;
    
    wire[15:0]                      cmos_16bit_data;
    wire                            cmos_16bit_clk;
    wire[15:0] 						write_data;
    
    wire[9:0]                       lut_index;
    wire[31:0]                      lut_data;
    
    assign cmos_xclk  = cmos_clk;
    assign cmos_pwdn  = 1'b0;
    assign cmos_rst_n = 1'b1;
    assign write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};
    assign hdmi_hpd   = 1;
    

    reg [4:0] lcd_vs_cnt;
    always@(posedge lcd_vs) lcd_vs_cnt <= lcd_vs_cnt + 1; // 场同步信号计数,记到8个指示灯Toggle一次
    


    wire start_mic;
    
    wire finished;
    wire [5:0] sequence1;
    wire [5:0] sequence2;
    wire [5:0] sequence3;
    wire [5:0] sequence4;
    wire [5:0] sequence5;
    
    wire signed[23:0] mic_0;
    wire signed[23:0] mic_1;
    wire signed[23:0] mic_2;
    wire signed[23:0] mic_3;
    wire signed[23:0] mic_4;
    wire signed[23:0] mic_5;
    // wire signed[23:0] mic_6;
    // wire signed[23:0] mic_7;
    
    wire rst_dsp;
    reg  [31:0]max_sequence_x;
    reg [31:0]max_sequence_y;
    
    
    wire [31:0] hrdata_i;
    wire [1:0] hresp_i;
    wire hready_i;
    wire [31:0] haddr_o;
    wire hwrite_o;
    wire [2:0] hsize_o;
    wire [2:0] hburst_o;
    wire [31:0] hwdata_o;
    wire hsel_o;
    wire [1:0] htrans_o;
    
    
    wire finished_left;
    wire finished_right;
    
    wire finished_temp;
    
    
    assign rst_dsp = rst_n&(!finished_temp1);


         wire [31:0] reg1;

    wire out_de;
    wire [9:0] lcd_x,lcd_y;

  localparam N = 7; //delay N clocks
    
    reg  [N-1:0]  Pout_hs_dn   ;
    reg  [N-1:0]  Pout_vs_dn   ;
    reg  [N-1:0]  Pout_de_dn   ;
    

    wire [4:0] lcd_r,lcd_b;
    wire [5:0] lcd_g;
    wire lcd_vs,lcd_de,lcd_hs,lcd_dclk;
    
    assign {lcd_r,lcd_g,lcd_b} = off0_syn_de ? off0_syn_data[15:0] : 16'h0000;//{r,g,b}
    assign lcd_vs      			     = Pout_vs_dn[4];//syn_off0_vs;
    assign lcd_hs      			     = Pout_hs_dn[4];//syn_off0_hs;
    assign lcd_de      			     = Pout_de_dn[4];//off0_syn_de;
    assign lcd_dclk    			     = video_clk;//video_clk_phs;

 
    cmos_pll cmos_pll_m0(
    .clkin                     (clk                      		),
    .clkout                    (cmos_clk 	              		)
    );
    
    mem_pll mem_pll_m0(
    .clkin                     (clk),
    .clkout                    (memory_clk 	              		),
    .lock 					   (DDR_pll_lock 						)
    );
    
    //I2C master controller
    i2c_config i2c_config_m0(
    .rst                        (~rst_n),
    .clk                        (clk),
    .clk_div_cnt                (16'd270),
    .i2c_addr_2byte             (1'b1),
    .lut_index                  (lut_index),
    .lut_dev_addr               (lut_data[31:24]),
    .lut_reg_addr               (lut_data[23:8]),
    .lut_reg_data               (lut_data[7:0]),
    .error                      (),
    .done                       (),
    .i2c_scl                    (cmos_scl),
    .i2c_sda                    (cmos_sda)
    );
    //configure look-up table
    lut_ov5640_rgb565_1024_768 lut_ov5640_rgb565_1024_768_m0(
    .lut_index                  (lut_index),
    .lut_data                   (lut_data)
    );
    //CMOS sensor 8bit data is converted to 16bit data
    cmos_8_16bit cmos_8_16bit_m0(
    .rst                        (~rst_n),
    .pclk                       (cmos_pclk),
    .pdata_i                    (cmos_db),
    .de_i                       (cmos_href),
    .pdata_o                    (cmos_16bit_data),
    .hblank                     (cmos_16bit_wr),
    .de_o                       (cmos_16bit_clk)
    );



    syn_gen syn_gen_inst(
    .clk (video_clk),
    .rst (~rst_n),
    
    .active_x(lcd_x),
    .active_y(lcd_y),
    
    .hs(syn_off0_hs),
    .vs(syn_off0_vs),
    .de(out_de)
    
    );
    
    

    Video_Frame_Buffer_Top Video_Frame_Buffer_Top_inst
    (
    .I_rst_n              (init_calib_complete),//rst_n),
    .I_dma_clk            (dma_clk),   //sram_clk),
    `ifdef USE_THREE_FRAME_BUFFER
    .I_wr_halt            (1'd0), //1:halt,  0:no halt
    .I_rd_halt            (1'd0), //1:halt,  0:no halt
    `endif
    // video data input
    // 视频信号输入
    .I_vin0_clk           (cmos_16bit_clk),
    .I_vin0_vs_n          (~cmos_vsync),//只接收负极性
    .I_vin0_de            (cmos_16bit_wr),
    .I_vin0_data          (write_data),
    .O_vin0_fifo_full     (),
    
   
    .I_vout0_clk          (video_clk),
    .I_vout0_vs_n         (syn_off0_vs),//只接收负极性
    .I_vout0_de           (out_de),
    .O_vout0_den          (off0_syn_de),
    .O_vout0_data         (off0_syn_data),
    .O_vout0_fifo_empty   (),
    
    // ddr write request
    // DDR3控制线
    .I_cmd_ready          (cmd_ready),
    .O_cmd                (cmd),//0:write;  1:read
    .O_cmd_en             (cmd_en),
    .O_app_burst_number   (app_burst_number),
    .O_addr               (addr),//[ADDR_WIDTH-1:0]
    .I_wr_data_rdy        (wr_data_rdy),
    .O_wr_data_en         (wr_data_en),//
    .O_wr_data_end        (wr_data_end),//
    .O_wr_data            (wr_data),//[DATA_WIDTH-1:0]
    .O_wr_data_mask       (wr_data_mask),
    .I_rd_data_valid      (rd_data_valid),
    .I_rd_data_end        (rd_data_end),//unused
    .I_rd_data            (rd_data),//[DATA_WIDTH-1:0]
    .I_init_calib_complete(init_calib_complete)
    );
    
    // 下面这部分是延时
    
  
    always@(posedge video_clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            Pout_hs_dn <= {N{1'b1}};
            Pout_vs_dn <= {N{1'b1}};
            Pout_de_dn <= {N{1'b0}}; // 这个是0,和上面不一样
        end
        else // 把低位往高位移动一位,然后低位填上新数据
        begin
            Pout_hs_dn <= {Pout_hs_dn[N-2:0],syn_off0_hs};
            Pout_vs_dn <= {Pout_vs_dn[N-2:0],syn_off0_vs};
            Pout_de_dn <= {Pout_de_dn[N-2:0],out_de};
        end
    end
    

    
    DDR3MI DDR3_Memory_Interface_Top_inst
    (
    .clk                (video_clk),
    .memory_clk         (memory_clk),
    .pll_lock           (DDR_pll_lock),
    .rst_n              (rst_n), //rst_n
    .app_burst_number   (app_burst_number),
    .cmd_ready          (cmd_ready),
    .cmd                (cmd),
    .cmd_en             (cmd_en),
    .addr               (addr),
    .wr_data_rdy        (wr_data_rdy),
    .wr_data            (wr_data),
    .wr_data_en         (wr_data_en),
    .wr_data_end        (wr_data_end),
    .wr_data_mask       (wr_data_mask),
    .rd_data            (rd_data),
    .rd_data_valid      (rd_data_valid),
    .rd_data_end        (rd_data_end),
    .sr_req             (1'b0),
    .ref_req            (1'b0),
    .sr_ack             (),
    .ref_ack            (),
    .init_calib_complete(init_calib_complete),
    .clk_out            (dma_clk),
    .burst              (1'b1),

    .ddr_rst            (),
    .O_ddr_addr         (ddr_addr),
    .O_ddr_ba           (ddr_bank),
    .O_ddr_cs_n         (ddr_cs),
    .O_ddr_ras_n        (ddr_ras),
    .O_ddr_cas_n        (ddr_cas),
    .O_ddr_we_n         (ddr_we),
    .O_ddr_clk          (ddr_ck),
    .O_ddr_clk_n        (ddr_ck_n),
    .O_ddr_cke          (ddr_cke),
    .O_ddr_odt          (ddr_odt),
    .O_ddr_reset_n      (ddr_reset_n),
    .O_ddr_dqm          (ddr_dm),
    .IO_ddr_dq          (ddr_dq),
    .IO_ddr_dqs         (ddr_dqs),
    .IO_ddr_dqs_n       (ddr_dqs_n)
    );

    
  
    wire serial_clk;
    wire TMDS_DDR_pll_lock;
    wire hdmi4_rst_n;
    
    TMDS_rPLL u_tmds_rpll
    (.clkin     (clk)     //input clk 27M 来自晶振
    ,.clkout    (serial_clk)     //output clk 325M
    ,.lock      (TMDS_DDR_pll_lock)     //output lock
    );
    
    assign hdmi4_rst_n = rst_n & TMDS_DDR_pll_lock;
    
    CLKDIV u_clkdiv
    (.RESETN(hdmi4_rst_n)
    ,.HCLKIN(serial_clk) //clk  x5 325M
    ,.CLKOUT(video_clk)    //clk  x1 65M
    ,.CALIB (1'b1)
    );
    defparam u_clkdiv.DIV_MODE = "5";
    defparam u_clkdiv.GSREN    = "false";
    
    
    
    DVI_TX_Top DVI_TX_Top_inst
    (
    .I_rst_n       (hdmi4_rst_n),  //asynchronous reset, low active // 重置
    .I_serial_clk  (serial_clk), // 串行信号时钟线
    
    // 输入视频信号(RGB565)和同步信号(hs vs de)和pixel clk
    .I_rgb_clk     (lcd_dclk),  //pixel clock
    .I_rgb_vs      (lcd_vs),
    .I_rgb_hs      (lcd_hs),
    .I_rgb_de      (lcd_de),
    .I_rgb_r       ({lcd_r_ov,3'd0}),  //tp0_data_r
    .I_rgb_g       ({lcd_g_ov,2'd0}),
    .I_rgb_b       ({lcd_b_ov,3'd0}),
    

    .O_tmds_clk_p  (O_tmds_clk_p),
    .O_tmds_clk_n  (O_tmds_clk_n),
    .O_tmds_data_p (O_tmds_data_p),  //{r,g,b}
    .O_tmds_data_n (O_tmds_data_n)
    );
    
    ///////////////////////////////////////////
    
    
    wire [4:0] lcd_r_ov,lcd_b_ov;
    wire [5:0] lcd_g_ov;
    reg [8:0] sound_band_in;

    wire signed[7:0] mic_cal_x;
    wire signed[7:0] mic_cal_y;

    vitual_image vitual_image_inst(
    .clk(lcd_dclk),
    .hsync(lcd_hs), // 行同步信号
    .vsync(lcd_vs), // 场同步信号
    .lcd_de(lcd_de),
    
    .base_r(lcd_r),
    .base_g(lcd_g),
    .base_b(lcd_b),
    .active_x(lcd_x),     //video x position
    .active_y(lcd_y),
    .mic1(sequence1),
    .mic2(sequence2),
    .mic3(sequence3),
    .mic4(sequence4),
    .reg1(reg1),
    .coeff_overlay(8'd150), // 127
    .output_r(lcd_r_ov),
    .output_g(lcd_g_ov),
    .output_b(lcd_b_ov),
    .sound_band(sound_band_in),
    .mic_cal_x(mic_cal_x),
    .mic_cal_y(mic_cal_y)
    );
    
    
    
    
    
   
    
    mic_serial mic_serial_inst (
    .clk(clk),                 // Clock
    .rst_n(rst_n),
    .rst_dsp(rst_dsp),
    .led(led),
    .mic_clk(mic_clk),
    .mic_ws(mic_ws),
    .mic_so1(mic_so1),
    .mic_so2(mic_so2),
    .mic_so3(mic_so3),
    // .mic_so4(mic_so4),
    .mic_0(mic_0),
    .mic_1(mic_1),
    .mic_2(mic_2),
    .mic_3(mic_3),
    .mic_4(mic_4),
    .mic_5(mic_5),
    // .mic_6(mic_6),
    // .mic_7(mic_7),
    .finished_left1(finished_left),
    .finished_right1(finished_right),
    .start(start_mic));
    
    
    
    
    xcorr xcorr1(
    .clk(clk),
    .rst_n(rst_dsp),
    .start_flag(start_mic),
    .finish_left(finished_left),
    .finish_right(finished_right),
    .mic_1(mic_0[23:6]),
    .mic_2(mic_1[23:6]),
    .sequence_num(sequence1),
    .finished(finished),
    .finished_temp1(finished_temp1)
    );
    
    
    xcorr xcorr2(
    .clk(clk),
    .rst_n(rst_dsp),
    .start_flag(start_mic),
    .finish_left(finished_left),
    .finish_right(finished_right),
    .mic_1(mic_4[23:6]),
    .mic_2(mic_3[23:6]),
    .sequence_num(sequence2),
    .finished(),
    .finished_temp1()
    );
    
    
    xcorr xcorr3(
    .clk(clk),
    .rst_n(rst_dsp),
    .start_flag(start_mic),
    .finish_left(finished_left),
    .finish_right(finished_left),
    .mic_1(mic_1[23:6]),
    .mic_2(mic_3[23:6]),
    .sequence_num(sequence3),
    .finished(),
    .finished_temp1()
    );
    
    
    
    
    xcorr xcorr4(
    .clk(clk),
    .rst_n(rst_dsp),
    .start_flag(start_mic),
    .finish_left(finished_left),
    .finish_right(finished_left),
    .mic_1(mic_0[23:6]),
    .mic_2(mic_4[23:6]),
    .sequence_num(sequence4),
    .finished(),
    .finished_temp1()
    );
    

     steer steer_inst1(
  .clk(clk),                    //输入27mhz
  .rst_n(rst_n),
  .direct(mic_cal_x>0?2'b10:(mic_cal_x==0?2'b00:2'b01)),             //0为
  .pwm_io(steer_x)
  );
 steer steer_inst2(
  .clk(clk),                    //输入27mhz
  .rst_n(rst_n),
  .direct(mic_cal_y>0?2'b01:(mic_cal_y==0?2'b00:2'b10)),             //0为
  .pwm_io(steer_y)
  );

wire btton_flag1;
wire [1:0]push_cnt1;


Btn_Control  Btn_Control_inst1(
                    .clk_50M(clk),
                    .Btn(btn[0]),
                    .rst_n(rst_n),
                    .btton_flag(btton_flag1),
                    .Push_Cnt(push_cnt1),
                    .led());
    



    
//    xcorr xcorr5(
//    .clk(clk),
//    .rst_n(rst_dsp),
//    .start_flag(start_mic),
//    .finish_left(finished_left),
//    .finish_right(finished_left),
//    .mic_1(mic_7[23:6]),
//    .mic_2(mic_6[23:6]),
//    .sequence_num(sequence5),
//    .finished(),
//    .finished_temp1()
//    );

    
    
    
//     always@(posedge clk or negedge rst_n)
//     begin
//         if (!rst_n)
//         begin
//             max_sequence_x <= 32'd0;
//             max_sequence_y <= 32'd0;
//         end
//         else if (finished)
//         begin


//             max_sequence_x <= {8'd0,sequence1,sequence2,sequence3,sequence4};
//             max_sequence_y <= {22'd0,sound_band,push_cnt1[0]};
//         end
//             end



always@(posedge max_finish)
begin
      max_sequence_x <= {8'd0,sequence1,sequence2,sequence3,sequence4};
      max_sequence_y <= {22'd0,sound_band,push_cnt1[0]};
//    max_sequence_x <= {23'd0,sound_band,sequence1,sequence2,sequence3,sequence4};
//    max_sequence_y <= {31'd0,push_cnt1[0]};
    sound_band_in<=sound_band;
end
            
  
            
            ahb_communicate ahb_communicate_inst (
            .hclk(clk),
            .hresetn(rst_n),
            .haddr(haddr_o),
            .htrans(htrans_o),
            .hwrite(hwrite_o),
            .hsize(hsize_o),
            .hburst(hburst_o),
            .hwdata(hwdata_o),
            .hsel(hsel_o),
            .hready_in(hready_i),
            .hready(hready_i),
            .hrdata(hrdata_i),
            .hresp(hresp_i),
            .max_sequence_x(max_sequence_x),
            .max_sequence_y(max_sequence_y),
            .reg1(reg1)
            );
            
            
            
            
            Gowin_PicoRV32_Top Gowin_PicoRV32_Top_inst(
            .wbuart_tx(wbuart_tx), //output wbuart_tx
            .wbuart_rx(wbuart_rx), //input wbuart_rx
            .hrdata(hrdata_i), //input [31:0] hrdata
            .hresp(hresp_i), //input [1:0] hresp
            .hready(hready_i), //input hready
            .haddr(haddr_o), //output [31:0] haddr
            .hwrite(hwrite_o), //output hwrite
            .hsize(hsize_o), //output [2:0] hsize
            .hburst(hburst_o), //output [2:0] hburst
            .hwdata(hwdata_o), //output [31:0] hwdata
            .hsel(hsel_o), //output hsel
            .htrans(htrans_o), //output [1:0] htrans
            .clk_in(clk), //input clk_in
            .resetn_in(rst_n) //input resetn_in
            );
            
            
               wire [9-1:0] sound_band;
                 wire max_finish;
             max_sample max_sample_inst(
             .clk(clk),
             .rst_n(rst_dsp),
             .mic_data(mic_0),
             .sound_band(sound_band),
              .max_finish(max_finish)
              );
            
            
            endmodule
