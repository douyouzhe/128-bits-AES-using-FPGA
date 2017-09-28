library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myip_v1_0 is
	port 
	(
		ACLK	: in	std_logic;
		ARESETN	: in	std_logic;
		S_AXIS_TREADY	: out	std_logic;
		S_AXIS_TDATA	: in	std_logic_vector(31 downto 0);
		S_AXIS_TLAST	: in	std_logic;
		S_AXIS_TVALID	: in	std_logic;
		M_AXIS_TVALID	: out	std_logic;
		M_AXIS_TDATA	: out	std_logic_vector(31 downto 0);
		M_AXIS_TLAST	: out	std_logic;
		M_AXIS_TREADY	: in	std_logic
	);
attribute SIGIS : string; 
attribute SIGIS of ACLK : signal is "Clk"; 
end myip_v1_0;


architecture EXAMPLE of myip_v1_0 is

   constant NUMBER_OF_INPUT_WORDS  : natural := 8;
   constant NUMBER_OF_OUTPUT_WORDS : natural := 8;
   type key_word is array (0 to 175) of std_logic_vector (7 downto 0);
   type box is array (0 to 255) of std_logic_vector(7 downto 0);
   type RoundConstant is array (0 to 9) of std_logic_vector(7 downto 0);
   
    constant Rcon:RoundConstant:=(x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"80", x"1b", x"36");
    constant sbox:box:=(   x"63", x"7c", x"77", x"7b", x"f2", x"6b", x"6f", x"c5", x"30", x"01", x"67", x"2b", x"fe", x"d7", x"ab", x"76",
                             x"ca", x"82", x"c9", x"7d", x"fa", x"59", x"47", x"f0", x"ad", x"d4", x"a2", x"af", x"9c", x"a4", x"72", x"c0",
                             x"b7", x"fd", x"93", x"26", x"36", x"3f", x"f7", x"cc", x"34", x"a5", x"e5", x"f1", x"71", x"d8", x"31", x"15",
                             x"04", x"c7", x"23", x"c3", x"18", x"96", x"05", x"9a", x"07", x"12", x"80", x"e2", x"eb", x"27", x"b2", x"75",
                             x"09", x"83", x"2c", x"1a", x"1b", x"6e", x"5a", x"a0", x"52", x"3b", x"d6", x"b3", x"29", x"e3", x"2f", x"84",
                             x"53", x"d1", x"00", x"ed", x"20", x"fc", x"b1", x"5b", x"6a", x"cb", x"be", x"39", x"4a", x"4c", x"58", x"cf",
                             x"d0", x"ef", x"aa", x"fb", x"43", x"4d", x"33", x"85", x"45", x"f9", x"02", x"7f", x"50", x"3c", x"9f", x"a8",
                             x"51", x"a3", x"40", x"8f", x"92", x"9d", x"38", x"f5", x"bc", x"b6", x"da", x"21", x"10", x"ff", x"f3", x"d2",
                             x"cd", x"0c", x"13", x"ec", x"5f", x"97", x"44", x"17", x"c4", x"a7", x"7e", x"3d", x"64", x"5d", x"19", x"73",
                             x"60", x"81", x"4f", x"dc", x"22", x"2a", x"90", x"88", x"46", x"ee", x"b8", x"14", x"de", x"5e", x"0b", x"db",
                             x"e0", x"32", x"3a", x"0a", x"49", x"06", x"24", x"5c", x"c2", x"d3", x"ac", x"62", x"91", x"95", x"e4", x"79",
                             x"e7", x"c8", x"37", x"6d", x"8d", x"d5", x"4e", x"a9", x"6c", x"56", x"f4", x"ea", x"65", x"7a", x"ae", x"08",
                             x"ba", x"78", x"25", x"2e", x"1c", x"a6", x"b4", x"c6", x"e8", x"dd", x"74", x"1f", x"4b", x"bd", x"8b", x"8a",
                             x"70", x"3e", x"b5", x"66", x"48", x"03", x"f6", x"0e", x"61", x"35", x"57", x"b9", x"86", x"c1", x"1d", x"9e",
                             x"e1", x"f8", x"98", x"11", x"69", x"d9", x"8e", x"94", x"9b", x"1e", x"87", x"e9", x"ce", x"55", x"28", x"df",
                             x"8c", x"a1", x"89", x"0d", x"bf", x"e6", x"42", x"68", x"41", x"99", x"2d", x"0f", x"b0", x"54", x"bb", x"16" );

   type STATE_TYPE is (Idle, Idle0, Read_Key, Key_Schedual , 
                       Add_RK0, Add_RK1,Add_RK2, Add_RK3,Add_RK4, Add_RK5,
                       Add_RK6, Add_RK7,Add_RK8, Add_RK9,Add_RK10,
                       Inv_Sbox1, Inv_Sbox2,Inv_Sbox3,Inv_Sbox4,Inv_Sbox5,
                       Inv_Sbox6, Inv_Sbox7,Inv_Sbox8,Inv_Sbox9,Inv_Sbox10,
					   Inv_MC1,Inv_MC2,Inv_MC3,Inv_MC4,Inv_MC5,
					   Inv_MC6,Inv_MC7,Inv_MC8,Inv_MC9,Last_Step,
					   Read_Inputs, 
					   Inv_SR1, Inv_SR2, Inv_SR3, Inv_SR4, Inv_SR5, 
					   Inv_SR6, Inv_SR7, Inv_SR8, Inv_SR9, Inv_SR10, 
					   Buffer_Write, Write_Outputs					               					   
					   );

   signal state        : STATE_TYPE;
   signal Key_round: integer := 0; 
   signal my_data : std_logic_vector(255 downto 0);
   signal my_key : std_logic_vector(255 downto 0);
   signal my_temp : std_logic_vector(255 downto 0);
   signal my_temp1 : std_logic_vector(255 downto 0);
   signal my_temp2 : std_logic_vector(255 downto 0);
   signal my_temp3 : std_logic_vector(255 downto 0);
   signal my_temp4 : std_logic_vector(255 downto 0);   
   signal nr_of_reads  : natural range 0 to NUMBER_OF_INPUT_WORDS - 1;
   signal nr_of_writes : natural range 0 to NUMBER_OF_OUTPUT_WORDS - 1;
 
