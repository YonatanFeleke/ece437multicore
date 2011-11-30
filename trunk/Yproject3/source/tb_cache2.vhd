library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity tb_cache is
	generic (Period : Time := 100 ns;
             Debug : Boolean := False);
end tb_cache;

architecture tb_arch of tb_cache is

	component icache
		port(
			clk					:	in	std_logic;
			nReset			: in	std_logic;			
			iMemRead		:	in	std_logic;
			iMemAddr		:	in	std_logic_vector(31 downto 0);
			aiMemData		:	in	std_logic_vector(31 downto 0);
			aiMemState	:	in	std_logic_vector(1 downto 0);
			
			aiMemRead		:	out	std_logic;
			aiMemAddr		:	out	std_logic_vector(31 downto 0)
			iMemWait		:	out	std_logic;
			iMemData		:	out	std_logic_vector(31 downto 0);
		);
	end component; 

	component VarLatRAM
		port(
			nReset						:	in	std_logic;
			clock							:	in	std_logic;
			address						:	in	std_logic_vector(15 downto 0);
			data							:	in	std_logic_vector(31 downto 0);
			wren							:	in	std_logic;
			rden							:	in	std_logic;
			latency_override	:	in	std_logic;
			q									:	out	std_logic_vector(31 downto 0);
			memstate					:	out	std_logic_vector(1 downto 0)
		);
	end component; 

	-- signals here
  signal halt, clk, nReset, iMemRead, iMemWait, aiMemRead, wren, rden, latover : std_logic;
	signal iMemdata, aiMemData :	std_logic_vector(31 downto 0);
	signal iMemAddr, aiMemAddr : std_logic_vector(31 downto 0);
	signal aiMemState : std_logic_vector(1 downto 0);

	constant ZEROV : std_logic_vector := x"00000000";
	constant ZEROB : std_logic := '0';
	constant ONESB : std_logic := '1';

begin

	SYNRAM: VarLatRAM port map(nReset, clk, aiMemAddr(15 downto 0), ZEROV, ZEROB, aiMemRead, ONESB, aiMemData, aiMemState);
  DUT: icache_top port map(clk, nReset, iMemRead, iMemWait, iMemAddr, iMemData, aiMemState, aiMemRead, aiMemAddr, aiMemData);

	-- generate clock signal
  clkgen: process
    variable clk_tmp : std_logic := '0';
  begin
    clk_tmp := not clk_tmp;
    clk <= clk_tmp;
    wait for Period/2;
  end process;

  -- print cycles for execution
  printprocess : process
    variable cycles : integer := 0;
    variable lout : line;
  begin
    if (nreset = '1') then
        cycles := cycles + 1;
        if (cycles mod 32 = 0) then
            write(lout, string'("Cycle #"));
            write(lout, integer'(cycles));
            writeline(output, lout);
        end if;
    end if;
    if (halt = '1') then
      write(lout, string'("Halted, cycles="));
      write(lout, integer'(cycles));
      writeline(output, lout);
			wait on halt;
    end if;
    wait for Period;
  end process;

	testing_process : process 
		variable i : integer := 0;
		begin
						iMemAddr <= x"00000000";
						iMemRead <= '0';
            nReset <= '0';
						halt <= '0';
            wait for 4 * Period;
            nReset <= '1';
						iMemRead <= '1';
						while halt = '0' loop
							iMemAddr <= std_logic_vector(to_unsigned(i, 32));
							wait until iMemwait = '0';
							wait for Period;
							i := i + 4;
							if (i > 64) then
								halt <= '1';
							end if;
						end loop;
						i := 0;
						halt <= '0';
						MemRead <= '0';
						wait for Period;
						MemRead <= '1';
						while halt = '0' loop
							MemAddr <= std_logic_vector(to_unsigned(i, 32));
							wait for Period;
							i := i + 4;
							if (i > 64) then
								halt <= '1';
								i := 0;
							end if;
						end loop;
            wait;
		end process;
end tb_arch;
