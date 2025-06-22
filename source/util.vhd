
package util is 
	constant pipe_min_y : integer := 112;
   constant pipe_max_y : integer := 368;
	constant pipe_width : integer := 45;
	constant pipe_gap : integer := 130;
	
	constant screen_max_x : integer := 639;
	constant screen_max_y : integer := 479;
	constant screen_centre_x : integer := 319;
	constant screen_centre_y : integer := 239;
	
	constant bird_width : integer := 16;
	constant bird_height : integer := 16;
	constant bird_max_x : integer := screen_max_x - bird_width;
	constant bird_max_y : integer := screen_max_y - bird_height;

	 
	 type collision_type is (
		none, pipe, gift
	 );
	 
   type game_state is (
      title, game, gameover
    );
	 

	 type bird_pos_type is record
		x : integer range 0 to bird_max_x;
		y : integer range 0 to bird_max_y;
	 end record;
	 
	 type pipe_pos_type is record
      x : integer range -pipe_width / 2 to 2 * screen_max_x; -- (-Pipe width / 2 to 2 * screen max)
      y : integer range pipe_min_y to pipe_max_y;
    end record;
	 
    type pipe_pos_arr_type is array (0 to 2) of pipe_pos_type;
	 
end package;

package body util is
end package body util;