component inv_s_box 
port(	d_in	:   IN  std_logic_vector(7 downto 0);
  	    d_out	:   OUT std_logic_vector(7 downto 0));
end component;


component inv_shift 
port(	d_in	:   IN  std_logic_vector(127 downto 0);       
  	    d_out	:   OUT std_logic_vector(127 downto 0));
end component;

component inv_mix
port(	d_in	:   IN  std_logic_vector(127 downto 0);       
  	    d_out	:   OUT std_logic_vector(127 downto 0));
end component;

begin

   S_AXIS_TREADY  <= '1'   when (state = Read_Inputs or state = Read_Key )  else '0';
   M_AXIS_TVALID <= '1' when state = Write_Outputs else '0';
   M_AXIS_TLAST <= '1' when (state = Write_Outputs and nr_of_writes = 0) else '0';

   The_SW_accelerator : process (ACLK) is
   
   variable expansion_key: key_word;
   variable buffer1:std_logic_vector(7 downto 0);
   variable index: integer := 0;
   
   begin  -- process The_SW_accelerator
    if ACLK'event and ACLK = '1' then     -- Rising clock edge
      if ARESETN = '0' then               -- Synchronous reset (active low)
        state        <= Idle;
        nr_of_reads  <= 0;
        nr_of_writes <= 0;
        my_data          <= (others => '0');
      else
        case state is
          when Idle =>            
            if (S_AXIS_TVALID = '1') then
              state       <= Read_Key;
              nr_of_reads <= NUMBER_OF_INPUT_WORDS - 1;            
            end if;
                        
         when Read_Key=> 
          if (S_AXIS_TVALID = '1') then
              if (nr_of_reads = 0) then
                my_key(31 downto 0) <= S_AXIS_TDATA;
                state        <= Key_Schedual;
              else
                if (nr_of_reads=7) then my_key(255 downto 224) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=6) then my_key(223 downto 192) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=5) then my_key(191 downto 160) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=4) then my_key(159 downto 128) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=3) then my_key(127 downto 96) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=2) then my_key(95 downto 64) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=1) then my_key(63 downto 32) <= S_AXIS_TDATA; end if;
                nr_of_reads <= nr_of_reads - 1;
              end if;
            end if;
            
                      
          when Key_Schedual=>
            if (Key_round = 0) then
             expansion_key(0) := my_key(255 downto 248);
             expansion_key(1) := my_key(247 downto 240);
             expansion_key(2) := my_key(239 downto 232);
             expansion_key(3) := my_key(231 downto 224);
             expansion_key(4) := my_key(223 downto 216);
             expansion_key(5) := my_key(215 downto 208);
             expansion_key(6) := my_key(207 downto 200);
             expansion_key(7) := my_key(199 downto 192);
             expansion_key(8) := my_key(191 downto 184);
             expansion_key(9) := my_key(183 downto 176);
             expansion_key(10) := my_key(175 downto 168);
             expansion_key(11) := my_key(167 downto 160);
             expansion_key(12) := my_key(159 downto 152);
             expansion_key(13) := my_key(151 downto 144);
             expansion_key(14) := my_key(143 downto 136);
             expansion_key(15) := my_key(135 downto 128);
           elsif(Key_round <= 10) then
                   index := Key_round * 16;
                   buffer1 := expansion_key(index -4);  
                   expansion_key(index) := sbox(to_integer(unsigned(expansion_key(index -3)))) xor Rcon(Key_round -1) xor expansion_key(index-16);
                   expansion_key(index+1) := sbox(to_integer(unsigned(expansion_key(index -2)))) xor expansion_key(index-15);
                   expansion_key(index+2) := sbox(to_integer(unsigned(expansion_key(index -1)))) xor expansion_key(index-14);
                   expansion_key(index+3) :=  sbox(to_integer(unsigned(buffer1))) xor expansion_key(index-13);
                   expansion_key(index+4) := expansion_key(index-12) xor expansion_key(index);
                   expansion_key(index + 5) := expansion_key(index-11) xor expansion_key(index+1);
                   expansion_key(index + 6) := expansion_key(index-10) xor expansion_key(index+2);
                   expansion_key(index + 7) := expansion_key(index-9) xor expansion_key(index+3);                  
                   expansion_key(index+8) := expansion_key(index-8) xor expansion_key(index+4);
                   expansion_key(index + 9) := expansion_key(index-7) xor expansion_key(index+5);
                   expansion_key(index + 10) := expansion_key(index-6) xor expansion_key(index+6);
                   expansion_key(index + 11) := expansion_key(index-5) xor expansion_key(index+7);                                     
                   expansion_key(index+12) := expansion_key(index-4) xor expansion_key(index+8);
                   expansion_key(index + 13) := expansion_key(index-3) xor expansion_key(index+9);
                   expansion_key(index + 14) := expansion_key(index-2) xor expansion_key(index+10);
                   expansion_key(index + 15) := expansion_key(index-1) xor expansion_key(index+11);
             end if;      
             if (Key_round = 10) then  -- finish
                    state <= Idle0;
                    Key_round <= 0;                    
             else
                    Key_round <= Key_round +1;
             end if;
           
          
          
          
          when Idle0=>
            if (S_AXIS_TVALID = '1') then
              state       <= Read_Inputs;
              nr_of_reads <= NUMBER_OF_INPUT_WORDS - 1;
            end if;
 
          
          

          when Read_Inputs =>
            if (S_AXIS_TVALID = '1') then
              if (nr_of_reads = 0) then
                my_data(31 downto 0) <= S_AXIS_TDATA;
                state        <= Add_RK0;
              else
                if (nr_of_reads=7) then my_data(255 downto 224) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=6) then my_data(223 downto 192) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=5) then my_data(191 downto 160) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=4) then my_data(159 downto 128) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=3) then my_data(127 downto 96) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=2) then my_data(95 downto 64) <= S_AXIS_TDATA; end if;
                if (nr_of_reads=1) then my_data(63 downto 32) <= S_AXIS_TDATA; end if;
                nr_of_reads <= nr_of_reads - 1;
              end if;
            end if;
            
                        
        when Add_RK0   =>
           my_temp (255 downto 128)<= my_data (255 downto 128) xor (expansion_key(160) & expansion_key(161) & expansion_key(162) & expansion_key(163)&
                                                                    expansion_key(164) & expansion_key(165) & expansion_key(166) & expansion_key(167)&
                                                                    expansion_key(168) & expansion_key(169) & expansion_key(170) & expansion_key(171)&
                                                                    expansion_key(172) & expansion_key(173) & expansion_key(174) & expansion_key(175));
           my_temp (127 downto 0)  <= my_data (127 downto 0) xor (expansion_key(160)&expansion_key(161)&expansion_key(162)&expansion_key(163)&
                                                                  expansion_key(164)&expansion_key(165)&expansion_key(166)&expansion_key(167)&
                                                                  expansion_key(168)&expansion_key(169)&expansion_key(170)&expansion_key(171)&
                                                                  expansion_key(172)&expansion_key(173)&expansion_key(174)&expansion_key(175));
           state   <= Inv_SR1;
           

                     
        when Inv_SR1 =>
        state        <= Inv_Sbox1;
        -- temp1 is the result        
        
 
            
        when Inv_Sbox1 =>  
      --  S_debug_state<="00111";  
        state        <= Add_RK1;
       -- temp2 is the result
       

	             
        when Add_RK1   =>
    --    S_debug_state<="01000";
        state        <= Inv_MC1;
           my_temp3 (255 downto 128)<= my_temp2 (255 downto 128) xor (expansion_key(144)&
                                                                     expansion_key(145)&
                                                                  expansion_key(146)&
                                                                  expansion_key(147)&
                                                                  expansion_key(148)&
                                                                  expansion_key(149)&
                                                                  expansion_key(150)&
                                                                     expansion_key(151)&
                                                                  expansion_key(152)&
                                                                  expansion_key(153)&
                                                                  expansion_key(154)&
                                                                  expansion_key(155)&
                                                                expansion_key(156)&
                                                                   expansion_key(157)&
                                                                expansion_key(158)&
                                                                expansion_key(159));
            
 
           my_temp3 (127 downto 0)<= my_temp2 (127 downto 0) xor (expansion_key(144)&
                                                                 expansion_key(145)&
                                                              expansion_key(146)&
                                                              expansion_key(147)&
                                                              expansion_key(148)&
                                                              expansion_key(149)&
                                                              expansion_key(150)&
                                                                 expansion_key(151)&
                                                              expansion_key(152)&
                                                              expansion_key(153)&
                                                              expansion_key(154)&
                                                              expansion_key(155)&
                                                            expansion_key(156)&
                                                               expansion_key(157)&
                                                            expansion_key(158)&
                                                            expansion_key(159));
		
	
		
		
		when Inv_MC1=>
		--S_debug_state<="01001";
		state        <= Inv_SR2;
		--result is temp4

