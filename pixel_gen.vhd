----------------------------------------------------------------------------------
-- Company:        USAFA
-- Engineer:       Josh Nielsen
-- 
-- Create Date:    10:42:09 01/29/2014 
-- Design Name:    Nielsen
-- Module Name:    pixel_gen
-- Project Name:   Lab 01
-- Target Devices: Spartan 6
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
-- TODO: Include requied libraries and packages
--       Don't forget about `unisim` and its `vcomponents` package.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.global_constants.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity pong_pixel_gen is
  port (
    row      : in unsigned(10 downto 0);
    column   : in unsigned(10 downto 0);
    blank    : in std_logic;
    ball_x   : in unsigned(10 downto 0);
    ball_y   : in unsigned(10 downto 0);
	 paddle_y : in unsigned(10 downto 0);
    r,g,b    : out std_logic_vector(7 downto 0)
  );
end pong_pixel_gen;

architecture nielsen of pong_pixel_gen is
  signal red, green, blue : std_logic_vector(7 downto 0);
begin

  process(row,column,blank)
  begin
    r<= (others => '0');
	 g<= (others => '0');
	 b<= (others => '0');
    if blank='0' then
 	   if (column > to_unsigned(3*width/12, 10)-15 and column < to_unsigned(3*width/12, 10)+15 and row <= to_unsigned(3*height/4, 10) and row >= to_unsigned(height/4, 10)) or--left side A
		   (column > to_unsigned(5*width/12, 10)-15 and column < to_unsigned(5*width/12, 10)+15 and row <= to_unsigned(3*height/4, 10) and row >= to_unsigned(height/4, 10)) or--right side A
		   (column > to_unsigned(7*width/12, 10)-15 and column < to_unsigned(7*width/12, 10)+15 and row <= to_unsigned(3*height/4, 10) and row >= to_unsigned(height/4, 10)) or--vertical F
		   (column > to_unsigned(3*width/12, 10)-15 and column < to_unsigned(5*width/12, 10)+15 and row <= to_unsigned(height/4, 10)+30 and row >= to_unsigned(height/4, 10))or--top A
		   (column > to_unsigned(7*width/12, 10)-15 and column < to_unsigned(9*width/12, 10)+15 and row <= to_unsigned(height/4, 10)+30 and row >= to_unsigned(height/4, 10))or--top F
		   (column > to_unsigned(3*width/12, 10)-15 and column < to_unsigned(5*width/12, 10)+15 and row <= to_unsigned(height/2, 10)+30 and row >= to_unsigned(height/2, 10))or--middle A
		   (column > to_unsigned(7*width/12, 10)-15 and column < to_unsigned(8*width/12, 10)+15 and row <= to_unsigned(height/2, 10)+30 and row >= to_unsigned(height/2, 10))then--middle F
		  r<= (others => '0');
		  g<= "10001000";
		  b<= (others => '1');
	   elsif	(column > to_unsigned(2*width/80, 10)-10 and column < to_unsigned(3*width/80, 10)+10 and row <= paddle_y+40 and row >= paddle_y-40) then
		  r <= (others => '0');
		  g <= (others => '1');
		  b <= (others => '0');
		else  
	     r <= (others => '0');
	     g <= (others => '0');
	     b <= (others => '0');
      end if;
	 else
	   r <= (others => '0');
	   g <= (others => '0');
	   b <= (others => '0');
    end if;
  end process;

end nielsen;

