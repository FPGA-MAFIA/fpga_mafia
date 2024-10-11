package accel_core_pkg;

    /****************************************CR SPACE*******************************/

    // Define CR memory sizes
    parameter CR_MEM_OFFSET       = 'h00FE_0000;
    parameter CR_MEM_REGION_FLOOR = CR_MEM_OFFSET;
    parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;

    // Region bits
    parameter LSB_REGION = 0;
    parameter MSB_REGION = 23;

    // CR Address Offsets

    parameter CR_XOR_IN_1 = CR_MEM_OFFSET + 'h200 ;
    parameter CR_XOR_IN_2 = CR_MEM_OFFSET + 'h204 ;
    parameter CR_XOR_OUT = CR_MEM_OFFSET + 'h208 ;
    
 // ============================================================================
// CR_MUL_IN Split into 63 x 32-bit Parameters
// ============================================================================
    parameter CR_MUL_IN_META = CR_MEM_OFFSET + 'h20C;

    parameter CR_MUL_IN_0  = CR_MEM_OFFSET + 'h210;
    parameter CR_MUL_IN_1  = CR_MEM_OFFSET + 'h214;
    parameter CR_MUL_IN_2  = CR_MEM_OFFSET + 'h218;
    parameter CR_MUL_IN_3  = CR_MEM_OFFSET + 'h21C;
    parameter CR_MUL_IN_4  = CR_MEM_OFFSET + 'h220;
    parameter CR_MUL_IN_5  = CR_MEM_OFFSET + 'h224;
    parameter CR_MUL_IN_6  = CR_MEM_OFFSET + 'h228;
    parameter CR_MUL_IN_7  = CR_MEM_OFFSET + 'h22C;
    parameter CR_MUL_IN_8  = CR_MEM_OFFSET + 'h230;
    parameter CR_MUL_IN_9  = CR_MEM_OFFSET + 'h234;
    parameter CR_MUL_IN_10 = CR_MEM_OFFSET + 'h238;
    parameter CR_MUL_IN_11 = CR_MEM_OFFSET + 'h23C;
    parameter CR_MUL_IN_12 = CR_MEM_OFFSET + 'h240;
    parameter CR_MUL_IN_13 = CR_MEM_OFFSET + 'h244;
    parameter CR_MUL_IN_14 = CR_MEM_OFFSET + 'h248;
    parameter CR_MUL_IN_15 = CR_MEM_OFFSET + 'h24C;
    parameter CR_MUL_IN_16 = CR_MEM_OFFSET + 'h250;
    parameter CR_MUL_IN_17 = CR_MEM_OFFSET + 'h254;
    parameter CR_MUL_IN_18 = CR_MEM_OFFSET + 'h258;
    parameter CR_MUL_IN_19 = CR_MEM_OFFSET + 'h25C;
    parameter CR_MUL_IN_20 = CR_MEM_OFFSET + 'h260;
    parameter CR_MUL_IN_21 = CR_MEM_OFFSET + 'h264;
    parameter CR_MUL_IN_22 = CR_MEM_OFFSET + 'h268;
    parameter CR_MUL_IN_23 = CR_MEM_OFFSET + 'h26C;
    parameter CR_MUL_IN_24 = CR_MEM_OFFSET + 'h270;
    parameter CR_MUL_IN_25 = CR_MEM_OFFSET + 'h274;
    parameter CR_MUL_IN_26 = CR_MEM_OFFSET + 'h278;
    parameter CR_MUL_IN_27 = CR_MEM_OFFSET + 'h27C;
    parameter CR_MUL_IN_28 = CR_MEM_OFFSET + 'h280;
    parameter CR_MUL_IN_29 = CR_MEM_OFFSET + 'h284;
    parameter CR_MUL_IN_30 = CR_MEM_OFFSET + 'h288;
    parameter CR_MUL_IN_31 = CR_MEM_OFFSET + 'h28C;
    parameter CR_MUL_IN_32 = CR_MEM_OFFSET + 'h290;
    parameter CR_MUL_IN_33 = CR_MEM_OFFSET + 'h294;
    parameter CR_MUL_IN_34 = CR_MEM_OFFSET + 'h298;
    parameter CR_MUL_IN_35 = CR_MEM_OFFSET + 'h29C;
    parameter CR_MUL_IN_36 = CR_MEM_OFFSET + 'h2A0;
    parameter CR_MUL_IN_37 = CR_MEM_OFFSET + 'h2A4;
    parameter CR_MUL_IN_38 = CR_MEM_OFFSET + 'h2A8;
    parameter CR_MUL_IN_39 = CR_MEM_OFFSET + 'h2AC;
    parameter CR_MUL_IN_40 = CR_MEM_OFFSET + 'h2B0;
    parameter CR_MUL_IN_41 = CR_MEM_OFFSET + 'h2B4;
    parameter CR_MUL_IN_42 = CR_MEM_OFFSET + 'h2B8;
    parameter CR_MUL_IN_43 = CR_MEM_OFFSET + 'h2BC;
    parameter CR_MUL_IN_44 = CR_MEM_OFFSET + 'h2C0;
    parameter CR_MUL_IN_45 = CR_MEM_OFFSET + 'h2C4;
    parameter CR_MUL_IN_46 = CR_MEM_OFFSET + 'h2C8;
    parameter CR_MUL_IN_47 = CR_MEM_OFFSET + 'h2CC;
    parameter CR_MUL_IN_48 = CR_MEM_OFFSET + 'h2D0;
    parameter CR_MUL_IN_49 = CR_MEM_OFFSET + 'h2D4;
    parameter CR_MUL_IN_50 = CR_MEM_OFFSET + 'h2D8;
    parameter CR_MUL_IN_51 = CR_MEM_OFFSET + 'h2DC;
    parameter CR_MUL_IN_52 = CR_MEM_OFFSET + 'h2E0;
    parameter CR_MUL_IN_53 = CR_MEM_OFFSET + 'h2E4;
    parameter CR_MUL_IN_54 = CR_MEM_OFFSET + 'h2E8;
    parameter CR_MUL_IN_55 = CR_MEM_OFFSET + 'h2EC;
    parameter CR_MUL_IN_56 = CR_MEM_OFFSET + 'h2F0;
    parameter CR_MUL_IN_57 = CR_MEM_OFFSET + 'h2F4;
    parameter CR_MUL_IN_58 = CR_MEM_OFFSET + 'h2F8;
    parameter CR_MUL_IN_59 = CR_MEM_OFFSET + 'h2FC;
    parameter CR_MUL_IN_60 = CR_MEM_OFFSET + 'h300;
    parameter CR_MUL_IN_61 = CR_MEM_OFFSET + 'h304;
    parameter CR_MUL_IN_62 = CR_MEM_OFFSET + 'h308;

    // ============================================================================
    // CR_MUL_W1 Split into 63 x 32-bit Parameters
    // ============================================================================
    parameter CR_MUL_W1_META = CR_MEM_OFFSET + 'h30C;

    parameter CR_MUL_W1_0  = CR_MEM_OFFSET + 'h310;
    parameter CR_MUL_W1_1  = CR_MEM_OFFSET + 'h314;
    parameter CR_MUL_W1_2  = CR_MEM_OFFSET + 'h318;
    parameter CR_MUL_W1_3  = CR_MEM_OFFSET + 'h31C;
    parameter CR_MUL_W1_4  = CR_MEM_OFFSET + 'h320;
    parameter CR_MUL_W1_5  = CR_MEM_OFFSET + 'h324;
    parameter CR_MUL_W1_6  = CR_MEM_OFFSET + 'h328;
    parameter CR_MUL_W1_7  = CR_MEM_OFFSET + 'h32C;
    parameter CR_MUL_W1_8  = CR_MEM_OFFSET + 'h330;
    parameter CR_MUL_W1_9  = CR_MEM_OFFSET + 'h334;
    parameter CR_MUL_W1_10 = CR_MEM_OFFSET + 'h338;
    parameter CR_MUL_W1_11 = CR_MEM_OFFSET + 'h33C;
    parameter CR_MUL_W1_12 = CR_MEM_OFFSET + 'h340;
    parameter CR_MUL_W1_13 = CR_MEM_OFFSET + 'h344;
    parameter CR_MUL_W1_14 = CR_MEM_OFFSET + 'h348;
    parameter CR_MUL_W1_15 = CR_MEM_OFFSET + 'h34C;
    parameter CR_MUL_W1_16 = CR_MEM_OFFSET + 'h350;
    parameter CR_MUL_W1_17 = CR_MEM_OFFSET + 'h354;
    parameter CR_MUL_W1_18 = CR_MEM_OFFSET + 'h358;
    parameter CR_MUL_W1_19 = CR_MEM_OFFSET + 'h35C;
    parameter CR_MUL_W1_20 = CR_MEM_OFFSET + 'h360;
    parameter CR_MUL_W1_21 = CR_MEM_OFFSET + 'h364;
    parameter CR_MUL_W1_22 = CR_MEM_OFFSET + 'h368;
    parameter CR_MUL_W1_23 = CR_MEM_OFFSET + 'h36C;
    parameter CR_MUL_W1_24 = CR_MEM_OFFSET + 'h370;
    parameter CR_MUL_W1_25 = CR_MEM_OFFSET + 'h374;
    parameter CR_MUL_W1_26 = CR_MEM_OFFSET + 'h378;
    parameter CR_MUL_W1_27 = CR_MEM_OFFSET + 'h37C;
    parameter CR_MUL_W1_28 = CR_MEM_OFFSET + 'h380;
    parameter CR_MUL_W1_29 = CR_MEM_OFFSET + 'h384;
    parameter CR_MUL_W1_30 = CR_MEM_OFFSET + 'h388;
    parameter CR_MUL_W1_31 = CR_MEM_OFFSET + 'h38C;
    parameter CR_MUL_W1_32 = CR_MEM_OFFSET + 'h390;
    parameter CR_MUL_W1_33 = CR_MEM_OFFSET + 'h394;
    parameter CR_MUL_W1_34 = CR_MEM_OFFSET + 'h398;
    parameter CR_MUL_W1_35 = CR_MEM_OFFSET + 'h39C;
    parameter CR_MUL_W1_36 = CR_MEM_OFFSET + 'h3A0;
    parameter CR_MUL_W1_37 = CR_MEM_OFFSET + 'h3A4;
    parameter CR_MUL_W1_38 = CR_MEM_OFFSET + 'h3A8;
    parameter CR_MUL_W1_39 = CR_MEM_OFFSET + 'h3AC;
    parameter CR_MUL_W1_40 = CR_MEM_OFFSET + 'h3B0;
    parameter CR_MUL_W1_41 = CR_MEM_OFFSET + 'h3B4;
    parameter CR_MUL_W1_42 = CR_MEM_OFFSET + 'h3B8;
    parameter CR_MUL_W1_43 = CR_MEM_OFFSET + 'h3BC;
    parameter CR_MUL_W1_44 = CR_MEM_OFFSET + 'h3C0;
    parameter CR_MUL_W1_45 = CR_MEM_OFFSET + 'h3C4;
    parameter CR_MUL_W1_46 = CR_MEM_OFFSET + 'h3C8;
    parameter CR_MUL_W1_47 = CR_MEM_OFFSET + 'h3CC;
    parameter CR_MUL_W1_48 = CR_MEM_OFFSET + 'h3D0;
    parameter CR_MUL_W1_49 = CR_MEM_OFFSET + 'h3D4;
    parameter CR_MUL_W1_50 = CR_MEM_OFFSET + 'h3D8;
    parameter CR_MUL_W1_51 = CR_MEM_OFFSET + 'h3DC;
    parameter CR_MUL_W1_52 = CR_MEM_OFFSET + 'h3E0;
    parameter CR_MUL_W1_53 = CR_MEM_OFFSET + 'h3E4;
    parameter CR_MUL_W1_54 = CR_MEM_OFFSET + 'h3E8;
    parameter CR_MUL_W1_55 = CR_MEM_OFFSET + 'h3EC;
    parameter CR_MUL_W1_56 = CR_MEM_OFFSET + 'h3F0;
    parameter CR_MUL_W1_57 = CR_MEM_OFFSET + 'h3F4;
    parameter CR_MUL_W1_58 = CR_MEM_OFFSET + 'h3F8;
    parameter CR_MUL_W1_59 = CR_MEM_OFFSET + 'h3FC;
    parameter CR_MUL_W1_60 = CR_MEM_OFFSET + 'h400;
    parameter CR_MUL_W1_61 = CR_MEM_OFFSET + 'h404;
    parameter CR_MUL_W1_62 = CR_MEM_OFFSET + 'h408;

    // ============================================================================
    // CR_MUL_W2 Split into 63 x 32-bit Parameters
    // ============================================================================
    parameter CR_MUL_W2_META = CR_MEM_OFFSET + 'h40C;

    parameter CR_MUL_W2_0  = CR_MEM_OFFSET + 'h410;
    parameter CR_MUL_W2_1  = CR_MEM_OFFSET + 'h414;
    parameter CR_MUL_W2_2  = CR_MEM_OFFSET + 'h418;
    parameter CR_MUL_W2_3  = CR_MEM_OFFSET + 'h41C;
    parameter CR_MUL_W2_4  = CR_MEM_OFFSET + 'h420;
    parameter CR_MUL_W2_5  = CR_MEM_OFFSET + 'h424;
    parameter CR_MUL_W2_6  = CR_MEM_OFFSET + 'h428;
    parameter CR_MUL_W2_7  = CR_MEM_OFFSET + 'h42C;
    parameter CR_MUL_W2_8  = CR_MEM_OFFSET + 'h430;
    parameter CR_MUL_W2_9  = CR_MEM_OFFSET + 'h434;
    parameter CR_MUL_W2_10 = CR_MEM_OFFSET + 'h438;
    parameter CR_MUL_W2_11 = CR_MEM_OFFSET + 'h43C;
    parameter CR_MUL_W2_12 = CR_MEM_OFFSET + 'h440;
    parameter CR_MUL_W2_13 = CR_MEM_OFFSET + 'h444;
    parameter CR_MUL_W2_14 = CR_MEM_OFFSET + 'h448;
    parameter CR_MUL_W2_15 = CR_MEM_OFFSET + 'h44C;
    parameter CR_MUL_W2_16 = CR_MEM_OFFSET + 'h450;
    parameter CR_MUL_W2_17 = CR_MEM_OFFSET + 'h454;
    parameter CR_MUL_W2_18 = CR_MEM_OFFSET + 'h458;
    parameter CR_MUL_W2_19 = CR_MEM_OFFSET + 'h45C;
    parameter CR_MUL_W2_20 = CR_MEM_OFFSET + 'h460;
    parameter CR_MUL_W2_21 = CR_MEM_OFFSET + 'h464;
    parameter CR_MUL_W2_22 = CR_MEM_OFFSET + 'h468;
    parameter CR_MUL_W2_23 = CR_MEM_OFFSET + 'h46C;
    parameter CR_MUL_W2_24 = CR_MEM_OFFSET + 'h470;
    parameter CR_MUL_W2_25 = CR_MEM_OFFSET + 'h474;
    parameter CR_MUL_W2_26 = CR_MEM_OFFSET + 'h478;
    parameter CR_MUL_W2_27 = CR_MEM_OFFSET + 'h47C;
    parameter CR_MUL_W2_28 = CR_MEM_OFFSET + 'h480;
    parameter CR_MUL_W2_29 = CR_MEM_OFFSET + 'h484;
    parameter CR_MUL_W2_30 = CR_MEM_OFFSET + 'h488;
    parameter CR_MUL_W2_31 = CR_MEM_OFFSET + 'h48C;
    parameter CR_MUL_W2_32 = CR_MEM_OFFSET + 'h490;
    parameter CR_MUL_W2_33 = CR_MEM_OFFSET + 'h494;
    parameter CR_MUL_W2_34 = CR_MEM_OFFSET + 'h498;
    parameter CR_MUL_W2_35 = CR_MEM_OFFSET + 'h49C;
    parameter CR_MUL_W2_36 = CR_MEM_OFFSET + 'h4A0;
    parameter CR_MUL_W2_37 = CR_MEM_OFFSET + 'h4A4;
    parameter CR_MUL_W2_38 = CR_MEM_OFFSET + 'h4A8;
    parameter CR_MUL_W2_39 = CR_MEM_OFFSET + 'h4AC;
    parameter CR_MUL_W2_40 = CR_MEM_OFFSET + 'h4B0;
    parameter CR_MUL_W2_41 = CR_MEM_OFFSET + 'h4B4;
    parameter CR_MUL_W2_42 = CR_MEM_OFFSET + 'h4B8;
    parameter CR_MUL_W2_43 = CR_MEM_OFFSET + 'h4BC;
    parameter CR_MUL_W2_44 = CR_MEM_OFFSET + 'h4C0;
    parameter CR_MUL_W2_45 = CR_MEM_OFFSET + 'h4C4;
    parameter CR_MUL_W2_46 = CR_MEM_OFFSET + 'h4C8;
    parameter CR_MUL_W2_47 = CR_MEM_OFFSET + 'h4CC;
    parameter CR_MUL_W2_48 = CR_MEM_OFFSET + 'h4D0;
    parameter CR_MUL_W2_49 = CR_MEM_OFFSET + 'h4D4;
    parameter CR_MUL_W2_50 = CR_MEM_OFFSET + 'h4D8;
    parameter CR_MUL_W2_51 = CR_MEM_OFFSET + 'h4DC;
    parameter CR_MUL_W2_52 = CR_MEM_OFFSET + 'h4E0;
    parameter CR_MUL_W2_53 = CR_MEM_OFFSET + 'h4E4;
    parameter CR_MUL_W2_54 = CR_MEM_OFFSET + 'h4E8;
    parameter CR_MUL_W2_55 = CR_MEM_OFFSET + 'h4EC;
    parameter CR_MUL_W2_56 = CR_MEM_OFFSET + 'h4F0;
    parameter CR_MUL_W2_57 = CR_MEM_OFFSET + 'h4F4;
    parameter CR_MUL_W2_58 = CR_MEM_OFFSET + 'h4F8;
    parameter CR_MUL_W2_59 = CR_MEM_OFFSET + 'h4FC;
    parameter CR_MUL_W2_60 = CR_MEM_OFFSET + 'h500;
    parameter CR_MUL_W2_61 = CR_MEM_OFFSET + 'h504;
    parameter CR_MUL_W2_62 = CR_MEM_OFFSET + 'h508;

    // ============================================================================
    // CR_MUL_Buffer1 Split into 63 x 32-bit Parameters
    // ============================================================================
    parameter CR_MUL_Buffer1_META = CR_MEM_OFFSET + 'h50C;

    parameter CR_MUL_Buffer1_0  = CR_MEM_OFFSET + 'h510;
    parameter CR_MUL_Buffer1_1  = CR_MEM_OFFSET + 'h514;
    parameter CR_MUL_Buffer1_2  = CR_MEM_OFFSET + 'h518;
    parameter CR_MUL_Buffer1_3  = CR_MEM_OFFSET + 'h51C;
    parameter CR_MUL_Buffer1_4  = CR_MEM_OFFSET + 'h520;
    parameter CR_MUL_Buffer1_5  = CR_MEM_OFFSET + 'h524;
    parameter CR_MUL_Buffer1_6  = CR_MEM_OFFSET + 'h528;
    parameter CR_MUL_Buffer1_7  = CR_MEM_OFFSET + 'h52C;
    parameter CR_MUL_Buffer1_8  = CR_MEM_OFFSET + 'h530;
    parameter CR_MUL_Buffer1_9  = CR_MEM_OFFSET + 'h534;
    parameter CR_MUL_Buffer1_10 = CR_MEM_OFFSET + 'h538;
    parameter CR_MUL_Buffer1_11 = CR_MEM_OFFSET + 'h53C;
    parameter CR_MUL_Buffer1_12 = CR_MEM_OFFSET + 'h540;
    parameter CR_MUL_Buffer1_13 = CR_MEM_OFFSET + 'h544;
    parameter CR_MUL_Buffer1_14 = CR_MEM_OFFSET + 'h548;
    parameter CR_MUL_Buffer1_15 = CR_MEM_OFFSET + 'h54C;
    parameter CR_MUL_Buffer1_16 = CR_MEM_OFFSET + 'h550;
    parameter CR_MUL_Buffer1_17 = CR_MEM_OFFSET + 'h554;
    parameter CR_MUL_Buffer1_18 = CR_MEM_OFFSET + 'h558;
    parameter CR_MUL_Buffer1_19 = CR_MEM_OFFSET + 'h55C;
    parameter CR_MUL_Buffer1_20 = CR_MEM_OFFSET + 'h560;
    parameter CR_MUL_Buffer1_21 = CR_MEM_OFFSET + 'h564;
    parameter CR_MUL_Buffer1_22 = CR_MEM_OFFSET + 'h568;
    parameter CR_MUL_Buffer1_23 = CR_MEM_OFFSET + 'h56C;
    parameter CR_MUL_Buffer1_24 = CR_MEM_OFFSET + 'h570;
    parameter CR_MUL_Buffer1_25 = CR_MEM_OFFSET + 'h574;
    parameter CR_MUL_Buffer1_26 = CR_MEM_OFFSET + 'h578;
    parameter CR_MUL_Buffer1_27 = CR_MEM_OFFSET + 'h57C;
    parameter CR_MUL_Buffer1_28 = CR_MEM_OFFSET + 'h580;
    parameter CR_MUL_Buffer1_29 = CR_MEM_OFFSET + 'h584;
    parameter CR_MUL_Buffer1_30 = CR_MEM_OFFSET + 'h588;
    parameter CR_MUL_Buffer1_31 = CR_MEM_OFFSET + 'h58C;
    parameter CR_MUL_Buffer1_32 = CR_MEM_OFFSET + 'h590;
    parameter CR_MUL_Buffer1_33 = CR_MEM_OFFSET + 'h594;
    parameter CR_MUL_Buffer1_34 = CR_MEM_OFFSET + 'h598;
    parameter CR_MUL_Buffer1_35 = CR_MEM_OFFSET + 'h59C;
    parameter CR_MUL_Buffer1_36 = CR_MEM_OFFSET + 'h5A0;
    parameter CR_MUL_Buffer1_37 = CR_MEM_OFFSET + 'h5A4;
    parameter CR_MUL_Buffer1_38 = CR_MEM_OFFSET + 'h5A8;
    parameter CR_MUL_Buffer1_39 = CR_MEM_OFFSET + 'h5AC;
    parameter CR_MUL_Buffer1_40 = CR_MEM_OFFSET + 'h5B0;
    parameter CR_MUL_Buffer1_41 = CR_MEM_OFFSET + 'h5B4;
    parameter CR_MUL_Buffer1_42 = CR_MEM_OFFSET + 'h5B8;
    parameter CR_MUL_Buffer1_43 = CR_MEM_OFFSET + 'h5BC;
    parameter CR_MUL_Buffer1_44 = CR_MEM_OFFSET + 'h5C0;
    parameter CR_MUL_Buffer1_45 = CR_MEM_OFFSET + 'h5C4;
    parameter CR_MUL_Buffer1_46 = CR_MEM_OFFSET + 'h5C8;
    parameter CR_MUL_Buffer1_47 = CR_MEM_OFFSET + 'h5CC;
    parameter CR_MUL_Buffer1_48 = CR_MEM_OFFSET + 'h5D0;
    parameter CR_MUL_Buffer1_49 = CR_MEM_OFFSET + 'h5D4;
    parameter CR_MUL_Buffer1_50 = CR_MEM_OFFSET + 'h5D8;
    parameter CR_MUL_Buffer1_51 = CR_MEM_OFFSET + 'h5DC;
    parameter CR_MUL_Buffer1_52 = CR_MEM_OFFSET + 'h5E0;
    parameter CR_MUL_Buffer1_53 = CR_MEM_OFFSET + 'h5E4;
    parameter CR_MUL_Buffer1_54 = CR_MEM_OFFSET + 'h5E8;
    parameter CR_MUL_Buffer1_55 = CR_MEM_OFFSET + 'h5EC;
    parameter CR_MUL_Buffer1_56 = CR_MEM_OFFSET + 'h5F0;
    parameter CR_MUL_Buffer1_57 = CR_MEM_OFFSET + 'h5F4;
    parameter CR_MUL_Buffer1_58 = CR_MEM_OFFSET + 'h5F8;
    parameter CR_MUL_Buffer1_59 = CR_MEM_OFFSET + 'h5FC;
    parameter CR_MUL_Buffer1_60 = CR_MEM_OFFSET + 'h600;
    parameter CR_MUL_Buffer1_61 = CR_MEM_OFFSET + 'h604;
    parameter CR_MUL_Buffer1_62 = CR_MEM_OFFSET + 'h608;

    // ============================================================================
    // CR_MUL_OUT Split into 63 x 32-bit Parameters
    // ============================================================================
    parameter CR_MUL_OUT_META   = CR_MEM_OFFSET + 'h60C;

    parameter CR_MUL_OUT_0  = CR_MEM_OFFSET + 'h610;
    parameter CR_MUL_OUT_1  = CR_MEM_OFFSET + 'h614;
    parameter CR_MUL_OUT_2  = CR_MEM_OFFSET + 'h618;
    parameter CR_MUL_OUT_3  = CR_MEM_OFFSET + 'h61C;
    parameter CR_MUL_OUT_4  = CR_MEM_OFFSET + 'h620;
    parameter CR_MUL_OUT_5  = CR_MEM_OFFSET + 'h624;
    parameter CR_MUL_OUT_6  = CR_MEM_OFFSET + 'h628;
    parameter CR_MUL_OUT_7  = CR_MEM_OFFSET + 'h62C;
    parameter CR_MUL_OUT_8  = CR_MEM_OFFSET + 'h630;
    parameter CR_MUL_OUT_9  = CR_MEM_OFFSET + 'h634;
    parameter CR_MUL_OUT_10 = CR_MEM_OFFSET + 'h638;
    parameter CR_MUL_OUT_11 = CR_MEM_OFFSET + 'h63C;
    parameter CR_MUL_OUT_12 = CR_MEM_OFFSET + 'h640;
    parameter CR_MUL_OUT_13 = CR_MEM_OFFSET + 'h644;
    parameter CR_MUL_OUT_14 = CR_MEM_OFFSET + 'h648;
    parameter CR_MUL_OUT_15 = CR_MEM_OFFSET + 'h64C;
    parameter CR_MUL_OUT_16 = CR_MEM_OFFSET + 'h650;
    parameter CR_MUL_OUT_17 = CR_MEM_OFFSET + 'h654;
    parameter CR_MUL_OUT_18 = CR_MEM_OFFSET + 'h658;
    parameter CR_MUL_OUT_19 = CR_MEM_OFFSET + 'h65C;
    parameter CR_MUL_OUT_20 = CR_MEM_OFFSET + 'h660;
    parameter CR_MUL_OUT_21 = CR_MEM_OFFSET + 'h664;
    parameter CR_MUL_OUT_22 = CR_MEM_OFFSET + 'h668;
    parameter CR_MUL_OUT_23 = CR_MEM_OFFSET + 'h66C;
    parameter CR_MUL_OUT_24 = CR_MEM_OFFSET + 'h670;
    parameter CR_MUL_OUT_25 = CR_MEM_OFFSET + 'h674;
    parameter CR_MUL_OUT_26 = CR_MEM_OFFSET + 'h678;
    parameter CR_MUL_OUT_27 = CR_MEM_OFFSET + 'h67C;
    parameter CR_MUL_OUT_28 = CR_MEM_OFFSET + 'h680;
    parameter CR_MUL_OUT_29 = CR_MEM_OFFSET + 'h684;
    parameter CR_MUL_OUT_30 = CR_MEM_OFFSET + 'h688;
    parameter CR_MUL_OUT_31 = CR_MEM_OFFSET + 'h68C;
    parameter CR_MUL_OUT_32 = CR_MEM_OFFSET + 'h690;
    parameter CR_MUL_OUT_33 = CR_MEM_OFFSET + 'h694;
    parameter CR_MUL_OUT_34 = CR_MEM_OFFSET + 'h698;
    parameter CR_MUL_OUT_35 = CR_MEM_OFFSET + 'h69C;
    parameter CR_MUL_OUT_36 = CR_MEM_OFFSET + 'h6A0;
    parameter CR_MUL_OUT_37 = CR_MEM_OFFSET + 'h6A4;
    parameter CR_MUL_OUT_38 = CR_MEM_OFFSET + 'h6A8;
    parameter CR_MUL_OUT_39 = CR_MEM_OFFSET + 'h6AC;
    parameter CR_MUL_OUT_40 = CR_MEM_OFFSET + 'h6B0;
    parameter CR_MUL_OUT_41 = CR_MEM_OFFSET + 'h6B4;
    parameter CR_MUL_OUT_42 = CR_MEM_OFFSET + 'h6B8;
    parameter CR_MUL_OUT_43 = CR_MEM_OFFSET + 'h6BC;
    parameter CR_MUL_OUT_44 = CR_MEM_OFFSET + 'h6C0;
    parameter CR_MUL_OUT_45 = CR_MEM_OFFSET + 'h6C4;
    parameter CR_MUL_OUT_46 = CR_MEM_OFFSET + 'h6C8;
    parameter CR_MUL_OUT_47 = CR_MEM_OFFSET + 'h6CC;
    parameter CR_MUL_OUT_48 = CR_MEM_OFFSET + 'h6D0;
    parameter CR_MUL_OUT_49 = CR_MEM_OFFSET + 'h6D4;
    parameter CR_MUL_OUT_50 = CR_MEM_OFFSET + 'h6D8;
    parameter CR_MUL_OUT_51 = CR_MEM_OFFSET + 'h6DC;
    parameter CR_MUL_OUT_52 = CR_MEM_OFFSET + 'h6E0;
    parameter CR_MUL_OUT_53 = CR_MEM_OFFSET + 'h6E4;
    parameter CR_MUL_OUT_54 = CR_MEM_OFFSET + 'h6E8;
    parameter CR_MUL_OUT_55 = CR_MEM_OFFSET + 'h6EC;
    parameter CR_MUL_OUT_56 = CR_MEM_OFFSET + 'h6F0;
    parameter CR_MUL_OUT_57 = CR_MEM_OFFSET + 'h6F4;
    parameter CR_MUL_OUT_58 = CR_MEM_OFFSET + 'h6F8;
    parameter CR_MUL_OUT_59 = CR_MEM_OFFSET + 'h6FC;
    parameter CR_MUL_OUT_60 = CR_MEM_OFFSET + 'h700;
    parameter CR_MUL_OUT_61 = CR_MEM_OFFSET + 'h704;
    parameter CR_MUL_OUT_62 = CR_MEM_OFFSET + 'h708;

    // ============================================================================
    // CR_MUL_OUT_READY Parameter
    // ============================================================================
    parameter CR_MUL_OUT_READY = CR_MEM_OFFSET + 'h70C;



    typedef struct packed {
        logic in_use;
        logic [7:0] neuron_idx;  // the output index (Weight Matrix Column)
        logic [7:0] input_len;  // this is the actual number of weights in the buffer
    } t_metadata_weights;

    typedef struct packed {
        logic in_use;
        logic mov_out_to_in;
        logic output_ready;
    } t_metadata_inout;


    parameter buffer_len = 252;
    typedef struct packed {
        t_metadata_weights meta_data;
        logic [buffer_len-1:0][7:0] data; // 252 elements, each 8 bits wide
    } t_buffer_weights;

    typedef struct packed {
        t_metadata_inout meta_data;
        logic [buffer_len-1:0][7:0] data; // 252 elements, each 8 bits wide
    } t_buffer_inout;



    typedef struct packed {
        logic [7:0] xor_inp1;
        logic [7:0] xor_inp2;
        logic [7:0] xor_result;
        t_buffer_inout neuron_in;
        t_buffer_weights w1;
        t_buffer_weights w2;
        t_buffer_weights w3;
        t_buffer_inout neuron_out;

    } t_cr;

    /****************************************ACCELERATORS*******************************/
    parameter WEIGHT_WIDTH = 8;
    typedef struct packed {
        logic [2*WEIGHT_WIDTH:0] AQQ_0;
        logic [WEIGHT_WIDTH-1:0] Mu;
    } stage_mul_inp_t;

endpackage
