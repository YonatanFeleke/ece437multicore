library ieee;
use ieee.std_logic_1164.all;

entity icacheTest is 
	port( 
			clk			:	in std_logic;
			nrst		:	in std_logic;
		  	iAddress	:	in std_logic_vector( 31 downto 0);
			instruction	:	out std_logic_vector(31 downto 0); 
			data_in		:	in std_logic_vector(31 downto 0);
			rdEn		:	out std_logic;
			icacheWait	:	out	std_logic;
			ramstate	: 	in	std_logic_vector(1 downto 0);
			PCWait		:	in std_logic;
			halt		:	in std_logic;
			memConflict	:	in std_logic);
end icacheTest;

architecture icacheTest_arch of icacheTest is

component icache
  PORT(
       clk : in std_logic;
       nrst : in std_logic;
       tag_in : in std_logic_vector( 25 downto 0);
       data_in : in std_logic_vector( 31 downto 0);
       data_out : out std_logic_vector( 31 downto 0);
       index_in : in std_logic_vector( 3 downto 0);
       hit : out std_logic;
       icache_en : in std_logic
  );
end component;

component icacheInterface
port( 
		  	iAddress: in std_logic_vector( 31 downto 0); 
			halt: in std_logic;
			hit	:	in std_logic;
			CacheData:	in std_logic_vector(31 downto 0);
			PCWait:			in std_logic;
			Instruction:	out std_logic_vector(31 downto 0);
			tag	:	out std_logic_vector(25 downto 0);
			index:	out	std_logic_vector(3 downto 0);
			icacheWait: out	std_logic;
			rdEn:	out std_logic);
end component;

component icache_ctrl
	port(	clk, nrst: in std_logic; 
			hit: in std_logic; 
			ramstate: in std_logic_vector( 1 downto 0); 
			icache_en: out std_logic;
			memConflict:	in std_logic); 
end component;

signal icache_en_int: std_logic;
signal hit_int: std_logic;
signal index_int: std_logic_vector(3 downto 0);
signal tag_int: std_logic_vector(25 downto 0);
signal cache_out : std_logic_vector(31 downto 0);


begin

icacheController	:	icache_ctrl
	PORT MAP(
		clk => clk,
		nrst => nrst,
		hit => hit_int,
		ramstate => ramstate,
		icache_en => icache_en_int,
		memConflict => memConflict
	);

icacheMain	:	icache
	Port map(
		clk => clk,
		nrst => nrst,
		tag_in => tag_int,
		data_in => data_in,
		data_out => cache_out,
		index_in => index_int,
		hit => hit_int,
		icache_en => icache_en_int);
		
icacheCPU	:	icacheInterface
	Port map(
		iAddress => iAddress,
		halt => halt,
		hit	=> hit_int,
		CacheData => cache_out,
		PCWait => PCWait,
		Instruction => instruction,
		tag	=> tag_int,
		index => index_int,
		icacheWait => icacheWait,
		rdEn => rdEn);
		
end icacheTest_arch;
