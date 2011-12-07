-- $Id: $
-- File name:   tb_data16x128.vhd
-- Created:     10/24/2011
-- Author:      Yonatan Feleke
-- Lab Section: Wednesday 2:30-5:20
-- Version:     1.0  Initial Test Bench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dCacheCLU is
  port(
    CLK       : in  std_logic;
    nReset    : in  std_logic;

		Halt			:	in	std_logic;											 -- CPU side
    MemRead		: in  std_logic;                       -- CPU side
		MemWrite	:	in	std_logic;											 -- CPU side
    MemWait		: out std_logic;                       -- CPU side
    MemAddr		: in  std_logic_vector (31 downto 0);  -- CPU side
    MemRdData	: out	std_logic_vector (31 downto 0);  -- CPU side
    MemWrData	: in	std_logic_vector (31 downto 0);  -- CPU side

    aMemWait	: in  std_logic;                       -- arbitrator side
		aMemState	: in	std_logic_vector (1 downto 0);	 -- arbitrator side
    aMemRead	: out std_logic;                       -- arbitrator side
    aMemWrite	: out std_logic;                       -- arbitrator side
    aMemAddr	: out std_logic_vector (31 downto 0);  -- arbitrator side
    aMemRdData: in  std_logic_vector (31 downto 0);  -- arbitrator side
    aMemWrData: out std_logic_vector (31 downto 0);	 -- arbitrator side
    -- LL SC Implementation
    LL,SC,valid    : in std_logic;
    -- Snoop Implementation
    cMemSnoopEn					    : in std_logic;
    cRdX					           : in std_logic;
    cMemAddr 									  :   in std_logic_vector(31 downto 0);     
    chrWaitDbusy			 				: out std_logic; -- tell coherance that a wb or cpufinish is underway
    cacheSnoopEn									: out std_logic; -- the chrWaitDbusy is valid
--    linkAddr       : out std_logic_vector(31 downto 0); in top Dcache level as memadr
    LLWen      : out std_logic;    
		-- Ram Connection	
		wEN				: out std_logic;
		readport 	: in 	 STD_LOGIC_VECTOR (184 DOWNTO 0);
    addr      : out  STD_LOGIC_VECTOR (3 DOWNTO 0);	    
  	writeport : out  STD_LOGIC_VECTOR (184 DOWNTO 0);
  	haltDone	: out  STD_LOGIC
		);
end dCacheCLU;
architecture behav of dCacheCLU is
constant MEMFREE        : std_logic_vector              := "00";
constant MEMBUSY        : std_logic_vector              := "01";
constant MEMACCESS      : std_logic_vector              := "10";
constant MEMERROR       : std_logic_vector              := "11";
----------------------------------------------------------------------------------------------------------------		
type tagAry is 					array( 15 downto 0) of std_logic_vector( 24 downto 0);-- array tracking the cached instructions
type tagWay is 					array( 1 downto 0) of tagAry; --(V|D|tag24->0|V|D|tag24downto)
type VDAry  is 					array (15 downto 0) of std_logic_vector( 1 downto 0);
type vlddrty is  array( 1 downto 0) of VDAry;
signal ValidDirtyBits, nextValidDirtyBits : vlddrty;
signal tag,nexttag      : 	tagWay;
signal addrInt 																						: STD_LOGIC_VECTOR (3 DOWNTO 0);
signal chrWaitDbusyInt,hitonway1,nexthitonway1,chrWork,nxtchrWork,locUpd		 : std_logic;
----------------------------------------------------------------------------------------------------------------------    
		signal readInt,nextWritePort,nextreadInt									: std_logic_vector(184 downto 0);
		signal tagA,tagB																					: std_logic_vector(24 downto 0);
		signal data1A,data2A																			: std_logic_vector(31 downto 0);
		signal data1B,data2B																			: std_logic_vector(31 downto 0);
		signal write2Data,nextwrite2Data        									: std_logic_vector(31 downto 0);
		signal validA,validB,dirtyA,dirtyB,LRU										: std_logic;
		signal haltAddr																						: std_logic_vector(3 downto 0);
		signal destWay,nextdestWay																: std_logic_vector(2 downto 0);--*******		
		type state_type is(idle,snpHitChk,snpUpdate,linkIt,SCInvalid, chkHit,cleanRW,dirtyRW,read1,read2,write1,write2,waitSingle1,waitSingle2,update,hitUpdate,haltDump,halted);
		signal state,nextState,rtnState,nextRtnState  : state_type; -- used to reloop

		signal mem2CacheData1,mem2CacheData2,nextmem2CacheData1,nextmem2CacheData2	: std_logic_vector(31 downto 0);
		signal hit,haltHit,wENInt,haltDump1,nexthaltDump1														:	std_logic;
		signal count16,nextCount16	 																								: integer range 17 downto 0;
		signal nextaMemWrData, aMemWrDataInt																				:   std_logic_vector (31 downto 0);  -- arbitrator side				
		signal nextaMemAddr, aMemAddrInt																						:   std_logic_vector (31 downto 0);  -- arbitrator side				
		signal nextaMemWrite																												:	std_logic;

