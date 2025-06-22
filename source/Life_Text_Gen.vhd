library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Life_Text_Gen is
    port (
        pixel_row, pixel_column : in std_logic_vector(9 downto 0);
        character_address : out std_logic_vector(5 downto 0);
        font_row, font_column : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behaviour of Life_Text_Gen is

	constant CHAR_COUNT : integer := 4;

    type pos_array is array (0 to CHAR_COUNT-1) of std_logic_vector(9 downto 0);
    type addr_array is array (0 to CHAR_COUNT-1) of std_logic_vector(5 downto 0);
	 type size_array is array (0 to CHAR_COUNT-1) of std_logic_vector(9 downto 0);
	 
    signal char_x_pos, char_y_pos : pos_array;
    signal first_row, first_col : pos_array;
	 signal char_size : size_array;
    signal char_rom_addr : std_logic_vector(5 downto 0);

    constant char_rom : addr_array := (
        0 => "001100",  -- L
        1 => "001001",  -- I
        2 => "000110",  -- F
        3 => "000101"  -- E
		  );

begin

    char_size(0 to 3)  <= (others => CONV_STD_LOGIC_VECTOR(16, 10));
	 
    char_x_pos(0) <= CONV_STD_LOGIC_VECTOR(88, 10);   -- L
    char_y_pos(0) <= CONV_STD_LOGIC_VECTOR(52, 10);

    char_x_pos(1) <= CONV_STD_LOGIC_VECTOR(118, 10);   -- I
    char_y_pos(1) <= CONV_STD_LOGIC_VECTOR(52, 10);

    char_x_pos(2) <= CONV_STD_LOGIC_VECTOR(148, 10);  -- F
    char_y_pos(2) <= CONV_STD_LOGIC_VECTOR(52, 10);

    char_x_pos(3) <= CONV_STD_LOGIC_VECTOR(178, 10);  -- E
    char_y_pos(3) <= CONV_STD_LOGIC_VECTOR(52, 10);
	 
    process(pixel_row, pixel_column)
    begin
        character_address <= "000000";
        font_row  <= "000";
        font_column <= "000";

        for i in 0 to CHAR_COUNT-1 loop
        if ((('0' & char_x_pos(i) <= pixel_column + char_size(i)) and
             ('0' & pixel_column < char_x_pos(i) + char_size(i)) and
             ('0' & char_y_pos(i) <= pixel_row + char_size(i)) and
             ('0' & pixel_row < char_y_pos(i) + char_size(i)))) then

            first_row(i) <= pixel_row - char_y_pos(i) + char_size(i);
            first_col(i) <= pixel_column - char_x_pos(i) + char_size(i);

            character_address <= char_rom(i);

                font_row    <= first_row(i)(4 downto 2);
                font_column <= first_col(i)(4 downto 2);

            exit;
        end if;
    end loop;
    end process;

end architecture;
