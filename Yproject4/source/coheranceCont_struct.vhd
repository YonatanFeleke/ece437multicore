--
-- VHDL Architecture multiCore_lib.coheranceCont.arch_name
--
-- Created:
--          by - mg255.bin (cparch03.ecn.purdue.edu)
--          at - 14:25:53 11/02/11
--
-- using Mentor Graphics HDL Designer(TM) 2010.2a (Build 7)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
LIBRARY std;
USE std.textio.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;

ENTITY coheranceCont IS
   PORT( 
      CLK         : IN     std_logic;
      MemWait     : IN     std_logic;
      aMemAddr    : IN     std_logic_vector (31 DOWNTO 0);
      aMemRead    : IN     std_logic;
      aMemRead1   : IN     std_logic;
      aMemWrData  : IN     std_logic_vector (31 DOWNTO 0);
      aMemWrData1 : IN     std_logic_vector (31 DOWNTO 0);
      aMemWrite   : IN     std_logic;
      aMemWrite1  : IN     std_logic;
      nReset      : IN     std_logic;
      ramState    : IN     std_logic_vector (1 DOWNTO 0)
   );

-- Declarations

END coheranceCont ;

--
ARCHITECTURE arch_name OF coheranceCont IS
BEGIN
END ARCHITECTURE arch_name;