begin
	chrWaitDbusy<= chrWaitDbusyInt;
	
	-----------

	aMemWrData<=aMemWrDataInt;
	aMemAddr<=aMemAddrInt;	
	wEN <= wENInt;
	writeport <= nextWritePort;
	addrInt <= cMemAddr(6 downto 3) when (chrWork='1') else MemAddr(6 downto 3) when (halt ='0' ) else haltAddr;-- when state=haltDump ;--F!
	addr <= addrInt;
	validB 	<=  readInt( 184 );
	dirtyB 	<=	readInt( 183 );
	LRU			<=	readInt( 182 );	--	LRU 0-> BLOCK A 1 BLOCKB
	tagB		<= 	readInt( 181 downto 157 );
	data2B	<=  readInt( 155 downto 124);
	data1B	<= 	readInt( 123 downto 92);
	validA 	<=	readInt( 91 );
	dirtyA 	<=	readInt( 90 );
	tagA		<=	readInt( 89 downto 65 );
	data2A	<=	readInt( 63 downto 32 ); 
	data1A	<=	readInt( 31 downto 0 );		
------------
  pauseSnoop: process(cMemSnoopEn,cRdx,MemWrite,MemRead,MemAddr,tag,ValidDirtyBits,cmemaddr,chrwork)
  	variable idxloc : integer range 0 to 15;
  	variable idxMem : integer range 0 to 15;
    begin 

  end process pauseSnoop;
-----------------------------------------------------------------------------------------------------

  latchIt: process( clk,chrWork,nxtchrWork,hitonway1,nexthitonway1,tag,nexttag,ValidDirtyBits,nextValidDirtyBits,wENInt, nReset,nextRtnState,nextCount16,nextState,nexthaltDump1,nextReadInt,halt,aMemWait,nextaMemWrData,nextaMemAddr,nextdestway,nextaMemWrite,nextwrite2Data,nextmem2CacheData1,nextmem2CacheData2)
    begin 
    	if nReset= '0' then 
    			state <= idle;
    			count16 <= 0;
    			rtnState <= idle;
    			haltDump1 <= '0';
    			readInt <=(others => '0');
    			aMemWrDataInt <= (others => '0');
    			aMemAddrInt <=(others => '0');
    			destWay <= (others =>'0');
    			aMemWrite <= '0';
		  		write2Data<=	(others =>'0');
		  		mem2CacheData1 <=(others =>'0');
		  		mem2CacheData2 <= (others =>'0');
		  		----- initialize local tag array.
		  		for w in 1 downto 0 loop
			 			for i in 15 downto 0 loop
							tag(w)(i) <= (others => '0');
							ValidDirtyBits(w)(i) <= "00";
						end loop;
					end loop;
	    		hitonway1 <= '0';
	    		chrWork <= '0';
	    elsif (rising_edge(clk) and aMemWait ='0' )   then  -- check fi 			
	    		chrWork <= nxtchrWork;
					hitonway1 <= nexthitonway1;	
	    		tag <= nexttag;
					ValidDirtyBits <= nextValidDirtyBits;
					---------
		  		mem2CacheData1 <= nextmem2CacheData1;
		  		mem2CacheData2 <= nextmem2CacheData2;
		  		write2Data<=	nextwrite2Data;	    		  		
	    		aMemWrite <= nextaMemWrite;
			    destWay <= nextdestWay;
    			aMemAddrInt <= nextaMemAddr;
    			aMemWrDataInt <= nextaMemWrData;
	    		readInt <=nextreadInt;	    		
			    haltDump1<=nexthaltDump1;
					state <= nextState;
					count16 <= nextCount16;
					rtnState <= nextRtnState;
			elsif (rising_edge(clk) and wENInt = '1') then							
	    		tag <= nexttag;
					ValidDirtyBits <= nextValidDirtyBits;							
		end if;
  end process latchIt;

