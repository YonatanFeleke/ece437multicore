-- $Id: $
-- File name:   tb_icache.vhd
-- Created:     10/17/2011
-- Author:      Brian Crone
-- Lab Section: Wednesday 2:30-5:20
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_icache is
end tb_icache;

architecture TEST of tb_icache is

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

-- Insert signals Declarations here
  signal clk : std_logic;
  signal nrst : std_logic;
  signal tag_in : std_logic_vector( 25 downto 0);
  signal data_in : std_logic_vector( 31 downto 0);
  signal data_out : std_logic_vector( 31 downto 0);
  signal index_in : std_logic_vector( 3 downto 0);
  signal hit : std_logic;
  signal icache_en : std_logic;

-- signal <name> : <type>;

begin
  DUT: icache port map(
                clk => clk,
                nrst => nrst,
                tag_in => tag_in,
                data_in => data_in,
                data_out => data_out,
                index_in => index_in,
                hit => hit,
                icache_en => icache_en
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process

  begin

-- Insert TEST BENCH Code Here

    clk <= 

    nrst <= 

    tag_in <= 

    data_in <= 

    index_in <= 

    icache_en <= 

  end process;
end TEST;