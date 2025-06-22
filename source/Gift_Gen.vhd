library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util.all;

entity Gift_Gen is
    port (
        clock_60hz    : in  std_logic;
        state         : in  game_state;
        rand_num      : in  std_logic_vector(7 downto 0);
        pixel_row     : in  std_logic_vector(9 downto 0);
        pixel_column  : in  std_logic_vector(9 downto 0);
        move_pixel    : in  integer;
        gift_on       : out std_logic;
        gift_x, gift_y: out integer
    );
end entity;

architecture behaviour of Gift_Gen is
    signal x_pos : integer := screen_max_x;
    signal y_pos : integer := screen_centre_y;
begin
    process(clock_60hz)
        variable rand_y : integer;
    begin
        if rising_edge(clock_60hz) then
            if state = title then
                x_pos <= screen_max_x + 100;  -- Reset off screen
                y_pos <= screen_centre_y;
            elsif state = game then
                x_pos <= x_pos - move_pixel;

                if x_pos < -10 then
                    x_pos <= screen_max_x;
                    rand_y := to_integer(unsigned(rand_num)) mod (screen_max_y - 10);
                    y_pos <= rand_y;
                end if;
            end if;
        end if;
    end process;

    gift_on <= '1' when
        (to_integer(unsigned(pixel_column)) >= x_pos and to_integer(unsigned(pixel_column)) < x_pos + 10 and
         to_integer(unsigned(pixel_row)) >= y_pos and to_integer(unsigned(pixel_row)) < y_pos + 10)
    else '0';

    gift_x <= x_pos;
    gift_y <= y_pos;
end architecture;
