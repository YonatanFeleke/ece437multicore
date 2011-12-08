-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity J_JAL is				
    port( IF_Instr             					: in std_logic_vector(31 downto 0);
          ID_PcSrc                			: in std_logic;          
          IF_JAddr26              			: out std_logic_vector(25 downto 0);
          IF_JMP                   			: out std_logic
         );
  end J_JAL;

architecture JJAL_behav of J_JAL is
	signal JTYPE					: std_logic;
-- OpCode_Int <= IF_Instr(31 downto 26);     
  begin
											--  OpCode_Int(5 downto 1) = "00001"
      JTYPE <= '1' when  (IF_Instr(31 downto 27) = "00001") else '0';   	      	
			IF_JAddr26 <= IF_Instr(25 downto 0) when JTYPE ='1' else  "00"& x"000000";-- JAL 
			IF_JMP <= '1' when JTYPE='1' and ID_PCSrc='0' else '0';
end JJAL_behav;
