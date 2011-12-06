-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity IDEX_REG is				
    port( CLK,nReset,Freeze           						: in std_logic; -- branch purposes
          ID_Imm16             													: in std_logic_vector(15 downto 0);          
          ID_PC_4,ID_BusA,ID_BusB           : in std_logic_vector(31 downto 0);
          ID_Shamt32,ID_XtdOut	             : in std_logic_vector(31 downto 0);
          ID_OpCode,ID_Funct            				: in std_logic_vector(5 downto 0);
          ID_Rw, ID_Rt                 : in std_logic_vector(4 downto 0);   --       ID_Rs,
          ID_SLT_En,ID_JAL,ID_MemWr,ID_LUI,ID_FLUSH			: in std_logic;          
          ID_MEM2REG,ID_REGWR,ID_SRL_SLL,ID_Halt										: in std_logic;                    
          ID_LL,ID_SC										: in std_logic;                    

          EX_Imm16             													: OUT std_logic_vector(15 downto 0);          
          EX_PC_4,EX_BusA,EX_BusB,EX_Shamt32,EX_XtdOut : out std_logic_vector(31 downto 0);
          EX_OpCode,EX_Funct            				: out std_logic_vector(5 downto 0);
          EX_Rw,  EX_Rt        : out std_logic_vector(4 downto 0);--            EX_Rs,
          EX_SLT_En,EX_JAL,EX_MemWr,EX_LUI,EX_Halt			: out std_logic;          
          EX_LL,EX_SC										: out std_logic;                 
          EX_MEM2REG,EX_REGWR,EX_SRL_SLL										: out std_logic
         );
  end IDEX_REG;

architecture IDEX_behav of IDEX_REG is
  begin
  	
  IDEXupdate : process(nReset,clk,Freeze,ID_Imm16,ID_PC_4,ID_BusA,ID_BusB,ID_Shamt32,ID_XtdOut,ID_OpCode,ID_Funct,ID_Rw, ID_Rt,ID_SLT_En,ID_JAL,ID_MemWr,ID_LUI,ID_FLUSH,ID_MEM2REG,ID_REGWR,ID_SRL_SLL,ID_Halt,ID_LL,ID_SC ) -- Async reset 
    begin
      if (nReset = '0') then
          EX_Imm16 <= x"0000";
          EX_PC_4  <= x"00000000";
          EX_BusA  <= x"00000000";
          EX_BusB  <= x"00000000";
     					EX_Shamt32 <= x"00000000";          
					EX_XtdOUT  <= x"00000000";
          EX_OpCode <= "000000";
          EX_Funct <= "000000";          
          EX_SLT_En <= '0';
          EX_JAL<='0';
					EX_MemWr<='0';
					EX_LUI<='0';
					EX_MEM2REG<='0';
					EX_REGWR<='0';
					EX_Halt <='0';
					EX_SRL_SLL <= '0';
					EX_LL <= '0';
					EX_SC <= '0';					
					EX_Rw <= "00000";
--					EX_Rs <= "00000";
					EX_Rt <= "00000";										
      elsif (ID_Flush = '1' and rising_edge(clk)and Freeze ='0') then -- insert a buble on IF_PcSkip
--      elsif (ID_Flush = '1' ) then
          EX_Imm16 <= x"0000";
          EX_PC_4  <= x"00000000";
          EX_BusA  <= x"00000000";
          EX_BusB  <= x"00000000";
     					EX_Shamt32 <= x"00000000";
					EX_XtdOUT  <= x"00000000";
          EX_OpCode <= "000000";
          EX_Funct <= "000000";          
          EX_SLT_En <= '0';
          EX_JAL<='0';
					EX_MemWr<='0';
					EX_LUI<='0';
      				EX_MEM2REG<='0';
					EX_REGWR<='0';
					EX_Halt <='0';
					EX_SRL_SLL <= '0';
					EX_LL <= '0';
					EX_SC <= '0';					
					EX_Rw <= "00000";
--        		EX_Rs <= "00000";
					EX_Rt <= "00000";	
							
					
      elsif( rising_edge(clk) and Freeze ='0') then
          EX_Imm16 <= ID_Imm16;
          EX_PC_4  <= ID_PC_4;
					EX_BusA  <= ID_BusA;
					EX_BusB  <= ID_BusB; 					
					EX_Shamt32 <= ID_Shamt32;
					EX_XtdOut <= ID_XtdOut;
          EX_OpCode <= ID_OpCode;
          EX_Funct <= ID_Funct;          
          EX_SLT_En <= ID_SLT_En;
          EX_JAL<= ID_JAL;
					EX_MemWr<=ID_MemWr;
					EX_LUI<=ID_LUI;
					EX_MEM2REG<=ID_MEM2REG;
					EX_REGWR<=ID_REGWR;	
					EX_Halt <= ID_Halt;
					EX_SRL_SLL <= ID_SRL_SLL;
					EX_LL <= ID_LL;
					EX_SC <= ID_SC;					
					EX_Rw<= ID_Rw;
--					EX_Rs <= ID_Rs;
					EX_Rt <= ID_Rt;										
      end if;
    end process IDEXupdate;

end IDEX_behav;
