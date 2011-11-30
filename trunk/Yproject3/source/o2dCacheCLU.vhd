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
		signal readInt,nextWritePort,nextreadInt												: std_logic_vector(184 downto 0);
		signal tagA,tagB																				: std_logic_vector(24 downto 0);
		signal data1A,data2A																										: std_logic_vector(31 downto 0);
		signal data1B,data2B																										: std_logic_vector(31 downto 0);
		signal write1Addr,write2Addr,write1Data,write2Data        : std_logic_vector(31 downto 0);
--		signal nextwrite1Addr,nextwrite2Addr,nextwrite1Data,nextwrite2Data        : std_logic_vector(31 downto 0);		
		signal validA,validB,dirtyA,dirtyB,LRU											: std_logic;
		signal haltAddr																						: std_logic_vector(3 downto 0);
		signal destWay,nextdestWay																													: std_logic_vector(2 downto 0);--*******		
		type state_type is(idle,chkHit,cleanRW,dirtyRW,read1,read2,write1,write2,waitSingle1,waitSingle2,update,hitUpdate,haltDump,halted);
		signal state,nextState,rtnState,nextRtnState  : state_type; -- used to reloop

		signal mem2CacheData1,mem2CacheData2																		: std_logic_vector(31 downto 0);
		signal read1Addr,read2Addr			 																									: std_logic_vector(31 downto 0);
		signal hit,haltHit,wENInt,haltDump1,nexthaltDump1														 :	 std_logic;
		signal count16,nextCount16 : integer range 16 downto 0;

-- Latch work
		signal nextaMemWrData, aMemWrDataInt											:   std_logic_vector (31 downto 0);  -- arbitrator side				
		signal nextaMemAddr, aMemAddrInt											:   std_logic_vector (31 downto 0);  -- arbitrator side				
		signal nextaMemWrite																	:	std_logic;
		
		

begin
	aMemWrData<=aMemWrDataInt;
	aMemAddr<=aMemAddrInt;	
	wEN <= wENInt;
	writeport <= nextWritePort;
--	readInt <=	(others => '0') when (MemRead = '0' and MemWrite = '0' and wENInt ='0')  else readport when state=chkHit;
	addr <= MemAddr(6 downto 3) when (halt ='0' ) else haltAddr;-- when state=haltDump ;--F!
	validB 	<=  readInt( 184 );
	dirtyB 	<=	readInt( 183 );
	LRU			<=	readInt( 182 );	--	LRU 0-> BLOCK A 1 BLOCKB
	tagB		<= 	readInt( 181 downto 157 );
--	offsetB <= 	readInt( 156 );
	data2B	<=  readInt( 155 downto 124);
	data1B	<= 	readInt( 123 downto 92);
	validA 	<=	readInt( 91 );
	dirtyA 	<=	readInt( 90 );
	tagA		<=	readInt( 89 downto 65 );
--	offsetA <= 	readInt( 64 );
	data2A	<=	readInt( 63 downto 32 ); 
	data1A	<=	readInt( 31 downto 0 );		


  latchIt: process( clk, nReset,nextRtnState,nextCount16,nextState,nexthaltDump1,nextReadInt,halt,aMemWait,nextaMemWrData,nextaMemAddr,nextdestway,nextaMemWrite)
    begin 
    	if nReset= '0' then 
    			state <= idle;
    			count16 <= 0;
    			rtnState <= idle;
    			haltDump1 <= '0';
    			readInt <=(others => '0');
    			aMemWrDataInt <=(others => '0');
    			aMemAddrInt <=(others => '0');
    			destWay <= (others =>'0');
    			aMemWrite <= '0';
--    			write1Addr <=(others =>'0');
--		  		write2Addr	<=(others =>'0'); 
--		  		write1Data<= (others =>'0');
--		  		write2Data<=	(others =>'0');
	    elsif (rising_edge(clk) and (aMemWait ='0' or halt='1'))   then  -- probably won't use aMemWait
