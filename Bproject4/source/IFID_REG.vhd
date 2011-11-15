-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity IFID_REG is				
    port( CLK,nReset,Freeze,ID_FLUSH  		: in std_logic;
          hit,halt,ID_PcSrc             : in std_logic; -- branch purposes
          IF_Instr             									: in std_logic_vector(31 downto 0);          
          IF_PC_4              									: in std_logic_vector(31 downto 0);
          ID_Instr             									: out std_logic_vector(31 downto 0);
          ID_PC_4																: out std_logic_vector(31 downto 0)
         );
  end IFID_REG;

architecture IFID_behav of IFID_REG is
  begin
  	
  IFIDupdate : process(nReset,clk,Freeze,hit,halt,ID_FLUSH,IF_Instr,IF_PC_4,ID_PcSrc) -- Async reset 
    begin
      if (nReset = '0') then
        ID_Instr <= x"00000000";
        ID_PC_4 <= x"00000000";
      elsif (halt = '1') then
        ID_Instr <= x"FFFFFFFF";
        ID_PC_4 <= x"FFFFFFFF";        
      elsif(rising_edge(clk) and ((hit ='0' and Freeze = '0')      -- Throw in a bubble evertime we miss since we need one cycle to latch into ram and then its valid
            or (hit='1' and ID_PcSrc ='1' and Freeze = '0'))) then -- If BEQ taken on a hit send bubble so pc updates  b/c BEQTakenFirst only squashes misses
        ID_Instr <= x"00000000";
        ID_PC_4 <= x"00000000";                
      elsif(rising_edge(clk) and hit ='1' and ID_FLUSH ='0' and freeze ='0') then 
      --- stall when hazard and freeze and don't update unless hit
        ID_Instr <= IF_Instr;
        ID_PC_4 <= IF_PC_4;
      end if;
    end process IFIDupdate;

end IFID_behav;