------------------------------------------------------------------------------------------------------------------		
		when Inv_SR2=>
		--S_debug_state<="01010";
		state        <= Inv_Sbox2;
		my_temp(255 downto 0)<= my_temp4(255 downto 0);
		
		
		
		when Inv_Sbox2 =>   
		--S_debug_state<="01011"; 
		state        <= Add_RK2;
       -- temp2 is the result
	             
        when Add_RK2   =>
       -- S_debug_state<="01100";
        state        <= Inv_MC2;
           my_temp3 (255 downto 128)<= my_temp2 (255 downto 128) xor (expansion_key(128)&
                                                                        expansion_key(129)&
                                                                     expansion_key(130)&
                                                                     expansion_key(131)&
                                                                     expansion_key(132)&
                                                                     expansion_key(133)&
                                                                     expansion_key(134)&
                                                                        expansion_key(135)&
                                                                     expansion_key(136)&
                                                                     expansion_key(137)&
                                                                     expansion_key(138)&
                                                                     expansion_key(139)&
                                                                   expansion_key(140)&
                                                                      expansion_key(141)&
                                                                   expansion_key(142)&
                                                                   expansion_key(143));
            
 
           my_temp3 (127 downto 0)<= my_temp2 (127 downto 0) xor (expansion_key(128)&
                                                               expansion_key(129)&
                                                            expansion_key(130)&
                                                            expansion_key(131)&
                                                            expansion_key(132)&
                                                            expansion_key(133)&
                                                            expansion_key(134)&
                                                               expansion_key(135)&
                                                            expansion_key(136)&
                                                            expansion_key(137)&
                                                            expansion_key(138)&
                                                            expansion_key(139)&
                                                          expansion_key(140)&
                                                             expansion_key(141)&
                                                          expansion_key(142)&
                                                          expansion_key(143));
		when Inv_MC2=>
		--S_debug_state<="01101";
		state        <= Inv_SR3;
		--result is temp4
 ------------------------------------------------------------------------------------------------------------------		
		when Inv_SR3=>
		state        <= Inv_Sbox3;
		my_temp(255 downto 0)<= my_temp4(255 downto 0);
		
		
		when Inv_Sbox3 =>  
		state        <= Add_RK3;  
       -- temp2 is the result
	             
        when Add_RK3   =>
        state        <= Inv_MC3;
           my_temp3 (255 downto 128)<= my_temp2 (255 downto 128) xor  (expansion_key(112)&
                                                                         expansion_key(113)&
                                                                      expansion_key(114)&
                                                                      expansion_key(115)&
                                                                      expansion_key(116)&
                                                                      expansion_key(117)&
                                                                      expansion_key(118)&
                                                                         expansion_key(119)&
                                                                      expansion_key(120)&
                                                                      expansion_key(121)&
                                                                      expansion_key(122)&
                                                                      expansion_key(123)&
                                                                    expansion_key(124)&
                                                                       expansion_key(125)&
                                                                    expansion_key(126)&
                                                                    expansion_key(127));
            
 
           my_temp3 (127 downto 0)<= my_temp2 (127 downto 0) xor (expansion_key(112)&
                                                                     expansion_key(113)&
                                                                  expansion_key(114)&
                                                                  expansion_key(115)&
                                                                  expansion_key(116)&
                                                                  expansion_key(117)&
                                                                  expansion_key(118)&
                                                                     expansion_key(119)&
                                                                  expansion_key(120)&
                                                                  expansion_key(121)&
                                                                  expansion_key(122)&
                                                                  expansion_key(123)&
                                                                expansion_key(124)&
                                                                   expansion_key(125)&
                                                                expansion_key(126)&
                                                                expansion_key(127));
		when Inv_MC3=>
		state        <= Inv_SR4;
		--result is temp4       
        
