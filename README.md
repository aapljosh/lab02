#Introduction
The goal of this code repository is to expand upon the VGA lab assignment by implementing a pong game. There are several requirements for this lab. First, the screen must display an “AF” logo in the middle that the bouncing pong ball travels behind as it moves across the screen. Second, there must be a user-controllable paddle that moves up and down the left side of the screen based upon user input. Finally, there must be a pong ball that moves smoothly across the screen and “bounces” when it hits the top, right or bottom of the screen. When the game is over, the ball must freeze in position on the left side of the screen, showing that it made it past the paddle. The game can be reset by pushing a “reset” button on the FPGA. For additional functionality, the ball must be able to change speed based on user input via a switch on the FPGA. For full “A” functionality the ball must bounce off of the paddle at different angles depending upon where it hits the paddle (top half or bottom half). 

#Implementation
Much of this lab’s functionality is based upon the functionality of [lab 1] (https://github.com/aapljosh/lab01). This previous lab provided the basis for outputting to a display. Without it there would be no sense in even trying to implement Pong on the Spartan 6.   

There is a new module associated with creating a pong game over simply displaying things to a screen as was done in lab 1. There now needs to be a module that controls all of the game logic based upon the user’s inputs. This logic then needs to be interpreted by the pixel_gen module into something that makes sense to the user. 

To keep things simple, the first module I worked on was the new pixel_gen. My goal was to get a static “AF” logo, paddle and ball to display. After implementing the test pattern from lab 1, this was fairly strait forward. The only difference now was that the location of the paddle and ball were also dependent on coordinate inputs to the pixel_gen module. The only trick part here was ensuring that the ball passed behind the “AF” logo on the screen. This was accomplished by simply using an if/elsif tree that starts with the “AF” logo. Because this is draw first, it draws the pieces of the “AF” logo over everything else. 

The next module I worked on was the top level atlys_lab_video. This is because I wanted to be able to test the functionality of my pong_control module. Without this top level set up, this would not be possible. Testing pong_control with the debugger would be far more complex than simply compiling and watching it run directly on the FPGA. Setting up atlys_lab_video was actual the easiest part of the lab. All that was different from lab 1 was the use of another component (the new pong_control module). Otherwise, I had already used the switches to switch between various test patterns for lab 1, so getting the new input signals from the FPGA buttons and switches was trivial.

The most time consuming and difficult module to implement was the game logic in pong_control. I ran into so many different problems that I was stuck for a long time (I will go over this more in testing and debugging). Overall I learned that the best way to output something out of the module or is to use a generic flip flop. For example, my code for outputting the vertical position for the paddle is as follows:

```vhdl
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
```
You will notice that there is a “paddle_y_next” that gets sent to the actual paddle position on the rising edge of the clock. Without this implementation for the variables I used, there were simply too many weird things going on for me to tell what was going on. I used the same implementation to control the position of the ball as well as the variables that control the direction the ball is moving. 

In order to overcome the high frequency of  v_completed signals coming into pong_control, I used a counter to only update the paddle position and ball position once every several hundred v_completeds depending on how fast I wanted things to go. This is where the “v_completed_count” comes from in the above code. The couter is actually very simple: 

```vhdl
process(clk, reset)
begin
	if reset = '1' then
		v_completed_count <= (others => '0');
	elsif rising_edge(clk) then
		v_completed_count <= v_completed_next;
	end if;
end process;
	 
v_completed_next <=	others => '0') when v_completed_count = 200 else--speed
					v_completed_count + 1 when v_completed = '1' else
					v_completed_count;

```

To deal with the game logic my code used a state machine. When I originally started I thought it would be easiest to implement the lab with only 3-4 states, but I eventually ditched this play to have many more. Basically, I have a state for every event that can happen:

```vhdl
type pong_state_type is
      (moving, hit_top, hit_bottom, hit_right, hit_paddle_top, hit_paddle_bottom, game_over);
```
This makes it very easy to use logic statements such as the following to generate the next state logic because there is a very specific task that must happen each of these states. (Also note how I added B functionality here using the "speed" input which was tied to a swith on the FPGA)

```vhdl
ball_x_next <= 	"00000100001" when reset = '1' else
	            ball_x_internal + speed_x_pos - speed_x_neg when v_completed_count_ball = 400 and speed = '0' and ball_next = moving else
                ball_x_internal + speed_x_pos - speed_x_neg when v_completed_count_ball = 600 and speed = '1' and ball_next = moving else							
				ball_x_next;
```

As you can see I have two variable speed_x_positive and speed_x_negative to control the direction the ball is moving. I did not want to use signed numbers because of type conversion issues, so this was the best way I could think of to have the ball move in 2 directions. Only one of these variable should ever be greater than zero. Whichever variable is greater than zero dictates the direction that the ball moves.  

For full implementation see the provided pong_control.vhd file. Although I did not go over every aspect, much of the logic is the same with just a few changed numbers. I did not provide screenshots of simulations or functionality because the quality would be very poor as I would have to take a picture of an LCD screen. A good example of what my display looks like with the game running can be found in the assignment for [lab 2] (http://ece383.com/labs/lab2/).

#Test/Debug
- The first issue I ran into was that for some reason my v_completed out of my vga_sync module must not have been working correctly according to simulations it was working fine, but my program was not performing as expected. When I downloaded the provided vga_sync module and used it instead of my own, everything started working as expected
- The next problem I had to overcome dealt with not using a rising edge flip flop and a “next” state to update my variables. Even when I did this with internal variables either the ball would not move or it would behave erratically. Switching to using flip flops for everything fixed any of the problems associated with this phenomenon.
- Another issue I dealt with was variable not behaving the way I expected them to. Sometimes the ball would be bouncing on the screen just fine and then it would jump to a random location or just disappear entirely. What I eventually found out was that this problem only arose when the v_completed_count I was waiting for to reset the count back to zero did not match the count my variable change was waiting for to increment the ball or paddle position. For example, If I reset the count every 500 v_completeds but only waited to update the call position after every 300 v_completeds then I saw this weird glitch. Otherwise it worked fine. It took me quite some time to realize this, however, because I cannot think of a logical reason why it should not work.

#Conclusion
This lab was time consuming but extremely rewarding and fun to implement. The VGA module was cool, but with this lab I actually found myself sitting an playing pong every once and a while when I should have been working on fixing glitches. I can honestly say I enjoyed myself.

The most difficult thing I had to overcome was the erratic behavior of the ball that arose from me not properly using “next” states and flip flops as well as the weird v_completed_count error when the number didn’t exactly match. This is what made the lab frustrating because I got stuck on trivial things for so long.

This is probably the most fun I have ever had on a programming project. Seeing my code work on an FPGA while displaying to an LCD was very satisfying. I can’t tell you how many times I had people come in my room wanting to try it. It was almost to distracting to actually get programming done.
 

