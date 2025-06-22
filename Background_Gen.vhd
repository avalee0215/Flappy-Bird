library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sprites_pkg.all;
use work.util.all;

entity Background_Gen is
    port (
        clock_25Mhz  : in std_logic;
        pixel_row    : in  std_logic_vector(9 downto 0);
        pixel_column : in  std_logic_vector(9 downto 0);
        red_o    : out std_logic_vector(3 downto 0);
        green_o  : out std_logic_vector(3 downto 0);
        blue_o   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of Background_Gen is

    signal rom_addr  : std_logic_vector(14 downto 0);  
    signal rom_q     : std_logic_vector(11 downto 0);  


    component altsyncram
        generic (
            width_a     : integer := 12;
            widthad_a   : integer := 15;
            numwords_a  : integer := 32768;
            lpm_type    : string := "altsyncram";
            operation_mode : string := "ROM";
            init_file   : string := "sprites.mif"
        );
        port (
            clock0      : in std_logic;
            address_a   : in std_logic_vector(14 downto 0);
            q_a         : out std_logic_vector(11 downto 0)
        );
    end component;

begin
    -- ROM
    rom: altsyncram
        port map (
            clock0 => clock_25Mhz,
            address_a => rom_addr,
            q_a => rom_q
        );

    -- Rendering logic
    process (clock_25Mhz)
        variable x, y : integer;
        variable dX, dY : integer;
    begin
        if falling_edge(clock_25Mhz) then
            x := to_integer(unsigned(pixel_column));
            y := to_integer(unsigned(pixel_row));

            if x < SPRITE_BG_WIDTH * 4 and y < SPRITE_BG_HEIGHT * 4 then
                dX := x / 4;
                dY := y / 4;
                rom_addr <= std_logic_vector(to_unsigned(
                    SPRITE_BG_OFFSET + dY * SPRITE_BG_WIDTH + dX,
                    15
                ));
            else
                rom_addr <= (others => '0');
            end if;
        end if;
    end process;
	 	 
    red_o <= rom_q(11 downto 8);
    green_o <= rom_q(7 downto 4);
    blue_o <= rom_q(3 downto 0);

end architecture;



