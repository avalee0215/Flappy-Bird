library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- <--- Use this for numeric operations (to_integer, to_unsigned)

entity Score_Gen is
    port (
        score            : in integer;
        pixel_row        : in std_logic_vector(9 downto 0);
        pixel_column     : in std_logic_vector(9 downto 0);
        character_address: out std_logic_vector(5 downto 0);
        font_row         : out std_logic_vector(2 downto 0);
        font_column      : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behaviour of Score_Gen is

    constant CHAR_COUNT       : integer := 2;
    constant CHAR_WIDTH_PIXELS  : integer := 32;
    constant CHAR_HEIGHT_PIXELS : integer := 32;

    constant CHAR_WIDTH_SLV  : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(CHAR_WIDTH_PIXELS, 10));
    constant CHAR_HEIGHT_SLV : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(CHAR_HEIGHT_PIXELS, 10));

    type pos_array_slv is array (0 to CHAR_COUNT-1) of std_logic_vector(9 downto 0);
    constant char_x_pos : pos_array_slv := (
        0 => std_logic_vector(to_unsigned(290, 10)), -- Tens digit X position
        1 => std_logic_vector(to_unsigned(320, 10))  -- Ones digit X position
    );
    constant char_y_pos : pos_array_slv := (
        0 => std_logic_vector(to_unsigned(20, 10)),  -- Tens digit Y position
        1 => std_logic_vector(to_unsigned(20, 10))   -- Ones digit Y position
    );

    signal first_row, first_col : std_logic_vector(9 downto 0); -- Temp signals for calculation

begin

    process(pixel_row, pixel_column, score)
        variable row_int, col_int : integer;
        variable char_x_int, char_y_int : integer;
        variable current_digit : integer := 0;
    begin
        character_address <= (others => '0');
        font_row          <= (others => '0');
        font_column       <= (others => '0');

        row_int := to_integer(unsigned(pixel_row));
        col_int := to_integer(unsigned(pixel_column));

        for i in 0 to CHAR_COUNT-1 loop
            char_x_int := to_integer(unsigned(char_x_pos(i)));
            char_y_int := to_integer(unsigned(char_y_pos(i)));

            if (col_int >= char_x_int and col_int < (char_x_int + CHAR_WIDTH_PIXELS) and
                row_int >= char_y_int and row_int < (char_y_int + CHAR_HEIGHT_PIXELS)) then

                if i = 0 then -- Tens digit
                    current_digit := (score / 10) mod 10;
                else -- Ones digit
                    current_digit := score mod 10;
                end if;
					 
					case current_digit is
						when 0 => character_address <= "110000";
						when 1 => character_address <= "110001";
						when 2 => character_address <= "110010";
						when 3 => character_address <= "110011";
						when 4 => character_address <= "110100";
						when 5 => character_address <= "110101";
						when 6 => character_address <= "110110";
						when 7 => character_address <= "110111";
						when 8 => character_address <= "111000";
						when 9 => character_address <= "111001";
						when others => character_address <= "000000";
				   end case;
					 
                -- Convert offsets to std_logic_vector using numeric_std's to_unsigned then cast
                first_row <= std_logic_vector(to_unsigned(row_int - char_y_int, 10));
                first_col <= std_logic_vector(to_unsigned(col_int - char_x_int, 10));

                font_row    <= std_logic_vector(to_unsigned(row_int - char_y_int, 3)); -- Corrected for 3 bits (0-7), or 4 bits (0-15) if 16x16 font
                font_column <= std_logic_vector(to_unsigned(col_int - char_x_int, 3)); -- Corrected for 3 bits (0-7), or 4 bits (0-15) if 16x16 font

                
                font_row    <= first_row(4 downto 2); -- Keep your original slicing for now
                font_column <= first_col(4 downto 2); -- Keep your original slicing for now

                exit;
            end if;
        end loop;
    end process;

end architecture;