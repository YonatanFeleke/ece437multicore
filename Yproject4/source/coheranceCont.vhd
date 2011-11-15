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
      nReset       : IN     std_logic;
      ramState     : IN     std_logic_vector (1 DOWNTO 0);
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
      cMemData0    : IN     std_logic_vector (31 DOWNTO 0);
      cMemHit0     : IN     std_logic;
      finalHalt0   : IN     std_logic;
      finalHalt1   : IN     std_logic;
      HALT         : OUT    std_logic;
      aMemAddr     : OUT    std_logic_vector (31 DOWNTO 0);
      aMemRdData0  : OUT    std_logic_vector (31 DOWNTO 0);
      aMemRdData1  : OUT    std_logic_vector (31 DOWNTO 0);
      aMemRead     : OUT    std_logic;
      aMemWrite    : OUT    std_logic;
      cMemAddr0    : OUT    std_logic_vector (31 DOWNTO 0);
      cMemAddr1    : OUT    std_logic_vector (31 DOWNTO 0);
      cMemSnoopEn0 : OUT    std_logic;
      cMemSnoopEn1 : OUT    std_logic;
      cMemWait0    : OUT    std_logic;
      cMemWait1    : OUT    std_logic;
      cWait0       : OUT    std_logic;
      cWait1       : OUT    std_logic;
      cMemData1    : IN     std_logic_vector (31 DOWNTO 0);
      cMemHit1     : IN     std_logic;
      aMemWrData   : OUT    std_logic_vector (31 DOWNTO 0);
      MEM_MEM2REG1 : IN     std_logic;
      MEM_MemWr1   : IN     std_logic;
      MEM_Out1     : IN     std_logic_vector (31 DOWNTO 0);
      MEM_MEM2REG0 : IN     std_logic;
      MEM_MemWr0   : IN     std_logic;
      MEM_Out0     : IN     std_logic_vector (31 DOWNTO 0);
      cRdX0        : OUT    std_logic;
      cRdX1        : OUT    std_logic
   );

-- Declarations

END coheranceCont ;

--
ARCHITECTURE arch_name OF coheranceCont IS
constant MEMFREE        : std_logic_vector              := "00";
constant MEMBUSY        : std_logic_vector              := "01";
constant MEMACCESS      : std_logic_vector              := "10";
constant MEMERROR       : std_logic_vector              := "11";

		signal chrSrvc,nextchrSrvc : std_logic_vector(1 downto 0);
BEGIN
cctrl_state: process(CLK, nReset)
begin
	if nReset = '0' then
		chrSrvc <= "11";
	elsif rising_edge(CLK) then
		if (ramState=MEMFREE) then	
		chrSrvc <= nextchrSrvc; 
		end if;
	end if;
end process cctrl_state;  
  HALT <=       finalHalt0 AND finalHalt1;
  nextchrSrvc <= 	"00" when (aMemRead0 ='1' or aMemWrite0 ='1') else -- always finish cpu0 first then 2
  								"01" when (aMemRead1 ='1' or aMemWrite1 ='1') else
									"00"	; -- neither are serviced by coherance
  aMemAddr <= aMemAddr0 when chrSrvc = "00" and busy='0' else
  						  aMemAddr1 when chrSrvc ="01" and busy ='0' else
  						  x"00000000";
 	aMemRdData0 <= aMemRdData when chrSrvc ="00" else x"00000000";
 	aMemRdData1 <= aMemRdData when chrSrvc ="01" else x"00000000";
 	aMemWrite <= aMemWrite0 when chrSrvc ="00" else aMemWrite1;
  aMemRead <= aMemRead0 when chrSrvc ="00" else aMemRead1; 	
 	aMemWrData <= aMemWrData0 when chrSrvc = "00" else aMemWrData1; 	
 	-- Dcache stop: later on will include snooping capability
 	cMemWait0 <= 	'1' when (busy = '1' or  chrSrvc="01") and (aMemRead0 ='1' or aMemWrite0 ='1') else 
 							'0';
 	cMemWait1 <= '1' when (busy = '1' or chrSrvc = "00") and (aMemRead1 ='1' or aMemWrite1 ='1') else -- waiting on ram to finish icacheAccess
 							 '0';
	-- Pause cpu while Dcache is being updated, icache wait set in the top level via arbwait0 and arbwait1 							 
	cWait0 <= '1' when MemWait0 = '1' else '0';
	cWait1 <= '1' when MemWait1	=	'1' else '0';
	-- Coherance controller snooping signals not impemented
	cMemAddr0 <= (others=> '0');
	cMemAddr1 <= (others=> '0');
	cMemSnoopEn0 <= '0';
	cMemSnoopEn1 <= '0';
	cRdx0 <= '0';
	cRdx1 <= '0';
		
END ARCHITECTURE arch_name;

