-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity MEMWB_REG is				
    port( CLK,nReset,Freeze									 			: in std_logic; -- branch purposes          
          MEM_datain	: in std_logic_vector(31 downto 0);
          MEM_Rw                 		: in std_logic_vector(4 downto 0);        
          MEM_REGWR,MEM_Halt						: in std_logic;                    
      
          WB_datain			: out std_logic_vector(31 downto 0);         
          WB_Rw                 		: out std_logic_vector(4 downto 0);                   
          WB_REGWR,WB_Halt						: out std_logic
         );
  end MEMWB_REG;

architecture MEMWB_behav of MEMWB_REG is
  begin
  	
  MEMWBupdate : process(nReset,clk,Freeze,MEM_datain,MEM_Rw,MEM_REGWR,MEM_Halt) -- Async reset 
    begin
      if (nReset = '0') then               
          WB_datain  <= x"00000000";
					WB_REGWR<='0';	
--					WB_MEM2Reg <= '0';
					WB_Halt <= '0';
					WB_Rw <= "00000";

      elsif( rising_edge(clk) and Freeze ='0') then
          WB_datain  <= MEM_datain;
					WB_REGWR<=MEM_REGWR;	
--					WB_MEM2Reg <= MEM_MEM2Reg;
					WB_Halt <= MEM_Halt;
					WB_Rw	<= MEM_Rw;
      end if;
    end process MEMWBupdate;

end MEMWB_behav;
