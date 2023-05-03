module Sdram_Control(
		//	HOST Side
      REF_CLK,
      RESET_N,
		CLK,
		//	FIFO Write Side 
      WR_DATA,
		WR,
		WR_ADDR,
		WR_MAX_ADDR,
		WR_LENGTH,
		WR_LOAD,
		WR_CLK,
		WR_FULL,
		WR_USE,
		//	FIFO Read Side 
      RD_DATA,
		RD,
		RD_ADDR,
		RD_MAX_ADDR,
		RD_LENGTH,
		RD_LOAD,	
		RD_CLK,
		RD_EMPTY,
		RD_USE,
		//	SDRAM Side
        SA,
        BA,
        CS_N,
        CKE,
        RAS_N,
        CAS_N,
        WE_N,
        DQ,
        DQM,
		  SDR_CLK
        );


`include        "Sdram_Params.h"
//	HOST Side
input                           REF_CLK;                //System Clock
input                           RESET_N;                //System Reset
//	FIFO Write Side 1
input   [`DSIZE-1:0]            WR_DATA;               //Data input
input							        WR;					//Write Request
input	  [`ASIZE-1:0]			     WR_ADDR;				//Write start address
input	  [`ASIZE-1:0]			     WR_MAX_ADDR;			//Write max address
input	  [8:0]					     WR_LENGTH;				//Write length
input							        WR_LOAD;				//Write register load & fifo clear
input							        WR_CLK;				//Write fifo clock
output							     WR_FULL;				//Write fifo full
output  [15:0]					     WR_USE;				//Write fifo usedw

//	FIFO Read Side 1
output  [`DSIZE-1:0]            RD_DATA;               //Data output
input							        RD;					//Read Request
input	  [`ASIZE-1:0]			     RD_ADDR;				//Read start address
input	  [`ASIZE-1:0]			     RD_MAX_ADDR;			//Read max address
input	  [8:0]					     RD_LENGTH;				//Read length
input							        RD_LOAD;				//Read register load & fifo clear
input							        RD_CLK;				//Read fifo clock
output							     RD_EMPTY;				//Read fifo empty
output	[15:0]					  RD_USE;				//Read fifo usedw
//	SDRAM Side
output  [`SASIZE-1:0]           SA;                     //SDRAM address output
output  [1:0]                   BA;                     //SDRAM bank address
output  [1:0]                   CS_N;                   //SDRAM Chip Selects
output                          CKE;                    //SDRAM clock enable
output                          RAS_N;                  //SDRAM Row address Strobe
output                          CAS_N;                  //SDRAM Column address Strobe
output                          WE_N;                   //SDRAM write enable
inout   [`DSIZE-1:0]            DQ;                     //SDRAM data bus
output  [`DSIZE/8-1:0]          DQM;                    //SDRAM data mask lines
output							     SDR_CLK;				//SDRAM clock
//	Internal Registers/Wires
//	Controller
reg		[`ASIZE-1:0]			  mADDR;					//Internal address
reg		[8:0]					     mLENGTH;				//Internal length
reg		[`ASIZE-1:0]			  rWR_ADDR;				//Register write address				
				
reg		[`ASIZE-1:0]			 rRD_ADDR;				//Register read address
reg							       WR_MASK;				//Write port active mask
reg							       RD_MASK;				//Read port active mask
reg								    mWR_DONE;				//Flag write done, 1 pulse SDR_CLK
reg								    mRD_DONE;				//Flag read done, 1 pulse SDR_CLK
reg								    mWR,Pre_WR;				//Internal WR edge capture
reg								    mRD,Pre_RD;				//Internal RD edge capture
reg 	[9:0] 					    ST;						//Controller status
reg		[1:0] 					 CMD;					//Controller command
reg								    PM_STOP;				//Flag page mode stop
reg								    PM_DONE;				//Flag page mode done
reg								    Read;					//Flag read active
reg								    Write;					//Flag write active
reg	    [`DSIZE-1:0]         mDATAOUT;               //Controller Data output

wire    [`DSIZE-1:0]           mDATAIN;                //Controller Data input 2
wire                           CMDACK;                 //Controller command acknowledgement
//	DRAM Control
reg  	[`DSIZE/8-1:0]            DQM;                    //SDRAM data mask lines
reg     [`SASIZE-1:0]           SA;                     //SDRAM address output
reg     [1:0]                   BA;                     //SDRAM bank address
reg     [1:0]                   CS_N;                   //SDRAM Chip Selects
reg                             CKE;                    //SDRAM clock enable
reg                             RAS_N;                  //SDRAM Row address Strobe
reg                             CAS_N;                  //SDRAM Column address Strobe
reg                             WE_N;                   //SDRAM write enable
wire    [`DSIZE-1:0]            DQOUT;					//SDRAM data out link
wire  	[`DSIZE/8-1:0]         IDQM;                   //SDRAM data mask lines
wire    [`SASIZE-1:0]           ISA;                    //SDRAM address output
wire    [1:0]                   IBA;                    //SDRAM bank address
wire    [1:0]                   ICS_N;                  //SDRAM Chip Selects
wire                            ICKE;                   //SDRAM clock enable
wire                            IRAS_N;                 //SDRAM Row address Strobe
wire                            ICAS_N;                 //SDRAM Column address Strobe
wire                            IWE_N;                  //SDRAM write enable
//	FIFO Control
reg								OUT_VALID;				//Output data request to read side fifo
reg								IN_REQ;					//Input	data request to write side fifo
wire	[15:0]					write_side_fifo_rusedw;
wire	[15:0]					read_side_fifo_wusedw;