--    			write1Addr <= nextwrite1Addr;
--		  		write2Addr	<=nextwrite2Addr; 
--		  		write1Data<= 	nextwrite1Data;
--		  		write2Data<=	nextwrite2Data;	    
	    		aMemWrite <= nextaMemWrite;
			    destWay <= nextdestWay;
    			aMemAddrInt <= nextaMemAddr;
    			aMemWrDataInt <= nextaMemWrData;
	    		readInt <=nextreadInt;	    		
			    haltDump1<=nexthaltDump1;
					state <= nextState;
					count16 <= nextCount16;
					rtnState <= nextRtnState;
		end if;
  end process latchIt;
-------------------------------------------------------------------------------		
	outputlogic: process(state,readport,aMemState,MemAddr,MemRead,MemWrData,data1A,data2A,data1B,data2B,read1Addr, aMemRdData, read2Addr, mem2CacheData2, mem2CacheData1, haltAddr, write1Addr, write1Data, write2Addr, write2Data ,MemWrite,LRU,tagA,tagB,validA,validB,dirtyA,dirtyB,readInt,nextdestWay,count16,haltDump1,destway) 
--			variable haltAddr : std_logic_vector(3 downto 0);
	begin
			-- Signal initializations	
			MemWait <= '1';
    	aMemRead	 <= '0';                       -- arbitrator side		

-- 	    aMemWrite	 <= '0';                       -- arbitrator side
--			aMemAddr	 <= (others => '1');  -- arbitrator side 	    		
--			aMemWrData <=	(others => '1'); --- FFFFFFF shows up on q means error
		  wENInt <= '0';			
			--RAM INTERFACE SINGALS			
  		haltDone	 <= '0';
 			haltHit <='0';
 			nextdestWay <= destWay;
 			nexthaltDump1 <= haltDump1;		
--		  nextWritePort <= (others => '0');
--		  nextwrite1Addr<= write1Addr;
--		  nextwrite2Addr<= write2Addr;
--		  nextwrite1Data<= write1Data;
--		  nextwrite2Data<=	write2Data;
		  
	    case state is     			
      		when idle =>
--      					aMemAddr	 <= (others => '1');  -- arbitrator side 	    		
--								aMemWrData <=	(others => '1'); --- FFFFFFF shows up on q means error
	
      					if ( MemWrite ='0' and MemRead ='0') then
		      					MemWait <= '0';      					
		      			end if;
      					-- Variable initializations; one time only involves latches

								if (MemRead = '0') then
										MemRdData  <= (others => '1'); --- FFFFFFF shows up in reg means wrong	
								end if;
--      					nextdestWay <= "000";
      					hit <= '0';
     					  mem2CacheData1 <= (others => '0');
     					  mem2CacheData2 <= (others => '0');     					  
     					  
								write1Addr <= (others => '0');
								write2Addr <=	(others => '0');
								write1Data <= (others => '0');
								write2Data <= (others => '0');
  							read1Addr <= (others => '0');
  							read2Addr <= (others => '0');
     					  
--   			  			haltHit <='0';
   			  			haltAddr <= (others => '0');
     					  haltDone <= '0';
     					  nexthaltDump1 <= '0';
     					  
--     					  nextWritePort <= (others => '0');
     					  
 			  	when chkHit 	=>
 			  			 hit <= '0';
 			  			---------------Hit Found -------------------
 			  			--- Way A
 			  			if (MemAddr(31 downto 7) = tagA and validA = '1' ) then -- Hit with A
 			  					hit <= '1';
 			  					nextdestWay <= "110"; 			  					  			 			  						
 			  			--- Way B
 			  			elsif (MemAddr(31 downto 7) = tagB and validB = '1' ) then -- Hit with B
 			  					hit <= '1';
 			  					nextdestWay <= "111"; 			  					
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
 			  			elsif (LRU = '0' and dirtyA = '1' and dirtyB = '1' ) then -- miss with DirtyB and dirtyA(LRU) use B
 			  					nextdestWay <= "101";
  						end if;
  				when hitUpdate =>
  						memWait <= '0';
  						hit <= '0'; -- deset hit and update ram and output values
 			  			---------------Hit Found -------------------
 			  			--- Way A
