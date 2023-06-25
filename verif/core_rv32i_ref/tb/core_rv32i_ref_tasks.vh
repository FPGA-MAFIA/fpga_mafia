task print_vga_ref_screen ;
// VGA memory snapshot - simulate a screen
    integer fd1;
    string draw;
    fd1 = $fopen({"../../../target/core_rv32i_ref/ref_screen.log"},"w");
    if (fd1) $display("File was open successfully : %0d", fd1);
    else $display("File was not open successfully : %0d", fd1);
    for (int i = VGA_MEM_REGION_FLOOR ; i < VGA_MEM_REGION_ROOF; i = i+320) begin // Lines
        for (int j = 0 ; j < 4; j = j+1) begin // Bytes
            for (int k = 0 ; k < 320; k = k+4) begin // Words
                for (int l = 0 ; l < 8; l = l+1) begin // Bits  
                    draw = (core_rv32i_ref.VGAMem[k+j+i][l] === 1'b1) ? "x" : " ";
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
    trk_reg_write = $fopen({"../../../target/core_rv32i_ref/trk_reg_write_ref.log"},"w");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");
    $fwrite(trk_reg_write," Time |Instruction|     X0   ,  X1   ,  X2   ,  X3    ,  X4    ,  X5    ,  X6    ,  X7    ,  X8    ,  X9    ,  X10    , X11    , X12    , X13    , X14    , X15    , X16    , X17    , X18    , X19    , X20    , X21    , X22    , X23    , X24    , X25    , X26    , X27    , X28    , X29    , X30    , X31 \n");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");  
end
always_ff @(posedge Clk ) begin
    if(core_rv32i_ref.regfile!=core_rv32i_ref.next_regfile) begin        //0, 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
        $fwrite(trk_reg_write,"%6d | %8h | %8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h \n"
        ,$time,            core_rv32i_ref.instruction,
                           core_rv32i_ref.regfile[0],
                           core_rv32i_ref.regfile[1],
                           core_rv32i_ref.regfile[2],
                           core_rv32i_ref.regfile[3],
                           core_rv32i_ref.regfile[4],
                           core_rv32i_ref.regfile[5],
                           core_rv32i_ref.regfile[6],
                           core_rv32i_ref.regfile[7],
                           core_rv32i_ref.regfile[8],
                           core_rv32i_ref.regfile[9],
                           core_rv32i_ref.regfile[10],
                           core_rv32i_ref.regfile[11],
                           core_rv32i_ref.regfile[12],
                           core_rv32i_ref.regfile[13],
                           core_rv32i_ref.regfile[14],
                           core_rv32i_ref.regfile[15],
                           core_rv32i_ref.regfile[16],
                           core_rv32i_ref.regfile[17],
                           core_rv32i_ref.regfile[18],
                           core_rv32i_ref.regfile[19],
                           core_rv32i_ref.regfile[20],
                           core_rv32i_ref.regfile[21],
                           core_rv32i_ref.regfile[22],
                           core_rv32i_ref.regfile[23],
                           core_rv32i_ref.regfile[24],
                           core_rv32i_ref.regfile[25],
                           core_rv32i_ref.regfile[26],
                           core_rv32i_ref.regfile[27],
                           core_rv32i_ref.regfile[28],
                           core_rv32i_ref.regfile[29],
                           core_rv32i_ref.regfile[30],
                           core_rv32i_ref.regfile[31]
                           );
    end
    
end

