library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util.all;

library altera_mf;
use altera_mf.all;

entity Game_Control is
    port (
        CLOCK2_50 : in std_logic;
        KEY : in std_logic_vector(1 downto 0);
        SW : in std_logic_vector(1 downto 0);
        VGA_HS, VGA_VS : out std_logic;
        VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0);
        PS2_CLK, PS2_DAT : inout std_logic
    );
end entity;

architecture behaviour of Game_Control is

    signal clock_25Mhz, clock_60hz : std_logic;
    signal pll_locked    : std_logic;

    signal pixel_row_temp, pixel_column_temp : std_logic_vector(9 downto 0);

    signal move_speed : integer := 1;
	 signal score : integer := 0;

    signal state_temp : game_state := title;

    signal rand_val : std_logic_vector(7 downto 0);
	 
    signal mode : std_logic;

    signal prev_key0     : std_logic := '1';
    signal key0_pressed  : std_logic := '0';
	 signal display_state_for_pipes : game_state; 
	 signal left_button : std_logic;
	 signal right_button : std_logic;

	 signal pipe_passed : integer;
	 signal pipe_pos : pipe_pos_arr_type;	
	
    signal vert_sync : std_logic;
	 signal prev_pipe : pipe_pos_arr_type;

	 
	 signal mouse_cursor_row : std_logic_vector(9 DOWNTO 0); 
	 signal mouse_cursor_column : std_logic_vector(9 DOWNTO 0); 
	 
	 signal pipe_collision : std_logic := '0';
	 signal gift_collision : std_logic := '0';
	 signal collision : collision_type;
	 signal life : integer := 3;

	 signal restart : std_logic := '0';
    signal pipe_passed_event : std_logic := '0';
	 signal prev_sw1 : std_logic;
	 signal sw1_pressed : std_logic;
	 
	 	 
	 --gift
	 signal bird_pos : bird_pos_type;
	 signal gift_x, gift_y : integer;
	 signal gift_pos : bird_pos_type;
	 signal gain_collision : std_logic;

	 
    component VGA_SYNC is 
        port (
            clock_25Mhz       : in  std_logic;
            red, green, blue  : in  std_logic;
            red_out, green_out, blue_out : out std_logic;
            horiz_sync_out    : out std_logic;
            vert_sync_out     : out std_logic;
            pixel_row         : out std_logic_vector(9 downto 0);
            pixel_column      : out std_logic_vector(9 downto 0)
        );
    end component;

    component Rand_num is 
        port (
            clock_60hz : in std_logic;
            enable     : in std_logic;
            reset      : in std_logic;
            rand_num   : out std_logic_vector(7 downto 0)
        );
    end component;

    component pll is 
        port (
            refclk   : in  std_logic;
            rst      : in  std_logic;
            outclk_0 : out std_logic;
            locked   : out std_logic
        );
    end component;

    component Display_Control is 
        port (
            clock_25Mhz, clock_60hz : in std_logic;
            rand_num : in std_logic_vector(7 downto 0);
            state : in game_state;
            pixel_row, pixel_column : in std_logic_vector(9 downto 0);
            mode_sel : in std_logic;
				score    : in integer;
				left_button : in std_logic;
				life_count  : in integer;
				move_speed_in : in integer range 0 to 10;
            VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0);
				pipe_passed : out integer;
				pipe_pos    : out pipe_pos_arr_type
--				collision   : out collision_type


        );
    end component;
	 
	 component MOUSE IS
		 PORT( clock_25Mhz, reset 		: IN std_logic;
         mouse_data					: INOUT std_logic;
         mouse_clk 					: INOUT std_logic;
         left_button, right_button	: OUT std_logic;
		 mouse_cursor_row 			: OUT std_logic_vector(9 DOWNTO 0); 
		 mouse_cursor_column 		: OUT std_logic_vector(9 DOWNTO 0)
		 );       	
	 end component;