------------------------------------------------------------------------------------------------------------------		
		when Inv_SR4=>
		state        <= Inv_Sbox4;
		my_temp(255 downto 0)<= my_temp4(255 downto 0);
		
		when Inv_Sbox4 =>  
		state        <= Add_RK4;  
       -- temp2 is the result
	             
        when Add_RK4   =>
        state        <= Inv_MC4;
           my_temp3 (255 downto 128)<= my_temp2 (255 downto 128) xor (expansion_key(96)&
                                                                    expansion_key(97)&
                                                                 expansion_key(98)&
                                                                 expansion_key(99)&
                                                                 expansion_key(100)&
                                                                 expansion_key(101)&
                                                                 expansion_key(102)&
                                                                    expansion_key(103)&
                                                                 expansion_key(104)&
                                                                 expansion_key(105)&
                                                                 expansion_key(106)&
                                                                 expansion_key(107)&
                                                               expansion_key(108)&
                                                                  expansion_key(109)&
                                                               expansion_key(110)&
                                                               expansion_key(111));
                                                                                    
            
 
           my_temp3 (127 downto 0)<= my_temp2 (127 downto 0) xor (expansion_key(96)&
                                                                   expansion_key(97)&
                                                                expansion_key(98)&
                                                                expansion_key(99)&
                                                                expansion_key(100)&
                                                                expansion_key(101)&
                                                                expansion_key(102)&
                                                                   expansion_key(103)&
                                                                expansion_key(104)&
                                                                expansion_key(105)&
                                                                expansion_key(106)&
                                                                expansion_key(107)&
                                                              expansion_key(108)&
                                                                 expansion_key(109)&
                                                              expansion_key(110)&
                                                              expansion_key(111));
                                                                                                                                                                
		when Inv_MC4=>
		state        <= Inv_SR5;
		--result is temp4   
		
