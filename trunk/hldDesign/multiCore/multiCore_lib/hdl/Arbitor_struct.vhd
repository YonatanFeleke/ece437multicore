--
-- VHDL Architecture multiCore_lib.Arbitor.arch_name
--
-- Created:
--          by - mg255.bin (cparch03.ecn.purdue.edu)
--          at - 14:26:03 11/02/11
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

ENTITY Arbitor IS
   PORT( 
      CLK        : IN     std_logic;
      nReset     : IN     std_logic;
      ramQ       : IN     std_logic_vector (31 DOWNTO 0);
      ramState   : IN     std_logic_vector (1 DOWNTO 0);
      aiMemAddr1 : IN     std_logic_vector (31 DOWNTO 0);
      aiMemRead1 : IN     std_logic;
      aiMemData1 : OUT    std_logic_vector (31 DOWNTO 0);
      iMemRead1  : OUT    std_logic;
      ramAddr    : OUT    std_logic_vector (31 DOWNTO 0);
      ramData    : OUT    std_logic_vector (31 DOWNTO 0);
      ramRen     : OUT    std_logic;
      ramWen     : OUT    std_logic;
      aiMemRead0 : IN     std_logic;
      aiMemAddr0 : IN     std_logic_vector (31 DOWNTO 0);
      aMemRead   : IN     std_logic;
      aMemWrite  : IN     std_logic;
      aMemAddr   : IN     std_logic_vector (31 DOWNTO 0);
      aMemRdData : OUT    std_logic_vector (31 DOWNTO 0);
      arbWait1   : OUT    std_logic;
      arbWait0   : OUT    std_logic;
      busy       : OUT    std_logic;
      iMemRead0  : OUT    std_logic;
      aiMemData0 : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END Arbitor ;

--
ARCHITECTURE arch_name OF Arbitor IS
BEGIN
END ARCHITECTURE arch_name;