begin

    vga_inst : VGA_SYNC
        port map (
            clock_25Mhz     => clock_25Mhz,
            red             => '1',
            green           => '1',
            blue            => '1',
            red_out         => open,
            green_out       => open,
            blue_out        => open,
            horiz_sync_out  => VGA_HS,
            vert_sync_out   => vert_sync,
            pixel_row       => pixel_row_temp,
            pixel_column    => pixel_column_temp
        );

    Display : Display_Control
        port map (
            clock_25Mhz => clock_25Mhz, 
            clock_60hz => clock_60hz, 
            rand_num => rand_val, 
            state => display_state_for_pipes, 
            pixel_row => pixel_row_temp,
            pixel_column => pixel_column_temp,
            mode_sel => mode, 
				score => score, 
				left_button => left_button, 
				life_count => life, 
				move_speed_in => move_speed,
            VGA_R => VGA_R,
            VGA_G => VGA_G, 
            VGA_B => VGA_B,
				pipe_passed => pipe_passed, 
			   pipe_pos => pipe_pos 
--				collision => collision
        );

    rand_inst : Rand_num
        port map (
            clock_60hz => clock_60hz,
            enable     => '1',
            reset      => '0',
            rand_num   => rand_val
        );

    pll_inst : pll
        port map (
            refclk   => CLOCK2_50,
            rst      => '0',
            outclk_0 => clock_25Mhz,
            locked   => pll_locked
        );
		  
	 Mouse_Control : Mouse
		 PORT map ( 
				clock_25Mhz  => clock_25Mhz,  
				reset 		 => restart, 
				mouse_data	 => PS2_DAT, 
				mouse_clk 	 => PS2_CLK, 
				left_button  => left_button, 
				right_button => right_button, 
				mouse_cursor_row => mouse_cursor_row, 
				mouse_cursor_column => mouse_cursor_column
		 ); 

	  U_GiftGen : entity work.Gift_Gen
        port map (
            clock_60hz    => clock_60hz,
            state         => state_temp,
            rand_num      => rand_val,
            pixel_row     => pixel_row_temp,
            pixel_column  => pixel_column_temp,
            move_pixel    => move_speed,
            gift_on       => open,
            gift_x        => gift_x,
            gift_y        => gift_y
        );

    gift_pos.x <= gift_x;
    gift_pos.y <= gift_y;

    -- NEW: Player
    U_Player : entity work.Player
        port map (
            clock_60hz   => clock_60hz,
            left_button  => left_button,
            key0         => KEY(0),
            pixel_row    => pixel_row_temp,
            pixel_column => pixel_column_temp,
            player_pos   => bird_pos,
            Player_on    => open
        );

    -- NEW: Collision Detect
    U_CollisionDetect : entity work.Collision_detect
        port map (
            clock_60hz     => clock_60hz,
            bird_pos       => bird_pos,
            pipe_posns     => pipe_pos,
            gift_pos       => gift_pos,
            collision      => collision,
            gain_collision => gain_collision
        );
		 
	 clock_60hz <= not vert_sync;
	 VGA_VS <= vert_sync;

    Finite_State_machine : process(clock_60hz)
    begin
        if rising_edge(clock_60hz) then

            -- Key0 falling edge detection
            if (KEY(0) = '0' and prev_key0 = '1') then
                key0_pressed <= '1';
            else
                key0_pressed <= '0';
            end if;
            prev_key0 <= KEY(0);

            -- SW1 toggle detection
            if (SW(1) = '0' and prev_sw1 = '1') then
                sw1_pressed <= '1';
            else
                sw1_pressed <= '0';
            end if;
            prev_sw1 <= SW(1);

            -- Game reset on gameover
            if (state_temp = gameover and key0_pressed = '1') or (pll_locked = '0') then 
                state_temp <= title;
                life       <= 3;
                move_speed <= 1;
                score      <= 0;
                restart    <= '1';
            else
                restart <= '0';
            end if;

            case state_temp is
                when title =>
                    -- Mode selection only in title state with confirmation by KEY0
                    if (SW(0) = '0') then
                        mode <= '0';  -- Training mode
                    else
                        mode <= '1';  -- Game mode
                    end if;

                    if key0_pressed = '1' then
								score <= 0;
							   life <= 3;
								move_speed <=1; 
                        state_temp <= game;
                        for i in 0 to 2 loop
                            prev_pipe(i).x <= 0; 
                        end loop;
                    end if;

                when game =>
                    -- Toggle between modes live during gameplay using SW1
                    if sw1_pressed = '1' then
                        mode <= not mode;
								score <= 0;
								life <= 3;
								move_speed <= 1;
                        state_temp <= title;
                    end if;

--                    -- Collision logic
--                    if (collision = pipe and life > 0) then
--                        life <= life - 1;
--                        if (life - 1 <= 0) then
--                            state_temp <= gameover;
--                        end if;
--                    elsif (collision = gift) then
--                        life <= life + 1;
--                    end if;

                    -- Training end condition (fixed speed, 30 scores only)
                    if (mode = '0' and score >= 30) then
                        state_temp <= gameover;
						  elsif (mode = '1' and collision = pipe and life > 0) then
                        life <= life - 1;
                        if (life - 1 <= 0) then
                            state_temp <= gameover;
                        end if;
                    elsif (collision = gift) then
                        life <= life + 1;
                    end if;

                when gameover =>
                    null;
                when others =>
                    state_temp <= title;
            end case;

            -- Propagate current game state to Display_Control
            display_state_for_pipes <= state_temp;

            -- Speed logic
            if (mode = '0') then
                move_speed <= 3;  -- Training fixed speed
            else
                case score is
                    when 10 => move_speed <= 3;
                    when 20 => move_speed <= 5;
                    when 30 => move_speed <= 0;
                    when others => null;
                end case;
            end if;

            -- Pipe passing = +1 score logic
            for i in 0 to 2 loop
                if (pipe_pos(i).x <= 320) then
                    if (pipe_pos(i).x - prev_pipe(i).x > 50) then
                        score <= score + 1;
                    end if;
                    prev_pipe(i).x <= pipe_pos(i).x;
                end if;
            end loop;
        end if;
    end process;
	 
end architecture;