--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the game logic for the snake physics etc.
--              
-- Assisted by:
--
-- Anthonix
-- 
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


use work.gamelogic_pkg.all;

entity corner_logic is
  port(
  gamelogic_state   : in  gamelogic_state_t;
    address_a_corner : out unsigned(12 downto 0);
    corner_write_data   : out unsigned(15 downto 0);
    corner_done     : out std_logic;
	 next_cell : in unsigned(12 downto 0);
	 old_direction_in : in unsigned(2 downto 0);
	 current_direction_in : in unsigned(2 downto 0)
    );
end corner_logic;

architecture Behavioral of corner_logic is


  signal snake_character : unsigned(8 downto 0);
 
  
begin
  
  address_a_corner <= next_cell;
  
p_update_character : process (gamelogic_state, current_direction_in, snake_character, old_direction_in)
begin
   if (gamelogic_state = CORNER) then
	if ((current_direction_in = "001") and (old_direction_in = "010")) or ((current_direction_in ="100") and (old_direction_in = "011")) then
	 snake_character <= to_unsigned(5*8, snake_character'length);
	 elsif ((current_direction_in = "010") and (old_direction_in = "011")) or ((current_direction_in ="001") and (old_direction_in = "100")) then
	 snake_character <= to_unsigned(4*8, snake_character'length);
	 	 elsif ((current_direction_in = "010") and (old_direction_in = "001")) or ((current_direction_in ="011") and (old_direction_in = "100")) then
	 snake_character <= to_unsigned(6*8, snake_character'length);
	 	 elsif ((current_direction_in = "011") and (old_direction_in = "010")) or ((current_direction_in ="100") and (old_direction_in = "001")) then
	 snake_character <= to_unsigned(7*8, snake_character'length);
	 end if;
	 
	corner_write_data <= "0000" & current_direction_in & snake_character;
	corner_done <= '1';
 else
 corner_done <= '0';	
 end if;
end process p_update_character;


    end Behavioral;