------------------------------------------------------------------------------------------------------------------		
		when Inv_SR5=>
		state        <= Inv_Sbox5;
		my_temp(255 downto 0)<= my_temp4(255 downto 0);
		
		when Inv_Sbox5 =>
		state        <= Add_RK5;    
       -- temp2 is the result
	             
        when Add_RK5   =>
        state        <= Inv_MC5;
           my_temp3 (255 downto 128)<= my_temp2 (255 downto 128) xor  (expansion_key(80)&
                                                                       expansion_key(81)&
                                                                    expansion_key(82)&
                                                                    expansion_key(83)&
                                                                    expansion_key(84)&
                                                                    expansion_key(85)&
                                                                    expansion_key(86)&
                                                                       expansion_key(87)&
                                                                    expansion_key(88)&
                                                                    expansion_key(89)&
                                                                    expansion_key(90)&
                                                                    expansion_key(91)&
                                                                  expansion_key(92)&
                                                                     expansion_key(93)&
                                                                  expansion_key(94)&
                                                                  expansion_key(95));
            
 
           my_temp3 (127 downto 0)<= my_temp2 (127 downto 0) xor  (expansion_key(80)&
                                                                 expansion_key(81)&
                                                              expansion_key(82)&
                                                              expansion_key(83)&
                                                              expansion_key(84)&
                                                              expansion_key(85)&
                                                              expansion_key(86)&
                                                                 expansion_key(87)&
                                                              expansion_key(88)&
                                                              expansion_key(89)&
                                                              expansion_key(90)&
                                                              expansion_key(91)&
                                                            expansion_key(92)&
                                                               expansion_key(93)&
                                                            expansion_key(94)&
                                                            expansion_key(95));
		when Inv_MC5=>
		state        <= Inv_SR6;
		--result is temp4		     
        
        
