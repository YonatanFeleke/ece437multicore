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
--USE ieee.std_logic_arith.all;
--LIBRARY std;
--USE std.textio.all;
--USE ieee.std_logic_unsigned.all;
--USE ieee.numeric_std.all;
--USE ieee.std_logic_textio.all;

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
      ramAddr    : OUT    std_logic_vector (15 DOWNTO 0);
      ramData    : OUT    std_logic_vector (31 DOWNTO 0);
      ramRen     : OUT    std_logic;
      ramWen     : OUT    std_logic     
   );
END Arbitor ;
ARCHITECTURE arch_name OF Arbitor IS
constant MEMFREE        : std_logic_vector              := "00";
constant MEMBUSY        : std_logic_vector              := "01";
constant MEMACCESS      : std_logic_vector              := "10";
constant MEMERROR       : std_logic_vector              := "11";
	type state_type is(idle, icache0, icache1, data);
	signal state, nextstate						:	state_type;
  signal servicing :std_logic_vector(1 downto 0); --01 data    10 icache0    11 icache1
	signal prevCache, nextprevCache : std_logic;
begin

cctrl_state: process(CLK, nReset)
begin
	if nReset = '0' then
		-- set state to idle
		state <= idle;
		prevCache <= '1';
	elsif rising_edge(CLK) then
		-- set state to next state
		state <= nextstate;
		prevCache <= nextprevCache;
	end if;
end process cctrl_state;

memControl_nextstate: process(state, aMemRead, aMemWrite, aiMemRead0,aiMemRead1, prevCache, ramState) begin
nextstate<=state;  
servicing <= "00";
nextprevCache <= prevCache;
case state is 
	when idle => 
		servicing <= "00";
		if(aMemRead = '1' or aMemWrite = '1') then--CoherenceController request
			servicing <= "01";
			nextstate <= data;
		elsif(aiMemRead0 = '1' or aiMemRead1 = '1') then-- no data request. service icaches
			if(aiMemRead0 = '1') then--cache0 request
				if(aiMemRead1 = '1') then--cache1 and cache0 request
					if(prevCache = '0') then--priority to cache1
						--servicing <= "11";
						nextstate <= icache1;
					else
						--servicing <= "10";
						nextstate <= icache0;
					end if;
				else--request granted to cache0
					--servicing <= "10";
					nextstate <= icache0;
				end if;
			else--cache1 only request
				--servicing <= "11";
				nextstate <= icache1;
			end if;
		end if;
	when icache0 =>
		servicing <= "10";
		nextstate <= icache0;		
		if (ramState = MEMACCESS) then
			nextprevCache <= '0';
			nextstate <= idle;
		elsif (ramState = MEMFREE) then
			nextprevCache <= '0';
			nextstate <= idle;
		end if;
	when icache1 =>
		servicing <= "11";
		nextstate <= icache1;
		if (ramState = MEMACCESS) then
			nextprevCache <= '1';
			nextstate <= idle;
		elsif (ramState = MEMFREE) then
			nextprevCache <= '1';
			nextstate <= idle;			
		end if;
	when data =>--will remain in data until MEMFREE. will go to idle if there are no requests from either icahce. Will go straight to appropriate icache state if requests exist
		servicing <= "01";
		if (ramstate = MEMFREE) then
			servicing <= "00";
			if(aiMemRead0 = '1') then--cache0 request
				if(aiMemRead1 = '1') then--cache1 and cache0 request
					if(prevCache = '0') then--priority to cache1
						nextstate <= icache1;
					else
						nextstate <= icache0; -- priority to cache0
					end if;
				else--cache0 only
					nextstate <= icache0;
				end if;
			elsif(aiMemRead1 = '1') then--cache1 only
				nextstate <= icache1;
			else--return to idle
				nextstate <= idle;
			end if;
		end if;
	end case;
end process memControl_nextstate;

--SERVICING:
--00 = No control
--01 = dCache(coherence) control
--10 = icache0 control
--11 = icache1 control
      aiMemData1 <= ramQ when servicing = "11" else x"00000000";
      iMemRead1 <= '1' when servicing = "11" else '0';
      aMemRdData <= ramQ when servicing = "01" else x"00000000";
      arbWait1 <= '1' when servicing = "11" else '0'; -- what about the data => handled in choherance controller??
      arbWait0 <= '1' when servicing = "10" else '0';
      busy <= '0' when servicing = "01" else '1';
      iMemRead0 <= '1' when servicing = "10" else '0';
      aiMemData0 <= ramQ when servicing = "10" else x"00000000";
      ramAddr <= aMemAddr(15 downto 0) when servicing = "01" else
								 aiMemAddr0(15 downto 0) when servicing = "10" else
								 aiMemAddr1(15 downto 0) when servicing = "11" else
								 (others => '1');					
      ramData <= aMemWrData;
      ramRen <= aiMemRead0 when servicing = "10" else
								aiMemRead1 when servicing = "11" else
								aMemRead when servicing = "01" else
								'0';
      ramWen <= aMemWrite when servicing = "01" else '0';
END ARCHITECTURE arch_name;

