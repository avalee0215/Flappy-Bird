library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util.all;

entity Collision_detect is
    port (
        clock_60hz     : in  std_logic;
        bird_pos       : in  bird_pos_type;
        pipe_posns     : in  pipe_pos_arr_type;
        gift_pos       : in  bird_pos_type;
        collision      : out collision_type;
        gain_collision : out std_logic
    );
end entity;

architecture behaviour of Collision_detect is
    signal collision_result_var : collision_type;
    signal gift_hit : std_logic := '0';
begin
    process (clock_60hz)
    begin
        if rising_edge(clock_60hz) then
            collision_result_var <= none;
            gift_hit <= '0';

            -- Pipe
            for i in 0 to 2 loop
                if (bird_pos.x + bird_width > pipe_posns(i).x - PIPE_WIDTH / 2 and
                    bird_pos.x < pipe_posns(i).x + PIPE_WIDTH / 2) then

                    if (bird_pos.y + bird_height >= (pipe_posns(i).y + pipe_gap) or 
                        bird_pos.y <= pipe_posns(i).y - pipe_gap) then
                        collision_result_var <= pipe;
                        exit;
                    end if;
                end if;
            end loop;

            -- Gift
            if abs(bird_pos.x - gift_pos.x) < 10 and abs(bird_pos.y - gift_pos.y) < 10 then
                gift_hit <= '1';
            else
                gift_hit <= '0';
            end if;

            collision <= collision_result_var;
            gain_collision <= gift_hit;
        end if;
    end process;
end architecture;