-- 			  			if (MemAddr(31 downto 7) = tagA and validA = '1' ) then -- Hit with A
-- 			  					hit <= '1'; 			  					destWay <= "110";
 			  			if ( destWay = "110" ) then -- Hit with A) then -- Hit with A
 			  					if (MemWrite = '1' and MemAddr(2)='0') then 								-- update data1A w/ dirty and valid
 			  						nextWritePort <= readInt(184 downto 92) & "11" & tagA & '0' & data2A & MemWrData;
 			  						wENInt <= '1';
 			  					elsif (MemWrite = '1' and MemAddr(2)='1') then 						-- update data2A w/ dirty and valid
 			  						nextWritePort <= readInt(184 downto 92) & "11" & tagA & '1' &  MemWrData & data1A ;
 			  						wENInt <= '1'; 			  						
								elsif (MemRead ='1' and MemAddr(2) = '0') then -- update LRU to 0 and output Value
 			  						nextWritePort <= ValidB & DirtyB & '0' & readInt(181 downto 0);--LRU Update
 			  						wENInt <= '1';
										MemRdData <= Data1A;
--										MemWait <= '0';
								elsif (MemRead ='1' and MemAddr(2) = '1') then
										nextWritePort <= ValidB & DirtyB & '0' & readInt(181 downto 0);--LRU Update
 			  						wENInt <= '1';										
										MemRdData <= Data2A;
--										MemWait <= '0';
								end if;								  			 			  						
 			  					--- Way B
-- 			  					elsif (MemAddr(31 downto 7) = tagB and validB = '1' ) then -- Hit with B 		
--	  							hit <= '1';-- 			  					destWay <= "111";
 			  			elsif (destWay = "111") then -- Hit with B
 			  					if (MemWrite = '1' and MemAddr(2)='0') then 								-- update data1B w/ dirty and valid
 			  						nextWritePort <= "11"& LRU & tagB & '0' & data2B & MemWrData & readInt(91 downto 0);
 			  						wENInt <= '1';
 			  					elsif (MemWrite = '1' and MemAddr(2)='1') then 						-- update data2B w/ dirty and valid
 			  						nextWritePort <= "11"& LRU & tagB & '1' &  MemWrData & readInt(123 downto 0) ;
 			  						wENInt <= '1'; 			  						
								elsif (MemRead ='1' and MemAddr(2) = '0') then--update LRU and output value
										--- LRU Updae make sure by the rising clk the addr doesn't change the latched ram value#####
 			  						nextWritePort <= ValidB & DirtyB & '1' & readInt(181 downto 0);--LRU Update
 			  						wENInt <= '1';
 			  						
										MemRdData <= Data1B;
--										MemWait <= '0';
								elsif (MemRead ='1' and MemAddr(2) = '1') then
 			  						nextWritePort <= ValidB & DirtyB & '1' & readInt(181 downto 0);--LRU Update
 			  						wENInt <= '1';
								
										MemRdData <= Data2B;
