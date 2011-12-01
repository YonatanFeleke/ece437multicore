-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity ShiftXtd is				
    port( Imm16                : in std_logic_vector(15 downto 0);
    			ExtOp								 : in std_logic; -- 1= sign 0 = zero extend
    			Shamt								 : in std_logic_vector(4 downto 0);
       ID_Imm16L2              : out std_logic_vector(31 downto 0);
       XtdOut               : out std_logic_vector(31 downto 0);
       Shamt32              : out std_logic_vector(31 downto 0)
         );
  end ShiftXtd;

architecture ShiftXtd_behav of ShiftXtd is

	signal XtdOut_Int			: std_logic_vector(31 downto 0);
  begin
  	XtdOut_Int <= x"0000" & Imm16 when (ExtOp = '0' or Imm16(15) = '0') else x"FFFF" & Imm16;
  	XtdOut <= XtdOut_Int;
   ID_Imm16L2 <= XtdOut_Int(29 downto 0) & "00";
  	Shamt32 <= "000" & x"000000"& Shamt;
end ShiftXtd_behav;
