
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"7f",x"7f",x"00",x"00"),
     1 => (x"66",x"7f",x"19",x"09"),
     2 => (x"6f",x"26",x"00",x"00"),
     3 => (x"32",x"7b",x"59",x"4d"),
     4 => (x"01",x"01",x"00",x"00"),
     5 => (x"01",x"01",x"7f",x"7f"),
     6 => (x"7f",x"3f",x"00",x"00"),
     7 => (x"3f",x"7f",x"40",x"40"),
     8 => (x"3f",x"0f",x"00",x"00"),
     9 => (x"0f",x"3f",x"70",x"70"),
    10 => (x"30",x"7f",x"7f",x"00"),
    11 => (x"7f",x"7f",x"30",x"18"),
    12 => (x"36",x"63",x"41",x"00"),
    13 => (x"63",x"36",x"1c",x"1c"),
    14 => (x"06",x"03",x"01",x"41"),
    15 => (x"03",x"06",x"7c",x"7c"),
    16 => (x"59",x"71",x"61",x"01"),
    17 => (x"41",x"43",x"47",x"4d"),
    18 => (x"7f",x"00",x"00",x"00"),
    19 => (x"00",x"41",x"41",x"7f"),
    20 => (x"06",x"03",x"01",x"00"),
    21 => (x"60",x"30",x"18",x"0c"),
    22 => (x"41",x"00",x"00",x"40"),
    23 => (x"00",x"7f",x"7f",x"41"),
    24 => (x"06",x"0c",x"08",x"00"),
    25 => (x"08",x"0c",x"06",x"03"),
    26 => (x"80",x"80",x"80",x"00"),
    27 => (x"80",x"80",x"80",x"80"),
    28 => (x"00",x"00",x"00",x"00"),
    29 => (x"00",x"04",x"07",x"03"),
    30 => (x"74",x"20",x"00",x"00"),
    31 => (x"78",x"7c",x"54",x"54"),
    32 => (x"7f",x"7f",x"00",x"00"),
    33 => (x"38",x"7c",x"44",x"44"),
    34 => (x"7c",x"38",x"00",x"00"),
    35 => (x"00",x"44",x"44",x"44"),
    36 => (x"7c",x"38",x"00",x"00"),
    37 => (x"7f",x"7f",x"44",x"44"),
    38 => (x"7c",x"38",x"00",x"00"),
    39 => (x"18",x"5c",x"54",x"54"),
    40 => (x"7e",x"04",x"00",x"00"),
    41 => (x"00",x"05",x"05",x"7f"),
    42 => (x"bc",x"18",x"00",x"00"),
    43 => (x"7c",x"fc",x"a4",x"a4"),
    44 => (x"7f",x"7f",x"00",x"00"),
    45 => (x"78",x"7c",x"04",x"04"),
    46 => (x"00",x"00",x"00",x"00"),
    47 => (x"00",x"40",x"7d",x"3d"),
    48 => (x"80",x"80",x"00",x"00"),
    49 => (x"00",x"7d",x"fd",x"80"),
    50 => (x"7f",x"7f",x"00",x"00"),
    51 => (x"44",x"6c",x"38",x"10"),
    52 => (x"00",x"00",x"00",x"00"),
    53 => (x"00",x"40",x"7f",x"3f"),
    54 => (x"0c",x"7c",x"7c",x"00"),
    55 => (x"78",x"7c",x"0c",x"18"),
    56 => (x"7c",x"7c",x"00",x"00"),
    57 => (x"78",x"7c",x"04",x"04"),
    58 => (x"7c",x"38",x"00",x"00"),
    59 => (x"38",x"7c",x"44",x"44"),
    60 => (x"fc",x"fc",x"00",x"00"),
    61 => (x"18",x"3c",x"24",x"24"),
    62 => (x"3c",x"18",x"00",x"00"),
    63 => (x"fc",x"fc",x"24",x"24"),
    64 => (x"7c",x"7c",x"00",x"00"),
    65 => (x"08",x"0c",x"04",x"04"),
    66 => (x"5c",x"48",x"00",x"00"),
    67 => (x"20",x"74",x"54",x"54"),
    68 => (x"3f",x"04",x"00",x"00"),
    69 => (x"00",x"44",x"44",x"7f"),
    70 => (x"7c",x"3c",x"00",x"00"),
    71 => (x"7c",x"7c",x"40",x"40"),
    72 => (x"3c",x"1c",x"00",x"00"),
    73 => (x"1c",x"3c",x"60",x"60"),
    74 => (x"60",x"7c",x"3c",x"00"),
    75 => (x"3c",x"7c",x"60",x"30"),
    76 => (x"38",x"6c",x"44",x"00"),
    77 => (x"44",x"6c",x"38",x"10"),
    78 => (x"bc",x"1c",x"00",x"00"),
    79 => (x"1c",x"3c",x"60",x"e0"),
    80 => (x"64",x"44",x"00",x"00"),
    81 => (x"44",x"4c",x"5c",x"74"),
    82 => (x"08",x"08",x"00",x"00"),
    83 => (x"41",x"41",x"77",x"3e"),
    84 => (x"00",x"00",x"00",x"00"),
    85 => (x"00",x"00",x"7f",x"7f"),
    86 => (x"41",x"41",x"00",x"00"),
    87 => (x"08",x"08",x"3e",x"77"),
    88 => (x"01",x"01",x"02",x"00"),
    89 => (x"01",x"02",x"02",x"03"),
    90 => (x"7f",x"7f",x"7f",x"00"),
    91 => (x"7f",x"7f",x"7f",x"7f"),
    92 => (x"1c",x"08",x"08",x"00"),
    93 => (x"7f",x"3e",x"3e",x"1c"),
    94 => (x"3e",x"7f",x"7f",x"7f"),
    95 => (x"08",x"1c",x"1c",x"3e"),
    96 => (x"18",x"10",x"00",x"08"),
    97 => (x"10",x"18",x"7c",x"7c"),
    98 => (x"30",x"10",x"00",x"00"),
    99 => (x"10",x"30",x"7c",x"7c"),
   100 => (x"60",x"30",x"10",x"00"),
   101 => (x"06",x"1e",x"78",x"60"),
   102 => (x"3c",x"66",x"42",x"00"),
   103 => (x"42",x"66",x"3c",x"18"),
   104 => (x"6a",x"38",x"78",x"00"),
   105 => (x"38",x"6c",x"c6",x"c2"),
   106 => (x"00",x"00",x"60",x"00"),
   107 => (x"60",x"00",x"00",x"60"),
   108 => (x"5b",x"5e",x"0e",x"00"),
   109 => (x"1e",x"0e",x"5d",x"5c"),
   110 => (x"f4",x"c2",x"4c",x"71"),
   111 => (x"c0",x"4d",x"bf",x"fe"),
   112 => (x"74",x"1e",x"c0",x"4b"),
   113 => (x"87",x"c7",x"02",x"ab"),
   114 => (x"c0",x"48",x"a6",x"c4"),
   115 => (x"c4",x"87",x"c5",x"78"),
   116 => (x"78",x"c1",x"48",x"a6"),
   117 => (x"73",x"1e",x"66",x"c4"),
   118 => (x"87",x"df",x"ee",x"49"),
   119 => (x"e0",x"c0",x"86",x"c8"),
   120 => (x"87",x"ef",x"ef",x"49"),
   121 => (x"6a",x"4a",x"a5",x"c4"),
   122 => (x"87",x"f0",x"f0",x"49"),
   123 => (x"cb",x"87",x"c6",x"f1"),
   124 => (x"c8",x"83",x"c1",x"85"),
   125 => (x"ff",x"04",x"ab",x"b7"),
   126 => (x"26",x"26",x"87",x"c7"),
   127 => (x"26",x"4c",x"26",x"4d"),
   128 => (x"1e",x"4f",x"26",x"4b"),
   129 => (x"f5",x"c2",x"4a",x"71"),
   130 => (x"f5",x"c2",x"5a",x"c2"),
   131 => (x"78",x"c7",x"48",x"c2"),
   132 => (x"87",x"dd",x"fe",x"49"),
   133 => (x"73",x"1e",x"4f",x"26"),
   134 => (x"c0",x"4a",x"71",x"1e"),
   135 => (x"d3",x"03",x"aa",x"b7"),
   136 => (x"e7",x"d5",x"c2",x"87"),
   137 => (x"87",x"c4",x"05",x"bf"),
   138 => (x"87",x"c2",x"4b",x"c1"),
   139 => (x"d5",x"c2",x"4b",x"c0"),
   140 => (x"87",x"c4",x"5b",x"eb"),
   141 => (x"5a",x"eb",x"d5",x"c2"),
   142 => (x"bf",x"e7",x"d5",x"c2"),
   143 => (x"c1",x"9a",x"c1",x"4a"),
   144 => (x"ec",x"49",x"a2",x"c0"),
   145 => (x"48",x"fc",x"87",x"e8"),
   146 => (x"bf",x"e7",x"d5",x"c2"),
   147 => (x"87",x"ef",x"fe",x"78"),
   148 => (x"c4",x"4a",x"71",x"1e"),
   149 => (x"49",x"72",x"1e",x"66"),
   150 => (x"26",x"87",x"fd",x"e9"),
   151 => (x"c2",x"1e",x"4f",x"26"),
   152 => (x"49",x"bf",x"e7",x"d5"),
   153 => (x"c2",x"87",x"d7",x"e6"),
   154 => (x"e8",x"48",x"f6",x"f4"),
   155 => (x"f4",x"c2",x"78",x"bf"),
   156 => (x"bf",x"ec",x"48",x"f2"),
   157 => (x"f6",x"f4",x"c2",x"78"),
   158 => (x"c3",x"49",x"4a",x"bf"),
   159 => (x"b7",x"c8",x"99",x"ff"),
   160 => (x"71",x"48",x"72",x"2a"),
   161 => (x"fe",x"f4",x"c2",x"b0"),
   162 => (x"0e",x"4f",x"26",x"58"),
   163 => (x"5d",x"5c",x"5b",x"5e"),
   164 => (x"ff",x"4b",x"71",x"0e"),
   165 => (x"f4",x"c2",x"87",x"c8"),
   166 => (x"50",x"c0",x"48",x"f1"),
   167 => (x"fd",x"e5",x"49",x"73"),
   168 => (x"4c",x"49",x"70",x"87"),
   169 => (x"ee",x"cb",x"9c",x"c2"),
   170 => (x"87",x"c3",x"cb",x"49"),
   171 => (x"c2",x"4d",x"49",x"70"),
   172 => (x"bf",x"97",x"f1",x"f4"),
   173 => (x"87",x"e2",x"c1",x"05"),
   174 => (x"c2",x"49",x"66",x"d0"),
   175 => (x"99",x"bf",x"fa",x"f4"),
   176 => (x"d4",x"87",x"d6",x"05"),
   177 => (x"f4",x"c2",x"49",x"66"),
   178 => (x"05",x"99",x"bf",x"f2"),
   179 => (x"49",x"73",x"87",x"cb"),
   180 => (x"70",x"87",x"cb",x"e5"),
   181 => (x"c1",x"c1",x"02",x"98"),
   182 => (x"fe",x"4c",x"c1",x"87"),
   183 => (x"49",x"75",x"87",x"c0"),
   184 => (x"70",x"87",x"d8",x"ca"),
   185 => (x"87",x"c6",x"02",x"98"),
   186 => (x"48",x"f1",x"f4",x"c2"),
   187 => (x"f4",x"c2",x"50",x"c1"),
   188 => (x"05",x"bf",x"97",x"f1"),
   189 => (x"c2",x"87",x"e3",x"c0"),
   190 => (x"49",x"bf",x"fa",x"f4"),
   191 => (x"05",x"99",x"66",x"d0"),
   192 => (x"c2",x"87",x"d6",x"ff"),
   193 => (x"49",x"bf",x"f2",x"f4"),
   194 => (x"05",x"99",x"66",x"d4"),
   195 => (x"73",x"87",x"ca",x"ff"),
   196 => (x"87",x"ca",x"e4",x"49"),
   197 => (x"fe",x"05",x"98",x"70"),
   198 => (x"48",x"74",x"87",x"ff"),
   199 => (x"0e",x"87",x"dc",x"fb"),
   200 => (x"5d",x"5c",x"5b",x"5e"),
   201 => (x"c0",x"86",x"f4",x"0e"),
   202 => (x"bf",x"ec",x"4c",x"4d"),
   203 => (x"48",x"a6",x"c4",x"7e"),
   204 => (x"bf",x"fe",x"f4",x"c2"),
   205 => (x"c0",x"1e",x"c1",x"78"),
   206 => (x"fd",x"49",x"c7",x"1e"),
   207 => (x"86",x"c8",x"87",x"cd"),
   208 => (x"cd",x"02",x"98",x"70"),
   209 => (x"fb",x"49",x"ff",x"87"),
   210 => (x"da",x"c1",x"87",x"cc"),
   211 => (x"87",x"ce",x"e3",x"49"),
   212 => (x"f4",x"c2",x"4d",x"c1"),
   213 => (x"02",x"bf",x"97",x"f1"),
   214 => (x"c3",x"d5",x"87",x"c3"),
   215 => (x"f6",x"f4",x"c2",x"87"),
   216 => (x"d5",x"c2",x"4b",x"bf"),
   217 => (x"c0",x"05",x"bf",x"e7"),
   218 => (x"fd",x"c3",x"87",x"e9"),
   219 => (x"87",x"ee",x"e2",x"49"),
   220 => (x"e2",x"49",x"fa",x"c3"),
   221 => (x"49",x"73",x"87",x"e8"),
   222 => (x"71",x"99",x"ff",x"c3"),
   223 => (x"fb",x"49",x"c0",x"1e"),
   224 => (x"49",x"73",x"87",x"ce"),
   225 => (x"71",x"29",x"b7",x"c8"),
   226 => (x"fb",x"49",x"c1",x"1e"),
   227 => (x"86",x"c8",x"87",x"c2"),
   228 => (x"c2",x"87",x"fa",x"c5"),
   229 => (x"4b",x"bf",x"fa",x"f4"),
   230 => (x"87",x"dd",x"02",x"9b"),
   231 => (x"bf",x"e3",x"d5",x"c2"),
   232 => (x"87",x"d7",x"c7",x"49"),
   233 => (x"c4",x"05",x"98",x"70"),
   234 => (x"d2",x"4b",x"c0",x"87"),
   235 => (x"49",x"e0",x"c2",x"87"),
   236 => (x"c2",x"87",x"fc",x"c6"),
   237 => (x"c6",x"58",x"e7",x"d5"),
   238 => (x"e3",x"d5",x"c2",x"87"),
   239 => (x"73",x"78",x"c0",x"48"),
   240 => (x"05",x"99",x"c2",x"49"),
   241 => (x"eb",x"c3",x"87",x"cd"),
   242 => (x"87",x"d2",x"e1",x"49"),
   243 => (x"99",x"c2",x"49",x"70"),
   244 => (x"fb",x"87",x"c2",x"02"),
   245 => (x"c1",x"49",x"73",x"4c"),
   246 => (x"87",x"cd",x"05",x"99"),
   247 => (x"e0",x"49",x"f4",x"c3"),
   248 => (x"49",x"70",x"87",x"fc"),
   249 => (x"c2",x"02",x"99",x"c2"),
   250 => (x"73",x"4c",x"fa",x"87"),
   251 => (x"05",x"99",x"c8",x"49"),
   252 => (x"f5",x"c3",x"87",x"cd"),
   253 => (x"87",x"e6",x"e0",x"49"),
   254 => (x"99",x"c2",x"49",x"70"),
   255 => (x"c2",x"87",x"d4",x"02"),
   256 => (x"02",x"bf",x"c2",x"f5"),
   257 => (x"c1",x"48",x"87",x"c9"),
   258 => (x"c6",x"f5",x"c2",x"88"),
   259 => (x"ff",x"87",x"c2",x"58"),
   260 => (x"73",x"4d",x"c1",x"4c"),
   261 => (x"05",x"99",x"c4",x"49"),
   262 => (x"f2",x"c3",x"87",x"ce"),
   263 => (x"fd",x"df",x"ff",x"49"),
   264 => (x"c2",x"49",x"70",x"87"),
   265 => (x"87",x"db",x"02",x"99"),
   266 => (x"bf",x"c2",x"f5",x"c2"),
   267 => (x"b7",x"c7",x"48",x"7e"),
   268 => (x"87",x"cb",x"03",x"a8"),
   269 => (x"80",x"c1",x"48",x"6e"),
   270 => (x"58",x"c6",x"f5",x"c2"),
   271 => (x"fe",x"87",x"c2",x"c0"),
   272 => (x"c3",x"4d",x"c1",x"4c"),
   273 => (x"df",x"ff",x"49",x"fd"),
   274 => (x"49",x"70",x"87",x"d4"),
   275 => (x"d5",x"02",x"99",x"c2"),
   276 => (x"c2",x"f5",x"c2",x"87"),
   277 => (x"c9",x"c0",x"02",x"bf"),
   278 => (x"c2",x"f5",x"c2",x"87"),
   279 => (x"c0",x"78",x"c0",x"48"),
   280 => (x"4c",x"fd",x"87",x"c2"),
   281 => (x"fa",x"c3",x"4d",x"c1"),
   282 => (x"f1",x"de",x"ff",x"49"),
   283 => (x"c2",x"49",x"70",x"87"),
   284 => (x"87",x"d9",x"02",x"99"),
   285 => (x"bf",x"c2",x"f5",x"c2"),
   286 => (x"a8",x"b7",x"c7",x"48"),
   287 => (x"87",x"c9",x"c0",x"03"),
   288 => (x"48",x"c2",x"f5",x"c2"),
   289 => (x"c2",x"c0",x"78",x"c7"),
   290 => (x"c1",x"4c",x"fc",x"87"),
   291 => (x"ac",x"b7",x"c0",x"4d"),
   292 => (x"87",x"d1",x"c0",x"03"),
   293 => (x"c1",x"4a",x"66",x"c4"),
   294 => (x"02",x"6a",x"82",x"d8"),
   295 => (x"6a",x"87",x"c6",x"c0"),
   296 => (x"73",x"49",x"74",x"4b"),
   297 => (x"c3",x"1e",x"c0",x"0f"),
   298 => (x"da",x"c1",x"1e",x"f0"),
   299 => (x"87",x"db",x"f7",x"49"),
   300 => (x"98",x"70",x"86",x"c8"),
   301 => (x"87",x"e2",x"c0",x"02"),
   302 => (x"c2",x"48",x"a6",x"c8"),
   303 => (x"78",x"bf",x"c2",x"f5"),
   304 => (x"cb",x"49",x"66",x"c8"),
   305 => (x"48",x"66",x"c4",x"91"),
   306 => (x"7e",x"70",x"80",x"71"),
   307 => (x"c0",x"02",x"bf",x"6e"),
   308 => (x"bf",x"6e",x"87",x"c8"),
   309 => (x"49",x"66",x"c8",x"4b"),
   310 => (x"9d",x"75",x"0f",x"73"),
   311 => (x"87",x"c8",x"c0",x"02"),
   312 => (x"bf",x"c2",x"f5",x"c2"),
   313 => (x"87",x"c9",x"f3",x"49"),
   314 => (x"bf",x"eb",x"d5",x"c2"),
   315 => (x"87",x"dd",x"c0",x"02"),
   316 => (x"87",x"c7",x"c2",x"49"),
   317 => (x"c0",x"02",x"98",x"70"),
   318 => (x"f5",x"c2",x"87",x"d3"),
   319 => (x"f2",x"49",x"bf",x"c2"),
   320 => (x"49",x"c0",x"87",x"ef"),
   321 => (x"c2",x"87",x"cf",x"f4"),
   322 => (x"c0",x"48",x"eb",x"d5"),
   323 => (x"f3",x"8e",x"f4",x"78"),
   324 => (x"5e",x"0e",x"87",x"e9"),
   325 => (x"0e",x"5d",x"5c",x"5b"),
   326 => (x"c2",x"4c",x"71",x"1e"),
   327 => (x"49",x"bf",x"fe",x"f4"),
   328 => (x"4d",x"a1",x"cd",x"c1"),
   329 => (x"69",x"81",x"d1",x"c1"),
   330 => (x"02",x"9c",x"74",x"7e"),
   331 => (x"a5",x"c4",x"87",x"cf"),
   332 => (x"c2",x"7b",x"74",x"4b"),
   333 => (x"49",x"bf",x"fe",x"f4"),
   334 => (x"6e",x"87",x"c8",x"f3"),
   335 => (x"05",x"9c",x"74",x"7b"),
   336 => (x"4b",x"c0",x"87",x"c4"),
   337 => (x"4b",x"c1",x"87",x"c2"),
   338 => (x"c9",x"f3",x"49",x"73"),
   339 => (x"02",x"66",x"d4",x"87"),
   340 => (x"da",x"49",x"87",x"c7"),
   341 => (x"c2",x"4a",x"70",x"87"),
   342 => (x"c2",x"4a",x"c0",x"87"),
   343 => (x"26",x"5a",x"ef",x"d5"),
   344 => (x"00",x"87",x"d8",x"f2"),
   345 => (x"00",x"00",x"00",x"00"),
   346 => (x"00",x"00",x"00",x"00"),
   347 => (x"1e",x"00",x"00",x"00"),
   348 => (x"c8",x"ff",x"4a",x"71"),
   349 => (x"a1",x"72",x"49",x"bf"),
   350 => (x"1e",x"4f",x"26",x"48"),
   351 => (x"89",x"bf",x"c8",x"ff"),
   352 => (x"c0",x"c0",x"c0",x"fe"),
   353 => (x"01",x"a9",x"c0",x"c0"),
   354 => (x"4a",x"c0",x"87",x"c4"),
   355 => (x"4a",x"c1",x"87",x"c2"),
   356 => (x"4f",x"26",x"48",x"72"),
   357 => (x"5c",x"5b",x"5e",x"0e"),
   358 => (x"4b",x"71",x"0e",x"5d"),
   359 => (x"d0",x"4c",x"d4",x"ff"),
   360 => (x"78",x"c0",x"48",x"66"),
   361 => (x"db",x"ff",x"49",x"d6"),
   362 => (x"ff",x"c3",x"87",x"f4"),
   363 => (x"c3",x"49",x"6c",x"7c"),
   364 => (x"4d",x"71",x"99",x"ff"),
   365 => (x"99",x"f0",x"c3",x"49"),
   366 => (x"05",x"a9",x"e0",x"c1"),
   367 => (x"ff",x"c3",x"87",x"cb"),
   368 => (x"c3",x"48",x"6c",x"7c"),
   369 => (x"08",x"66",x"d0",x"98"),
   370 => (x"7c",x"ff",x"c3",x"78"),
   371 => (x"c8",x"49",x"4a",x"6c"),
   372 => (x"7c",x"ff",x"c3",x"31"),
   373 => (x"b2",x"71",x"4a",x"6c"),
   374 => (x"31",x"c8",x"49",x"72"),
   375 => (x"6c",x"7c",x"ff",x"c3"),
   376 => (x"72",x"b2",x"71",x"4a"),
   377 => (x"c3",x"31",x"c8",x"49"),
   378 => (x"4a",x"6c",x"7c",x"ff"),
   379 => (x"d0",x"ff",x"b2",x"71"),
   380 => (x"78",x"e0",x"c0",x"48"),
   381 => (x"c2",x"02",x"9b",x"73"),
   382 => (x"75",x"7b",x"72",x"87"),
   383 => (x"26",x"4d",x"26",x"48"),
   384 => (x"26",x"4b",x"26",x"4c"),
   385 => (x"4f",x"26",x"1e",x"4f"),
   386 => (x"5c",x"5b",x"5e",x"0e"),
   387 => (x"76",x"86",x"f8",x"0e"),
   388 => (x"49",x"a6",x"c8",x"1e"),
   389 => (x"c4",x"87",x"fd",x"fd"),
   390 => (x"6e",x"4b",x"70",x"86"),
   391 => (x"03",x"a8",x"c4",x"48"),
   392 => (x"73",x"87",x"ca",x"c3"),
   393 => (x"9a",x"f0",x"c3",x"4a"),
   394 => (x"02",x"aa",x"d0",x"c1"),
   395 => (x"e0",x"c1",x"87",x"c7"),
   396 => (x"f8",x"c2",x"05",x"aa"),
   397 => (x"c8",x"49",x"73",x"87"),
   398 => (x"87",x"c3",x"02",x"99"),
   399 => (x"73",x"87",x"c6",x"ff"),
   400 => (x"c2",x"9c",x"c3",x"4c"),
   401 => (x"cf",x"c1",x"05",x"ac"),
   402 => (x"49",x"66",x"c4",x"87"),
   403 => (x"1e",x"71",x"31",x"c9"),
   404 => (x"c1",x"4a",x"66",x"c4"),
   405 => (x"f5",x"c2",x"92",x"c8"),
   406 => (x"81",x"72",x"49",x"c6"),
   407 => (x"87",x"ef",x"d2",x"fe"),
   408 => (x"1e",x"49",x"66",x"c4"),
   409 => (x"ff",x"49",x"e3",x"c0"),
   410 => (x"d8",x"87",x"d8",x"d9"),
   411 => (x"ed",x"d8",x"ff",x"49"),
   412 => (x"1e",x"c0",x"c8",x"87"),
   413 => (x"49",x"f6",x"e3",x"c2"),
   414 => (x"87",x"c4",x"eb",x"fd"),
   415 => (x"c0",x"48",x"d0",x"ff"),
   416 => (x"e3",x"c2",x"78",x"e0"),
   417 => (x"66",x"d0",x"1e",x"f6"),
   418 => (x"92",x"c8",x"c1",x"4a"),
   419 => (x"49",x"c6",x"f5",x"c2"),
   420 => (x"cd",x"fe",x"81",x"72"),
   421 => (x"86",x"d0",x"87",x"f7"),
   422 => (x"c1",x"05",x"ac",x"c1"),
   423 => (x"66",x"c4",x"87",x"cf"),
   424 => (x"71",x"31",x"c9",x"49"),
   425 => (x"4a",x"66",x"c4",x"1e"),
   426 => (x"c2",x"92",x"c8",x"c1"),
   427 => (x"72",x"49",x"c6",x"f5"),
   428 => (x"da",x"d1",x"fe",x"81"),
   429 => (x"f6",x"e3",x"c2",x"87"),
   430 => (x"4a",x"66",x"c8",x"1e"),
   431 => (x"c2",x"92",x"c8",x"c1"),
   432 => (x"72",x"49",x"c6",x"f5"),
   433 => (x"c1",x"cc",x"fe",x"81"),
   434 => (x"49",x"66",x"c8",x"87"),
   435 => (x"49",x"e3",x"c0",x"1e"),
   436 => (x"87",x"ef",x"d7",x"ff"),
   437 => (x"d7",x"ff",x"49",x"d7"),
   438 => (x"c0",x"c8",x"87",x"c4"),
   439 => (x"f6",x"e3",x"c2",x"1e"),
   440 => (x"c5",x"e9",x"fd",x"49"),
   441 => (x"ff",x"86",x"d0",x"87"),
   442 => (x"e0",x"c0",x"48",x"d0"),
   443 => (x"fc",x"8e",x"f8",x"78"),
   444 => (x"5e",x"0e",x"87",x"cd"),
   445 => (x"0e",x"5d",x"5c",x"5b"),
   446 => (x"ff",x"4d",x"71",x"1e"),
   447 => (x"66",x"d4",x"4c",x"d4"),
   448 => (x"b7",x"c3",x"48",x"7e"),
   449 => (x"87",x"c5",x"06",x"a8"),
   450 => (x"e3",x"c1",x"48",x"c0"),
   451 => (x"fe",x"49",x"75",x"87"),
   452 => (x"75",x"87",x"e3",x"e1"),
   453 => (x"4b",x"66",x"c4",x"1e"),
   454 => (x"c2",x"93",x"c8",x"c1"),
   455 => (x"73",x"83",x"c6",x"f5"),
   456 => (x"cf",x"c6",x"fe",x"49"),
   457 => (x"6b",x"83",x"c8",x"87"),
   458 => (x"48",x"d0",x"ff",x"4b"),
   459 => (x"dd",x"78",x"e1",x"c8"),
   460 => (x"c3",x"49",x"73",x"7c"),
   461 => (x"7c",x"71",x"99",x"ff"),
   462 => (x"b7",x"c8",x"49",x"73"),
   463 => (x"99",x"ff",x"c3",x"29"),
   464 => (x"49",x"73",x"7c",x"71"),
   465 => (x"c3",x"29",x"b7",x"d0"),
   466 => (x"7c",x"71",x"99",x"ff"),
   467 => (x"b7",x"d8",x"49",x"73"),
   468 => (x"c0",x"7c",x"71",x"29"),
   469 => (x"7c",x"7c",x"7c",x"7c"),
   470 => (x"7c",x"7c",x"7c",x"7c"),
   471 => (x"7c",x"7c",x"7c",x"7c"),
   472 => (x"c4",x"78",x"e0",x"c0"),
   473 => (x"49",x"dc",x"1e",x"66"),
   474 => (x"87",x"d7",x"d5",x"ff"),
   475 => (x"48",x"73",x"86",x"c8"),
   476 => (x"87",x"c9",x"fa",x"26"),
   477 => (x"5c",x"5b",x"5e",x"0e"),
   478 => (x"71",x"1e",x"0e",x"5d"),
   479 => (x"4b",x"d4",x"ff",x"7e"),
   480 => (x"f9",x"c2",x"1e",x"6e"),
   481 => (x"c4",x"fe",x"49",x"e6"),
   482 => (x"86",x"c4",x"87",x"ea"),
   483 => (x"02",x"9d",x"4d",x"70"),
   484 => (x"c2",x"87",x"c3",x"c3"),
   485 => (x"4c",x"bf",x"ee",x"f9"),
   486 => (x"df",x"fe",x"49",x"6e"),
   487 => (x"d0",x"ff",x"87",x"d8"),
   488 => (x"78",x"c5",x"c8",x"48"),
   489 => (x"c0",x"7b",x"d6",x"c1"),
   490 => (x"c1",x"7b",x"15",x"4a"),
   491 => (x"b7",x"e0",x"c0",x"82"),
   492 => (x"87",x"f5",x"04",x"aa"),
   493 => (x"c4",x"48",x"d0",x"ff"),
   494 => (x"78",x"c5",x"c8",x"78"),
   495 => (x"c1",x"7b",x"d3",x"c1"),
   496 => (x"74",x"78",x"c4",x"7b"),
   497 => (x"fc",x"c1",x"02",x"9c"),
   498 => (x"f6",x"e3",x"c2",x"87"),
   499 => (x"4d",x"c0",x"c8",x"7e"),
   500 => (x"ac",x"b7",x"c0",x"8c"),
   501 => (x"c8",x"87",x"c6",x"03"),
   502 => (x"c0",x"4d",x"a4",x"c0"),
   503 => (x"e7",x"f0",x"c2",x"4c"),
   504 => (x"d0",x"49",x"bf",x"97"),
   505 => (x"87",x"d2",x"02",x"99"),
   506 => (x"f9",x"c2",x"1e",x"c0"),
   507 => (x"c7",x"fe",x"49",x"e6"),
   508 => (x"86",x"c4",x"87",x"d8"),
   509 => (x"c0",x"4a",x"49",x"70"),
   510 => (x"e3",x"c2",x"87",x"ef"),
   511 => (x"f9",x"c2",x"1e",x"f6"),
   512 => (x"c7",x"fe",x"49",x"e6"),
   513 => (x"86",x"c4",x"87",x"c4"),
   514 => (x"ff",x"4a",x"49",x"70"),
   515 => (x"c5",x"c8",x"48",x"d0"),
   516 => (x"7b",x"d4",x"c1",x"78"),
   517 => (x"7b",x"bf",x"97",x"6e"),
   518 => (x"80",x"c1",x"48",x"6e"),
   519 => (x"8d",x"c1",x"7e",x"70"),
   520 => (x"87",x"f0",x"ff",x"05"),
   521 => (x"c4",x"48",x"d0",x"ff"),
   522 => (x"05",x"9a",x"72",x"78"),
   523 => (x"48",x"c0",x"87",x"c5"),
   524 => (x"c1",x"87",x"e5",x"c0"),
   525 => (x"e6",x"f9",x"c2",x"1e"),
   526 => (x"ec",x"c4",x"fe",x"49"),
   527 => (x"74",x"86",x"c4",x"87"),
   528 => (x"c4",x"fe",x"05",x"9c"),
   529 => (x"48",x"d0",x"ff",x"87"),
   530 => (x"c1",x"78",x"c5",x"c8"),
   531 => (x"7b",x"c0",x"7b",x"d3"),
   532 => (x"48",x"c1",x"78",x"c4"),
   533 => (x"48",x"c0",x"87",x"c2"),
   534 => (x"26",x"4d",x"26",x"26"),
   535 => (x"26",x"4b",x"26",x"4c"),
   536 => (x"5b",x"5e",x"0e",x"4f"),
   537 => (x"4b",x"71",x"0e",x"5c"),
   538 => (x"d8",x"02",x"66",x"cc"),
   539 => (x"f0",x"c0",x"4c",x"87"),
   540 => (x"87",x"d8",x"02",x"8c"),
   541 => (x"8a",x"c1",x"4a",x"74"),
   542 => (x"8a",x"87",x"d1",x"02"),
   543 => (x"8a",x"87",x"cd",x"02"),
   544 => (x"d7",x"87",x"c9",x"02"),
   545 => (x"fb",x"49",x"73",x"87"),
   546 => (x"87",x"d0",x"87",x"ea"),
   547 => (x"49",x"c0",x"1e",x"74"),
   548 => (x"74",x"87",x"df",x"f9"),
   549 => (x"f9",x"49",x"73",x"1e"),
   550 => (x"86",x"c8",x"87",x"d8"),
   551 => (x"00",x"87",x"fc",x"fe"),
   552 => (x"c9",x"e3",x"c2",x"1e"),
   553 => (x"b9",x"c1",x"49",x"bf"),
   554 => (x"59",x"cd",x"e3",x"c2"),
   555 => (x"c3",x"48",x"d4",x"ff"),
   556 => (x"d0",x"ff",x"78",x"ff"),
   557 => (x"78",x"e1",x"c8",x"48"),
   558 => (x"c1",x"48",x"d4",x"ff"),
   559 => (x"71",x"31",x"c4",x"78"),
   560 => (x"48",x"d0",x"ff",x"78"),
   561 => (x"26",x"78",x"e0",x"c0"),
   562 => (x"00",x"00",x"00",x"4f"),
   563 => (x"00",x"00",x"00",x"00"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