--										MemWait <= '0';	
								end if;	
							end if; 		  						
      		when cleanRW 	=>
							read1Addr <= MemAddr(31 downto 3) & '0' & MemAddr(1 downto 0); -- set offset = 0 for the first read
							read2Addr <= MemAddr(31 downto 3) & '1' & MemAddr(1 downto 0);							
 			  	when dirtyRW 	=>	 			           		  
							if( destWay = "100") then -- replace DirtyA
								write1Addr <= TagA & MemAddr(6 downto 3) & "000";
								write2Addr <= TagA & MemAddr(6 downto 3) & "100";
								write1Data <= Data1A;--Tag&Idx&offset&skipBits
								write2Data <= Data2A;								
  							read1Addr <= MemAddr(31 downto 3) & '0' & MemAddr(1 downto 0); -- set offset = 0 for the first read
  							read2Addr <= MemAddr(31 downto 3) & '1' & MemAddr(1 downto 0);
  						elsif ( destWay = "101") then -- replace DirtyB
								write1Addr <= TagB & MemAddr(6 downto 3) & "000";--Tag&Idx&offset&skipBits
								write2Addr <= TagB & MemAddr(6 downto 3) & "100";
								write1Data <= Data1B;--Tag&Idx&offset&skipBits
								write2Data <= Data2B;
  							read1Addr <= MemAddr(31 downto 3) & '0' & MemAddr(1 downto 0); -- set offset = 0 for the first read
  							read2Addr <= MemAddr(31 downto 3) & '1' & MemAddr(1 downto 0);
  						end if;  														
      		when read1 		=>
      				aMemRead <= '1';
--      				aMemAddr <= read1Addr;		      		
      				if (aMemState = MEMACCESS) then 
      						mem2CacheData1<= aMemRdData;      						
      				end if;		    					
 			  	when read2 		=>
      				aMemRead <= '1';
--      				aMemAddr <= read2Addr; 			  	
      				if (aMemState = MEMACCESS) then 
      						mem2CacheData2<= aMemRdData;      						
      				end if;	
      		when write1 	=> -- updates on falling edge of MemAccess ?? necesary?
--      				aMemWrite <= '1';    				
--      				aMemWrData <= write1Data;
--      				aMemAddr <= write1Addr;
      		when waitSingle1 	=>
--							if (aMemState = MEMACCESS) then
--							aMemWrite <= '1';    				
--							end if;
--							aMemWrData <= write1Data;
--      				aMemAddr <= write1Addr;       				     				
 			  	when write2 	=>-- updates on falling edge of MemAccess??
--      				aMemWrite <= '1';    				
--      				aMemWrData <= write2Data;
--      				aMemAddr <= write2Addr; 			  	     
      		when waitSingle2 	=>  
