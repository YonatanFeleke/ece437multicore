-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity MemCont is				
    port( Clk, nReset           : in std_logic;
          ramQ    													: in  std_logic_vector(31 downto 0);
          ramState 													: in std_logic_vector(1 downto 0);
          MEM_BusB,PC,MEM_Out								: in std_logic_vector(31 downto 0);
          MEM_MemWr,MEM_Mem2Reg							: in std_logic;
          ID_PcSrc, ID_FLUSH,HALT						: in std_logic;
          hit, dCacheWait        						: in std_logic;
          
          ramAddr 													: out std_logic_vector(15 downto 0);
          ramData 													: out std_logic_vector(31 downto 0);
          MEM_ramOut 												: out std_logic_vector(31 downto 0);          
					INSTR_OUT													: out std_logic_vector(31 downto 0); 
          ramWen,IF_PCSkip         					: out std_logic;
          ramRen,Freeze,stopIcache,stopDcache       		: out std_logic
         );
  end MemCont;

architecture MemCont_behav of MemCont is
	signal ramWriteInt,ramReadInt		 	: std_logic;
  constant MEMFREE        					: std_logic_vector              := "00";
  constant MEMBUSY        					: std_logic_vector              := "01";
  constant MEMACCESS      					: std_logic_vector              := "10";
  constant MEMERROR       					: std_logic_vector              := "11";
  begin

    ramAddr <= MEM_Out(15 downto 0) when (MEM_MemWr = '1' or MEM_Mem2Reg ='1') else PC(15 downto 0);
    ramData <= MEM_BusB when MEM_MemWr = '1' else x"00000000";
    MEM_ramOut <= ramQ when MEM_Mem2Reg ='1' else x"00000000";
    INSTR_OUT <= ramQ	when (hit='0') else  x"00000000";
    ramWen <= ramWriteInt;
    ramRen <= ramReadInt;
    IF_PCSkip <=  '1' when (halt = '1') else 		-- Don't change PC when halt or waiting for dcache
    							'1' when (ID_FLUSH = '1') else -- hazard implementation, don't change PC while buble inserted in EX latch
    							'0' when (ID_PCSrc='1' and dCacheWait ='0') else-- sqaush value in one clk
                	'1' when (hit='0' ) else -- update squash val in 1 cycle and don't get instr(done in stopIcache)          
    							'1' when (hit='1' and dCacheWait ='1') else 
                 	'0'; 
    stopIcache <= '1' when (dCacheWait ='1' or halt ='1' or ID_PcSrc = '1') else
                  '0';-- don't get the value of the (haltPc)+4 instruction or the squash value instr
    Freeze <= '1' when dCacheWait ='1' else
    					'1' when (ID_PcSrc ='0' and hit ='0' and halt='0') else
    					'0';  
		stopDcache <= '0' when ramState= "00" else
    							'1' when (dCacheWait ='0' and  ramState/=MEMFREE and halt='0' and ID_PcSrc='0')or nReset='0';  -- 
---------------------------------------------------- 
-- NOT IMPLEMENTEED!: ramRead skip on branch taken or jr
--ramWrite stays asseted for one more clock cycle by dCache
--------------------------------------------------------------------------------------------         
		    --READ: normal operation
	ramReadInt <= '1'	when (MEM_MEM2REG = '1' or (hit='0' AND dCacheWait ='0' and ID_PcSrc ='0')) else '0'; -- don't set readOnIDPcSrc
	ramWriteInt <= MEM_MemWr;  	        


--  latchIt: process( clk, nReset) 
--   begin 
--    	if nReset= '0' then 
--				stopDcache <= '1';				
--			elsif (ramState=MEMFREE) then
--				stopDcache <= '0';				
--	    elsif (dCacheWait ='0' and  ramState/=MEMFREE and halt='0' and ID_PcSrc='0') then	    	
--				stopDcache <= '1';
--		end if;
--	end process latchIt;


end MemCont_behav;
	

-- Components that need to be moved out
 	 		      --RamRead delay 1 cycle, updatePC Squash val on branch taken on normal operation
--	     		      if (hit='0' AND ID_PcSrc = '1' and dCacheWait ='0') then  
--      		        branchTakenFirstCycle <= '1'; 
--      		        Freeze_Int<= '0'; -- makes the ID_PcSrc move along after that one clk cycle, also flip flops due to WB hazard  		        
--      		        ramReadInt <= '0';
--      		        end if;	
      		        
		-- IF_PCSkip: needs to be moved to the Icache top level block for organizational purpose
		-- stop_iCache can move out too, but not very compartmental.

-- Current component Explanation
--  IF_PCSkip <=  '1' when (ID_FLUSH = '1') else -- hazard implementation, don't change PC while buble inserted in EX latch
--                	'1' when (hit='0' AND (branchTakenFirstCycle='0')) else -- update squash val in 1 cycle and don't get instr Implemented by read below
--                	'1' when (hit='0' AND (ID_PcSrc='0')) else --  Same as above but makes it dependent on the freezing correctly=> BAD! for Dcache              
--								'1' when (hit='1' and Freeze_Int ='1' and (MEM_MemWr = '1' or MEM_Mem2Reg='1')) else 
--'1' when (hit='1' and (MEM_MemWr = '1' or MEM_Mem2Reg='1')) Taken care of in icache_en for misses and right above for
--a memRW session and a local copy found in the icache(pipe should wait so don't update PC), won't propagate due to freeze


-- Old code commented lines

--  	stop <= '1' when halt ='1';

--   Freeze <= '1' when (ramState = MEMBUSY or ramState = "MEMACCESS") else '0' ;
--     	    Freeze <='0';
--					Freeze_Int <='0';

--  ramWen <= MEM_MemWr; -- need to keep 
--  ramRen <=   '0' when branchTakenFirstCycle = '1' else-- will not read squash value since update. SQUASH WHEN hit='1' and pcSrc='1'
--              '0  when Clk='1'and ID_BEQBNE ='1' and 
--              '1' when (MEM_MEM2REG = '1' or (hit='0' AND(MEM_MemWr = '0' and MEM_Mem2Reg='0' and ID_FLUSH = '0'))) else
									 -- LW need to pause the pc so that no bus fighting weather or not there is a hit or miss
--              '0';

--  	INSTR_OUT <= ramQ	when (MEM_MemWr = '0' and MEM_Mem2Reg = '0' and halt='0' and ID_PcSrc ='0' and ID_FLUSH ='0' and hit='0') else 
--  	             x"FFFFFFFF" when halt ='1' else x"00000000";
  	                   -- halt set from ID, bubble on PCSKip or Squash(PC_sRC ='1')
	                    -- 2 Squashes for JR and for BEQ/BNE there will be an error PC
