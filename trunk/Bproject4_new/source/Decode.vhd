-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity Decode is				
    port( Instr32             : in std_logic_vector(31 downto 0);
--    			HALT								: out std_logic;
          Imm16                : out std_logic_vector(15 downto 0);
--          JAddr26              : out std_logic_vector(25 downto 0);
          Shamt                : out std_logic_vector(4 downto 0);
          Funct                : out std_logic_vector(5 downto 0);
          Rt,Rs,Rd             : out std_logic_vector(4 downto 0);
          OpCode                : out std_logic_vector(5 downto 0)
         );
  end Decode;

architecture Decode_behav of Decode is
--      foo <= “10” when (condition) else “01” when (condition) else “00”;
    signal RTYPE,ITYPE,JTYPE	      					: std_logic;
    signal OpCode_Int 												: std_logic_vector(5 downto 0);
    begin
--    	HALT <= '1' WHEN (Instr32 = x"FFFFFFFF") else '0';
      OpCode_Int <= Instr32(31 downto 26);
      RTYPE <= '1' when  (OpCode_Int = "000000") else '0';
      JTYPE <= '1' when  (OpCode_Int(5 downto 1) = "00001") else '0';
      ITYPE <= '1' when  ((RTYPE ='0') AND (JTYPE = '0')) else '0';

      Rs <= Instr32(25 downto 21) when RTYPE = '1' else 
            Instr32(25 downto 21) when ITYPE ='1' else
            "00000"; --Error Flag for jtype
      Rt <= Instr32(20 downto 16) when RTYPE = '1' else 
            Instr32(20 downto 16) when ITYPE ='1' else
            "00000"; --Error Flag
      Rd <= Instr32(15 downto 11) when RTYPE = '1' else
           "11111" when OpCode_Int = "000011" else -- JAL write to $31 
            		 "00000"; --Error Flag
      Shamt <= Instr32(10 downto 6) when RTYPE = '1' else 
            		 "00000"; --Error Flag
      Funct <= Instr32(5 downto 0) when RTYPE = '1' else
            		 "000000"; --Error Flag            		 
			Imm16 <= 	Instr32(15 downto 0)	when ITYPE ='1' else x"0000";
--			JAddr26 <= Instr32(25 downto 0) when JTYPE ='1' else  "00"& x"000000";-- JAL 
      OpCode  <= OpCode_Int;
      
end Decode_behav;