------------------------------------------------------------------------------------------------------------------		
		when Inv_SR6=>
		state        <= Inv_Sbox6;
		my_temp(255 downto 0)<= my_temp4(255 downto 0);
		
		when Inv_Sbox6 =>    
		state        <= Add_RK6;
       -- temp2 is the result
	             
        when Add_RK6   =>
        state        <= Inv_MC6;
           my_temp3 (255 downto 128)<= my_temp2 (255 downto 128) xor   (expansion_key(64)&
                                                                        expansion_key(65)&
                                                                     expansion_key(66)&
                                                                     expansion_key(67)&
                                                                     expansion_key(68)&
                                                                     expansion_key(69)&
                                                                     expansion_key(70)&
                                                                        expansion_key(71)&
                                                                     expansion_key(72)&
                                                                     expansion_key(73)&
                                                                     expansion_key(74)&
                                                                     expansion_key(75)&
                                                                   expansion_key(76)&
                                                                      expansion_key(77)&
                                                                   expansion_key(78)&
                                                                   expansion_key(79));
            
 
           my_temp3 (127 downto 0)<= my_temp2 (127 downto 0) xor   (expansion_key(64)&
                                                                   expansion_key(65)&
                                                                expansion_key(66)&
                                                                expansion_key(67)&
                                                                expansion_key(68)&
                                                                expansion_key(69)&
                                                                expansion_key(70)&
                                                                   expansion_key(71)&
                                                                expansion_key(72)&
                                                                expansion_key(73)&
                                                                expansion_key(74)&
                                                                expansion_key(75)&
                                                              expansion_key(76)&
                                                                 expansion_key(77)&
                                                              expansion_key(78)&
                                                              expansion_key(79));
		when Inv_MC6=>
		state        <= Inv_SR7;
		--result is temp4
