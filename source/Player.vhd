LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

use work.util.all; -- Ensure this points to your util package

entity Player is
    port (
        clock_60hz   : in  std_logic;
        left_button  : in  std_logic; -- Or 'jump_button' if that's more descriptive
        key0         : in  std_logic; -- Not used in provided code, can be removed if not needed
        pixel_row    : in  std_logic_vector(9 downto 0);
        pixel_column : in  std_logic_vector(9 downto 0);
        player_pos   : out bird_pos_type; -- Bird's actual game position
        Player_on    : out std_logic      -- Indicates if current pixel is part of the player sprite
    );
end Player;

architecture behavior of Player is

    -- These signals hold the current position of the player (bird)
    -- They should be internal and represent the game state position.
    signal current_ball_x_pos : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(320, 10));
    signal current_ball_y_pos : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(240, 10));

    -- Player's vertical velocity
    signal ball_y_velocity_slv : std_logic_vector(9 downto 0) := std_logic_vector(to_signed(0, 10));

    signal prev_button_state : std_logic := '0'; -- Used for edge detection on jump button

    -- Constants for movement physics
    constant GRAVITY         : integer := 1;
    constant JUMP_VELOCITY   : integer := -10;
    constant MAX_FALL_VELOCITY : integer := 6;
    constant MAX_JUMP_VELOCITY : integer := -15; -- Corrected to be a negative velocity

begin

    -- The 'Player_on' output determines if the current pixel (pixel_row, pixel_column)
    -- falls within the player's sprite boundaries. This is for drawing.
    Player_on <= '1' when (
        (unsigned(pixel_column) >= unsigned(current_ball_x_pos) and unsigned(pixel_column) < unsigned(current_ball_x_pos) + to_unsigned(bird_width, 10)) and
        (unsigned(pixel_row)    >= unsigned(current_ball_y_pos) and unsigned(pixel_row)    < unsigned(current_ball_y_pos) + to_unsigned(bird_height, 10))
    ) else '0';

    -- Player position calculation (game logic)
    -- This process updates the bird's X and Y coordinates based on physics and input.
    Move_Player_Physics: process (clock_60hz)
        variable current_y_velocity_int : integer;
        variable next_ball_y_pos_int    : integer;
    begin
        if rising_edge(clock_60hz) then
            current_y_velocity_int := to_integer(signed(ball_y_velocity_slv));

            -- Jump logic (on button press detected by rising edge)
            if left_button = '1' and prev_button_state = '0' then
                current_y_velocity_int := JUMP_VELOCITY;
            else
                -- Apply gravity
                current_y_velocity_int := current_y_velocity_int + GRAVITY;

                -- Clamp velocity to max/min values
                if current_y_velocity_int > MAX_FALL_VELOCITY then
                    current_y_velocity_int := MAX_FALL_VELOCITY;
                elsif current_y_velocity_int < MAX_JUMP_VELOCITY then
                    current_y_velocity_int := MAX_JUMP_VELOCITY;
                end if;
            end if;

            -- Calculate next Y position
            next_ball_y_pos_int := to_integer(unsigned(current_ball_y_pos)) + current_y_velocity_int;

            -- Boundary checking for Y position (top and bottom of screen)
            if next_ball_y_pos_int < 0 then
                current_ball_y_pos <= std_logic_vector(to_unsigned(0, 10));
                current_y_velocity_int := 0; -- Stop vertical movement if hit top
            elsif next_ball_y_pos_int > (screen_max_y - bird_height) then -- Use screen_max_y and bird_height from util
                current_ball_y_pos <= std_logic_vector(to_unsigned((screen_max_y - bird_height), 10));
                current_y_velocity_int := 0; -- Stop vertical movement if hit bottom
            else
                current_ball_y_pos <= std_logic_vector(to_unsigned(next_ball_y_pos_int, 10));
            end if;

            -- Update velocity for next cycle
            ball_y_velocity_slv <= std_logic_vector(to_signed(current_y_velocity_int, 10));

            -- Update previous button state for edge detection
            prev_button_state <= left_button;

            -- The X position of the bird is typically constant in Flappy Bird
            -- If you want it to move, you'd add similar logic for X.
            -- For now, it remains at the initial value (320).
            current_ball_x_pos <= std_logic_vector(to_unsigned(screen_centre_x, 10)); -- Center X from util, or a fixed value

        end if;
    end process Move_Player_Physics;

    -- Drive the output 'player_pos' with the calculated game position
    -- This is a concurrent assignment, outside of a process, or in a separate combinational process
    -- if it depends on multiple inputs. Here, it simply connects the internal signals to the output.
    player_pos.x <= to_integer(unsigned(current_ball_x_pos));
    player_pos.y <= to_integer(unsigned(current_ball_y_pos));

end behavior;