-------------------------------------------------------------------------------
	nextStateProcess: process(state,valid,SC,LL,readport,aMemState,MemAddr,MemWrData,data1A,data2A,data1B,data2B,aMemRdData,mem2CacheData2, mem2CacheData1, haltAddr,locUpd,write2Data,LRU,tagA,tagB,validA,validB,dirtyA,dirtyB,readInt,nextdestWay,count16,haltDump1,destway,MemWrite,MemRead,hit,rtnState,haltHit,halt,aMemWrDataInt,aMemAddrInt,cmemaddr,cRdx,cmemsnoopen,hitonway1,chrwork,addrint,validdirtybits,tag)
   	variable  idxloc,idxMem           : integer range 0 to 15;
   	variable	wayVal								: integer range 0 to 1;
   	variable	localUpdNeeded : std_logic;
    begin    
--------------------------------------------------------------------------------------------------------------------------
			   idxloc := to_integer(unsigned(cMemAddr(6 downto 3)));
			   idxMem  := to_integer(unsigned(MemAddr(6 downto 3)));			   
			   chrWaitDbusyInt <= '0';
			   locUpd <= '0';
			   nexthitonway1 <= hitonway1;
			   		if (cRdx ='1' or cMemSnoopEn ='1') then  -- Conditions where a WB is required or Currently working on such variable
          		for w in 1 downto 0 loop-- so that we don't pause other in mid operation. Immediately pause while other in idle
    						if (tag(w)(idxloc) = cMemAddr(31 downto 7) and  ValidDirtyBits(w)(idxloc) = "11") then
    									chrWaitDbusyInt <= '1'; --wait for write back 
    									if (w = 1) then nexthitonway1 <= '1'; else nexthitonway1 <= '0'; end if; -- modified -> Invalidate or shared (figured out in update)
    									locUpd <= '1';
  							elsif (tag(w)(idxloc) = cMemAddr(31 downto 7) and  validDirtyBits(w)(idxloc) = "10" and cRdx = '1' ) then	--snpCleanHit; shared to invalidate
      							if (w = 1 ) then nexthitonway1 <= '1'; else nexthitonway1 <= '0'; end if;	
      							chrWaitDbusyInt <= '1'; --make other cache wait for local tagarray update.
      							locUpd <= '1';		
    						elsif (tag(w)(idxMem) = cMemAddr(31 downto 7) and  MemWrite ='1' and chrWork='0') then-- conflict with a write occuring (wait for update of tagarray)
    									chrWaitDbusyInt <= '1'; --wait for current write to finish and then write back;
    									locUpd <= '0';
    						--elsif (tag(w)(idxMem) = cMemAddr(31 downto 7) and ValidDirtyBits(w)(idxloc)(1 downto 1) = "1" and chrWork='1' ) then
								--			chrWaitDbusyInt <= '1'; --wait for write back to finish since on chrWork. NO NEED SNPUPDATE will change the bits
								--			locUpd <= '0'; -- when wb finishes it will update accordingly						
								end if;
							end loop;
					end if;    
    
