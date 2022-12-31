//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.07
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18C
//Created Time: Sun Nov 20 04:33:09 2022

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Gowin_PicoRV32_Top your_instance_name(
		.wbuart_tx(wbuart_tx_o), //output wbuart_tx
		.wbuart_rx(wbuart_rx_i), //input wbuart_rx
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
		.irq_in(irq_in_i), //input [31:20] irq_in
		.jtag_TDI(jtag_TDI_i), //input jtag_TDI
		.jtag_TDO(jtag_TDO_o), //output jtag_TDO
		.jtag_TCK(jtag_TCK_i), //input jtag_TCK
		.jtag_TMS(jtag_TMS_i), //input jtag_TMS
		.clk_in(clk_in_i), //input clk_in
		.resetn_in(resetn_in_i) //input resetn_in
	);

//--------Copy end-------------------
