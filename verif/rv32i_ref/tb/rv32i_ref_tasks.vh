task print_vga_ref_screen ;
// VGA memory snapshot - simulate a screen
    integer fd1;
    string draw;
    fd1 = $fopen({"../../../target/rv32i_ref/tests/",test_name,"/ref_screen.log"},"w");
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

task eot (string msg);
    #10;
    print_vga_ref_screen();
    $display("===============================");
    $display("End of simulation: %s", msg);
    $display("===============================");
    $finish;
endtask
