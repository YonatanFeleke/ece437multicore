-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity CLU is				
    port( OpCode,Funct         								 : in std_logic_vector(5 downto 0);
          Zero,OvrFlo,ID_EQ													: in std_logic;
					Mem2Reg,RegDest,RegWr,ExtOp   : out std_logic;
				  ID_PcSrc				        : out std_logic;					
--					JMP,PcSrc,LD												: out std_logic;
					MemWr,LUI,ID_JR,JAL,SLT_EN,SRL_SLL,LL,SC	: out std_logic
         );
  end CLU;

architecture CLU_behav of CLU is
	signal RTYPE       : std_logic;
--	,ITYPE,JTYPE			 			
  begin
  RTYPE <= '1' when  (OpCode = "000000") else '0';
--  JTYPE <= '1' when  (OpCode(5 downto 1) = "00001") else '0';
--  ITYPE <= '0' when  (OpCode="000000" OR OpCode(5 downto 1)="00001" OR opCode(5 downto 2) ="0100") else '1';

  
--Mem2Reg      
	Mem2Reg <= '1' when (OpCode = "100011") else --lw 	    rt, immediate(rs) 	OPcOde =100011
             '1' when (OpCode = "110000" or OpCode="110110") else --LL and SC respectively
	           '0';
--RegDest
	RegDest <= '1' when (RTYPE = '1') else --Rd
						 '1' when ( OpCode= "000011") else -- RD when JAL is $31						
						 '0'; -- RS for all 
--PcSrc 	PcSrc <= '1' when (OpCode="000100"  and Zero = '1') else --BEQ
--					 '1' when (OpCode="000101"  and Zero = '0')  else --BNE
--					 '0';
--PcSrc used for the MEM to output buble or squash current
 	ID_PcSrc <= '1' when (OpCode="000100"  and ID_EQ ='1') else --BEQ
					 '1' when (OpCode="000101"  and ID_EQ ='0')  else --BNE
					 '1' when (RTYPE='1' and Funct= "001000") else -- JR needs to also squash a PC					 
					 '0';			 

--RegWr  	
	RegWr <= '0' when (RTYPE='1' and Funct="001000") else	--jr rs Funct= 001000      0 OR
					 '0' when (OpCode= "000100") else 	--beq 	  rs, rt, label 	OpCode=000100 
					 '0' when (OpCode= "000101") else   --bne 	  rs, rt, label 	    000101 	
					 '0' when (OpCode= "101011") else  	--sw 	    rt, immediate(rs) 	101011 	
					 '0' when (OpCode= "000010") else 	--j 	label 	000010 	coded address of label 
					 '1'; -- will include LL and SC
--ExtOp 
	ExtOp <= '1' when (OpCode= "001001") else -- ADDIU
					 '1' when (OpCode= "100011") else -- LW
					 '1' when (OpCode= "001010" OR OpCode= "001011") else -- SLTI OR SLTIU
					 '1' when (OpCode= "101011") else -- SW
           --BEQ or BNE need Imm16L2 to be sign extended else no backward branch
					 '1' when (OpCode= "000100") else 	--beq 	  rs, rt, label 	OpCode=000100 
					 '1' when (OpCode= "000101") else   --bne 	  rs, rt, label 	    000101            
           '1' when (OpCode = "110000" or OpCode="110110") else --LL and SC respectively sign extended
					 '0';
--MemWr
	MemWr <= '1' when (OpCode= "101011") else --sw
					 '0';					 
--LD  LD <= '1' when (OpCode= "100011") else '0'; -- LW need to pause one period					 
--LUI
	LUI <= '1' when (OpCode= "001111") else '0'; -- LUI  Rt <= Imm
--JMP 	JMP <= '1' when (OpCode= "000010" or OpCode="000011") else '0';--JAL and J
--JAL 
	JAL <= '1' when (OpCode="000011") else '0';--JAL
--JR
	ID_JR <= '1' when (RTYPE='1' and Funct= "001000") else '0'; -- JR
--SLT_EN
	SLT_EN  <= '1' when (OpCode="001010" or OpCode="001011") else --SLTI AND SLTIU
						 '1' when (RTYPE = '1' and (Funct="101010" or Funct="101011")) else --SLT AND SLTU
						 '0'; 
--SRL_SLL	
	SRL_SLL <= '1' when (RTYPE='1' and (Funct = "000000" or Funct="000010")) else '0';	--SLL or SRL	
--LL and SC	
	LL <= '1' when OpCode = "110000" else '0';--LL signal
	SC <= '1' when OpCode = "110110" else '0'; --SC signal
end CLU_behav;	
	