-----------------------------------------------------------------------------------------------------------------------    
    	-- Signal initializations	to avoid latches
			MemWait <= '1';
    	aMemRead	 <= '0';                       -- arbitrator side		
		  wENInt <= '0';			

			--RAM INTERFACE SINGALS			
  		haltDone	 <= '0';
 			haltHit <='0';
 			nextdestWay <= destWay;
 			nexthaltDump1 <= haltDump1;		
		  nextWritePort <= (others => '0');
		  nextwrite2Data<=	write2Data;		
  		nextReadInt <= ReadInt;
  		nextaMemAddr<= aMemAddrInt;--(others => '0');
      nextaMemWrData<= aMemWrDataInt;--(others => '0');
		  nextmem2CacheData1 <= mem2CacheData1;
		  nextmem2CacheData2 <= mem2CacheData2; 
		  nextaMemWrite	 <= '0';
		  MemRdData <= x"00000001";-- need to have 1 returned on succesful SC but will be set to 0 in invalidate
			------------------------------
  		nextState <= state;
  		nextCount16 <=Count16;
  		LLwen <= '0'; 							-- link enable
			nextRtnState <= rtnState;
		 	hit <= '0';
		 	haltAddr <= (others => '0'); -- used only in haltDump
		 	-------------------------------------------------------------
		 	-- Coherance snoop work
			nexttag <= tag;
			nextValidDirtyBits <= ValidDirtyBits;
     	localUpdNeeded := '0';
			nxtchrwork <= chrwork;
			
      cacheSnoopEn <= '0'; -- only snoop in idle, if snoop needs a wait aMemWait(stopdcahce ='1')
    case state is 
      	when idle =>
              if ( MemWrite ='0' and MemRead ='0' and cMemSnoopEn='0' and cRdx ='0' and SC ='0') then
              	MemWait <= '0';-- so if conflict CPU finishes ,idle and then snoop check while PC waits		
              end if;
              -- Variable initializations; one time only involves latches
              if (MemRead = '0') then
              	MemRdData  <= (others => '1'); --- FFFFFFF shows up in reg means wrong	
              end if;
              hit <= '0';
              haltDone <= '0';
              nexthaltDump1 <= '0';     					   	      	 
              nextReadInt <= readport;
              nextState <= idle;
              nextRtnState <= idle;
              --nexthitonway1 <= '0';
              cacheSnoopEn <= '1'; --signal that this cache is snooping right now in idle.. if SC miss don't bother snooping
              nxtchrWork <='0'; 
              if (locUpd ='1') then -- are only asserted in IDLE of other cache
              		nxtchrWork <='1';
              		nextstate <= snpHitChk;
       				elsif LL = '1' then
       						nextstate <= linkIt;
       				elsif SC ='1' then
			        		if (valid = '1') then
      			  			nextState <= chkHit;
        					else 	nextState <= SCInvalid;
      			  		end if;	       						       					  					
       				elsif halt = '1' then 
  	      				nextState <= haltDump;
        			elsif (MemRead = '1' or MemWrite = '1') then
									nextState <= chkHit;
        			end if; 
       	---- MSI programming
      	when snpHitChk =>
																	if ( hitonway1 ='1') then wayVal:= 1; else wayVal:=0; end if; -- convert hitonway1 to 
																	nxtchrwork <= '0'; 
																	locUpd <= '0';
		        	          					-- copy of idle to move straight to next valid state
                           				if LL = '1' then	nextstate <= linkIt;                				
                           				elsif SC ='1'then
                    			        		if (valid = '1') then	nextState <= chkHit;
                            					else 	nextState <= SCInvalid;		end if;	       
                           				--elsif halt = '1' then nextState <= haltDump;--have to go back to idle and then to halt
                            			elsif (MemRead = '1' or MemWrite = '1') then	nextState <= chkHit; 
                            			else nextstate <= idle; MemWait <= '0';
                            			end if;           			
	    						if (tag(wayVal)(idxloc) = cMemAddr(31 downto 7) and  ValidDirtyBits(wayVal)(idxloc) = "11") then --snpDirtyHit;						
    									nxtchrwork <= '1';        						
          						nextState <= write1;-- neccesary preparation to write twice
          						nextaMemWrite	 <= '1';  
          						MemWait <= '1';
          						nextRtnState <= snpUpdate;
                		  nextaMemAddr <= cMemAddr(31 downto 3) & '0' & cMemAddr(1 downto 0);
                     	if wayVal = 0 then --hit on way 0 (a)
                     			nextaMemWrData<= readport( 31 downto 0 );  -- assumes that addrInt is correct 
          								nextwrite2Data <= readport( 63 downto 32 );
          						elsif wayVal=1 then -- hit on way 1 (b)      				
                     			nextaMemWrData<= readport( 123 downto 92);  -- assumes that addressInt is correct 
          								nextwrite2Data <= readport( 155 downto 124);
                     	end if;   
    							elsif (tag(wayVal)(idxloc) = cMemAddr(31 downto 7) and  validDirtyBits(wayVal)(idxloc) = "10" ) then--clean Hit, invalidate
        							if (cRdx = '1') then 
        									if wayVal = 0 then  --invalidate if shared
          	 			  				nextWritePort <= readport(184 downto 92) & "00" & readport(89 downto 0); -- invalidate
          	 			  				nextvalidDirtyBits(0)(idxloc) <= "00";
            				  			wENInt <= '1';
          								elsif wayVal = 1 then 			  		
          									nextWritePort <= "00" & readport(182 downto 0);--invalidate
          									nextvalidDirtyBits(1)(idxloc) <= "00";
          									wENInt <= '1';
          								end if;
       								else 
        								wENInt <= '0';
       								end if;				
								end if;
				when snpUpdate => -- snpDirty Hit update tag array and ram
                           				if LL = '1' then	nextstate <= linkIt;
                           				elsif SC ='1' then
                        			        		if (valid = '1') then	nextState <= chkHit;
                                					else 	nextState <= SCInvalid;		end if;	       
                           				--elsif halt = '1' then nextState <= haltDump; -- need to go idle then halt
                            			elsif (MemRead = '1' or MemWrite = '1') then	nextState <= chkHit; else nextstate <= idle; MemWait <= '0';end if; 					
              nxtchrwork <= '0';