--							if (aMemState = MEMACCESS) then
--							aMemWrite <= '1';    				
--							end if;
--      				aMemWrData <= write2Data;
--      				aMemAddr <= write2Addr; 			  	           		       		      		      		      		
      		when update 	=>
		      		MemWait <= '0';
      				if (MemWrite ='1') then
      					-- Replace way A
  	    				if (destWay="000" or destWay="011" or destWay="100") then -- replace A's read data with busb, and makedirty
  	    					if (MemAddr(2) = '0') then -- write data1a<= busb(memwrdata)
		      					nextWritePort <= readport(184 downto 92) & "11" & MemAddr(31 downto 7) & '0' & mem2CacheData2 & MemWrData;
		      					wENInt <= '1';
  	    					elsif (MemAddr(2) = '1') then -- write data2a<= busb(memwrdata)
		      					nextWritePort <= readport(184 downto 92) & "11" & MemAddr(31 downto 7) & '1' &  MemWrData & mem2CacheData1;
		      					wENInt <= '1';
		      				end if;
		      			-- Replace Way B	
  	    				elsif (destWay="001" or destWay="010" or destWay="101") then -- replace B's read data with busb
  	    					  if (MemAddr(2) = '0') then -- write data1b <= busb(memwrdata)
		      					nextWritePort <= "110" & MemAddr(31 downto 7) & '0' & mem2CacheData2 & MemWrData  & readport(91 downto 0) ;	
		      					wENInt <= '1';
		      				elsif (MemAddr(2) = '1') then -- write data2b <= busb(memwrdata)
		      					nextWritePort <=  "110" & MemAddr(31 downto 7) & '1' & MemWrData & mem2CacheData1 & readport(91 downto 0) ;		      		
		      					wENInt <= '1';
              		end if;
            		end if;
        		    
		    		elsif (MemRead = '1') then -- only difference is that not dirty and update both data1 and 2
      					-- Replace way A
  	    				if (destWay="000" or destWay="011" or destWay="100") then -- replace A's read data with busb, and makedirty  	    					
		      					nextWritePort <= readport(184 downto 92) & "10" & MemAddr(31 downto 7) & '0' & mem2CacheData2 & mem2CacheData1;
		      					wENInt <= '1';
										if( MemAddr(2) = '0') then-- Output to the bus the correct offset data
				      					MemRdData <= mem2CacheData1;
										else MemRdData <= mem2CacheData2;--offset ='1' or block2
										end if;
		      			-- Replace Way B	
  	    				elsif (destWay="001" or destWay="010" or destWay="101") then -- replace B's read data with busb
  	    						nextWritePort <= "101" & MemAddr(31 downto 7) & '0' & mem2CacheData2 & mem2CacheData1 & readport(91 downto 0) ;	      		
  	    						wENInt <= '1';
										if( MemAddr(2) = '0') then-- Output to the bus the correct offset data
				      					MemRdData <= mem2CacheData1;
										else MemRdData <= mem2CacheData2;--offset ='1' or block2  	    						
										end if;
  	    				end if;
  	    			end if;	  						
  						

 			  	when haltDump => -- for 0->15 if dirtyBit write to Memory	; Assume no invalid dirty bits
 			  			-- has till next clk to stop
 			  			haltAddr <= std_logic_vector(to_unsigned(count16,4));
 			  			if (count16 /= 16 ) then 			  					
 			  					if (readport( 90 ) = '1' and haltDump1='0') then --haltdirtyA = '1'
 			  						write1Addr <= readport(89 downto 65) & haltAddr & "000";--TagA&Idx&offsetA&skipBits
										write2Addr <= readport(89 downto 65) & haltAddr & "100";
										write1Data <= readport(31 downto 0 );	--data1A
										write2Data <= readport(63 downto 32 );--data2a
										haltHit  <= '1';
										nexthaltDump1 <= '1';						
									elsif (readport( 183 ) = '1') then  --haltDirtyB = '1'
 			  						write1Addr <= readport( 181 downto 157 ) & haltAddr & "000";--Tag&Idx&offset&skipBits
										write2Addr <= readport( 181 downto 157 ) & haltAddr & "100";
										write1Data <= readport(123 downto 92 );	--data1B
										write2Data <= readport(155 downto 124 );--data2B
										haltHit <= '1';
										nexthaltDump1 <= '0';
									elsif (readport(183) = '1' and haltDump1='1') then -- if finished first and second is not dirty
										nexthaltDump1 <= '0'; -- not hit and allow next time to be first run
									end if;						
 			  			end if;								
 			  	when halted =>
 			  				haltDone <= '1';
-- 			  	when Err =>
-- 			  	     	haltDone <= '1';
     			end case;
 	end process outputlogic;
-------------------------------------------------------------------------------
	nextStateProcess: process(state,MemWrite,MemRead,hit,rtnState,aMemState,readPort,haltHit,halt,count16,write1data,write2data,write1Addr,write2Addr,read1Addr,read2Addr,aMemWrDataInt,aMemAddrInt,dirtyB,dirtyA) 
    begin
		nextState <= state;
		nextCount16 <=Count16;
			if (halt ='0') then
					nextRtnState <= rtnState;
			else nextRtnState <= haltDump; end if;
		nextReadInt <= (others => '0');
		nextaMemAddr<= aMemAddrInt;--(others => '0');
    nextaMemWrData<= aMemWrDataInt;--(others => '0');
    nextaMemWrite	 <= '0';                       -- arbitrator side    		
    case state is 
      	when idle =>  
	      	 			nextReadInt <= readport;
       				nextState <= idle;
        			if halt = '1' then 
        				nextState <= haltDump;
        			elsif (MemRead = '1' or MemWrite = '1') then
								nextState <= chkHit;
--					else nextState <= idle;
        			end if;      			
 			  when chkHit 	=>
							nextReadInt <= readport;
   			  		if (hit = '1') then  -- JUST TRYING TO MAKE SURE!!! BOTH ARE SAME
