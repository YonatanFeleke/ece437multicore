-- $Id: $
-- File name:   tb_icacheTest.vhd
-- Created:     10/17/2011
-- Author:      Brian Crone
-- Lab Section: Wednesday 2:30-5:20
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_icacheTest is
generic (Period : Time := 50 ns);
end tb_icacheTest;

architecture TEST of tb_icacheTest is

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

  component icacheTest
    PORT(
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
  end component;

-- Insert signals Declarations here
  signal clk : std_logic;
  signal nrst : std_logic;
  signal iAddress : std_logic_vector( 31 downto 0);
  signal instruction : std_logic_vector(31 downto 0);
  signal data_in : std_logic_vector(31 downto 0);
  signal rdEn : std_logic;
  signal icacheWait : std_logic;
  signal ramstate : std_logic_vector(1 downto 0);
  signal PCWait : std_logic;
  signal halt	:	std_logic;
  signal memConflict : std_logic;

-- signal <name> : <type>;

begin

CLKGEN: process
  variable clk_tmp: std_logic := '0';
begin
  clk_tmp := not clk_tmp;
  clk <= clk_tmp;
  wait for Period/2;
end process;

  DUT: icacheTest port map(
                clk => clk,
                nrst => nrst,
                iAddress => iAddress,
                instruction => instruction,
                data_in => data_in,
                rdEn => rdEn,
                icacheWait => icacheWait,
                ramstate => ramstate,
				PCWait => PCWait,
				halt => halt,	
				memConflict => memConflict
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process

  begin

-- Insert TEST BENCH Code Here

    nrst <= '0';

    iAddress <= x"00000000"; 

    data_in <= x"00000000";

    ramstate <= "00";

	PCWait <= '0';
	halt <= '0';	
	memConflict <= '0';

	wait for Period*2;
	nrst <= '1';
	data_in <= x"DEADBEEF";
	ramstate <= "01";

	wait for Period * 10;
	ramstate <= "10";
	wait for Period;
	ramstate <= "00";
	wait for Period;
	iAddress <= x"00000004";
	data_in <= x"BCBCBCBC";
	ramstate <= "01";
		wait for Period * 10;
	ramstate <= "10";
	wait for Period;
	ramstate <= "00";
	wait for Period;
	iAddress <= x"00000000";

	wait;
  end process;
end TEST;
