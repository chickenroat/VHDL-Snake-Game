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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.gamelogic_pkg.all;

entity reset_logic is
  port(
    gamelogic_state  : in  gamelogic_state_t;
    clk25            : in  std_logic;
    ext_reset        : in  std_logic;
    address_a_reset  : out unsigned(12 downto 0);
    reset_write_data : out unsigned(11 downto 0);
    reset_done       : out std_logic;
    keyboard         : in  unsigned(2 downto 0)
    );
end reset_logic;

architecture Behavioral of reset_logic is


  signal reset_done_int       : std_logic             := '0';
  signal reset_write_done_int : std_logic             := '0';
  signal reset_write_data_int : unsigned(11 downto 0) := (others => '0');
  signal address_a_reset_int  : unsigned(12 downto 0) := (others => '0');

  type   reset_state_t is (IDLE, RESET, WAITING);
  signal reset_state : reset_state_t := IDLE;
  
begin

  reset_done       <= reset_done_int;
  reset_write_data <= reset_write_data_int;
  address_a_reset  <= address_a_reset_int;

  p_reset_state : process (clk25, ext_reset)
    variable ramcnt_i : integer;
    variable ramcnt_j : integer;
  begin
    
    if (ext_reset = '1') then           --asynchronous reset (active high)
      reset_done_int       <= '0';
      reset_write_done_int <= '0';
      address_a_reset_int  <= (others => '0');
      reset_write_data_int <= (others => '0');
      reset_state          <= IDLE;
    elsif clk25'event and clk25 = '1' then
      if (gamelogic_state = RESET) then
        if (reset_state = IDLE) then
          reset_state          <= RESET;
          reset_write_data_int <= (others => '0');
          ramcnt_i             := ramcnt_i + 1;
          if (ramcnt_i = 80) then
            ramcnt_j := ramcnt_j + 1;
            ramcnt_i := 0;
            if (ramcnt_j = 55) then
              reset_write_done_int <= '1';
              ramcnt_i             := 0;
              ramcnt_j             := 0;
            end if;
          elsif (ramcnt_i > 0) and (ramcnt_i < 79) and (ramcnt_j > 0) and (ramcnt_j < 55) then
            address_a_reset_int  <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a_reset_int'length);
            reset_write_data_int <= (others => '0');
          else
            address_a_reset_int  <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a_reset_int'length);
            reset_write_data_int <= to_unsigned(8, reset_write_data_int'length);
          end if;
        elsif (reset_state = RESET) and (reset_write_done_int = '1') then
          reset_state <= WAITING;
        elsif (reset_state = WAITING) then
          if (keyboard = "111") then
            reset_state    <= IDLE;
            reset_done_int <= '1';
          end if;
        end if;
      else
        reset_done_int       <= '0';
        reset_write_done_int <= '0';
        reset_state          <= IDLE;
      end if;
    end if;
  end process p_reset_state;





end Behavioral;
