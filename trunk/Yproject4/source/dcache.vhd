-- $Id: $
-- File name:   tb_data16x126.vhd
-- Created:     10/24/2011
-- Author:      Yonatan Feleke
-- Lab Section: Wednesday 2:30-5:20
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity dcache is
  port(
    CLK       : in  std_logic;
    nReset    : in  std_logic;

		Halt			:	in	std_logic;											 -- CPU side 
    MemRead		: in  std_logic;                       -- CPU side
		MemWrite	:	in	std_logic;											 -- CPU side
    MemWait		: out std_logic;                       -- CPU side
    MemAddr		: in  std_logic_vector (31 downto 0);  -- CPU side
    MemRdData	: out	std_logic_vector (31 downto 0);  -- CPU side
    MemWrData	: in	std_logic_vector (31 downto 0);  -- CPU side
    finalHalt	: out std_logic;                       -- CPU side

    aMemWait	: in  std_logic;                       -- arbitrator side
		aMemState	: in	std_logic_vector (1 downto 0);	 -- arbitrator side
    aMemRead	: out std_logic;                       -- arbitrator side
    aMemWrite	: out std_logic;                       -- arbitrator side
    aMemAddr	: out std_logic_vector (31 downto 0);  -- arbitrator side
    aMemRdData: in  std_logic_vector (31 downto 0);   -- arbitrator side
    aMemWrData: out  std_logic_vector (31 downto 0)  -- arbitrator side
    
	);

end dcache;



architecture struct of dcache is
  component data16x184
    PORT(
         clk,nrst : IN STD_LOGIC;
         addr : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
         we : IN STD_LOGIC;
         writeport : IN STD_LOGIC_VECTOR (184 DOWNTO 0);
         readport : OUT STD_LOGIC_VECTOR (184 DOWNTO 0)
    );
  end component;
  component dCacheCLU
    PORT(
         CLK : in std_logic;
         nReset : in std_logic;
         Halt : in std_logic;
         MemRead : in std_logic;
         MemWrite : in std_logic;
         MemWait : out std_logic;
         MemAddr : in std_logic_vector (31 downto 0);
         MemRdData : out std_logic_vector (31 downto 0);
         MemWrData : in std_logic_vector (31 downto 0);
         aMemWait : in std_logic;
         aMemState : in std_logic_vector (1 downto 0);
         aMemRead : out std_logic;
         aMemWrite : out std_logic;
         aMemAddr : out std_logic_vector (31 downto 0);
         aMemRdData : in std_logic_vector (31 downto 0);
         aMemWrData : out std_logic_vector (31 downto 0);         
         wEN : out std_logic;
         readport : in STD_LOGIC_VECTOR (184 DOWNTO 0);
         addr : out STD_LOGIC_VECTOR (3 DOWNTO 0);
         writeport : out STD_LOGIC_VECTOR (184 DOWNTO 0);
         haltDone : out STD_LOGIC
    );
  end component;
  signal wEN : std_logic;
  signal readport : STD_LOGIC_VECTOR (184 DOWNTO 0);
  signal addr : STD_LOGIC_VECTOR (3 DOWNTO 0);
  signal writeport : STD_LOGIC_VECTOR (184 DOWNTO 0);
  signal haltDone : STD_LOGIC;
begin
-- The routing options
	finalHalt <= haltDone;
  dRam: data16x184
  	port map(
                clk => clk,
                nrst=> nReset,
                addr => addr,
                we => wEN,
                writeport => writeport,
                readport => readport
                );
  dRamCLU: dCacheCLU
  	 port map(
                CLK => CLK,
                nReset => nReset,
                Halt => Halt,
                MemRead => MemRead,
                MemWrite => MemWrite,
                MemWait => MemWait,
                MemAddr => MemAddr,
                MemRdData => MemRdData,
                MemWrData => MemWrData,
                aMemWait => aMemWait,
                aMemState => aMemState,
                aMemRead => aMemRead,
                aMemWrite => aMemWrite,
                aMemAddr => aMemAddr,
                aMemRdData => aMemRdData,
                aMemWrData => aMemWrData,
                wEN => wEN,
                readport => readport,
                addr => addr,
                writeport => writeport,
                haltDone => haltDone
                );
end struct;
