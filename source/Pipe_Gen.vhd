library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.util.all;

entity Pipe_Gen is
    port (
        state        : in  game_state;
        clock_60hz   : in  std_logic;
        rand_num     : in  std_logic_vector(7 downto 0);
        pixel_row    : in  std_logic_vector(9 downto 0);
        pixel_column : in  std_logic_vector(9 downto 0);
        move_pixel   : in  integer;
        pipe_on      : out std_logic;
		  pipe_pass    : out integer;
		  pipe_pos     : out pipe_pos_arr_type
    );
end entity;

architecture behaviour of Pipe_Gen is
    signal current_pipe    : pipe_pos_arr_type;
    signal next_y_pipe     : pipe_pos_arr_type;  -- buffer for next pipe Y
    signal init_pipe       : std_logic := '1';
	 signal new_pipe_num    : integer := 3;

begin

    -- Pipe Movement Process (60Hz)
    process(clock_60hz)
        variable new_x, new_y : integer;
        variable pipe_tmp     : pipe_pos_type;
        variable rand         : integer;
    begin
        if rising_edge(clock_60hz) then
            rand := to_integer(unsigned(rand_num)) mod (pipe_max_y - pipe_min_y);

            if state = title and init_pipe = '1' then
                init_pipe <= '0';

                for i in 0 to 2 loop
                    current_pipe(i).x <= screen_centre_x + ((screen_max_x + pipe_width) / 3) + i * ((screen_max_x + pipe_width) / 3);
                    current_pipe(i).y <= ((rand + i * 50) mod (pipe_max_y - pipe_min_y)) + pipe_min_y;
                    next_y_pipe(i).y  <= ((rand + i * 90) mod (pipe_max_y - pipe_min_y)) + pipe_min_y;  -- preload next y
                end loop;

            elsif state = game then
                init_pipe <= '1';

                for i in 0 to 2 loop
                    pipe_tmp := current_pipe(i);
                    new_x := pipe_tmp.x - move_pixel;

                    if new_x < -pipe_width/2 then
                        new_x := screen_max_x + pipe_width;
                        current_pipe(i).y <= next_y_pipe(i).y;  -- use preloaded y
                        new_pipe_num <= new_pipe_num + 1;
								next_y_pipe(i).y  <= ((rand + i * 90) mod (pipe_max_y - pipe_min_y)) + pipe_min_y;  -- prepare next y
                    else
                        current_pipe(i).y <= pipe_tmp.y;
                    end if;
						  pipe_pass <= new_pipe_num;
                    current_pipe(i).x <= new_x;
                end loop;
            end if;
				for i in 0 to 2 loop
					pipe_pos(i).x <= current_pipe(i).x;
				end loop;
        end if;
    end process;

    -- Display Process (25MHz)
    process(pixel_row, pixel_column)
        variable row_int, col_int : integer;
        variable pipe_hit         : std_logic;
    begin
        row_int := to_integer(unsigned(pixel_row));
        col_int := to_integer(unsigned(pixel_column));
        pipe_hit := '0';

        for i in 0 to 2 loop
            if col_int >= current_pipe(i).x - pipe_width/2 and col_int <= current_pipe(i).x + pipe_width/2 then
                if row_int < current_pipe(i).y - pipe_gap/2 or row_int > current_pipe(i).y + pipe_gap/2 then
                    pipe_hit := '1';
                    exit;
                end if;
            end if;
        end loop;

        pipe_on <= pipe_hit;
    end process;

end architecture;
