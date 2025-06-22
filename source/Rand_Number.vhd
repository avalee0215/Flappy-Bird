library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Rand_num is 
	port (clock_60hz : in std_logic;
			enable : in std_logic;
			reset : in std_logic;
			rand_num : out std_logic_vector (7 downto 0));
end entity Rand_num;

architecture behaviour of Rand_num is 
	signal seed : std_logic_vector(7 downto 0) := "10101010";
begin

	process (clock_60hz, reset)
	begin 
		if (reset = '1') then
			seed <= "10101010";
		elsif (rising_edge(clock_60hz)) then
			if (enable = '1') then
				seed(0) <= seed(7);
				seed(1) <= seed(0);
				seed(2) <= seed(1) xnor seed(7);
				seed(3) <= seed(2) xnor seed(7);
				seed(4) <= seed(3) xnor seed(7);
				seed(5) <= seed(4);
				seed(6) <= seed(5);
				seed(7) <= seed(6);
			end if;
		end if;
	end process;
	rand_num <= seed;
end architecture behaviour;