------------------------------------------------------------------------------------------------------------------		
		when Inv_SR7=>
		state        <= Inv_Sbox7;
		my_temp(255 downto 0)<= my_temp4(255 downto 0);
		
		when Inv_Sbox7 => 
		state        <= Add_RK7;   
       -- temp2 is the result
	             
        when Add_RK7   =>
        state        <= Inv_MC7;
           my_temp3 (255 downto 128)<= my_temp2 (255 downto 128) xor  (expansion_key(48)&
                                                                         expansion_key(49)&
                                                                      expansion_key(50)&
                                                                      expansion_key(51)&
                                                                      expansion_key(52)&
                                                                      expansion_key(53)&
                                                                      expansion_key(54)&
                                                                         expansion_key(55)&
                                                                      expansion_key(56)&
                                                                      expansion_key(57)&
                                                                      expansion_key(58)&
                                                                      expansion_key(59)&
                                                                    expansion_key(60)&
                                                                       expansion_key(61)&
                                                                    expansion_key(62)&
                                                                    expansion_key(63));
            
 
           my_temp3 (127 downto 0)<= my_temp2 (127 downto 0) xor  (expansion_key(48)&
                                                                 expansion_key(49)&
                                                              expansion_key(50)&
                                                              expansion_key(51)&
                                                              expansion_key(52)&
                                                              expansion_key(53)&
                                                              expansion_key(54)&
                                                                 expansion_key(55)&
                                                              expansion_key(56)&
                                                              expansion_key(57)&
                                                              expansion_key(58)&
                                                              expansion_key(59)&
                                                            expansion_key(60)&
                                                               expansion_key(61)&
                                                            expansion_key(62)&
                                                            expansion_key(63));
		when Inv_MC7=>
		state        <= Inv_SR8;
		--result is temp4
------------------------------------------------------------------------------------------------------------------		
		when Inv_SR8=>
		state        <= Inv_Sbox8;
		my_temp(255 downto 0)<= my_temp4(255 downto 0);
		
		when Inv_Sbox8 => 
		state        <= Add_RK8;   
       -- temp2 is the result
	             
        when Add_RK8   =>
        state        <= Inv_MC8;
           my_temp3 (255 downto 128)<= my_temp2 (255 downto 128) xor  (expansion_key(32)&
                                                                      expansion_key(33)&
                                                                   expansion_key(34)&
                                                                   expansion_key(35)&
                                                                   expansion_key(36)&
                                                                   expansion_key(37)&
                                                                   expansion_key(38)&
                                                                      expansion_key(39)&
                                                                   expansion_key(40)&
                                                                   expansion_key(41)&
                                                                   expansion_key(42)&
                                                                   expansion_key(43)&
                                                                 expansion_key(44)&
                                                                    expansion_key(45)&
                                                                 expansion_key(46)&
                                                                 expansion_key(47));
            
 
           my_temp3 (127 downto 0)<= my_temp2 (127 downto 0) xor  (expansion_key(32)&
                                                                   expansion_key(33)&
                                                                expansion_key(34)&
                                                                expansion_key(35)&
                                                                expansion_key(36)&
                                                                expansion_key(37)&
                                                                expansion_key(38)&
                                                                   expansion_key(39)&
                                                                expansion_key(40)&
                                                                expansion_key(41)&
                                                                expansion_key(42)&
                                                                expansion_key(43)&
                                                              expansion_key(44)&
                                                                 expansion_key(45)&
                                                              expansion_key(46)&
                                                              expansion_key(47));
		when Inv_MC8=>
		state        <= Inv_SR9;
		--result is temp4	
		
