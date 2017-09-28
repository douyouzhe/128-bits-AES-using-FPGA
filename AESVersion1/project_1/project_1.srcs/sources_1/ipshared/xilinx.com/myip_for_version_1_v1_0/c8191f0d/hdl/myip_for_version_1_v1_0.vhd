library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_logic_unsigned.all;
use ieee.numeric_std.all;

entity AES is
    port 
	(	ACLK	: in	std_logic;
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
end AES;

architecture Behavioral of AES is


  type box is array (0 to 255) of std_logic_vector(7 downto 0);  -- sbox should contain 256 byte
  
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
                           
  constant inv_sbox: box:=( x"52", x"09", x"6A", x"D5", x"30", x"36", x"A5", x"38", x"BF", x"40", x"A3", x"9E", x"81", x"F3", x"D7", x"FB",
                         x"7C", x"E3", x"39", x"82", x"9B", x"2F", x"FF", x"87", x"34", x"8E", x"43", x"44", x"C4", x"DE", x"E9", x"CB",
                         x"54", x"7B", x"94", x"32", x"A6", x"C2", x"23", x"3D", x"EE", x"4C", x"95", x"0B", x"42", x"FA", x"C3", x"4E",
                         x"08", x"2E", x"A1", x"66", x"28", x"D9", x"24", x"B2", x"76", x"5B", x"A2", x"49", x"6D", x"8B", x"D1", x"25",
                         x"72", x"F8", x"F6", x"64", x"86", x"68", x"98", x"16", x"D4", x"A4", x"5C", x"CC", x"5D", x"65", x"B6", x"92",
                         x"6C", x"70", x"48", x"50", x"FD", x"ED", x"B9", x"DA", x"5E", x"15", x"46", x"57", x"A7", x"8D", x"9D", x"84",
                         x"90", x"D8", x"AB", x"00", x"8C", x"BC", x"D3", x"0A", x"F7", x"E4", x"58", x"05", x"B8", x"B3", x"45", x"06",
                         x"D0", x"2C", x"1E", x"8F", x"CA", x"3F", x"0F", x"02", x"C1", x"AF", x"BD", x"03", x"01", x"13", x"8A", x"6B",
                         x"3A", x"91", x"11", x"41", x"4F", x"67", x"DC", x"EA", x"97", x"F2", x"CF", x"CE", x"F0", x"B4", x"E6", x"73",
                         x"96", x"AC", x"74", x"22", x"E7", x"AD", x"35", x"85", x"E2", x"F9", x"37", x"E8", x"1C", x"75", x"DF", x"6E",
                         x"47", x"F1", x"1A", x"71", x"1D", x"29", x"C5", x"89", x"6F", x"B7", x"62", x"0E", x"AA", x"18", x"BE", x"1B",
                         x"FC", x"56", x"3E", x"4B", x"C6", x"D2", x"79", x"20", x"9A", x"DB", x"C0", x"FE", x"78", x"CD", x"5A", x"F4",
                         x"1F", x"DD", x"A8", x"33", x"88", x"07", x"C7", x"31", x"B1", x"12", x"10", x"59", x"27", x"80", x"EC", x"5F",
                         x"60", x"51", x"7F", x"A9", x"19", x"B5", x"4A", x"0D", x"2D", x"E5", x"7A", x"9F", x"93", x"C9", x"9C", x"EF",
                         x"A0", x"E0", x"3B", x"4D", x"AE", x"2A", x"F5", x"B0", x"C8", x"EB", x"BB", x"3C", x"83", x"53", x"99", x"61",
                         x"17", x"2B", x"04", x"7E", x"BA", x"77", x"D6", x"26", x"E1", x"69", x"14", x"63", x"55", x"21", x"0C", x"7D");


  constant sbox9: box:=( x"00",x"09",x"12",x"1b",x"24",x"2d",x"36",x"3f",x"48",x"41",x"5a",x"53",x"6c",x"65",x"7e",x"77",
                         x"90",x"99",x"82",x"8b",x"b4",x"bd",x"a6",x"af",x"d8",x"d1",x"ca",x"c3",x"fc",x"f5",x"ee",x"e7",
                         x"3b",x"32",x"29",x"20",x"1f",x"16",x"0d",x"04",x"73",x"7a",x"61",x"68",x"57",x"5e",x"45",x"4c",
                         x"ab",x"a2",x"b9",x"b0",x"8f",x"86",x"9d",x"94",x"e3",x"ea",x"f1",x"f8",x"c7",x"ce",x"d5",x"dc",
                         x"76",x"7f",x"64",x"6d",x"52",x"5b",x"40",x"49",x"3e",x"37",x"2c",x"25",x"1a",x"13",x"08",x"01",
                         x"e6",x"ef",x"f4",x"fd",x"c2",x"cb",x"d0",x"d9",x"ae",x"a7",x"bc",x"b5",x"8a",x"83",x"98",x"91",
                         x"4d",x"44",x"5f",x"56",x"69",x"60",x"7b",x"72",x"05",x"0c",x"17",x"1e",x"21",x"28",x"33",x"3a",
                         x"dd",x"d4",x"cf",x"c6",x"f9",x"f0",x"eb",x"e2",x"95",x"9c",x"87",x"8e",x"b1",x"b8",x"a3",x"aa",
                         x"ec",x"e5",x"fe",x"f7",x"c8",x"c1",x"da",x"d3",x"a4",x"ad",x"b6",x"bf",x"80",x"89",x"92",x"9b",
                         x"7c",x"75",x"6e",x"67",x"58",x"51",x"4a",x"43",x"34",x"3d",x"26",x"2f",x"10",x"19",x"02",x"0b",
                         x"d7",x"de",x"c5",x"cc",x"f3",x"fa",x"e1",x"e8",x"9f",x"96",x"8d",x"84",x"bb",x"b2",x"a9",x"a0",
                         x"47",x"4e",x"55",x"5c",x"63",x"6a",x"71",x"78",x"0f",x"06",x"1d",x"14",x"2b",x"22",x"39",x"30",
                         x"9a",x"93",x"88",x"81",x"be",x"b7",x"ac",x"a5",x"d2",x"db",x"c0",x"c9",x"f6",x"ff",x"e4",x"ed",
                         x"0a",x"03",x"18",x"11",x"2e",x"27",x"3c",x"35",x"42",x"4b",x"50",x"59",x"66",x"6f",x"74",x"7d",
                         x"a1",x"a8",x"b3",x"ba",x"85",x"8c",x"97",x"9e",x"e9",x"e0",x"fb",x"f2",x"cd",x"c4",x"df",x"d6",
                         x"31",x"38",x"23",x"2a",x"15",x"1c",x"07",x"0e",x"79",x"70",x"6b",x"62",x"5d",x"54",x"4f",x"46");

  constant sbox11:box:=( x"00",x"0b",x"16",x"1d",x"2c",x"27",x"3a",x"31",x"58",x"53",x"4e",x"45",x"74",x"7f",x"62",x"69",
                         x"b0",x"bb",x"a6",x"ad",x"9c",x"97",x"8a",x"81",x"e8",x"e3",x"fe",x"f5",x"c4",x"cf",x"d2",x"d9",
                         x"7b",x"70",x"6d",x"66",x"57",x"5c",x"41",x"4a",x"23",x"28",x"35",x"3e",x"0f",x"04",x"19",x"12",
                         x"cb",x"c0",x"dd",x"d6",x"e7",x"ec",x"f1",x"fa",x"93",x"98",x"85",x"8e",x"bf",x"b4",x"a9",x"a2",
                         x"f6",x"fd",x"e0",x"eb",x"da",x"d1",x"cc",x"c7",x"ae",x"a5",x"b8",x"b3",x"82",x"89",x"94",x"9f",
                         x"46",x"4d",x"50",x"5b",x"6a",x"61",x"7c",x"77",x"1e",x"15",x"08",x"03",x"32",x"39",x"24",x"2f",
                         x"8d",x"86",x"9b",x"90",x"a1",x"aa",x"b7",x"bc",x"d5",x"de",x"c3",x"c8",x"f9",x"f2",x"ef",x"e4",
                         x"3d",x"36",x"2b",x"20",x"11",x"1a",x"07",x"0c",x"65",x"6e",x"73",x"78",x"49",x"42",x"5f",x"54",
                         x"f7",x"fc",x"e1",x"ea",x"db",x"d0",x"cd",x"c6",x"af",x"a4",x"b9",x"b2",x"83",x"88",x"95",x"9e",
                         x"47",x"4c",x"51",x"5a",x"6b",x"60",x"7d",x"76",x"1f",x"14",x"09",x"02",x"33",x"38",x"25",x"2e",
                         x"8c",x"87",x"9a",x"91",x"a0",x"ab",x"b6",x"bd",x"d4",x"df",x"c2",x"c9",x"f8",x"f3",x"ee",x"e5",
                         x"3c",x"37",x"2a",x"21",x"10",x"1b",x"06",x"0d",x"64",x"6f",x"72",x"79",x"48",x"43",x"5e",x"55",
                         x"01",x"0a",x"17",x"1c",x"2d",x"26",x"3b",x"30",x"59",x"52",x"4f",x"44",x"75",x"7e",x"63",x"68",
                         x"b1",x"ba",x"a7",x"ac",x"9d",x"96",x"8b",x"80",x"e9",x"e2",x"ff",x"f4",x"c5",x"ce",x"d3",x"d8",
                         x"7a",x"71",x"6c",x"67",x"56",x"5d",x"40",x"4b",x"22",x"29",x"34",x"3f",x"0e",x"05",x"18",x"13",
                         x"ca",x"c1",x"dc",x"d7",x"e6",x"ed",x"f0",x"fb",x"92",x"99",x"84",x"8f",x"be",x"b5",x"a8",x"a3");
                           
 constant sbox13: box:=( x"00",x"0d",x"1a",x"17",x"34",x"39",x"2e",x"23",x"68",x"65",x"72",x"7f",x"5c",x"51",x"46",x"4b",
                         x"d0",x"dd",x"ca",x"c7",x"e4",x"e9",x"fe",x"f3",x"b8",x"b5",x"a2",x"af",x"8c",x"81",x"96",x"9b",
                         x"bb",x"b6",x"a1",x"ac",x"8f",x"82",x"95",x"98",x"d3",x"de",x"c9",x"c4",x"e7",x"ea",x"fd",x"f0",
                         x"6b",x"66",x"71",x"7c",x"5f",x"52",x"45",x"48",x"03",x"0e",x"19",x"14",x"37",x"3a",x"2d",x"20",
                         x"6d",x"60",x"77",x"7a",x"59",x"54",x"43",x"4e",x"05",x"08",x"1f",x"12",x"31",x"3c",x"2b",x"26",
                         x"bd",x"b0",x"a7",x"aa",x"89",x"84",x"93",x"9e",x"d5",x"d8",x"cf",x"c2",x"e1",x"ec",x"fb",x"f6",
                         x"d6",x"db",x"cc",x"c1",x"e2",x"ef",x"f8",x"f5",x"be",x"b3",x"a4",x"a9",x"8a",x"87",x"90",x"9d",
                         x"06",x"0b",x"1c",x"11",x"32",x"3f",x"28",x"25",x"6e",x"63",x"74",x"79",x"5a",x"57",x"40",x"4d",
                         x"da",x"d7",x"c0",x"cd",x"ee",x"e3",x"f4",x"f9",x"b2",x"bf",x"a8",x"a5",x"86",x"8b",x"9c",x"91",
                         x"0a",x"07",x"10",x"1d",x"3e",x"33",x"24",x"29",x"62",x"6f",x"78",x"75",x"56",x"5b",x"4c",x"41",
                         x"61",x"6c",x"7b",x"76",x"55",x"58",x"4f",x"42",x"09",x"04",x"13",x"1e",x"3d",x"30",x"27",x"2a",
                         x"b1",x"bc",x"ab",x"a6",x"85",x"88",x"9f",x"92",x"d9",x"d4",x"c3",x"ce",x"ed",x"e0",x"f7",x"fa",
                         x"b7",x"ba",x"ad",x"a0",x"83",x"8e",x"99",x"94",x"df",x"d2",x"c5",x"c8",x"eb",x"e6",x"f1",x"fc",
                         x"67",x"6a",x"7d",x"70",x"53",x"5e",x"49",x"44",x"0f",x"02",x"15",x"18",x"3b",x"36",x"21",x"2c",
                         x"0c",x"01",x"16",x"1b",x"38",x"35",x"22",x"2f",x"64",x"69",x"7e",x"73",x"50",x"5d",x"4a",x"47",
                         x"dc",x"d1",x"c6",x"cb",x"e8",x"e5",x"f2",x"ff",x"b4",x"b9",x"ae",x"a3",x"80",x"8d",x"9a",x"97");
   
 constant sbox14: box:=( x"00",x"0e",x"1c",x"12",x"38",x"36",x"24",x"2a",x"70",x"7e",x"6c",x"62",x"48",x"46",x"54",x"5a",
                         x"e0",x"ee",x"fc",x"f2",x"d8",x"d6",x"c4",x"ca",x"90",x"9e",x"8c",x"82",x"a8",x"a6",x"b4",x"ba",
                         x"db",x"d5",x"c7",x"c9",x"e3",x"ed",x"ff",x"f1",x"ab",x"a5",x"b7",x"b9",x"93",x"9d",x"8f",x"81",
                         x"3b",x"35",x"27",x"29",x"03",x"0d",x"1f",x"11",x"4b",x"45",x"57",x"59",x"73",x"7d",x"6f",x"61",
                         x"ad",x"a3",x"b1",x"bf",x"95",x"9b",x"89",x"87",x"dd",x"d3",x"c1",x"cf",x"e5",x"eb",x"f9",x"f7",
                         x"4d",x"43",x"51",x"5f",x"75",x"7b",x"69",x"67",x"3d",x"33",x"21",x"2f",x"05",x"0b",x"19",x"17",
                         x"76",x"78",x"6a",x"64",x"4e",x"40",x"52",x"5c",x"06",x"08",x"1a",x"14",x"3e",x"30",x"22",x"2c",
                         x"96",x"98",x"8a",x"84",x"ae",x"a0",x"b2",x"bc",x"e6",x"e8",x"fa",x"f4",x"de",x"d0",x"c2",x"cc",
                         x"41",x"4f",x"5d",x"53",x"79",x"77",x"65",x"6b",x"31",x"3f",x"2d",x"23",x"09",x"07",x"15",x"1b",
                         x"a1",x"af",x"bd",x"b3",x"99",x"97",x"85",x"8b",x"d1",x"df",x"cd",x"c3",x"e9",x"e7",x"f5",x"fb",
                         x"9a",x"94",x"86",x"88",x"a2",x"ac",x"be",x"b0",x"ea",x"e4",x"f6",x"f8",x"d2",x"dc",x"ce",x"c0",
                         x"7a",x"74",x"66",x"68",x"42",x"4c",x"5e",x"50",x"0a",x"04",x"16",x"18",x"32",x"3c",x"2e",x"20",
                         x"ec",x"e2",x"f0",x"fe",x"d4",x"da",x"c8",x"c6",x"9c",x"92",x"80",x"8e",x"a4",x"aa",x"b8",x"b6",
                         x"0c",x"02",x"10",x"1e",x"34",x"3a",x"28",x"26",x"7c",x"72",x"60",x"6e",x"44",x"4a",x"58",x"56",
                         x"37",x"39",x"2b",x"25",x"0f",x"01",x"13",x"1d",x"47",x"49",x"5b",x"55",x"7f",x"71",x"63",x"6d",
                         x"d7",x"d9",x"cb",x"c5",x"ef",x"e1",x"f3",x"fd",x"a7",x"a9",x"bb",x"b5",x"9f",x"91",x"83",x"8d");


    type RoundConstant is array (0 to 9) of std_logic_vector(7 downto 0);
    constant Rcon:RoundConstant:=(x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"80", x"1b", x"36");
 
   type data is array(0 to 15) of std_logic_vector(7 downto 0);
   signal Ecoded_data:data;
   
   
   type Keyword is array(0 to 175) of std_logic_vector(7 downto 0);

    
   type STATE_TYPE is (Idle, Read_Inputs, Key_expansion,InvMixColumns,AddRoundKey, InvShiftRows, InvSubbytes,Write_Outputs, Buffer_Out);
   signal state: STATE_TYPE;    
   
   signal output: std_logic_vector(31 downto 0);    
   signal round: integer:= 0; 
   signal Key_round: integer := 0;
   signal Key_column: integer := 0;
   signal nr_of_blocks: integer := 0;
   signal nr_of_reads  :integer := 0; 
   signal nr_of_writes :integer := 0;
   signal HasKeyBeenExpanded : boolean := false;

begin
  S_AXIS_TREADY <= '1' when state = Read_Inputs   else '0';
  M_AXIS_TVALID <= '1' when state = Write_Outputs   else '0';
  M_AXIS_TLAST <= '1' when (state = Write_Outputs and nr_of_writes = 16) else '0'; 
  M_AXIS_TDATA <= output;
  
  decryption : process (ACLK) is

  variable temp1:std_logic_vector(7 downto 0);
  variable temp2:std_logic_vector(7 downto 0);
  variable temp3:std_logic_vector(7 downto 0);
  variable temp4:std_logic_vector(7 downto 0);
  variable index,index1: integer := 0;
  variable Key_Schedual: Keyword;

  begin 
   if ACLK'event and ACLK = '1' then   
     if ARESETN = '0' then
       state        <= Idle;
       nr_of_reads  <= 0;
       nr_of_writes <= 0;
       nr_of_blocks <= 0;
       output  <= (others => '0');
     else
       case state is  
         when Idle =>
           if (S_AXIS_TVALID = '1') then   
             state <= Read_Inputs;
             HasKeyBeenExpanded <= false;
             nr_of_writes <= 0;
             nr_of_reads <= 0;
             round <= 10;
             Key_round <= 0;
             nr_of_blocks <= 0;
           end if;
           
         when Read_Inputs =>    
           if (S_AXIS_TVALID = '1') then  
             if (nr_of_reads < 12) then  
                Ecoded_data(nr_of_reads) <= S_AXIS_TDATA(31 downto 24);
                Ecoded_data(nr_of_reads+1) <= S_AXIS_TDATA(23 downto 16);
                Ecoded_data(nr_of_reads+2) <= S_AXIS_TDATA(15 downto 8);
                Ecoded_data(nr_of_reads+3) <= S_AXIS_TDATA(7 downto 0);
                nr_of_reads <= nr_of_reads + 4; 
              elsif(HasKeyBeenExpanded=false) then 
                  Ecoded_data(nr_of_reads) <= S_AXIS_TDATA(31 downto 24);
                  Ecoded_data(nr_of_reads+1) <= S_AXIS_TDATA(23 downto 16);
                  Ecoded_data(nr_of_reads+2) <= S_AXIS_TDATA(15 downto 8);
                  Ecoded_data(nr_of_reads+3) <= S_AXIS_TDATA(7 downto 0);
                  state <= Key_expansion;
              else
                  Ecoded_data(nr_of_reads) <= S_AXIS_TDATA(31 downto 24);
                  Ecoded_data(nr_of_reads+1) <= S_AXIS_TDATA(23 downto 16);
                  Ecoded_data(nr_of_reads+2) <= S_AXIS_TDATA(15 downto 8);
                  Ecoded_data(nr_of_reads+3) <= S_AXIS_TDATA(7 downto 0);
                  state <= AddRoundKey; 
                  nr_of_reads <= 0;
                  round <= 10;
              end if;
          end if;
           
         when Key_expansion => 
           if (Key_round = 0) then  
             Key_Schedual(0) := Ecoded_data(0); Key_Schedual(1) := Ecoded_data(1); Key_Schedual(2) := Ecoded_data(2); Key_Schedual(3) := Ecoded_data(3);
             Key_Schedual(4) := Ecoded_data(4); Key_Schedual(5) := Ecoded_data(5); Key_Schedual(6) := Ecoded_data(6); Key_Schedual(7) := Ecoded_data(7);
             Key_Schedual(8) := Ecoded_data(8); Key_Schedual(9) := Ecoded_data(9); Key_Schedual(10):= Ecoded_data(10);Key_Schedual(11):= Ecoded_data(11);
             Key_Schedual(12):= Ecoded_data(12);Key_Schedual(13):= Ecoded_data(13);Key_Schedual(14):= Ecoded_data(14);Key_Schedual(15):= Ecoded_data(15); 
           elsif(Key_round <= 10) then
                   index := Key_round * 16;
                   temp1 := Key_Schedual(index -4);  
                   Key_Schedual(index) := sbox(to_integer(unsigned(Key_Schedual(index -3)))) xor Rcon(Key_round -1) xor Key_Schedual(index-16);
                   Key_Schedual(index+1) := sbox(to_integer(unsigned(Key_Schedual(index -2)))) xor Key_Schedual(index-15);
                   Key_Schedual(index+2) := sbox(to_integer(unsigned(Key_Schedual(index -1)))) xor Key_Schedual(index-14);
                   Key_Schedual(index+3) :=  sbox(to_integer(unsigned(temp1))) xor Key_Schedual(index-13);
                   Key_Schedual(index+4) := Key_Schedual(index-12) xor Key_Schedual(index);
                   Key_Schedual(index + 5) := Key_Schedual(index-11) xor Key_Schedual(index+1);
                   Key_Schedual(index + 6) := Key_Schedual(index-10) xor Key_Schedual(index+2);
                   Key_Schedual(index + 7) := Key_Schedual(index-9) xor Key_Schedual(index+3);             
                   Key_Schedual(index+8) := Key_Schedual(index-8) xor Key_Schedual(index+4);
                   Key_Schedual(index + 9) := Key_Schedual(index-7) xor Key_Schedual(index+5);
                   Key_Schedual(index + 10) := Key_Schedual(index-6) xor Key_Schedual(index+6);
                   Key_Schedual(index + 11) := Key_Schedual(index-5) xor Key_Schedual(index+7);                                    
                   Key_Schedual(index+12) := Key_Schedual(index-4) xor Key_Schedual(index+8);
                   Key_Schedual(index + 13) := Key_Schedual(index-3) xor Key_Schedual(index+9);
                   Key_Schedual(index + 14) := Key_Schedual(index-2) xor Key_Schedual(index+10);
                   Key_Schedual(index + 15) := Key_Schedual(index-1) xor Key_Schedual(index+11);
             end if;      
             if (Key_round = 10) then 
                    Key_round <= 0; 
                    nr_of_reads <= 0;
                    nr_of_writes <= 0;
                    nr_of_blocks <= 0;   
                    state <= Read_Inputs;  
                    HasKeyBeenExpanded <= true;              
             else
                    Key_round <= Key_round +1;
             end if;
             
        when InvShiftRows=>
              temp1 := Ecoded_data(13);
              Ecoded_data(13)  <= Ecoded_data(9);
              Ecoded_data(9)  <= Ecoded_data(5);
              Ecoded_data(5)  <= Ecoded_data(1);
              Ecoded_data(1)  <= temp1;              
              temp2 := Ecoded_data(2);
              temp3 := Ecoded_data(6);
              Ecoded_data(2) <= Ecoded_data(10);
              Ecoded_data(6) <= Ecoded_data(14);
              Ecoded_data(10) <= temp2;
              Ecoded_data(14) <= temp3;
              temp4 := Ecoded_data(3);
              Ecoded_data(3)  <= Ecoded_data(7);
              Ecoded_data(7)  <= Ecoded_data(11);
              Ecoded_data(11)  <= Ecoded_data(15);
              Ecoded_data(15)  <= temp4;
              state <= InvSubbytes;   
             
        when InvSubbytes =>
             Ecoded_data(0) <= inv_sbox(to_integer(unsigned(Ecoded_data(0)))); Ecoded_data(1) <= inv_sbox(to_integer(unsigned(Ecoded_data(1))));
             Ecoded_data(2) <= inv_sbox(to_integer(unsigned(Ecoded_data(2)))); Ecoded_data(3) <= inv_sbox(to_integer(unsigned(Ecoded_data(3))));
             Ecoded_data(4) <= inv_sbox(to_integer(unsigned(Ecoded_data(4)))); Ecoded_data(5) <= inv_sbox(to_integer(unsigned(Ecoded_data(5))));
             Ecoded_data(6) <= inv_sbox(to_integer(unsigned(Ecoded_data(6))));Ecoded_data(7) <= inv_sbox(to_integer(unsigned(Ecoded_data(7))));
             Ecoded_data(8)  <= inv_sbox(to_integer(unsigned(Ecoded_data(8)))); Ecoded_data(9) <= inv_sbox(to_integer(unsigned(Ecoded_data(9))));
             Ecoded_data(10) <= inv_sbox(to_integer(unsigned(Ecoded_data(10)))); Ecoded_data(11) <= inv_sbox(to_integer(unsigned(Ecoded_data(11))));
             Ecoded_data(12)  <= inv_sbox(to_integer(unsigned(Ecoded_data(12))));Ecoded_data(13) <= inv_sbox(to_integer(unsigned(Ecoded_data(13))));
             Ecoded_data(14) <= inv_sbox(to_integer(unsigned(Ecoded_data(14))));Ecoded_data(15) <= inv_sbox(to_integer(unsigned(Ecoded_data(15))));  
             state <= AddRoundKey;
			 
			          
         when InvMixColumns =>
               Ecoded_data(0)<=sbox14(to_integer(unsigned(Ecoded_data(0)))) xor sbox11(to_integer(unsigned(Ecoded_data(1)))) xor sbox13(to_integer(unsigned(Ecoded_data(2)))) xor sbox9(to_integer(unsigned(Ecoded_data(3))));
               Ecoded_data(1)<=sbox9(to_integer(unsigned(Ecoded_data(0)))) xor sbox14(to_integer(unsigned(Ecoded_data(1)))) xor sbox11(to_integer(unsigned(Ecoded_data(2)))) xor sbox13(to_integer(unsigned(Ecoded_data(3))));
               Ecoded_data(2)<=sbox13(to_integer(unsigned(Ecoded_data(0)))) xor sbox9(to_integer(unsigned(Ecoded_data(1)))) xor sbox14(to_integer(unsigned(Ecoded_data(2)))) xor sbox11(to_integer(unsigned(Ecoded_data(3))));
               Ecoded_data(3)<=sbox11(to_integer(unsigned(Ecoded_data(0)))) xor sbox13(to_integer(unsigned(Ecoded_data(1)))) xor sbox9(to_integer(unsigned(Ecoded_data(2)))) xor sbox14(to_integer(unsigned(Ecoded_data(3))));
               Ecoded_data(4)<=sbox14(to_integer(unsigned(Ecoded_data(4)))) xor sbox11(to_integer(unsigned(Ecoded_data(5)))) xor sbox13(to_integer(unsigned(Ecoded_data(6)))) xor sbox9(to_integer(unsigned(Ecoded_data(7))));
               Ecoded_data(5)<=sbox9(to_integer(unsigned(Ecoded_data(4)))) xor sbox14(to_integer(unsigned(Ecoded_data(5)))) xor sbox11(to_integer(unsigned(Ecoded_data(6)))) xor sbox13(to_integer(unsigned(Ecoded_data(7))));
               Ecoded_data(6)<=sbox13(to_integer(unsigned(Ecoded_data(4)))) xor sbox9(to_integer(unsigned(Ecoded_data(5)))) xor sbox14(to_integer(unsigned(Ecoded_data(6)))) xor sbox11(to_integer(unsigned(Ecoded_data(7))));
               Ecoded_data(7)<=sbox11(to_integer(unsigned(Ecoded_data(4)))) xor sbox13(to_integer(unsigned(Ecoded_data(5)))) xor sbox9(to_integer(unsigned(Ecoded_data(6)))) xor sbox14(to_integer(unsigned(Ecoded_data(7))));
               Ecoded_data(8)<=sbox14(to_integer(unsigned(Ecoded_data(8)))) xor sbox11(to_integer(unsigned(Ecoded_data(9)))) xor sbox13(to_integer(unsigned(Ecoded_data(10)))) xor sbox9(to_integer(unsigned(Ecoded_data(11))));
               Ecoded_data(9)<=sbox9(to_integer(unsigned(Ecoded_data(8)))) xor sbox14(to_integer(unsigned(Ecoded_data(9)))) xor sbox11(to_integer(unsigned(Ecoded_data(10)))) xor sbox13(to_integer(unsigned(Ecoded_data(11))));
               Ecoded_data(10)<=sbox13(to_integer(unsigned(Ecoded_data(8)))) xor sbox9(to_integer(unsigned(Ecoded_data(9)))) xor sbox14(to_integer(unsigned(Ecoded_data(10)))) xor sbox11(to_integer(unsigned(Ecoded_data(11))));
               Ecoded_data(11)<=sbox11(to_integer(unsigned(Ecoded_data(8)))) xor sbox13(to_integer(unsigned(Ecoded_data(9)))) xor sbox9(to_integer(unsigned(Ecoded_data(10)))) xor sbox14(to_integer(unsigned(Ecoded_data(11))));
               Ecoded_data(12)<=sbox14(to_integer(unsigned(Ecoded_data(12)))) xor sbox11(to_integer(unsigned(Ecoded_data(13)))) xor sbox13(to_integer(unsigned(Ecoded_data(14)))) xor sbox9(to_integer(unsigned(Ecoded_data(15))));
               Ecoded_data(13)<=sbox9(to_integer(unsigned(Ecoded_data(12)))) xor sbox14(to_integer(unsigned(Ecoded_data(13)))) xor sbox11(to_integer(unsigned(Ecoded_data(14)))) xor sbox13(to_integer(unsigned(Ecoded_data(15))));
               Ecoded_data(14)<=sbox13(to_integer(unsigned(Ecoded_data(12)))) xor sbox9(to_integer(unsigned(Ecoded_data(13)))) xor sbox14(to_integer(unsigned(Ecoded_data(14)))) xor sbox11(to_integer(unsigned(Ecoded_data(15))));
               Ecoded_data(15)<=sbox11(to_integer(unsigned(Ecoded_data(12)))) xor sbox13(to_integer(unsigned(Ecoded_data(13)))) xor sbox9(to_integer(unsigned(Ecoded_data(14)))) xor sbox14(to_integer(unsigned(Ecoded_data(15))));                    
               state <= InvShiftRows;
                 
        when AddRoundKey=>
              index1 := round*16;  
              Ecoded_data(0) <= Ecoded_data(0) xor Key_Schedual(index1);  
              Ecoded_data(1) <= Ecoded_data(1) xor Key_Schedual(index1+1);
              Ecoded_data(2) <= Ecoded_data(2) xor Key_Schedual(index1+2);
              Ecoded_data(3) <= Ecoded_data(3) xor Key_Schedual(index1+3);
              Ecoded_data(4) <= Ecoded_data(4) xor Key_Schedual(index1+4);
              Ecoded_data(5) <= Ecoded_data(5) xor Key_Schedual(index1+5);
              Ecoded_data(6) <= Ecoded_data(6) xor Key_Schedual(index1+6);
              Ecoded_data(7) <= Ecoded_data(7) xor Key_Schedual(index1+7);
              Ecoded_data(8) <= Ecoded_data(8) xor Key_Schedual(index1+8);
              Ecoded_data(9) <= Ecoded_data(9) xor Key_Schedual(index1+9);
              Ecoded_data(10) <= Ecoded_data(10) xor Key_Schedual(index1+10);
              Ecoded_data(11) <= Ecoded_data(11) xor Key_Schedual(index1+11);
              Ecoded_data(12) <= Ecoded_data(12) xor Key_Schedual(index1+12);
              Ecoded_data(13) <= Ecoded_data(13) xor Key_Schedual(index1+13);
              Ecoded_data(14) <= Ecoded_data(14) xor Key_Schedual(index1+14);
              Ecoded_data(15) <= Ecoded_data(15) xor Key_Schedual(index1+15);     
              if(round = 10) then 
                state <= InvShiftRows;
              elsif(round = 0) then 
                state <= Buffer_Out;
              else
                state <= InvMixcolumns;
              end if;              
              round <= round -1;  
              
         when Buffer_Out =>
              output <= Ecoded_data(0) & Ecoded_data(1) & Ecoded_data(2) & Ecoded_data(3);
                state <= Write_Outputs;
               nr_of_writes <= nr_of_writes+4;
             
         
              
                       
        when Write_Outputs =>
           if (M_AXIS_TREADY = '1') then                           
             if (nr_of_writes > 15 and nr_of_blocks=1920) then
               state <= Idle;
               nr_of_writes <= 0;
             elsif (nr_of_writes > 15 and nr_of_blocks<1920) then
               state <= Read_Inputs;
               nr_of_writes <= 0;
               nr_of_blocks <= nr_of_blocks +1;           
             else
               output <= Ecoded_data(nr_of_writes) & Ecoded_data(nr_of_writes+1) & Ecoded_data(nr_of_writes+2) & Ecoded_data(nr_of_writes+3);
               nr_of_writes <= nr_of_writes+4;
             end if;
           end if;           
       end case;     
     end if;
   end if;
  
  end process decryption;
end Behavioral;