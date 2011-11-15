-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity AluCont is				
    port( OpCode              : in std_logic_vector(5 downto 0);
    			Funct								: in std_logic_vector(5 downto 0); -- 1= sign 0 = zero extend
          AluSrc              : out std_logic;
          AluOp               : out std_logic_vector(2 downto 0)
         );
  end AluCont;

architecture AluCont_behav of AluCont is
  signal AluOpItype,AluOpRtype 	: std_logic_vector(2 downto 0);
  signal RTYPE		: std_logic; --,ITYPE			 	not used
  begin
-- J Type instruction don't have any impact on AluSrc
-- BNE and BEQ are the only I type Instructions that use alusrc=0
  RTYPE <= '1' when  (OpCode = "000000") else '0';
--  ITYPE <= '0' when  (OpCode="000000" OR OpCode(5 downto 1)="00001" OR opCode(5 downto 2) ="0100") else '1';


-- R Type Instructins depend on Funct with opcode = "000000"	
	with funct select
	    AluOpRtype <= "010" when "100001",     
          --addu 	rd, rs, rt 	100001      0 ADD
          --and 	rd, rs, rt 	100100      0 AND
            "100" when "100100",
          --jr 	  rs 	        001000      0 OR
            "110" when "001000",
          --nor 	rd, rs, rt 	100111      0 NOR
            "101" when "100111",
          --or 	  rd, rs, rt 	100101      0 OR
            "110" when "100101",
          --slt 	rd, rs, rt 	101010      0 SUB
            "011" when "101010",
          --sltu 	rd, rs, rt 	101011      0 SUB
            "011" when "101011",
          --sll 	rd, rt, sa 	000000      0 SLL
            "000" when "000000",
          --srl 	rd, rt, sa 	000010      0muxdep
            "001" when "000010",
          --subu 	rd, rs, rt 	100011 ??   0 SUB
            "011" when "100011",
          --xor 	rd, rs, rt 	100110 	    0 XOR
            "111" when "100110",
            "111" when others; --xor

-- I Type Instructions depend on Opcode and could have any Funct
  with OpCode select
    AluOpItype <= "010" when "001000",      
    	--addi 	  rt, rs, immediate 	001000 	1 ADD
      --addiu 	rt, rs, immediate 	001001 	1 ADD
            "010" when "001001",
      --andi 	  rt, rs, immediate 	001100 	1 AND
            "100" when "001100",
		  --beq 	  rs, rt, label 	    000100 	1 SUB
            "011" when "000100",
      --bne 	  rs, rt, label 	    000101 	1 SUB
            "011" when "000101",
      --lui 	  rt, immediate 	    001111 	1 OR
            "110" when "001111",
      --lw 	    rt, immediate(rs) 	100011 	1 ADD
            "010" when "100011",
      --ori 	  rt, rs, immediate 	001101 	1 OR
            "110" when "001101",
      --slti 	  rt, rs, immediate 	001010 	1 SUB
            "011" when "001010",
      --sltiu 	rt, rs, immediate 	001011  1 SUB
            "011" when "001011",
    	--sw 	    rt, immediate(rs) 	101011 	1 ADD
            "010" when "101011",
      --xori 	  rt, rs, immediate 	001110  1 XOR
            "111" when "001110",
            "111" when others; --xor

--------------------------------------------------------------------------------            
  AluSrc <= '0' when OpCode = "000100" else
  					'0' when OpCode = "000101" else
  					'0' when RTYPE = '1' else --BEQ BNE and RType =0
  					'1'; --JTYPE doesn't care about alu and remainiing Itype  
  AluOp <= AluOpRtype when (RTYPE ='1') else AluOpItype;-- when (ITYPE = '1') else "111";
  --Prob not Important since when in itype Funct and Shamt go to zero in decode
  end AluCont_behav;
