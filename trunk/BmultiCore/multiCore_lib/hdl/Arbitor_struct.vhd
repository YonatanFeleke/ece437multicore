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
      aiMemData0 : OUT    std_logic_vector (31 DOWNTO 0);
      aMemWrData : IN     std_logic_vector (31 DOWNTO 0);
      ramAddr    : OUT    std_logic_vector (31 DOWNTO 0);
      ramData    : OUT    std_logic_vector (31 DOWNTO 0);
      ramRen     : OUT    std_logic;
      ramWen     : OUT    std_logic     
   );

-- Declarations

END Arbitor ;

--
ARCHITECTURE arch_name OF Arbitor IS
constant MEMFREE        : std_logic_vector              := "00";
constant MEMBUSY        : std_logic_vector              := "01";
constant MEMACCESS      : std_logic_vector              := "10";
constant MEMERROR       : std_logic_vector              := "11";

  signal servicing :std_logic; --01 data    10 icache0    11 icache1
BEGIN
  servicing <= "01" when ramState = MEMFREE and (aMemRead = '1' or aMemWrie ='1') else
  						 "10" when ramstate = MEMFREE and (aiMemRead0 ='1') else
  						 "11" when ramstate = MEMFREE and (aiMemRead1 ='1') else
  						 "00";
  ramAddr <= aMemAddr when servicing = "01" else
  					 aiMemAddr0 when servicing ="10" else
  					 aiMemAddr1 when servicing ="11" else
  					 (others => '1');
	ramData <= aMemWrData;
--	ramRen <= 
	ramWen <= aMemWrite when serving ="01";
END ARCHITECTURE arch_name;

