--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the game logic for the snake physics etc.
--              
-- 
-- 
-- Dependencies: VRAM
-- 
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

entity check_logic is
  port(
    gamelogic_state       : in  gamelogic_state_t;
    clk_slow              : in  std_logic;
    ext_reset             : in  std_logic;
    address_a_check       : out unsigned(12 downto 0);
    check_read_data       : in  unsigned(11 downto 0);
    check_done            : out std_logic;
    keyboard              : in  unsigned(2 downto 0);
    crashed               : out std_logic;
    nochange              : out std_logic;
    current_direction_out : out unsigned(2 downto 0);
    old_direction_out     : out unsigned(2 downto 0);
    next_cell             : out unsigned(12 downto 0);
    corner_cell           : out unsigned(12 downto 0)
    );
end check_logic;

architecture Behavioral of check_logic is

  signal current_direction_int : unsigned(2 downto 0)  := "001";
  signal next_direction        : unsigned(2 downto 0)  := "001";
  signal current_cell          : unsigned(12 downto 0) := to_unsigned(2440, 13);
  signal next_cell_int         : unsigned(12 downto 0) := to_unsigned(2360, 13);
  signal corner_cell_int       : unsigned(12 downto 0) := (others => '0');
  signal checking              : unsigned(2 downto 0)  := (others => '0');
  signal old_direction_out_int : unsigned(2 downto 0)  := "001";
  signal address_a_check_int   : unsigned(12 downto 0) := to_unsigned(2360, 13);
  signal nochange_int          : std_logic             := '1';
  signal crashed_int           : std_logic             := '0';

  
begin
  
  old_direction_out     <= old_direction_out_int;
  current_direction_out <= current_direction_int;
  address_a_check       <= address_a_check_int;
  nochange              <= nochange_int;
  crashed               <= crashed_int;
  corner_cell           <= corner_cell_int;

  next_direction <= keyboard;
  next_cell      <= next_cell_int;


  --purpose: checks if the snake has crashed into a border or itself
  --type   : sequential
  --inputs : clk25, ext_reset, state, next_direction, output_a_int, crash_result_ready
  --outputs: crash_test, crashed
  p_collision_checker : process (clk_slow, ext_reset)
  begin  -- process p_collision_checker
    if (ext_reset = '1') then           --  asynchronous reset (active high)
      crashed_int           <= '0';
      check_done            <= '0';
      nochange_int          <= '1';
      checking              <= "000";
      current_cell          <= to_unsigned(2440, current_cell'length);
      current_direction_int <= "001";   -- reset to moving up
      next_cell_int         <= to_unsigned(2360, next_cell_int'length);
      old_direction_out_int <= "001";
      corner_cell_int       <= (others => '0');
    elsif (clk_slow'event and clk_slow = '1') then
      if (gamelogic_state = CHECK) then
        if (checking = "000") then
          check_done <= '0';
          checking   <= "001";

          if (crashed_int = '1') then
            crashed_int           <= '0';
            current_cell          <= to_unsigned(2440, current_cell'length);
            current_direction_int <= "001";  -- reset to moving up
            next_cell_int         <= to_unsigned(2360, next_cell_int'length);
            old_direction_out_int <= "001";
          else
            if (current_direction_int /= next_direction) then
              nochange_int          <= '0';
              old_direction_out_int <= current_direction_int;
              corner_cell_int       <= current_cell;
            else
              nochange_int <= '1';
            end if;
            if (next_direction = "001") then
              next_cell_int <= to_unsigned(to_integer(current_cell) - 80, next_cell_int'length);
            elsif (next_direction = "010") then
              next_cell_int <= to_unsigned(to_integer(current_cell) + 1, next_cell_int'length);
            elsif (next_direction = "011") then
              next_cell_int <= to_unsigned(to_integer(current_cell) + 80, next_cell_int'length);
            elsif (next_direction = "100") then
              next_cell_int <= to_unsigned(to_integer(current_cell) - 1, next_cell_int'length);
            end if;
          end if;
          

        elsif (checking = "001") then
          current_direction_int <= next_direction;
          checking              <= "010";
          address_a_check_int   <= next_cell_int;
          current_cell          <= next_cell_int;
        elsif (checking = "010") then
          checking <= "011";
          if (nochange_int = '1') then
            if (to_integer(check_read_data) = 0) then
              crashed_int <= '0';
            else
              crashed_int <= '1';
            end if;
          end if;
        elsif (checking = "011") then
          checking   <= "000";
          check_done <= '1';
        end if;
      else
        check_done <= '0';
        checking   <= "000";
      end if;
    end if;
  end process p_collision_checker;



end Behavioral;
