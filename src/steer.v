module steer (
  input clk,                    //输入27mhz
  input rst_n,
  input [1:0]direct,             //0为
  output  pwm_io
);
    reg [21:0] cnt;
    reg [20:0] ccr;
    reg clk_50hz;
    
    initial
    begin
       ccr=40500;
    end
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            cnt=0;
        end
        else
        begin
            if(cnt==540000-1)
            begin
                cnt=0;
                clk_50hz=~clk_50hz;
            end
            else
            begin
                cnt=cnt+1;
            end
        end
        
    end
    
    always @(posedge clk_50hz or negedge rst_n)
    begin
        if(!rst_n)
        begin
            ccr=40500;
        end
        else
        begin
            case(direct)
            2'b00:
                    ;
            2'b01:
            begin
                ccr=ccr-100;
                if(ccr<27000)
                    ccr=27000;
            end
            2'b10:
            begin
                ccr=ccr+100;
                if(ccr>54000)
                    ccr=54000;
            end 
            2'b11:ccr=40500;
            endcase
        end
        
    end

    assign pwm_io=cnt<ccr?1:0;

    
endmodule