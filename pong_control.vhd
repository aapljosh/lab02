----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:59:49 02/10/2014 
-- Design Name: 
-- Module Name:    pong_control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.global_constants.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity pong_control is
  port (
    clk         : in std_logic;
    reset       : in std_logic;
    up          : in std_logic;
    down        : in std_logic;
	 speed       : in std_logic;
    v_completed : in std_logic;
    ball_x      : out unsigned(10 downto 0);
    ball_y      : out unsigned(10 downto 0);
    paddle_y    : out unsigned(10 downto 0)
  );
end pong_control;

architecture nielsen of pong_control is
    --TODO - required siganls
  type pong_state_type is
      (moving, hit_top, hit_bottom, hit_right, hit_paddle_top, hit_paddle_bottom, game_over);
		
  signal speed_x_pos, speed_y_pos, speed_x_neg, speed_y_neg : unsigned(10 downto 0);
  signal speed_x_pos_next, speed_y_pos_next, speed_x_neg_next, speed_y_neg_next : unsigned(10 downto 0);
  
  signal ball_x_internal, ball_y_internal, ball_x_next, ball_y_next : unsigned(10 downto 0);
  
  signal paddle_y_internal, paddle_y_next : unsigned(10 downto 0); 
  
  signal v_completed_count, v_completed_next, v_completed_count_ball, v_completed_next_ball : unsigned(10 downto 0);
  
  signal ball, ball_next : pong_state_type;
