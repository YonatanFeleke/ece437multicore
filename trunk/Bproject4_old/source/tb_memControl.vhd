-- $Id: $
-- File name:   tb_memControl.vhd
-- Created:     9/20/2011
-- Author:      Brian Crone
-- Lab Section: Wednesday 2:30-5:20
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_memControl is
	generic (Period : Time := 10 ns);
end tb_memControl;

architecture TEST of tb_memControl is

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

  component memControl
    PORT(
         iAddress : in std_logic_vector(15 downto 0);
         dAddress : in std_logic_vector(15 downto 0);
         wData : in std_logic_vector(31 downto 0);
         q : in std_logic_vector(31 downto 0);
         MemWr : in std_logic;
         halt : in std_logic;
         MemRd : in std_logic;
         memState : in std_logic_vector(1 downto 0);
         Instruction : out std_logic_vector(31 downto 0);
         readData : out std_logic_vector(31 downto 0);
         PCWait : out std_logic;
         address : out std_logic_vector(15 downto 0);
         data : out std_logic_vector(31 downto 0);
         wrEn : out std_logic;
         rdEn : out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal iAddress : std_logic_vector(15 downto 0);
  signal dAddress : std_logic_vector(15 downto 0);
  signal wData : std_logic_vector(31 downto 0);
  signal q : std_logic_vector(31 downto 0);
  signal MemWr : std_logic;
  signal halt : std_logic;
  signal MemRd : std_logic;
  signal memState : std_logic_vector(1 downto 0);
  signal Instruction : std_logic_vector(31 downto 0);
  signal readData : std_logic_vector(31 downto 0);
  signal PCWait : std_logic;
  signal address : std_logic_vector(15 downto 0);
  signal data : std_logic_vector(31 downto 0);
  signal wrEn : std_logic;
  signal rdEn : std_logic;
  signal clk: std_logic;

-- signal <name> : <type>;

begin
  DUT: memControl port map(
                iAddress => iAddress,
                dAddress => dAddress,
                wData => wData,
                q => q,
                MemWr => MemWr,
                halt => halt,
                MemRd => MemRd,
                memState => memState,
                Instruction => Instruction,
                readData => readData,
                PCWait => PCWait,
                address => address,
                data => data,
                wrEn => wrEn,
                rdEn => rdEn
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);
  clkgen: process
    variable clk_tmp : std_logic := '0';
  begin
    clk_tmp := not clk_tmp;
    clk <= clk_tmp;
    wait for Period/2;
  end process;
process

  begin

-- Insert TEST BENCH Code Here

    iAddress <= x"0000";

    dAddress <= x"FFFF";

    wData <= x"B00BB00B";

    q <=x"DEADBEEF";

    MemWr <= '0';

    halt <= '0';

    MemRd <= '0';

    memState <= "00";

	wait for Period;

	iAddress <= x"0004";
	q <= x"BACBACBA";		
	
	wait for Period;

	MemWr <= '1';

	wait for Period;

	MemWr <= '0';
	MemRd <= '1';

	wait for Period;

	halt <= '1';
	wait;

  end process;
end TEST;
