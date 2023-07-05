task print_vga_ref_screen ;
// VGA memory snapshot - simulate a screen
    integer fd1;
    string draw;
    fd1 = $fopen({"../../../target/rv32i_ref/ref_screen.log"},"w");
    if (fd1) $display("File was open successfully : %0d", fd1);
    else $display("File was not open successfully : %0d", fd1);
    for (int i = VGA_MEM_REGION_FLOOR ; i < VGA_MEM_REGION_ROOF; i = i+320) begin // Lines
        for (int j = 0 ; j < 4; j = j+1) begin // Bytes
            for (int k = 0 ; k < 320; k = k+4) begin // Words
                for (int l = 0 ; l < 8; l = l+1) begin // Bits  
                    draw = (rv32i_ref.VGAMem[k+j+i][l] === 1'b1) ? "x" : " ";
                    $fwrite(fd1,"%s",draw);
                end        
            end 
            $fwrite(fd1,"\n");
        end
    end
endtask

integer trk_reg_write;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_reg_write = $fopen({"../../../target/rv32i_ref/trk_reg_write_ref.log"},"w");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");
    $fwrite(trk_reg_write," Time | PC |Instruction|  ENUM |reg_dst|  X0   ,  X1   ,  X2   ,  X3    ,  X4    ,  X5    ,  X6    ,  X7    ,  X8    ,  X9    ,  X10    , X11    , X12    , X13    , X14    , X15    , X16    , X17    , X18    , X19    , X20    , X21    , X22    , X23    , X24    , X25    , X26    , X27    , X28    , X29    , X30    , X31 \n");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");  
end

always_ff @(posedge Clk ) begin
        $fwrite(trk_reg_write,"%6d | %4h |  %8h |%7s | %2d | %8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h \n"
        ,$time,            
                           rv32i_ref.pc,
                           rv32i_ref.instruction,
                           rv32i_ref.instr_type,
                           rv32i_ref.rd,
                           rv32i_ref.regfile[0],
                           rv32i_ref.regfile[1],
                           rv32i_ref.regfile[2],
                           rv32i_ref.regfile[3],
                           rv32i_ref.regfile[4],
                           rv32i_ref.regfile[5],
                           rv32i_ref.regfile[6],
                           rv32i_ref.regfile[7],
                           rv32i_ref.regfile[8],
                           rv32i_ref.regfile[9],
                           rv32i_ref.regfile[10],
                           rv32i_ref.regfile[11],
                           rv32i_ref.regfile[12],
                           rv32i_ref.regfile[13],
                           rv32i_ref.regfile[14],
                           rv32i_ref.regfile[15],
                           rv32i_ref.regfile[16],
                           rv32i_ref.regfile[17],
                           rv32i_ref.regfile[18],
                           rv32i_ref.regfile[19],
                           rv32i_ref.regfile[20],
                           rv32i_ref.regfile[21],
                           rv32i_ref.regfile[22],
                           rv32i_ref.regfile[23],
                           rv32i_ref.regfile[24],
                           rv32i_ref.regfile[25],
                           rv32i_ref.regfile[26],
                           rv32i_ref.regfile[27],
                           rv32i_ref.regfile[28],
                           rv32i_ref.regfile[29],
                           rv32i_ref.regfile[30],
                           rv32i_ref.regfile[31]
                           );
end

initial begin: check_eot
    forever begin
        #10 
        if(rv32i_ref.ebreak_was_called)   eot("ebreak_was_called");
        if(rv32i_ref.ecall_was_called)    eot("ecall_was_called");
        if(rv32i_ref.illegal_instruction) eot("ERROR: illegal_instruction");
    end
end
task eot (string msg);
    #10;
    print_vga_ref_screen();
    $display("===============================");
    $display("End of simulation: %s", msg);
    $display("===============================");
    $finish;
endtask