//	DRAM Internal Control
wire    [`ASIZE-1:0]            saddr;
wire                            load_mode;
wire                            nop;
wire                            reada;
wire                            writea;
wire                            refresh;
wire                            precharge;
wire                            oe;
wire							ref_ack;
wire							ref_req;
wire							init_req;
wire							cm_ack;
wire							active;
output                  CLK;
	
//sdram_pll0 sdram_pll0_inst(
//		.refclk(REF_CLK),   //  refclk.clk
//		.rst(1'b0),      //   reset.reset
//		.outclk_0(CLK), // outclk0.clk
//		.outclk_1(SDR_CLK), // outclk1.clk
//		.locked()    //  locked.export
//	);
	
	
sdram_pll0 sdram_pll0_inst(
	.areset(),
	.inclk0(REF_CLK),
	.c0(CLK),
	.c1(SDR_CLK),
	.locked());	

control_interface control1 (                                                                                                                               
                .CLK(CLK),
                .RESET_N(RESET_N),
                .CMD(CMD),
                .ADDR(mADDR),
                .REF_ACK(ref_ack),
                .CM_ACK(cm_ack),
                .NOP(nop),
                .READA(reada),
                .WRITEA(writea),
                .REFRESH(refresh),
                .PRECHARGE(precharge),
                .LOAD_MODE(load_mode),
                .SADDR(saddr),
                .REF_REQ(ref_req),
				    .INIT_REQ(init_req),
                .CMD_ACK(CMDACK)
                );

command command1(
                .CLK(CLK),
                .RESET_N(RESET_N),
                .SADDR(saddr),
                .NOP(nop),
                .READA(reada),
                .WRITEA(writea),
                .REFRESH(refresh),
				    .LOAD_MODE(load_mode),
                .PRECHARGE(precharge),
                .REF_REQ(ref_req),
				    .INIT_REQ(init_req),
                .REF_ACK(ref_ack),
                .CM_ACK(cm_ack),
                .OE(oe),
				    .PM_STOP(PM_STOP),
				    .PM_DONE(PM_DONE),
                .SA(ISA),
                .BA(IBA),
                .CS_N(ICS_N),
                .CKE(ICKE),
                .RAS_N(IRAS_N),
                .CAS_N(ICAS_N),
                .WE_N(IWE_N)
                );
                
sdr_data_path data_path1(
                .CLK(CLK),
                .RESET_N(RESET_N),
                .DATAIN(mDATAIN),
                .DM(2'b00),
                .DQOUT(DQOUT),
                .DQM(IDQM)
                );

Sdram_WR_FIFO 	write_fifo1(
				.data(WR_DATA),
				.wrreq(WR),
				.wrclk(WR_CLK),
				.aclr(WR_LOAD),
				.rdreq(IN_REQ&WR_MASK),
				.rdclk(CLK),
				.q(mDATAIN),
				.wrfull(WR_FULL),
				.wrusedw(WR_USE),
				.rdusedw(write_side_fifo_rusedw)
				);
				
reg flag;	 
always@(posedge CLK or negedge RESET_N)
begin
 if(!RESET_N)
 flag	<=	0;
 else
 begin
  if(write_side_fifo_rusedw==WR_LENGTH)
  flag	<=	1;
 end
end				


Sdram_RD_FIFO 	read_fifo1(
				.data(mDATAOUT),
				.wrreq(OUT_VALID&RD_MASK),
				.wrclk(CLK),
				.aclr(RD_LOAD),
				.rdreq(RD),
				.rdclk(RD_CLK),
				.q(RD_DATA),
				.wrusedw(read_side_fifo_wusedw),
				.rdempty(RD_EMPTY),
				.rdusedw(RD_USE)
				);
				

always @(posedge CLK)
begin
	SA      <= (ST==SC_CL+mLENGTH)			?	13'h200	:	ISA;
    BA      <= IBA;
    CS_N    <= ICS_N;
    CKE     <= ICKE;
    RAS_N   <= (ST==SC_CL+mLENGTH)			?	1'b0	:	IRAS_N;
    CAS_N   <= (ST==SC_CL+mLENGTH)			?	1'b1	:	ICAS_N;
    WE_N    <= (ST==SC_CL+mLENGTH)			?	1'b0	:	IWE_N;
	PM_STOP	<= (ST==SC_CL+mLENGTH)			?	1'b1	:	1'b0;
	PM_DONE	<= (ST==SC_CL+SC_RCD+mLENGTH+2)	?	1'b1	:	1'b0;
	DQM		<= ( active && (ST>=SC_CL) )	?	(	((ST==SC_CL+mLENGTH) && Write)?	2'b11	:	2'b00	)	:	2'b11	;
	mDATAOUT<= DQ;
end

assign  DQ = oe ? DQOUT : `DSIZE'hzzzz;
assign	active	=	Read | Write;

always@(posedge CLK or negedge RESET_N)
begin
	if(RESET_N==0)
	begin
		CMD			<=  0;
		ST			<=  0;
		Pre_RD		<=  0;
		Pre_WR		<=  0;
		Read		<=	0;
		Write		<=	0;
		OUT_VALID	<=	0;
		IN_REQ		<=	0;
		mWR_DONE	<=	0;
		mRD_DONE	<=	0;
	end
	else
	begin
		Pre_RD	<=	mRD;
		Pre_WR	<=	mWR;
		case(ST)
		0:	begin
				if({Pre_RD,mRD}==2'b01)
				begin
					Read	<=	1;
					Write	<=	0;
					CMD		<=	2'b01;
					ST		<=	1;
				end
				else if({Pre_WR,mWR}==2'b01)
				begin
					Read	<=	0;
					Write	<=	1;
					CMD		<=	2'b10;
					ST		<=	1;
				end
			end
		1:	begin
				if(CMDACK==1)
				begin
					CMD<=2'b00;
					ST<=2;
				end
			end
		default:	
			begin	
				if(ST!=SC_CL+SC_RCD+mLENGTH+1)
				ST<=ST+1;
				else
				ST<=0;
			end
		endcase
	
		if(Read)
		begin
			if(ST==SC_CL+SC_RCD+1)
			OUT_VALID	<=	1;
			else if(ST==SC_CL+SC_RCD+mLENGTH+1)
			begin
				OUT_VALID	<=	0;
				Read		<=	0;
				mRD_DONE	<=	1;
			end
		end
		else
		mRD_DONE	<=	0;
		
		if(Write)
		begin
			if(ST==SC_CL-1)
			IN_REQ	<=	1;
			else if(ST==SC_CL+mLENGTH-1)
			IN_REQ	<=	0;
			else if(ST==SC_CL+SC_RCD+mLENGTH)
			begin
				Write	<=	0;
				mWR_DONE<=	1;
			end
		end
		else
		mWR_DONE<=	0;

	end
end
//	Internal Address & Length Control
always@(posedge CLK or negedge RESET_N)
begin
	if(!RESET_N)
	begin
		rWR_ADDR		<=	WR_ADDR;
		rRD_ADDR		<=	RD_ADDR;
	end
	else
	begin
		//	Write Side 
		if(WR_LOAD)
			rWR_ADDR	<=	WR_ADDR;
		else if(mWR_DONE&WR_MASK)
		begin
			if(rWR_ADDR<WR_MAX_ADDR-WR_LENGTH)
			rWR_ADDR	<=	rWR_ADDR+WR_LENGTH;
			else
			rWR_ADDR	<=	WR_ADDR;
		end

		//	Read Side 
		if(RD_LOAD)
			rRD_ADDR	<=	RD_ADDR;
		else if(mRD_DONE&RD_MASK)
		begin
			if(rRD_ADDR<RD_MAX_ADDR-RD_LENGTH)
			rRD_ADDR	<=	rRD_ADDR+RD_LENGTH;
			else
			rRD_ADDR	<=	RD_ADDR;
		end
	end
end
//	Auto Read/Write Control
always@(posedge CLK or negedge RESET_N)
begin
	if(!RESET_N)
	begin
		mWR		<=	0;
		mRD		<=	0;
		mADDR	<=	0;
		mLENGTH	<=	0;
		WR_MASK <=	0;
		RD_MASK <=	0;
	end
	else
	begin
		if( (mWR==0) && (mRD==0) && (ST==0) &&
			(WR_MASK==0)	&&	(RD_MASK==0) &&
			(WR_LOAD==0)	&&	(RD_LOAD==0) &&(flag==1) )
		begin
		
					//	Write Side 
			 if( (write_side_fifo_rusedw >= WR_LENGTH) && (WR_LENGTH!=0) )
			begin
				mADDR	<=	rWR_ADDR;
				mLENGTH	<=	WR_LENGTH;
				WR_MASK	<=	1'b1;
				RD_MASK	<=	1'b0;
				mWR		<=	1;
				mRD		<=	0;
			end
			//	Read Side 
			else if( (read_side_fifo_wusedw < RD_LENGTH) )
			begin
				mADDR	<=	rRD_ADDR;
				mLENGTH	<=	RD_LENGTH;
				WR_MASK	<=	1'b0;
				RD_MASK	<=	1'b1;
				mWR		<=	0;
				mRD		<=	1;				
			end

		end
		if(mWR_DONE)
		begin
			WR_MASK	<=	0;
			mWR		<=	0;
		end
		if(mRD_DONE)
		begin
			RD_MASK	<=	0;
			mRD		<=	0;
		end
	end
end

endmodule
