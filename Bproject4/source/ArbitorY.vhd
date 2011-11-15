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
      aiMemData0 : OUT    std_logic_vector (31 DOWNTO 0);
      aMemWrData : IN     std_logic_vector (31 DOWNTO 0);
      ramData    : OUT    std_logic_vector (31 DOWNTO 0);
      ramAddr    : OUT    std_logic_vector (15 DOWNTO 0)
   );

-- Declarations

END Arbitor ;

--
ARCHITECTURE arch_name OF Arbitor IS
constant MEMFREE        : std_logic_vector              := "00";
constant MEMBUSY        : std_logic_vector              := "01";
constant MEMACCESS      : std_logic_vector              := "10";
constant MEMERROR       : std_logic_vector              := "11";

  signal serving :std_logic_vector(1 downto 0); --01 data    10 icache0    11 icache1
BEGIN
  serving <= "01" when (ramState = MEMFREE and (aMemRead = '1' or aMemWrite ='1')) else
  						   "10" when (ramstate = MEMFREE and aiMemRead0 ='1') else
						   "11" when (ramstate = MEMFREE and aiMemRead1 ='1') else
					     "00";
  ramAddr <= aMemAddr(15 downto 0) when serving = "01" else
  					 aiMemAddr0(15 downto 0) when serving ="10" else
  					 aiMemAddr1(15 downto 0) when serving ="11" else
  					 (others => '1');
	ramData <= aMemWrData when serving = "01" else x"00000000";
	ramWen <= aMemWrite when serving ="01" else '0';
	arbWait0 <= '1' when serving = "10" else '0';
	arbWait1 <= '1' when serving = "11" else '0';
	iMemRead0 <= '1' when serving = "10" else '0';
	iMemRead1 <= '1' when serving = "11" else '0';
  busy  <= '0' when serving = "01" else '1';	
	
	  readENState: process( clk, nReset,ramState)
    begin 
    	if nReset= '0' then 
    	  ramRen <= '0';
       aiMemData0 <= (others => '0');
       aiMemData1 <= (others => '0');
       aMemRdData <= (others => '0');
	    elsif (rising_edge(clk))   then  -- probably won't use aMemWait
       aiMemData0 <= (others => '0');
       aiMemData1 <= (others => '0');
       aMemRdData <= (others => '0');
	      if (ramState = MEMACCESS) then 
	        ramRen <= '0';
	      end if;
	      if serving = "01" then -- updates only on MemFree hence on MemFree and rising clk
	        ramRen <= aMemRead;
 	        aMemRdData <= ramQ;      
	      elsif serving = "10" then
	        ramRen <= aiMemRead0;
	        aiMemData0 <= ramQ;
	      elsif serving = "10" then
	        ramRen <= aiMemRead1;
	        aiMemData1 <= ramQ;
	      end if;
    		end if;
  end process readENState;
END ARCHITECTURE arch_name;

