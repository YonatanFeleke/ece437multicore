-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity alu is				
    port( OPCODE                  : in std_logic_vector(2 downto 0);
          A, B	                  : in std_logic_vector(31 downto 0);
          aluOut                  : out std_logic_vector(31 downto 0);
          NEGATIVE, OVERFLOW, ZERO: out std_logic );
  end alu;


--Opcode Operation Description
--000 SLL OUTPUT <= A << B
--001 SRL OUTPUT <= A >> B
--010 ADD OUTPUT <= A + B
--011 SUB OUTPUT <= A - B
--100 AND OUTPUT <= A and B
--101 NOR OUTPUT <= A nor B
--110 OR  OUTPUT <= A or B
--111 XOR OUTPUT <= A xor B



architecture alu_behav of alu is
	component bitadder is				
    port(											
    			CIN,A1, B1              : in std_logic; -- carry in , a , b
          bitOut,COUT             : out std_logic);
	end component;


  signal sllout,srlout,addout,subout					: std_logic_vector(31 downto 0);
  signal lstg1,lstg2,lstg3,lstg4          		: std_logic_vector(31 downto 0);
  signal rstg1,rstg2,rstg3,rstg4          		: std_logic_vector(31 downto 0);
  signal CarryAdder, CarrySub									: std_logic_vector(32 downto 0);
  signal LOCout,Bsub													: std_logic_vector(31 downto 0);
  signal ovrAdd,ovrSub												: std_logic;
  
  begin    
    --DATAFLOW mux for selecting output
    with OPCODE select
      --000 SLL OUTPUT <= A << B
      aluOut <= sllout when "000", 
      --001 SRL OUTPUT <= A >> B
       srlout when "001",
      --010 ADD OUTPUT <= A + B
      addout when "010",
      --011 SUB OUTPUT <= A - B
      subout when "011",
      --100 AND OUTPUT <= A and B
      (A and B) when "100",
      --101 NOR OUTPUT <= A nor B
      (A nor B) when "101",
      --110 OR OUTPUT <= A or B
      (A or B) when "110",
      --111 XOR OUTPUT <= A xor B    
      (A xor B) when "111",
      x"00000000" when others;

		-- local variable to use for access for calculating Zero
    with OPCODE select
      	--010 ADD OUTPUT <= A + B
      	LOCout <=  addout when "010",
  	    --011 SUB OUTPUT <= A - B
	  	    subout when "011",
		      x"00000001" when others;            
		Zero <= '1' when (LOCout = x"00000000") else '0';     -- buggy zero will have to be set in subout too
		NEGATIVE <='1' when LOCout(31) ='1' else '0';
		-- Overflow calculation
    with OPCODE select
      --010 ADD OUTPUT <= A + B
     	OVERFLOW <= ovrAdd WHEN "010",
      --011 SUB OUTPUT <= A - B
     					 ovrSub when "011", '0' when others;

      
    --DATAFLOW left BARREL SHIFT  
    with B(0) select
      lstg1 <= A(30 downto 0) & '0' when '1',
               A(31 downto 0) when others;
      
    with B(1) select
      lstg2 <= lstg1(29 downto 0) & "00" when '1',
               lstg1(31 downto 0) when others;      

    with B(2) select
      lstg3 <= lstg2(27 downto 0) & "0000" when '1',
               lstg2(31 downto 0) when others;          

    with B(3) select
      lstg4 <= lstg3(23 downto 0) & "00000000" when '1',
               lstg3(31 downto 0) when others;  
      
    with B(4) select
      sllout <= lstg4(15 downto 0) & "0000000000000000" when '1',
                 lstg4(31 downto 0) when others;
                              
   -- DATAFLOW RIGHT BARREL SHIFT   
     with B(0) select
      rstg1 <=  '0' & A(31 downto 1) when '1',
               A(31 downto 0) when others;
      
    with B(1) select
      rstg2 <= "00" & rstg1(31 downto 2)  when '1',
               rstg1(31 downto 0) when others;      

    with B(2) select
      rstg3 <= "0000" & rstg2(31 downto 4)  when '1',
               rstg2(31 downto 0) when others;          

    with B(3) select
      rstg4 <="00000000" &  rstg3(31 downto 8)  when '1',
               rstg3(31 downto 0) when others;  
      
    with B(4) select
      srlout <="0000000000000000" & rstg4(31 downto 16)  when '1',
               rstg4(31 downto 0) when others;   
   
		-- DATAFLOW ADD OUT
--      addout <= x"00000000";
--      	FA1: bitAdder 	PORT MAP ( CIN=>'0',A1=>A(0),B1=>B(0),OUTPUT=>OUTPUT(0),COUT=>coutadder);\
  	CarryAdder(0) <= '0';
  	genFullAdder :		for z in 0 to 31 generate
  			FA: bitAdder port map( CIN=>CarryAdder(z),A1=>A(z),B1=>B(z),bitOut=>addout(z),COUT=>CarryAdder(z+1));
  		end generate;
  	ovrAdd <= (CarryAdder(32) xor CarryAdder(31));
 
    -- DATAFLOW SUB OUT
--       subout <= x"00000000";  
    CarrySub(0) <= '1';
    Bsub <= B xor x"FFFFFFFF";
  	genFullSub :		for j in 0 to 31 generate
  			FS: bitAdder port map( CIN=>CarrySub(j),A1=>A(j),B1=>Bsub(j),bitOut=>subout(j),COUT=>CarrySub(j+1));
  		end generate;
  	ovrSub <= (CarrySub(32) xor CarrySub(31));       
end alu_behav;