------------------------------------------------------------------------------------------------------------------		
		when Inv_SR9=>
		state        <= Inv_Sbox9;
		my_temp(255 downto 0)<= my_temp4(255 downto 0);
		
		when Inv_Sbox9 => 
		state        <= Add_RK9;   
       -- temp2 is the result
	             
        when Add_RK9   =>
        state        <= Inv_MC9;
           my_temp3 (255 downto 128)<= my_temp2 (255 downto 128) xor   (expansion_key(16)&
                                                                         expansion_key(17)&
                                                                      expansion_key(18)&
                                                                      expansion_key(19)&
                                                                      expansion_key(20)&
                                                                      expansion_key(21)&
                                                                      expansion_key(22)&
                                                                         expansion_key(23)&
                                                                      expansion_key(24)&
                                                                      expansion_key(25)&
                                                                      expansion_key(26)&
                                                                      expansion_key(27)&
                                                                    expansion_key(28)&
                                                                       expansion_key(29)&
                                                                    expansion_key(30)&
                                                                    expansion_key(31));
            
 
           my_temp3 (127 downto 0)<= my_temp2 (127 downto 0) xor  (expansion_key(16)&
                                                                 expansion_key(17)&
                                                              expansion_key(18)&
                                                              expansion_key(19)&
                                                              expansion_key(20)&
                                                              expansion_key(21)&
                                                              expansion_key(22)&
                                                                 expansion_key(23)&
                                                              expansion_key(24)&
                                                              expansion_key(25)&
                                                              expansion_key(26)&
                                                              expansion_key(27)&
                                                            expansion_key(28)&
                                                               expansion_key(29)&
                                                            expansion_key(30)&
                                                            expansion_key(31));
		when Inv_MC9=>
		state        <= Inv_SR10;
		--result is temp4	
------------------------------------------------------------------------------------------------------------------		
		when Inv_SR10=>
		state        <= Inv_Sbox10;
		my_temp(255 downto 0)<= my_temp4(255 downto 0);
		
		when Inv_Sbox10 => 
		state        <= Add_RK10;   
       -- temp2 is the result
	             
        when Add_RK10   =>
        state        <= Last_Step;
           my_temp3 (255 downto 128)<= my_temp2 (255 downto 128) xor my_key(255 downto 128);
           my_temp3 (127 downto 0)<= my_temp2 (127 downto 0) xor my_key(255 downto 128);

		when Last_Step=>
		state        <= Buffer_Write;
		my_data(255 downto 0)<= my_temp3(255 downto 0);
		 
		  when Buffer_Write => 
                 M_AXIS_TDATA<= my_data(255 downto 224);
                  --nr_of_writes <= nr_of_writes ;
                  nr_of_writes <= NUMBER_OF_OUTPUT_WORDS -1;
                  state <= Write_Outputs;

  
         
          when Write_Outputs =>
            if (M_AXIS_TREADY = '1') then                           
              if (nr_of_writes = 0) then
                state <= Read_Inputs;
                nr_of_reads <= NUMBER_OF_INPUT_WORDS - 1;
                                
              else
           
              if (nr_of_writes=7) then M_AXIS_TDATA<= my_data(223 downto 192); end if;
              if (nr_of_writes=6) then M_AXIS_TDATA<= my_data(191 downto 160); end if;
              if (nr_of_writes=5) then M_AXIS_TDATA<= my_data(159 downto 128); end if;
              if (nr_of_writes=4) then M_AXIS_TDATA<= my_data(127 downto 96); end if;
              if (nr_of_writes=3) then M_AXIS_TDATA<= my_data(95 downto 64); end if;
              if (nr_of_writes=2) then M_AXIS_TDATA<= my_data(63 downto 32); end if;
              if (nr_of_writes=1) then M_AXIS_TDATA<= my_data(31 downto 0); end if;
                nr_of_writes <= nr_of_writes - 1;
              end if; 
            end if;
        end case;
      end if;
    end if;
   end process The_SW_accelerator;

    INV_SR_0:inv_shift
                   port map (
                       d_in=>my_temp(255 downto 128),
                       d_out=>my_temp1(255 downto 128)
                   );
    INV_SR_1:inv_shift
                   port map (
                       d_in=>my_temp(127 downto 0),
                       d_out=>my_temp1(127 downto 0)
                   );
                   
    INV_MC_0:inv_mix
                   port map (
                       d_in=>my_temp3(255 downto 128),
                       d_out=>my_temp4(255 downto 128)
                   );
    INV_MC_1:inv_mix
                   port map (
                       d_in=>my_temp3(127 downto 0),
                       d_out=>my_temp4(127 downto 0)
                   );


inv_s_box_32: FOR i IN 31 DOWNTO 0 GENERATE
    sbox_map:	inv_s_box
    PORT MAP(
	    d_in => my_temp1(8*i+7 downto 8*i),
	    d_out =>my_temp2(8*i+7 downto 8*i)
	    );
END GENERATE inv_s_box_32;
 
end architecture EXAMPLE;



