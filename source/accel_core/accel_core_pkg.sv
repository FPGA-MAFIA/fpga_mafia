package accel_core_pkg;

    /****************************************CR SPACE*******************************/

    // Define CR memory sizes
    parameter CR_MEM_OFFSET       = 'h00FE_0000;
    parameter CR_MEM_REGION_FLOOR = CR_MEM_OFFSET;
    parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;
    parameter CR_ACCEL_OFFSET     = CR_MEM_OFFSET +  'h210;

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
    parameter CR_MUL_IN_META = CR_ACCEL_OFFSET;

    parameter CR_MUL_IN_0  = CR_ACCEL_OFFSET + 1;
    parameter CR_MUL_IN_1  = CR_ACCEL_OFFSET + 2;
    parameter CR_MUL_IN_2  = CR_ACCEL_OFFSET + 3;
    parameter CR_MUL_IN_3  = CR_ACCEL_OFFSET + 4;
    parameter CR_MUL_IN_4  = CR_ACCEL_OFFSET + 5;
    parameter CR_MUL_IN_5  = CR_ACCEL_OFFSET + 6;
    parameter CR_MUL_IN_6  = CR_ACCEL_OFFSET + 7;
    parameter CR_MUL_IN_7  = CR_ACCEL_OFFSET + 8;
    parameter CR_MUL_IN_8  = CR_ACCEL_OFFSET + 9;
    parameter CR_MUL_IN_9  = CR_ACCEL_OFFSET + 10;
    parameter CR_MUL_IN_10 = CR_ACCEL_OFFSET + 11;
    parameter CR_MUL_IN_11 = CR_ACCEL_OFFSET + 12;
    parameter CR_MUL_IN_12 = CR_ACCEL_OFFSET + 13;
    parameter CR_MUL_IN_13 = CR_ACCEL_OFFSET + 14;
    parameter CR_MUL_IN_14 = CR_ACCEL_OFFSET + 15;
    parameter CR_MUL_IN_15 = CR_ACCEL_OFFSET + 16;
    parameter CR_MUL_IN_16 = CR_ACCEL_OFFSET + 17;
    parameter CR_MUL_IN_17 = CR_ACCEL_OFFSET + 18;
    parameter CR_MUL_IN_18 = CR_ACCEL_OFFSET + 19;
    parameter CR_MUL_IN_19 = CR_ACCEL_OFFSET + 20;
    parameter CR_MUL_IN_20 = CR_ACCEL_OFFSET + 21;
    parameter CR_MUL_IN_21 = CR_ACCEL_OFFSET + 22;
    parameter CR_MUL_IN_22 = CR_ACCEL_OFFSET + 23;
    parameter CR_MUL_IN_23 = CR_ACCEL_OFFSET + 24;
    parameter CR_MUL_IN_24 = CR_ACCEL_OFFSET + 25;
    parameter CR_MUL_IN_25 = CR_ACCEL_OFFSET + 26;
    parameter CR_MUL_IN_26 = CR_ACCEL_OFFSET + 27;
    parameter CR_MUL_IN_27 = CR_ACCEL_OFFSET + 28;
    parameter CR_MUL_IN_28 = CR_ACCEL_OFFSET + 29;
    parameter CR_MUL_IN_29 = CR_ACCEL_OFFSET + 30;
    parameter CR_MUL_IN_30 = CR_ACCEL_OFFSET + 31;
    parameter CR_MUL_IN_31 = CR_ACCEL_OFFSET + 32;
    parameter CR_MUL_IN_32 = CR_ACCEL_OFFSET + 33;
    parameter CR_MUL_IN_33 = CR_ACCEL_OFFSET + 34;
    parameter CR_MUL_IN_34 = CR_ACCEL_OFFSET + 35;
    parameter CR_MUL_IN_35 = CR_ACCEL_OFFSET + 36;
    parameter CR_MUL_IN_36 = CR_ACCEL_OFFSET + 37;
    parameter CR_MUL_IN_37 = CR_ACCEL_OFFSET + 38;
    parameter CR_MUL_IN_38 = CR_ACCEL_OFFSET + 39;
    parameter CR_MUL_IN_39 = CR_ACCEL_OFFSET + 40;
    parameter CR_MUL_IN_40 = CR_ACCEL_OFFSET + 41;
    parameter CR_MUL_IN_41 = CR_ACCEL_OFFSET + 42;
    parameter CR_MUL_IN_42 = CR_ACCEL_OFFSET + 43;
    parameter CR_MUL_IN_43 = CR_ACCEL_OFFSET + 44;
    parameter CR_MUL_IN_44 = CR_ACCEL_OFFSET + 45;
    parameter CR_MUL_IN_45 = CR_ACCEL_OFFSET + 46;
    parameter CR_MUL_IN_46 = CR_ACCEL_OFFSET + 47;
    parameter CR_MUL_IN_47 = CR_ACCEL_OFFSET + 48;
    parameter CR_MUL_IN_48 = CR_ACCEL_OFFSET + 49;
    parameter CR_MUL_IN_49 = CR_ACCEL_OFFSET + 50;
    parameter CR_MUL_IN_50 = CR_ACCEL_OFFSET + 51;
    parameter CR_MUL_IN_51 = CR_ACCEL_OFFSET + 52;
    parameter CR_MUL_IN_52 = CR_ACCEL_OFFSET + 53;
    parameter CR_MUL_IN_53 = CR_ACCEL_OFFSET + 54;
    parameter CR_MUL_IN_54 = CR_ACCEL_OFFSET + 55;
    parameter CR_MUL_IN_55 = CR_ACCEL_OFFSET + 56;
    parameter CR_MUL_IN_56 = CR_ACCEL_OFFSET + 57;
    parameter CR_MUL_IN_57 = CR_ACCEL_OFFSET + 58;
    parameter CR_MUL_IN_58 = CR_ACCEL_OFFSET + 59;
    parameter CR_MUL_IN_59 = CR_ACCEL_OFFSET + 60;
    parameter CR_MUL_IN_60 = CR_ACCEL_OFFSET + 61;
    parameter CR_MUL_IN_61 = CR_ACCEL_OFFSET + 62;
    parameter CR_MUL_IN_62 = CR_ACCEL_OFFSET + 63;

    // ============================================================================
    // CR_MUL_W1 Split into 63 x 32-bit Parameters
    // ============================================================================
    parameter CR_MUL_W1_META = CR_ACCEL_OFFSET + 64;

    parameter CR_MUL_W1_0  = CR_ACCEL_OFFSET + 65;
    parameter CR_MUL_W1_1  = CR_ACCEL_OFFSET + 66;
    parameter CR_MUL_W1_2  = CR_ACCEL_OFFSET + 67;
    parameter CR_MUL_W1_3  = CR_ACCEL_OFFSET + 68;
    parameter CR_MUL_W1_4  = CR_ACCEL_OFFSET + 69;
    parameter CR_MUL_W1_5  = CR_ACCEL_OFFSET + 70;
    parameter CR_MUL_W1_6  = CR_ACCEL_OFFSET + 71;
    parameter CR_MUL_W1_7  = CR_ACCEL_OFFSET + 72;
    parameter CR_MUL_W1_8  = CR_ACCEL_OFFSET + 73;
    parameter CR_MUL_W1_9  = CR_ACCEL_OFFSET + 74;
    parameter CR_MUL_W1_10 = CR_ACCEL_OFFSET + 75;
    parameter CR_MUL_W1_11 = CR_ACCEL_OFFSET + 76;
    parameter CR_MUL_W1_12 = CR_ACCEL_OFFSET + 77;
    parameter CR_MUL_W1_13 = CR_ACCEL_OFFSET + 78;
    parameter CR_MUL_W1_14 = CR_ACCEL_OFFSET + 79;
    parameter CR_MUL_W1_15 = CR_ACCEL_OFFSET + 80;
    parameter CR_MUL_W1_16 = CR_ACCEL_OFFSET + 81;
    parameter CR_MUL_W1_17 = CR_ACCEL_OFFSET + 82;
    parameter CR_MUL_W1_18 = CR_ACCEL_OFFSET + 83;
    parameter CR_MUL_W1_19 = CR_ACCEL_OFFSET + 84;
    parameter CR_MUL_W1_20 = CR_ACCEL_OFFSET + 85;
    parameter CR_MUL_W1_21 = CR_ACCEL_OFFSET + 86;
    parameter CR_MUL_W1_22 = CR_ACCEL_OFFSET + 87;
    parameter CR_MUL_W1_23 = CR_ACCEL_OFFSET + 88;
    parameter CR_MUL_W1_24 = CR_ACCEL_OFFSET + 89;
    parameter CR_MUL_W1_25 = CR_ACCEL_OFFSET + 90;
    parameter CR_MUL_W1_26 = CR_ACCEL_OFFSET + 91;
    parameter CR_MUL_W1_27 = CR_ACCEL_OFFSET + 92;
    parameter CR_MUL_W1_28 = CR_ACCEL_OFFSET + 93;
    parameter CR_MUL_W1_29 = CR_ACCEL_OFFSET + 94;
    parameter CR_MUL_W1_30 = CR_ACCEL_OFFSET + 95;
    parameter CR_MUL_W1_31 = CR_ACCEL_OFFSET + 96;
    parameter CR_MUL_W1_32 = CR_ACCEL_OFFSET + 97;
    parameter CR_MUL_W1_33 = CR_ACCEL_OFFSET + 98;
    parameter CR_MUL_W1_34 = CR_ACCEL_OFFSET + 99;
    parameter CR_MUL_W1_35 = CR_ACCEL_OFFSET + 100;
    parameter CR_MUL_W1_36 = CR_ACCEL_OFFSET + 101;
    parameter CR_MUL_W1_37 = CR_ACCEL_OFFSET + 102;
    parameter CR_MUL_W1_38 = CR_ACCEL_OFFSET + 103;
    parameter CR_MUL_W1_39 = CR_ACCEL_OFFSET + 104;
    parameter CR_MUL_W1_40 = CR_ACCEL_OFFSET + 105;
    parameter CR_MUL_W1_41 = CR_ACCEL_OFFSET + 106;
    parameter CR_MUL_W1_42 = CR_ACCEL_OFFSET + 107;
    parameter CR_MUL_W1_43 = CR_ACCEL_OFFSET + 108;
    parameter CR_MUL_W1_44 = CR_ACCEL_OFFSET + 109;
    parameter CR_MUL_W1_45 = CR_ACCEL_OFFSET + 110;
    parameter CR_MUL_W1_46 = CR_ACCEL_OFFSET + 111;
    parameter CR_MUL_W1_47 = CR_ACCEL_OFFSET + 112;
    parameter CR_MUL_W1_48 = CR_ACCEL_OFFSET + 113;
    parameter CR_MUL_W1_49 = CR_ACCEL_OFFSET + 114;
    parameter CR_MUL_W1_50 = CR_ACCEL_OFFSET + 115;
    parameter CR_MUL_W1_51 = CR_ACCEL_OFFSET + 116;
    parameter CR_MUL_W1_52 = CR_ACCEL_OFFSET + 117;
    parameter CR_MUL_W1_53 = CR_ACCEL_OFFSET + 118;
    parameter CR_MUL_W1_54 = CR_ACCEL_OFFSET + 119;
    parameter CR_MUL_W1_55 = CR_ACCEL_OFFSET + 120;
    parameter CR_MUL_W1_56 = CR_ACCEL_OFFSET + 121;
    parameter CR_MUL_W1_57 = CR_ACCEL_OFFSET + 122;
    parameter CR_MUL_W1_58 = CR_ACCEL_OFFSET + 123;
    parameter CR_MUL_W1_59 = CR_ACCEL_OFFSET + 124;
    parameter CR_MUL_W1_60 = CR_ACCEL_OFFSET + 125;
    parameter CR_MUL_W1_61 = CR_ACCEL_OFFSET + 126;
    parameter CR_MUL_W1_62 = CR_ACCEL_OFFSET + 127;

    // ============================================================================
    // CR_MUL_W2 Split into 63 x 32-bit Parameters
    // ============================================================================
    parameter CR_MUL_W2_META = CR_ACCEL_OFFSET + 128;

    parameter CR_MUL_W2_0  = CR_ACCEL_OFFSET + 129;
    parameter CR_MUL_W2_1  = CR_ACCEL_OFFSET + 130;
    parameter CR_MUL_W2_2  = CR_ACCEL_OFFSET + 131;
    parameter CR_MUL_W2_3  = CR_ACCEL_OFFSET + 132;
    parameter CR_MUL_W2_4  = CR_ACCEL_OFFSET + 133;
    parameter CR_MUL_W2_5  = CR_ACCEL_OFFSET + 134;
    parameter CR_MUL_W2_6  = CR_ACCEL_OFFSET + 135;
    parameter CR_MUL_W2_7  = CR_ACCEL_OFFSET + 136;
    parameter CR_MUL_W2_8  = CR_ACCEL_OFFSET + 137;
    parameter CR_MUL_W2_9  = CR_ACCEL_OFFSET + 138;
    parameter CR_MUL_W2_10 = CR_ACCEL_OFFSET + 139;
    parameter CR_MUL_W2_11 = CR_ACCEL_OFFSET + 140;
    parameter CR_MUL_W2_12 = CR_ACCEL_OFFSET + 141;
    parameter CR_MUL_W2_13 = CR_ACCEL_OFFSET + 142;
    parameter CR_MUL_W2_14 = CR_ACCEL_OFFSET + 143;
    parameter CR_MUL_W2_15 = CR_ACCEL_OFFSET + 144;
    parameter CR_MUL_W2_16 = CR_ACCEL_OFFSET + 145;
    parameter CR_MUL_W2_17 = CR_ACCEL_OFFSET + 146;
    parameter CR_MUL_W2_18 = CR_ACCEL_OFFSET + 147;
    parameter CR_MUL_W2_19 = CR_ACCEL_OFFSET + 148;
    parameter CR_MUL_W2_20 = CR_ACCEL_OFFSET + 149;
    parameter CR_MUL_W2_21 = CR_ACCEL_OFFSET + 150;
    parameter CR_MUL_W2_22 = CR_ACCEL_OFFSET + 151;
    parameter CR_MUL_W2_23 = CR_ACCEL_OFFSET + 152;
    parameter CR_MUL_W2_24 = CR_ACCEL_OFFSET + 153;
    parameter CR_MUL_W2_25 = CR_ACCEL_OFFSET + 154;
    parameter CR_MUL_W2_26 = CR_ACCEL_OFFSET + 155;
    parameter CR_MUL_W2_27 = CR_ACCEL_OFFSET + 156;
    parameter CR_MUL_W2_28 = CR_ACCEL_OFFSET + 157;
    parameter CR_MUL_W2_29 = CR_ACCEL_OFFSET + 158;
    parameter CR_MUL_W2_30 = CR_ACCEL_OFFSET + 159;
    parameter CR_MUL_W2_31 = CR_ACCEL_OFFSET + 160;
    parameter CR_MUL_W2_32 = CR_ACCEL_OFFSET + 161;
    parameter CR_MUL_W2_33 = CR_ACCEL_OFFSET + 162;
    parameter CR_MUL_W2_34 = CR_ACCEL_OFFSET + 163;
    parameter CR_MUL_W2_35 = CR_ACCEL_OFFSET + 164;
    parameter CR_MUL_W2_36 = CR_ACCEL_OFFSET + 165;
    parameter CR_MUL_W2_37 = CR_ACCEL_OFFSET + 166;
    parameter CR_MUL_W2_38 = CR_ACCEL_OFFSET + 167;
    parameter CR_MUL_W2_39 = CR_ACCEL_OFFSET + 168;
    parameter CR_MUL_W2_40 = CR_ACCEL_OFFSET + 169;
    parameter CR_MUL_W2_41 = CR_ACCEL_OFFSET + 170;
    parameter CR_MUL_W2_42 = CR_ACCEL_OFFSET + 171;
    parameter CR_MUL_W2_43 = CR_ACCEL_OFFSET + 172;
    parameter CR_MUL_W2_44 = CR_ACCEL_OFFSET + 173;
    parameter CR_MUL_W2_45 = CR_ACCEL_OFFSET + 174;
    parameter CR_MUL_W2_46 = CR_ACCEL_OFFSET + 175;
    parameter CR_MUL_W2_47 = CR_ACCEL_OFFSET + 176;
    parameter CR_MUL_W2_48 = CR_ACCEL_OFFSET + 177;
    parameter CR_MUL_W2_49 = CR_ACCEL_OFFSET + 178;
    parameter CR_MUL_W2_50 = CR_ACCEL_OFFSET + 179;
    parameter CR_MUL_W2_51 = CR_ACCEL_OFFSET + 180;
    parameter CR_MUL_W2_52 = CR_ACCEL_OFFSET + 181;
    parameter CR_MUL_W2_53 = CR_ACCEL_OFFSET + 182;
    parameter CR_MUL_W2_54 = CR_ACCEL_OFFSET + 183;
    parameter CR_MUL_W2_55 = CR_ACCEL_OFFSET + 184;
    parameter CR_MUL_W2_56 = CR_ACCEL_OFFSET + 185;
    parameter CR_MUL_W2_57 = CR_ACCEL_OFFSET + 186;
    parameter CR_MUL_W2_58 = CR_ACCEL_OFFSET + 187;
    parameter CR_MUL_W2_59 = CR_ACCEL_OFFSET + 188;
    parameter CR_MUL_W2_60 = CR_ACCEL_OFFSET + 189;
    parameter CR_MUL_W2_61 = CR_ACCEL_OFFSET + 190;
    parameter CR_MUL_W2_62 = CR_ACCEL_OFFSET + 191;

    // ============================================================================
    // CR_MUL_W3 Split into 63 x 32-bit Parameters
    // ============================================================================
    parameter CR_MUL_W3_META = CR_ACCEL_OFFSET + 192;

    parameter CR_MUL_W3_0  = CR_ACCEL_OFFSET + 193;
    parameter CR_MUL_W3_1  = CR_ACCEL_OFFSET + 194;
    parameter CR_MUL_W3_2  = CR_ACCEL_OFFSET + 195;
    parameter CR_MUL_W3_3  = CR_ACCEL_OFFSET + 196;
    parameter CR_MUL_W3_4  = CR_ACCEL_OFFSET + 197;
    parameter CR_MUL_W3_5  = CR_ACCEL_OFFSET + 198;
    parameter CR_MUL_W3_6  = CR_ACCEL_OFFSET + 199;
    parameter CR_MUL_W3_7  = CR_ACCEL_OFFSET + 200;
    parameter CR_MUL_W3_8  = CR_ACCEL_OFFSET + 201;
    parameter CR_MUL_W3_9  = CR_ACCEL_OFFSET + 202;
    parameter CR_MUL_W3_10 = CR_ACCEL_OFFSET + 203;
    parameter CR_MUL_W3_11 = CR_ACCEL_OFFSET + 204;
    parameter CR_MUL_W3_12 = CR_ACCEL_OFFSET + 205;
    parameter CR_MUL_W3_13 = CR_ACCEL_OFFSET + 206;
    parameter CR_MUL_W3_14 = CR_ACCEL_OFFSET + 207;
    parameter CR_MUL_W3_15 = CR_ACCEL_OFFSET + 208;
    parameter CR_MUL_W3_16 = CR_ACCEL_OFFSET + 209;
    parameter CR_MUL_W3_17 = CR_ACCEL_OFFSET + 210;
    parameter CR_MUL_W3_18 = CR_ACCEL_OFFSET + 211;
    parameter CR_MUL_W3_19 = CR_ACCEL_OFFSET + 212;
    parameter CR_MUL_W3_20 = CR_ACCEL_OFFSET + 213;
    parameter CR_MUL_W3_21 = CR_ACCEL_OFFSET + 214;
    parameter CR_MUL_W3_22 = CR_ACCEL_OFFSET + 215;
    parameter CR_MUL_W3_23 = CR_ACCEL_OFFSET + 216;
    parameter CR_MUL_W3_24 = CR_ACCEL_OFFSET + 217;
    parameter CR_MUL_W3_25 = CR_ACCEL_OFFSET + 218;
    parameter CR_MUL_W3_26 = CR_ACCEL_OFFSET + 219;
    parameter CR_MUL_W3_27 = CR_ACCEL_OFFSET + 220;
    parameter CR_MUL_W3_28 = CR_ACCEL_OFFSET + 221;
    parameter CR_MUL_W3_29 = CR_ACCEL_OFFSET + 222;
    parameter CR_MUL_W3_30 = CR_ACCEL_OFFSET + 223;
    parameter CR_MUL_W3_31 = CR_ACCEL_OFFSET + 224;
    parameter CR_MUL_W3_32 = CR_ACCEL_OFFSET + 225;
    parameter CR_MUL_W3_33 = CR_ACCEL_OFFSET + 226;
    parameter CR_MUL_W3_34 = CR_ACCEL_OFFSET + 227;
    parameter CR_MUL_W3_35 = CR_ACCEL_OFFSET + 228;
    parameter CR_MUL_W3_36 = CR_ACCEL_OFFSET + 229;
    parameter CR_MUL_W3_37 = CR_ACCEL_OFFSET + 230;
    parameter CR_MUL_W3_38 = CR_ACCEL_OFFSET + 231;
    parameter CR_MUL_W3_39 = CR_ACCEL_OFFSET + 232;
    parameter CR_MUL_W3_40 = CR_ACCEL_OFFSET + 233;
    parameter CR_MUL_W3_41 = CR_ACCEL_OFFSET + 234;
    parameter CR_MUL_W3_42 = CR_ACCEL_OFFSET + 235;
    parameter CR_MUL_W3_43 = CR_ACCEL_OFFSET + 236;
    parameter CR_MUL_W3_44 = CR_ACCEL_OFFSET + 237;
    parameter CR_MUL_W3_45 = CR_ACCEL_OFFSET + 238;
    parameter CR_MUL_W3_46 = CR_ACCEL_OFFSET + 239;
    parameter CR_MUL_W3_47 = CR_ACCEL_OFFSET + 240;
    parameter CR_MUL_W3_48 = CR_ACCEL_OFFSET + 241;
    parameter CR_MUL_W3_49 = CR_ACCEL_OFFSET + 242;
    parameter CR_MUL_W3_50 = CR_ACCEL_OFFSET + 243;
    parameter CR_MUL_W3_51 = CR_ACCEL_OFFSET + 244;
    parameter CR_MUL_W3_52 = CR_ACCEL_OFFSET + 245;
    parameter CR_MUL_W3_53 = CR_ACCEL_OFFSET + 246;
    parameter CR_MUL_W3_54 = CR_ACCEL_OFFSET + 247;
    parameter CR_MUL_W3_55 = CR_ACCEL_OFFSET + 248;
    parameter CR_MUL_W3_56 = CR_ACCEL_OFFSET + 249;
    parameter CR_MUL_W3_57 = CR_ACCEL_OFFSET + 250;
    parameter CR_MUL_W3_58 = CR_ACCEL_OFFSET + 251;
    parameter CR_MUL_W3_59 = CR_ACCEL_OFFSET + 252;
    parameter CR_MUL_W3_60 = CR_ACCEL_OFFSET + 253;
    parameter CR_MUL_W3_61 = CR_ACCEL_OFFSET + 254;
    parameter CR_MUL_W3_62 = CR_ACCEL_OFFSET + 255;

    // ============================================================================
    // CR_MUL_OUT Split into 63 x 32-bit Parameters
    // ============================================================================
    parameter CR_MUL_OUT_META = CR_ACCEL_OFFSET + 256;

    parameter CR_MUL_OUT_0  = CR_ACCEL_OFFSET + 257;
    parameter CR_MUL_OUT_1  = CR_ACCEL_OFFSET + 258;
    parameter CR_MUL_OUT_2  = CR_ACCEL_OFFSET + 259;
    parameter CR_MUL_OUT_3  = CR_ACCEL_OFFSET + 260;
    parameter CR_MUL_OUT_4  = CR_ACCEL_OFFSET + 261;
    parameter CR_MUL_OUT_5  = CR_ACCEL_OFFSET + 262;
    parameter CR_MUL_OUT_6  = CR_ACCEL_OFFSET + 263;
    parameter CR_MUL_OUT_7  = CR_ACCEL_OFFSET + 264;
    parameter CR_MUL_OUT_8  = CR_ACCEL_OFFSET + 265;
    parameter CR_MUL_OUT_9  = CR_ACCEL_OFFSET + 266;
    parameter CR_MUL_OUT_10 = CR_ACCEL_OFFSET + 267;
    parameter CR_MUL_OUT_11 = CR_ACCEL_OFFSET + 268;
    parameter CR_MUL_OUT_12 = CR_ACCEL_OFFSET + 269;
    parameter CR_MUL_OUT_13 = CR_ACCEL_OFFSET + 270;
    parameter CR_MUL_OUT_14 = CR_ACCEL_OFFSET + 271;
    parameter CR_MUL_OUT_15 = CR_ACCEL_OFFSET + 272;
    parameter CR_MUL_OUT_16 = CR_ACCEL_OFFSET + 273;
    parameter CR_MUL_OUT_17 = CR_ACCEL_OFFSET + 274;
    parameter CR_MUL_OUT_18 = CR_ACCEL_OFFSET + 275;
    parameter CR_MUL_OUT_19 = CR_ACCEL_OFFSET + 276;
    parameter CR_MUL_OUT_20 = CR_ACCEL_OFFSET + 277;
    parameter CR_MUL_OUT_21 = CR_ACCEL_OFFSET + 278;
    parameter CR_MUL_OUT_22 = CR_ACCEL_OFFSET + 279;
    parameter CR_MUL_OUT_23 = CR_ACCEL_OFFSET + 280;
    parameter CR_MUL_OUT_24 = CR_ACCEL_OFFSET + 281;
    parameter CR_MUL_OUT_25 = CR_ACCEL_OFFSET + 282;
    parameter CR_MUL_OUT_26 = CR_ACCEL_OFFSET + 283;
    parameter CR_MUL_OUT_27 = CR_ACCEL_OFFSET + 284;
    parameter CR_MUL_OUT_28 = CR_ACCEL_OFFSET + 285;
    parameter CR_MUL_OUT_29 = CR_ACCEL_OFFSET + 286;
    parameter CR_MUL_OUT_30 = CR_ACCEL_OFFSET + 287;
    parameter CR_MUL_OUT_31 = CR_ACCEL_OFFSET + 288;
    parameter CR_MUL_OUT_32 = CR_ACCEL_OFFSET + 289;
    parameter CR_MUL_OUT_33 = CR_ACCEL_OFFSET + 290;
    parameter CR_MUL_OUT_34 = CR_ACCEL_OFFSET + 291;
    parameter CR_MUL_OUT_35 = CR_ACCEL_OFFSET + 292;
    parameter CR_MUL_OUT_36 = CR_ACCEL_OFFSET + 293;
    parameter CR_MUL_OUT_37 = CR_ACCEL_OFFSET + 294;
    parameter CR_MUL_OUT_38 = CR_ACCEL_OFFSET + 295;
    parameter CR_MUL_OUT_39 = CR_ACCEL_OFFSET + 296;
    parameter CR_MUL_OUT_40 = CR_ACCEL_OFFSET + 297;
    parameter CR_MUL_OUT_41 = CR_ACCEL_OFFSET + 298;
    parameter CR_MUL_OUT_42 = CR_ACCEL_OFFSET + 299;
    parameter CR_MUL_OUT_43 = CR_ACCEL_OFFSET + 300;
    parameter CR_MUL_OUT_44 = CR_ACCEL_OFFSET + 301;
    parameter CR_MUL_OUT_45 = CR_ACCEL_OFFSET + 302;
    parameter CR_MUL_OUT_46 = CR_ACCEL_OFFSET + 303;
    parameter CR_MUL_OUT_47 = CR_ACCEL_OFFSET + 304;
    parameter CR_MUL_OUT_48 = CR_ACCEL_OFFSET + 305;
    parameter CR_MUL_OUT_49 = CR_ACCEL_OFFSET + 306;
    parameter CR_MUL_OUT_50 = CR_ACCEL_OFFSET + 307;
    parameter CR_MUL_OUT_51 = CR_ACCEL_OFFSET + 308;
    parameter CR_MUL_OUT_52 = CR_ACCEL_OFFSET + 309;
    parameter CR_MUL_OUT_53 = CR_ACCEL_OFFSET + 310;
    parameter CR_MUL_OUT_54 = CR_ACCEL_OFFSET + 311;
    parameter CR_MUL_OUT_55 = CR_ACCEL_OFFSET + 312;
    parameter CR_MUL_OUT_56 = CR_ACCEL_OFFSET + 313;
    parameter CR_MUL_OUT_57 = CR_ACCEL_OFFSET + 314;
    parameter CR_MUL_OUT_58 = CR_ACCEL_OFFSET + 315;
    parameter CR_MUL_OUT_59 = CR_ACCEL_OFFSET + 316;
    parameter CR_MUL_OUT_60 = CR_ACCEL_OFFSET + 317;
    parameter CR_MUL_OUT_61 = CR_ACCEL_OFFSET + 318;
    parameter CR_MUL_OUT_62 = CR_ACCEL_OFFSET + 319;

    typedef struct packed {
        logic [7:0] neuron_idx;  // the output index (Weight Matrix Column)
        logic [7:0] data_len;  // this is the actual number of weights + bias in the buffer
        logic in_use;
    } t_metadata_weights;

    typedef struct packed {
        logic [7:0] matrix_row_num;
        logic [7:0] matrix_col_num;
        logic in_use_by_accel;
        logic mov_out_to_in;
        logic output_ready;
    } t_metadata_inout;


    parameter buffer_len = 252;
    typedef logic [buffer_len-1:0][7:0] t_l8_array;
    typedef struct packed {
        t_metadata_weights meta_data;
        t_l8_array data; // 252 elements, each 8 bits wide
    } t_buffer_weights;

    typedef struct packed {
        t_metadata_inout meta_data;
        t_l8_array data; // 252 elements, each 8 bits wide
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

    typedef struct packed {
        t_buffer_inout input_vec;
        t_buffer_weights w1;
        t_buffer_weights w2;
        t_buffer_weights w3;
    } accel_inputs_t;

    typedef struct packed {
        t_buffer_inout output_vec;
        logic release_w1;
        logic release_w2;
        logic release_w3;
        logic move_out_to_in;
        logic done_layer;
    } accel_outputs_t;

    /*************************************ENUMS******************************************/
    typedef enum logic [1:0] { 
        FREE = 2'b00,
        W1   = 2'b01,
        W2   = 2'b10,
        W3   = 2'b11
    } t_buffer_sel;

endpackage
