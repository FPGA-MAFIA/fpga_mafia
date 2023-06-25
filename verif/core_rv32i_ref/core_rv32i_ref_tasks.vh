task print_vga_ref_screen ;
// VGA memory snapshot - simulate a screen
    integer fd1;
    string draw;
    fd1 = $fopen({"../../../target/mini_core/ref_screen.log"},"w");
    if (fd1) $display("File was open successfully : %0d", fd1);
    else $display("File was not open successfully : %0d", fd1);
    for (int i = 0 ; i < SIZE_VGA_MEM; i = i+320) begin // Lines
        for (int j = 0 ; j < 4; j = j+1) begin // Bytes
            for (int k = 0 ; k < 320; k = k+4) begin // Words
                for (int l = 0 ; l < 8; l = l+1) begin // Bits  
                    draw = (big_core_top.big_core_mem_wrap.big_core_vga_ctrl.vga_mem.VGAMem[k+j+i][l] === 1'b1) ? "x" : " ";
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
    trk_reg_write = $fopen({"../../../target/mini_core/trk_reg_write_ref.log"},"w");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");
    $fwrite(trk_reg_write," Time |Instruction|     X0   ,  X1   ,  X2   ,  X3    ,  X4    ,  X5    ,  X6    ,  X7    ,  X8    ,  X9    ,  X10    , X11    , X12    , X13    , X14    , X15    , X16    , X17    , X18    , X19    , X20    , X21    , X22    , X23    , X24    , X25    , X26    , X27    , X28    , X29    , X30    , X31 \n");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");  
end
always_ff @(posedge clk ) begin
    if(regfile!=next_regfile) begin        //0, 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
        $fwrite(trk_reg_write,"%6d | %8h | %8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h \n"
        ,$time,instruction,regfile[0],
                           regfile[1],
                           regfile[2],
                           regfile[3],
                           regfile[4],
                           regfile[5],
                           regfile[6],
                           regfile[7],
                           regfile[8],
                           regfile[9],
                           regfile[10],
                           regfile[11],
                           regfile[12],
                           regfile[13],
                           regfile[14],
                           regfile[15],
                           regfile[16],
                           regfile[17],
                           regfile[18],
                           regfile[19],
                           regfile[20],
                           regfile[21],
                           regfile[22],
                           regfile[23],
                           regfile[24],
                           regfile[25],
                           regfile[26],
                           regfile[27],
                           regfile[28],
                           regfile[29],
                           regfile[30],
                           regfile[31]
                           );
    end
    
end

