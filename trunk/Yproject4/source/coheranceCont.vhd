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
      CLK          : IN     std_logic;
      MemWait0     : IN     std_logic;
      MemWait1     : IN     std_logic;
      aMemAddr0    : IN     std_logic_vector (31 DOWNTO 0);
      aMemAddr1    : IN     std_logic_vector (31 DOWNTO 0);
      aMemRdData   : IN     std_logic_vector (31 DOWNTO 0);
      aMemRead0    : IN     std_logic;
      aMemRead1    : IN     std_logic;
      aMemWrData0  : IN     std_logic_vector (31 DOWNTO 0);
      aMemWrData1  : IN     std_logic_vector (31 DOWNTO 0);
      aMemWrite0   : IN     std_logic;
      aMemWrite1   : IN     std_logic;
      busy         : IN     std_logic;
      cMemData     : IN     std_logic_vector (31 DOWNTO 0);
      cMemData0    : IN     std_logic_vector (31 DOWNTO 0);
      cMemHit      : IN     std_logic;
      cMemHit0     : IN     std_logic;
      finalHalt0   : IN     std_logic;
      finalHalt1   : IN     std_logic;
      nReset       : IN     std_logic;
      ramState     : IN     std_logic_vector (1 DOWNTO 0);
      HALT         : OUT    std_logic;
      aMemAddr     : OUT    std_logic_vector (31 DOWNTO 0);
      aMemRdData0  : OUT    std_logic_vector (31 DOWNTO 0);
      aMemRdData1  : OUT    std_logic_vector (31 DOWNTO 0);
      aMemRead     : OUT    std_logic;
      aMemWrite    : OUT    std_logic;
      cMemAddr     : OUT    std_logic_vector (31 DOWNTO 0);
      cMemAddr0    : OUT    std_logic_vector (31 DOWNTO 0);
      cMemSnoopEn  : OUT    std_logic;
      cMemSnoopEn0 : OUT    std_logic;
      cMemWait0    : OUT    std_logic;
      cMemWait1    : OUT    std_logic;
      cWait0       : OUT    std_logic;
      cWait1       : OUT    std_logic
   );

-- Declarations

END coheranceCont ;

--
ARCHITECTURE arch_name OF coheranceCont IS
		servicing : std_logic;
BEGIN

  
  HALT <=       finalHalt0 AND finalHalt1;
  servicing <= '0' when (aMemRead0 ='1' or aMemWrite0 ='1') else
  							'1' when (aMemRead0 ='1' or aMemWrite0 ='1') else
  							'0';
  aMemAddr <= aMemAddr0 when servicing ='0' and busy='0' else
  						aMemAddr0
  
END ARCHITECTURE arch_name;

