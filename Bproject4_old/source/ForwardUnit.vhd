library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 

entity ForwardUnit is
        port
        (
				Opcode_EX:		IN  std_logic_vector(5 downto 0);
				Opcode_MEM:		IN  std_logic_vector(5 downto 0);
                Data_EX:		IN	std_logic_vector(31 downto 0);
                Data_MEM:		IN	std_logic_vector(31 downto 0);
                Data_WB:		IN	std_logic_vector(31 downto 0);
                PCplus4_EX:		IN	std_logic_vector(31 downto 0);
                PCplus4_MEM:	IN	std_logic_vector(31 downto 0);
                Imm16Ext_EX:	IN	std_logic_vector(31 downto 0);
                Imm16Ext_MEM:	IN	std_logic_vector(31 downto 0);
				Rw_EX:			IN  std_logic_vector(4 downto 0);
				Rw_MEM:			IN  std_logic_vector(4 downto 0);
				Rw_WB:			IN  std_logic_vector(4 downto 0);
				Rs	:			IN std_logic_vector(4 downto 0);
				Rt	:			IN std_logic_vector(4 downto 0);
				RegWr_EX:		IN std_logic;
				RegWr_MEM:		IN std_logic;
				RegWr_WB:		IN std_logic;
				ForwardRs:		OUT std_logic_vector(31 downto 0);
				ForwardRt:		OUT std_logic_vector(31 downto 0);
				RsSel:			OUT std_logic;
				RtSel:			OUT std_logic
				
        );
end ForwardUnit;

architecture ForwardUnit_arch of ForwardUnit is

	signal intData_EX,intData_MEM	: std_logic_vector(31 downto 0);

    constant JAL       : std_logic_vector              := "000011";
    constant LUI       : std_logic_vector              := "001111";

begin
	RsSel <= '1' when ((Rw_EX = Rs and RegWr_EX = '1') or --forward from ex stage
					   (Rw_MEM = Rs and RegWr_MEM = '1') or --forward from mem stage
					   (Rw_WB = Rs and RegWr_WB = '1')) --forward from wb stage
				else '0';

	RtSel <= '1' when ((Rw_EX = Rt and RegWr_EX = '1') or --forward from ex stage
					   (Rw_MEM = Rt and RegWr_MEM = '1') or --forward from mem stage
					   (Rw_WB = Rt and RegWr_WB = '1')) --forward from wb stage
				else '0';

--FIX THIS****************************************************************	
--	RtSel <= '1' when (Rw_EX = Rt or Rw_MEM = Rt or Rw_WB = Rt) else '0';
--************************************************************************


	intData_EX <= PCplus4_EX when (Opcode_EX = JAL) else
				  IMM16Ext_EX(15 downto 0) & x"0000" when (Opcode_EX = LUI) else
				  Data_EX;

	intData_MEM <= PCplus4_MEM when (Opcode_MEM = JAL) else
				  IMM16Ext_MEM(15 downto 0) & x"0000" when (Opcode_MEM = LUI) else
				  Data_MEM;

	ForwardRs <= intData_EX when (Rw_EX = Rs) else
				 intData_MEM when (Rw_MEM = Rs) else
				 Data_WB when (Rw_WB = Rs) else
				 x"00000000";

	ForwardRt <= Data_EX when (Rw_EX = Rt) else
				 Data_MEM when (Rw_MEM = Rt) else
				 Data_WB when (Rw_WB = Rt) else
				 x"00000000";

end ForwardUnit_arch;