--   			  			nextState <= update;
									nextState <= hitUpdate;
--   			  		elsif (destWay(2) = '1') then
 			  			elsif (dirtyA = '1' and dirtyB = '1' ) then -- miss with DirtyB and dirtyA(LRU) use B
   			  			nextState <= dirtyRW;
   			  		else  nextState <= cleanRW;
  						end if; 			  		
      	when hitUpdate 	=>
      				nextState <= idle;						
      	when cleanRW 	=>
      				nextRtnState <= update;
      				nextState<= read1;
      				nextaMemAddr <= read1Addr;
 			  when dirtyRW 	=>	 			           		  
        			if (rtnState = idle) then
        				nextRtnState <= dirtyRW;
        				nextState<= write1;
        				nextaMemWrData<= write1Data;
     						nextaMemAddr <= write1Addr;
     						nextaMemWrite	 <= '1';                       -- arbitrator side  
        			elsif(rtnState = dirtyRW) then
        				nextRtnState <= update;
        				nextState <= read1;
        				nextaMemAddr <= read1Addr;
        			end if;
      	when read1 		=>
		      		nextState <= read1;
--		      		nextaMemAddr <= read1Addr;
      				if (aMemState = MEMACCESS) then 
      						nextState <= read2;
      						nextaMemAddr <= read2Addr;
      				end if;		    					
 			  when read2 		=>
 			  			nextState <= read2;
--							nextaMemAddr <= read2Addr; 			  			
      				if (aMemState = MEMACCESS) then 
      						nextState <= rtnState;
      				end if;	
      	when write1 	=>
      					nextaMemWrite	 <= '1';       	
--							nextaMemWrData<= write1Data; 
--							nextaMemWrData<=aMemWrDataInt;  -- hold value    				
      				nextState <= write1;							
      				if (aMemState = MEMACCESS) then
      					nextState <= waitSingle1;	  						  
      				end if;
      	when waitSingle1 	=>  
      				nextState <= write2;
      				nextaMemWrData<= write2Data;
   						nextaMemAddr <= write2Addr;
   						nextaMemWrite	 <= '0';    				
 			  when write2 	=>
			 			  nextaMemWrite	 <= '1'; 
--						nextaMemWrData<= write2Data; 
--					nextaMemWrData<=aMemWrDataInt;-- hold value
 			  	    nextState <= write2;
      				if (aMemState = MEMACCESS) then
      					nextState <= waitSingle2;
      				end if;	 			           		  
      	when waitSingle2 	=> 
			      	nextaMemWrite	 <= '0';
      				nextState <= rtnState;  -- Note nextWrData is going to be zero        		      		      		      		
      	when update 	=>
--      				if halt ='0' then
	      				nextState <= idle;--NEXT ONE TO GO!
--	      			else
--	      				nextState <= haltDump;
--	      			end if;
 			  when haltDump =>
 			  			nextState <= haltDump;--if not hit inc count and goto dump again
							nextrtnState <= haltDump; 			  			
								if (readport( 90 ) = '1' and readport( 183 ) = '1') then
									nextCount16 <= count16;
								elsif (count16 /=15) then
									 nextCount16 <= count16 + 1;
								else
										nextCount16 <= 15;
								end if;-- allows to dump out both wayA wayB when both are dirty

 			  				if (count16 = 15 and haltHit='1') then -- address in the last idx
 			  				nextrtnState <= halted;
 			  				elsif (count16 =15) then
 			  				nextState <= halted;
 			  				elsif( haltHit = '1') then
 			  				nextState <= write1;--else haltDump
							  nextaMemWrData<= write1Data;
     						nextaMemAddr <= write1Addr;
     						nextaMemWrite	 <= '1'; 
 			  				end if;
 			  when halted	 	=>
 			  			nextCount16 <= 15;	
 			  			nextState <= halted;  	
     			end case;
	end process nextStateProcess;		
end behav;