begin
    --process for handling changing states
    process(clk,reset)
    begin
	   if reset='1' then
		  ball <= moving;
	   elsif (clk'event and clk='1') then
		  ball <= ball_next;
		  ball_x <= ball_x_internal;
		  ball_y <= ball_y_internal;
		  paddle_y <= paddle_y_internal;
	   else
		  ball <= ball;--memory
	   end if; 
    end process;
	 
	 
	 --process for determining the next state
	 process(ball, ball_next, ball_x_internal)
	 begin
	   ball_next <= ball;
		  case ball is
		    when moving =>
			   if ball_x_internal <= 5 then --or ball_x_internal >= width ) then
				  ball_next <= game_over;
				elsif ball_x_internal >= width - 5 then
				  ball_next <= hit_right;
				elsif ball_y_internal <= 5 then--or ball_y_internal >= height) then
				  ball_next <= hit_top;
				elsif ball_y_internal >= height - 5 then
				  ball_next <= hit_bottom;
				elsif ball_x_next <= to_unsigned(3*paddle_width/2, 10)+15 and 
				      ball_y_next <= paddle_y_internal and
				      ball_y_next >= paddle_y_internal - to_unsigned(paddle_height/2, 10) then
				  ball_next <= hit_paddle_top;
				elsif ball_x_next <= to_unsigned(3*paddle_width/2, 10)+15 and 
				      ball_y_next > paddle_y_internal and
				      ball_y_next <= paddle_y_internal + to_unsigned(paddle_height/2, 10) then
				  ball_next <= hit_paddle_bottom;
				else
				  ball_next <= moving;
            end if;
			 when hit_top =>
			   ball_next <= moving;
		    when hit_right =>
			   ball_next <= moving;
			 when hit_bottom =>
			   ball_next <= moving;
			 when hit_paddle_top =>
			   ball_next <= moving;
		    when hit_paddle_bottom =>
			   ball_next <= moving;
			 when game_over =>
			   ball_next <= game_over;
		  end case;
	 end process;
	 
									
	 process(clk, reset)
	 begin
	   if reset = '1' then
		  v_completed_count_ball <= (others => '0');
		elsif rising_edge(clk) then
			v_completed_count_ball <= v_completed_next_ball;
		end if;
	 end process;
	 
	 v_completed_next_ball <= 	(others => '0') when v_completed_count_ball = 400 and speed = '0' else--speed
	                           (others => '0') when v_completed_count_ball = 600 and speed = '1' else--speed
									   v_completed_count_ball + 1 when v_completed = '1' else
									   v_completed_count_ball;
									
	 process(clk, reset)
	 begin
		if reset = '1' then
		  ball_x_internal <= "00000100000";
		  ball_y_internal <= "00000100000";
		  speed_x_pos <= "00000000001";
		  speed_y_pos <= "00000000001";
		  speed_x_neg <= (others => '0');
		  speed_y_neg <= (others => '0');
		elsif rising_edge(clk) then
		  ball_x_internal <= ball_x_next;
		  ball_y_internal <= ball_y_next;
		  speed_x_pos <= speed_x_pos_next;
		  speed_y_pos <= speed_y_pos_next;
		  speed_x_neg <= speed_x_neg_next;
		  speed_y_neg <= speed_y_neg_next;
		end if;
	 end process;
									
	 ball_x_next <= 	"00000100001" when reset = '1' else
	                  ball_x_internal + speed_x_pos - speed_x_neg when v_completed_count_ball = 400 and speed = '0' and ball_next = moving else
                     ball_x_internal + speed_x_pos - speed_x_neg when v_completed_count_ball = 600 and speed = '1' and ball_next = moving else							
							ball_x_next;
							
	 ball_y_next <=	"00000100001" when reset = '1' else
	                  ball_y_internal + speed_y_pos - speed_y_neg when  v_completed_count_ball = 400 and speed = '0' and ball_next = moving else
							ball_y_internal + speed_y_pos - speed_y_neg when  v_completed_count_ball = 600 and speed = '1' and ball_next = moving else
	                  ball_y_next;

	 speed_x_pos_next <= "00000000001" when reset = '1' or ball_next = hit_paddle_top or ball_next = hit_paddle_bottom else
	                     speed_x_pos when ball_next = moving else
	                     (others => '0') when ball_next = hit_right else
	                     speed_x_pos;
						 
    speed_y_pos_next <= "00000000001" when reset = '1' or ball_next = hit_top or ball_next = hit_paddle_bottom else
	                     speed_y_pos when ball_next = moving else
	                     (others => '0') when ball_next = hit_bottom or ball_next = hit_paddle_top else
	                     speed_y_pos;
	 
	 speed_x_neg_next <= (others => '0') when reset = '1' or ball_next = hit_paddle_top or ball_next = hit_paddle_bottom else
	                     speed_x_neg when ball_next = moving else
	                     "00000000001" when ball_next = hit_right else
	                     speed_x_neg;                     
						 
    speed_y_neg_next <= (others => '0') when reset = '1' or ball_next = hit_top or ball_next = hit_paddle_bottom else
	                     speed_y_neg when ball_next = moving else
	                     "00000000001" when ball_next = hit_bottom or ball_next = hit_paddle_top else
	                     speed_y_neg;   
    --speed of ball
	 process(clk, reset)
	 begin
	   if reset = '1' then
		  v_completed_count <= (others => '0');
		elsif rising_edge(clk) then
			v_completed_count <= v_completed_next;
		end if;
	 end process;
	 
	 v_completed_next <= 	(others => '0') when v_completed_count = 200 else--speed
									v_completed_count + 1 when v_completed = '1' else
									v_completed_count;
	 
	 process(clk, reset)
	 begin
		if reset = '1' then
		  paddle_y_internal <= to_unsigned(height/3, 11);
		elsif rising_edge(clk) then
			paddle_y_internal <= paddle_y_next;
		end if;
	 end process;
	 
	 paddle_y_next <= 	paddle_y_internal - 1 when up = '1' and v_completed_count = 200 and paddle_y_internal > to_unsigned(paddle_height/2, 10) else
								paddle_y_internal + 1 when down = '1' and v_completed_count = 200 and paddle_y_internal < height-to_unsigned(paddle_height/2, 10)else
								paddle_y_internal;

end nielsen;