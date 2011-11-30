-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity EXMEM_REG is				
    port( CLK,nReset,Freeze									 					: in std_logic; -- branch purposes        
          EX_BusB,EX_Out							: in std_logic_vector(31 downto 0);       
          EX_Rw     : in std_logic_vector(4 downto 0);
          EX_MemWr,EX_Halt			: in std_logic;          
          EX_MEM2REG,EX_REGWR						: in std_logic;                    
        
          MEM_BusB,MEM_Out						: out std_logic_vector(31 downto 0);
          MEM_Rw                         : out std_logic_vector(4 downto 0);         
          MEM_MemWr,MEM_Halt		: out std_logic;          
          MEM_MEM2REG,MEM_REGWR					: out std_logic
         );
  end EXMEM_REG;

architecture EXMEM_behav of EXMEM_REG is
  begin
  	
  EXMEMupdate : process(nReset,clk,Freeze,EX_BusB,EX_Out,EX_Rw,EX_MemWr,EX_Halt,EX_MEM2REG,EX_REGWR) -- Async reset 
    begin
      if (nReset = '0') then
                 
          MEM_Out  <= x"00000000";                            
          MEM_BusB  <= x"00000000";  
					MEM_MEM2REG<='0';
					MEM_REGWR<='0';
					MEM_MemWr <= '0';
					MEM_Halt <='0';
					MEM_Rw <= "00000";



      elsif( rising_edge(clk) and Freeze ='0') then
          MEM_Out  <= EX_Out;
          MEM_BusB  <= EX_BusB;
					MEM_MemWr<=EX_MemWr;
					MEM_MEM2REG<=EX_MEM2REG;
					MEM_REGWR<=EX_REGWR;	
					MEM_Halt <= EX_Halt;
					MEM_Rw <= EX_Rw;
      end if;
    end process EXMEMupdate;

end EXMEM_behav;
