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
    v_completed : in std_logic;
    ball_x      : out unsigned(10 downto 0);
    ball_y      : out unsigned(10 downto 0);
    paddle_y    : out unsigned(10 downto 0)
  );
end pong_control;

architecture nielsen of pong_control is
    --TODO - required siganls
  type pong_state_type is
      (moving, hit_wall, hit_paddle);
  signal ball_x_internal, ball_y_internal, speed_x, speed_y : unsigned(10 downto 0);
  signal paddle_y_internal : unsigned(10 downto 0) := to_unsigned(height/2, 11); 
  signal v_completed_count : unsigned(10 downto 0) := (others => '0');
  --signal count_up, count_dn : unsigned(20 downto 0);
  signal count_up, count_dn, db_up, db_dn : std_logic;
  signal ball, ball_next : pong_state_type;
begin
    --process for handling changing states
    process(clk,reset)
    begin
	   if reset='1' then
		  ball <= moving;
		  ball_x_internal <= to_unsigned(width/2, 11);
		  ball_y_internal <= to_unsigned(height/2, 11);
	   elsif (clk'event and clk='1') then
		  ball <= ball_next;
		  paddle_y <= paddle_y_internal;
	   else
		  ball <= ball;--memory
	   end if; 
    end process;
	 
	 process(clk, reset)
	 begin
	   if reset = '1' then
		  v_completed_count <= (others => '0');
		elsif (clk'event and clk='1') then
		  if v_completed = '1' then
		    v_completed_count <= v_completed_count + 1;
		  elsif v_completed_count = 600 then
		    v_completed_count <= (others => '0');
        else
          v_completed_count <= v_completed_count;
		  end if;
		end if;
	 end process;
	 
	 --process for determining the next state
	 process(ball, ball_next)
	 begin
	   ball_next <= ball;
		  case ball is
		    when moving =>

			 when hit_wall =>

			 when hit_paddle =>

		  end case;
	 end process;
	 
	 process(up, down, reset)
	 begin
	   if up = '1' and v_completed_count = 50 then--and paddle_y_internal - to_unsigned(paddle_height/2, 11) <= 0 then -- add "and not touching the top"
		  paddle_y_internal <= paddle_y_internal - 1;
		elsif down = '1' and v_completed_count = 50 then--and paddle_y_internal + to_unsigned(paddle_height/2, 11) <= height then --and not touching bottom
        paddle_y_internal <= paddle_y_internal + 1;
		elsif v_completed_count = 0 and reset = '1' then
		  paddle_y_internal <= to_unsigned(height/3, 11);
      else
        paddle_y_internal <= paddle_y_internal;
      end if;		
	 end process;

end nielsen;

