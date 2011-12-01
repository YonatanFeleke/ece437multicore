-- $Id: $
-- File name:   tb_SLT.vhd
-- Created:     11/30/2011
-- Author:      Brian Crone
-- Lab Section: Wednesday 2:30-5:20
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_SLT is
end tb_SLT;

architecture TEST of tb_SLT is

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

  component SLT
    PORT(
         Opcode : in std_logic_vector(5 downto 0);
         Fx : in std_logic_vector(5 downto 0);
         A : in std_logic_vector(31 downto 0);
         B : in std_logic_vector(31 downto 0);
         Negative : in std_logic;
         Overflow : in std_logic;
         SLTvalue : out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal Opcode : std_logic_vector(5 downto 0);
  signal Fx : std_logic_vector(5 downto 0);
  signal A : std_logic_vector(31 downto 0);
  signal B : std_logic_vector(31 downto 0);
  signal Negative : std_logic;
  signal Overflow : std_logic;
  signal SLTvalue : std_logic;

-- signal <name> : <type>;

begin
  DUT: SLT port map(
                Opcode => Opcode,
                Fx => Fx,
                A => A,
                B => B,
                Negative => Negative,
                Overflow => Overflow,
                SLTvalue => SLTvalue
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process

  begin

-- Insert TEST BENCH Code Here

    Opcode <= "001011";
    Fx <= "000000";
    A <= x"7FFFFFFF";
    B <= x"FFFFFFFF";
    Negative <= '0';
    Overflow <= '0';
		wait for 10 ns;
-----------------------------
    Opcode <= "001011";
    Fx <= "000000";
    A <= x"FFFFFFFF";
    B <= x"7FFFFFFF";
    Negative <= '0';
    Overflow <= '0';
		wait for 10 ns;
-----------------------------
    Opcode <= "000000";
    Fx <= "101011";
    A <= x"7FFFFFFF";
    B <= x"80000000";
    Negative <= '0';
    Overflow <= '0';
		wait for 10 ns;
-----------------------------
    Opcode <= "000000";
    Fx <= "101011";
    A <= x"FFFFFFFF";
    B <= x"FFFFFFFF";
    Negative <= '0';
    Overflow <= '0';
		wait for 10 ns;
-----------------------------
    Opcode <= "000000";
    Fx <= "101011";
    A <= x"FFFFFFFF";
    B <= x"FFFFFFFF";
    Negative <= '0';
    Overflow <= '0';
		wait for 10 ns;




  end process;
end TEST;
