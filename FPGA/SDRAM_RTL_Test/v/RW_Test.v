module RW_Test #(parameter ADDR_W = 25,
				parameter DATA_W  = 16)
(
        input                   iCLK,
		input                   iRST_n,
		input                   iBUTTON,
	    output reg              write,
		output reg [DATA_W-1:0] writedata,
        output     [ADDR_W-1:0] wr_addr,
	    output reg              read,
        output     [ADDR_W-1:0] rd_addr 
        );


//=======================================================
//  Signal declarations
//=======================================================
reg [6:0] seven_seg [9:0];

always@(*) begin
	seven_seg[0] = 7'b1000000; // 0
	seven_seg[1] = 7'b1111001; // 1
	seven_seg[2] = 7'b0100100; // 2
	seven_seg[3] = 7'b0110000; // 3
	seven_seg[4] = 7'b0011001; // 4
	seven_seg[5] = 7'b0010010; // 5
	seven_seg[6] = 7'b0000010; // 6
	seven_seg[7] = 7'b1111000; // 7
	seven_seg[8] = 7'b0000000; // 8 
	seven_seg[9] = 7'b0010000; // 9
end


reg             trigger;
reg [3:0]       c_state;
reg [3:0]       cnt;
reg [3:0]       write_en, read_en;
integer         wait_delay;

assign wr_addr = {{21{1'b0}},write_en};
assign rd_addr = {{21{1'b0}},read_en};

always@(posedge iCLK) begin
    if(!iRST_n) begin
        trigger  <= 1'b0;
        c_state  <= 4'b0;
        cnt      <= 4'b0;
        write_en <= 4'b0;
        read_en  <= 4'b0;
		wait_delay <= 0;
    end
    else begin
       trigger <= iBUTTON;
       case(c_state)
            0: begin // idle
                write_en <= 0;
                if(trigger) 
                    c_state <= 1;
				else	
					c_state <= 0; 
            end
            1: begin  // write
                if(write_en < 4'ha) begin
                    read_en <= 1'b0;
                    write <= 1'b1;
                    writedata <= {{8{1'b0}},seven_seg[cnt]};
                    c_state <= 1;
                    write_en <= write_en + 1;
                    cnt <= cnt + 1;
                end
                else begin
                    write <= 1'b0;
                    c_state <= 2; 
                    read_en <= 1'b1;
                end
            end
            2: begin  // start to read
                if(read_en < 4'ha) begin
                    read <= 1'b1;
                    c_state <= 3;
                    read_en <= read_en + 1;
                end
                else begin
                    c_state <= 4; 
                end
			end
            3: begin   // wait state in reading
                if(wait_delay < 32'd8_000_001) begin
                    read <= 1'b1;
					wait_delay <= wait_delay + 1;
                    c_state = 3;
				end
                else begin
                    read <= 1'b1;
                    c_state <= 2;
                end 
			end
            4:    c_state <= 4;     
            default : c_state <= 0;
			        
       endcase     

    end

end


endmodule 