--              nextRtnState <= idle;
              wENInt <= '1';
              if (cRdx = '1') then -- invalidate
              		if hitonway1 = '1' then 
  										nextWritePort <= "00" & readport(182 downto 0);--invalidate
  										nextvalidDirtyBits(1)(idxloc) <= "00";
  								elsif hitonway1 ='0' then 	
              				nextWritePort <= readport(184 downto 92) & "00" & readport(89 downto 0); -- invalidate 			  			
              				nextvalidDirtyBits(0)(idxloc) <= "00";            				
              		end if;
   			  		else  -- change to shared
              		if hitonway1 = '1' then 
  										nextWritePort <= "10" & readport(182 downto 0);--invalidate
  										nextvalidDirtyBits(1)(idxloc) <= "10";
  								elsif hitonway1 = '0' then 	
              				nextWritePort <= readport(184 downto 92) & "10" & readport(89 downto 0); -- invalidate 			  			
              				nextvalidDirtyBits(0)(idxloc) <= "10";			  			
              		end if;
              end if;
  							
				--linkIt,SCchk,SCInvld,----------------------------------------------------------
        when linkIt	=>
        		LLwen  <= '1'; -- link it
						nextState <= chkHit;
        when SCInvalid =>
        		nextState <= Idle;
   					MemWait <= '0'; -- allows pipe to get the value
   					MemRdData <= (others =>'0'); -- SC failed value returned to pipe
   			----------------------------- Normal operation states------------------------
 			  when chkHit 	=>
 			  			 nextState <= cleanRW;
 			  			 nextReadInt <= readport;
 			  			---------------Hit Found -------------------
 			  			--- Way A
 			  			if (MemAddr(31 downto 7) = tagA and validA = '1' ) then -- Hit with A
 			  					hit <= '1';
 			  					nextdestWay <= "110";
 			  					nextState <= hitUpdate;		  					  			 			  						
 			  			--- Way B
 			  			elsif (MemAddr(31 downto 7) = tagB and validB = '1' ) then -- Hit with B
 			  					hit <= '1';
 			  					nextdestWay <= "111";
 			  					nextState <= hitUpdate; 			  					
 			  			-------------- Miss Combinations-------------		
 			  			elsif (LRU = '1' and dirtyA = '0' ) then -- miss with cleanA(LRU)
 			  					nextdestWay <= "000";
 			  			elsif (LRU = '0' and dirtyB = '0' ) then -- miss with CleanB(LRU)
 			  					nextdestWay <= "001"; 			
 			  			elsif (LRU = '1' and dirtyA = '1' and dirtyB = '0' ) then -- miss with DirtyA and CleanB(LRU) use B
 			  					nextdestWay <= "010";
 			  			elsif (LRU = '0' and dirtyB = '1' and dirtyA = '0' ) then -- miss with DirtyB and CleanA(LRU) use A
 			  					nextdestWay <= "011";
 			  			elsif (LRU = '1' and dirtyA = '1' and dirtyB = '1' ) then -- miss with DirtyA and DirtyB(LRU) use A
 			  					nextdestWay <= "100";
 			  					nextState <= dirtyRW;
 			  			elsif (LRU = '0' and dirtyA = '1' and dirtyB = '1' ) then -- miss with DirtyB and dirtyA(LRU) use B
 			  					nextdestWay <= "101";
 			  					nextState <= dirtyRW;
  						end if;
			  		
      	when hitUpdate 	=>
  						memWait <= '0';
 			  			---------------Hit Found -------------------
 			  			--- Way A
 			  			if ( destWay = "110" ) then 																		-- Hit with wayA 
 			  					if ((SC ='1' or MemWrite = '1') and MemAddr(2)='0') then 								-- update data1A w/ dirty and valid
 			  						nextWritePort <= readInt(184 downto 92) & "11" & tagA & '0' & data2A & MemWrData;
 			  						nexttag(0)(idxMem) <= tagA;
 			  						nextValidDirtyBits(0)(idxMem) <= "11"; 			  						
 			  						wENInt <= '1';
 			  					elsif ((SC ='1' or MemWrite = '1') and MemAddr(2)='1') then 							-- update data2A w/ dirty and valid
 			  						nextWritePort <= readInt(184 downto 92) & "11" & tagA & '1' &  MemWrData & data1A ;
 			  						wENInt <= '1'; 			  						
 			  						nexttag(0)(idxMem) <= tagA;
 			  						nextValidDirtyBits(0)(idxMem) <= "11"; 
								elsif (MemRead ='1' and MemAddr(2) = '0') then 								-- update LRU to 0 and output Value
 			  						nextWritePort <= ValidB & DirtyB & '0' & readInt(181 downto 0);--LRU Update
 			  						wENInt <= '1';
										MemRdData <= Data1A;
								elsif (MemRead ='1' and MemAddr(2) = '1') then
										nextWritePort <= ValidB & DirtyB & '0' & readInt(181 downto 0);--LRU Update
 			  						wENInt <= '1';										
										MemRdData <= Data2A;
								end if;								  			 			  						
	  					--- Way B
 			  			elsif (destWay = "111") then 																		-- Hit with B
			  					if ((SC ='1' or MemWrite = '1') and MemAddr(2)='0') then 								-- update data1B w/ dirty and valid
			  						nextWritePort <= "11"& LRU & tagB & '0' & data2B & MemWrData & readInt(91 downto 0);
			  						wENInt <= '1';
 			  						nexttag(1)(idxMem) <= tagB;
 			  						nextValidDirtyBits(1)(idxMem) <= "11"; 
			  					elsif ((SC ='1' or MemWrite = '1') and MemAddr(2)='1') then 						-- update data2B w/ dirty and valid
			  						nextWritePort <= "11"& LRU & tagB & '1' &  MemWrData & readInt(123 downto 0) ;
			  						wENInt <= '1'; 			  						
 			  						nexttag(1)(idxMem) <= tagB;			  						
 			  						nextValidDirtyBits(1)(idxMem) <= "11"; 
									elsif (MemRead ='1' and MemAddr(2) = '0') then--update LRU and output value
										--- LRU Updae make sure by the rising clk the addr doesn't change the latched ram value#####
			  						nextWritePort <= ValidB & DirtyB & '1' & readInt(181 downto 0);--LRU Update
			  						wENInt <= '1';			  						
										MemRdData <= Data1B;
									elsif (MemRead ='1' and MemAddr(2) = '1') then
			  						nextWritePort <= ValidB & DirtyB & '1' & readInt(181 downto 0);--LRU Update
			  						wENInt <= '1';
										MemRdData <= Data2B;
								end if;	
							end if; 		      	
							---------------------------------------------------------------      	
      				nextState <= idle;						
      	when cleanRW 	=>
      				nextaMemAddr <= MemAddr(31 downto 3) & '0' & MemAddr(1 downto 0);    	      	      	
      				nextRtnState <= update;
      				nextState<= read1;

 			  when dirtyRW 	=>
 			      	if(rtnState = dirtyRW) then -- back from writing dirty blocks
          				nextRtnState <= update;
          				nextState <= read1;
          				nextaMemAddr <= MemAddr(31 downto 3) & '0' & MemAddr(1 downto 0); -- set offset = 0 for the first read
	  					elsif (rtnState = idle) then -- first time, wr wr rd rd.
      						if( destWay = "100") then -- replace DirtyA
      	         				nextaMemWrData<= Data1A;      
      									nextwrite2Data <= Data2A;
      		        			nextaMemAddr <= TagA & MemAddr(6 downto 3) & "000";	        			
                				nextRtnState <= dirtyRW;
                				nextState<= write1;      						  
             						nextaMemWrite	 <= '1';                       -- arbitrator side  
      						elsif ( destWay = "101") then -- replace DirtyB
    		        			nextaMemAddr <= TagB & MemAddr(6 downto 3) & "000";--Tag&idxMem&offset&skipBits
              				nextaMemWrData<= Data1B;    
	    								nextwrite2Data <= Data2B;
              				nextRtnState <= dirtyRW;
              				nextState<= write1;      						  
           						nextaMemWrite	 <= '1';                       -- arbitrator side  
          			end if;			  							
  						end if;
      	when read1 		=>
      				aMemRead <= '1';
		      		nextState <= read1;		      		
      				if (aMemState = MEMACCESS) then 
      						nextmem2CacheData1<= aMemRdData;
      						nextState <= read2;
      						nextaMemAddr <= aMemAddrInt(31 downto 3) & "100";
      				end if;		 
 			  when read2 		=>
      				aMemRead <= '1';
 			  			nextState <= read2; 			  	
      				if (aMemState = MEMACCESS) then 
      						nextmem2CacheData2<= aMemRdData;
      						nextState <= rtnState;
      				end if;	

      	when write1 	=>
      					nextaMemWrite	 <= '1';       	  				
      				nextState <= write1;							
      				if (aMemState = MEMACCESS) then
      					nextState <= waitSingle1;	  						  
      				end if;
      	when waitSingle1 	=>  
      				nextState <= write2;
      				nextaMemWrData<= write2Data;
   						nextaMemAddr <= aMemAddrInt(31 downto 3) & "100";
   						nextaMemWrite	 <= '0';    				
 			  when write2 	=>
			 			  nextaMemWrite	 <= '1'; 
 			  	    nextState <= write2;
      				if (aMemState = MEMACCESS) then
      					nextState <= waitSingle2;
      				end if;	 			           		  
      	when waitSingle2 	=> 
			      	nextaMemWrite	 <= '0';
      				nextState <= rtnState;  -- Note nextWrData is going to be zero        		      		      		      		
      	when update 	=>
		      		MemWait <= '0';
      				if ((SC ='1' or MemWrite = '1')) then
      					-- Replace way A
  	    				if (destWay="000" or destWay="011" or destWay="100") then -- replace A's read data with busb, and makedirty
  	    					if (MemAddr(2) = '0') then -- write data1a<= busb(memwrdata)
		      					nextWritePort <= readport(184 downto 92) & "11" & MemAddr(31 downto 7) & '0' & mem2CacheData2 & MemWrData;
		      					wENInt <= '1';		
			  						nexttag(0)(idxMem) <= MemAddr(31 downto 7);     					
			  						nextValidDirtyBits(0)(idxMem) <= "11"; 
  	    					elsif (MemAddr(2) = '1') then -- write data2a<= busb(memwrdata)
		      					nextWritePort <= readport(184 downto 92) & "11" & MemAddr(31 downto 7) & '1' &  MemWrData & mem2CacheData1;
		      					wENInt <= '1';
			  						nexttag(0)(idxMem) <= MemAddr(31 downto 7);		      					
			  						nextValidDirtyBits(0)(idxMem) <= "11"; 
		      				end if;
		      			-- Replace Way B	
  	    				elsif (destWay="001" or destWay="010" or destWay="101") then -- replace B's read data with busb
  	    					  if (MemAddr(2) = '0') then -- write data1b <= busb(memwrdata)
		      					nextWritePort <= "110" & MemAddr(31 downto 7) & '0' & mem2CacheData2 & MemWrData  & readport(91 downto 0) ;	
		      					wENInt <= '1';
		      					nexttag(1)(idxMem) <= MemAddr(31 downto 7);		
		      					nextValidDirtyBits(1)(idxMem) <= "11"; 
		      				elsif (MemAddr(2) = '1') then -- write data2b <= busb(memwrdata)
		      					nextWritePort <=  "110" & MemAddr(31 downto 7) & '1' & MemWrData & mem2CacheData1 & readport(91 downto 0) ;		      		
		      					wENInt <= '1';
		      					nexttag(1)(idxMem) <= MemAddr(31 downto 7);		
		      					nextValidDirtyBits(1)(idxMem) <= "11"; 
              		end if;
            		end if;
        		    
		    		elsif (MemRead = '1') then -- only difference is that not dirty and update both data1 and 2
      					-- Replace way A
  	    				if (destWay="000" or destWay="011" or destWay="100") then -- replace A's read data with busb, and makedirty  	    					
		      					nextWritePort <= readport(184 downto 92) & "10" & MemAddr(31 downto 7) & '0' & mem2CacheData2 & mem2CacheData1;
		      					wENInt <= '1';
		      					nexttag(0)(idxMem) <= MemAddr(31 downto 7);	
		      					nextValidDirtyBits(0)(idxMem) <= "10"; 
										if( MemAddr(2) = '0') then-- Output to the bus the correct offset data
				      					MemRdData <= mem2CacheData1;
										else MemRdData <= mem2CacheData2;--offset ='1' or block2
										end if;
		      			-- Replace Way B	
  	    				elsif (destWay="001" or destWay="010" or destWay="101") then -- replace B's read data with busb
  	    						nextWritePort <= "101" & MemAddr(31 downto 7) & '0' & mem2CacheData2 & mem2CacheData1 & readport(91 downto 0) ;	      		
  	    						wENInt <= '1';
		      					nexttag(1)(idxMem) <=MemAddr(31 downto 7);
										nextValidDirtyBits(1)(idxMem) <= "10";
										if( MemAddr(2) = '0') then-- Output to the bus the correct offset data
				      					MemRdData <= mem2CacheData1;
										else MemRdData <= mem2CacheData2;--offset ='1' or block2  	    						
										end if;
  	    				end if;
  	    			end if;	  	
  	    			----------------------------------------------------------      	
	      				nextState <= idle;--NEXT ONE TO GO!
 			  when haltDump =>			-- for 0->15 if dirtyBit write to Memory	***; Assume no invalid dirty bits
 			  			-- has till next clk to stop
 			  			haltAddr <= std_logic_vector(to_unsigned(count16,4));
 			  			nextReadInt <= readport;
 			  			nextCount16 <= count16 + 1;
 			  			nextState <= haltDump;--if not hit inc count and goto dump again
							nextrtnState <= haltDump; -- from 
 			  			if (count16 /= 16 ) then 			  					
 			  					if (readport( 90 ) = '1' and haltDump1='0') then --haltdirtyA = '1'--
										nextaMemAddr <= readport(89 downto 65) & haltAddr & "000";--TagA&idxMem&offsetA&skipBits	
										nextaMemWrData <= readport(31 downto 0 );	--data1A
										nextwrite2Data <= readport(63 downto 32 );--data2a
										haltHit  <= '1';
										nexthaltDump1 <= '1';
										nextCount16 <= count16 ;-- don't count since we haven't checked wayB yet
 			  						nextState <= write1;--else haltDump
     								nextaMemWrite	 <= '1'; 										
									elsif (readport( 183 ) = '1') then  --haltDirtyB = '1'
			  						nextaMemAddr <= readport( 181 downto 157 ) & haltAddr & "000";--Tag&idxMem&offset&skipBits
										nextaMemWrData <= readport(123 downto 92 );	--data1B
										nextwrite2Data <= readport(155 downto 124 );--data2B
										haltHit <= '1';
										nexthaltDump1 <= '0';
		 			  				nextState <= write1;--else haltDump
     								nextaMemWrite	 <= '1'; 										
									elsif (readport(183) = '0' and haltDump1='1') then -- finished with dirtyA and B is not dirty
										nexthaltDump1 <= '0'; -- not hit and allow next time to be first run
									elsif (count16 = 15)  then-- both are not dirty and final
										nextState <= halted; -- could tweak out by using rtnState if (count16 = 15 and haltHit='1') nextrtnState <= halted;
									end if;
							else
								nextState <= halted; -- halt since finished with idxMem 15
								nextCount16 <= 16; -- stop incrementing
 			  			end if;
 			  when halted	 	=>
 			  			nextCount16 <= 15;	
 			  			nextState <= halted;  	
		  				haltDone <= '1';
 							MemWait <= '0';
     			end case;
	end process nextStateProcess;		
end behav;
