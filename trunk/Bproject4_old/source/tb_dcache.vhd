-- $Id: $
-- File name:   tb_dcache.vhd
-- Created:     10/25/2011
-- Author:      Brian Crone
-- Lab Section: Wednesday 2:30-5:20
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_dcache is
generic (Period : Time := 50 ns);
end tb_dcache;

architecture TEST of tb_dcache is

  function INT_TO_STD_LOGIC( X: INTEGER; NumBits: INTEGER )
     return STD_LOGIC_VECTOR is
    variable RES : STD_LOGIC_VECTOR(NumBits-1 downto 0);
    variable tmp : INTEGER;
  begin
    tmp := X;
    for i in 0 to NumBits-1 loop
      if (tmp mod 2)=1 then
        res(i) := '1';
      else
        res(i) := '0';
      end if;
      tmp := tmp/2;
    end loop;
    return res;
  end;

  component dcache
    PORT(
         CLK : in std_logic;
         nReset : in std_logic;
         halt_in : in std_logic;
		 halt_out: out std_logic;
         MemRead : in std_logic;
         MemWrite : in std_logic;
         MemAddr : in std_logic_vector (31 downto 0);
         MemRdData : out std_logic_vector (31 downto 0);
         MemWrData : in std_logic_vector (31 downto 0);
         aMemState : in std_logic_vector (1 downto 0);
         aMemRead : out std_logic;
         aMemWrite : out std_logic;
         aMemwData : out std_logic_vector(31 downto 0);
         aMemAddr : out std_logic_vector (31 downto 0);
         aMemData : in std_logic_vector (31 downto 0);
		 dcachewait: out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal CLK : std_logic;
  signal nReset : std_logic;
  signal halt_in,halt_out,dcachewait : std_logic;
  signal MemRead : std_logic;
  signal MemWrite : std_logic;
  signal MemAddr : std_logic_vector (31 downto 0);
  signal MemRdData : std_logic_vector (31 downto 0);
  signal MemWrData : std_logic_vector (31 downto 0);
  signal aMemState : std_logic_vector (1 downto 0);
  signal aMemRead : std_logic;
  signal aMemWrite : std_logic;
  signal aMemwData : std_logic_vector(31 downto 0);
  signal aMemAddr : std_logic_vector (31 downto 0);
  signal aMemData : std_logic_vector (31 downto 0);

-- signal <name> : <type>;

begin

CLKGEN: process
  variable clk_tmp: std_logic := '0';
begin
  clk_tmp := not clk_tmp;
  clk <= clk_tmp;
  wait for Period/2;
end process;

  DUT: dcache port map(
                CLK => CLK,
                nReset => nReset,
                halt_in => halt_in,
				halt_out => halt_out,
                MemRead => MemRead,
                MemWrite => MemWrite,
                MemAddr => MemAddr,
                MemRdData => MemRdData,
                MemWrData => MemWrData,
                aMemState => aMemState,
                aMemRead => aMemRead,
                aMemWrite => aMemWrite,
                aMemwData => aMemwData,
                aMemAddr => aMemAddr,
                aMemData => aMemData,
				dcachewait => dcachewait
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process

  begin

-- Insert TEST BENCH Code Here

    nReset <= '0';
    halt_in <= '0';
    MemRead <= '0';
    MemWrite <= '0';
    MemAddr <= x"00000000";
    MemWrData <= x"BAD1BAD1";
    aMemState <= "00";
    aMemData <= x"BAD2BAD2";
	wait for Period*2;

	nReset <= '1';

	--test invalid read. cache should load block from RAM.
	MemRead <= '1';
	aMemState <= "01";
	aMemData <= x"BCBCBCBC";

	wait for Period*4;

	aMemState <= "10";
	wait for Period;
	aMemState <= "01";
	aMemData <= x"00000000";
	wait for Period*4;
	aMemState <= "10";
	wait for Period;

	--test write on hit
	aMemState <= "00";
	MemRead <= '0';
	MemWrite <= '1';
	MemAddr <= x"00000004";
	MemWrData <= x"DDDDDDDD";
	wait for Period;
	MemWrite <= '0';

	--test replacing dirty block
	MemRead <= '1';
	MemAddr <= x"00000C00";
	aMemData <= x"12345678";
	aMemState <= "01";
	wait for Period*4;
	aMemState <= "10";
	wait for Period;
	aMemState <= "01";
	aMemData <= x"98765432";
	wait for Period*4;
	aMemState <= "10";
	wait for Period;
	MemRead <= '0';
	wait for Period;
	
	MemRead <= '1';
	MemAddr <= x"00000D00";
	aMemData <= x"11111111";
	aMemState <= "01";
	wait for Period*4;
	aMemState <= "10";
	wait for Period*2;
	aMemState <= "01";
	wait for Period*4;
	aMemState <= "10";
	wait for Period*2;
	aMemState <= "01";
	wait for Period*4;
	aMemState <= "10";
	wait for Period;
	aMemState <= "01";
	aMemData <= x"99999999";
	wait for Period*4;
	aMemState <= "10";
	wait for Period;
	MemRead <= '0';
	wait for Period;



	wait;	

  end process;
end TEST;
