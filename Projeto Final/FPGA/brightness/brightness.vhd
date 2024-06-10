LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity brightness is
    generic (
        WIDTH: integer := 800;
        HEIGHT: integer := 600;
        COLOR_DEPTH := 24 integer
    );
    port (
        clock, reset: in bit;
        HL: in bit;
        done: out bit
     );
 end brightness;

architecture arch_brightness of brightness is

    component images_register is
        generic (
            WIDTH : integer := 800;
            HEIGHT : integer := 600;
            COLOR_DEPTH : integer := 12
        );
        port (
            clock : in std_logic;
            x, y : in integer;
            RW : in std_logic;
            address_offset : in std_logic_vector(19 downto 0);
            
            data : in std_logic_vector(COLOR_DEPTH-1 downto 0);
    
            pixel : out std_logic_vector(COLOR_DEPTH-1 downto 0)
        );
    end component;

    -- Sinais de conexão port map
    signal x, y : integer := 0;
    signal RW : std_logic;
    signal r_adress_offset, w_adress_offset : std_logic_vector(19 downto 0);
    signal r_data, w_data : std_logic_vector(COLOR_DEPTH-1 downto 0);
    signal r_pixel, w_pixel : std_logic_vector(COLOR_DEPTH-1 downto 0);

    -- Sinais de dados BGR
    signal B, G, R : std_logic_vector(3 downto 0);

    --Sinal de controle
    signal control : integer;
    signal start : bit := '0';

    type state is (idle, read_write, ended);
    signal filter_state : state;
    
    begin

        R_IMAGE: images_register generic map (WIDTH, HEIGHT, COLOR_DEPTH) port map (clock, x, y, '0', r_address_offset, r_data, r_pixel);
        W_IMAGE: images_register generic map (WIDTH, HEIGHT, COLOR_DEPTH) port map (clock, x, y, RW, w_address_offset, w_data, w_pixel);

        process (reset, clock) is
        begin

            if (reset = '1') then
                RW <= '0';
                r_address_offset <= 0;
                w_address_offset <= 0;

                done <= '0';
                filter_state <= idle;
            end if;

            elsif (rising_edge(clock)) then
                case filter_state is
                    when idle =>
                        if (start = '1') then
                            RW <= '1';
                            w_address_offset <= (WIDTH * HEIGHT) + 10;

                            x <= 0;
                            y <= 0;

                            filter_state <= read_write;
                        else 
                            RW <= '0';
                            r_address_offset <= 0;

                            x <= 0;
                            y <= 0;

                            done <= '0';
                            start <= '1';
                            filter_state <= idle;
                        end if;

                        when read_write => 
                            
                            if (x < WIDTH and y < HEIGHT - 1) then
                                
                                filter_state <= read_write

                                if(x = WIDTH) then
                                    x <= 0;
                                    y <= y + 1;
                                else
                                    x <= x + 1;
                                end if;

                                if (HL = '1' and r_pixel(11 downto 8) <= 11) then
                                    B <= conv_std_logic_vector((conv_integer(unsigned(r_pixel(11 downto 8))) + 4), B'length);
                                elsif (HL = '1' and r_pixel(11 downto 8) > 11) then
                                    B <= 15;
                                end if;

                                if (HL = '1' and r_pixel(7 downto 4) <= 11) then
                                    G <= conv_std_logic_vector((conv_integer(unsigned(r_pixel(7 downto 4))) + 4), G'length);
                                elsif (HL = '1' and r_pixel(7 downto 4) > 11) then
                                    G <= 15;
                                end if;

                                if (HL = '1' and r_pixel(3 downto 0) <= 11) then
                                    R <= conv_std_logic_vector((conv_integer(unsigned(r_pixel(3 downto 0))) + 4), R'length);
                                elsif (HL = '1' and r_pixel(3 downto 0) > 11) then
                                    R <= 15;
                                end if;

                                if (HL = '0' and r_pixel(11 downto 8) >= 4) then
                                    B <= conv_std_logic_vector((conv_integer(unsigned(r_pixel(11 downto 8))) - 4), B'length);
                                elsif (HL = '0' and r_pixel(11 downto 8) < 4) then
                                    B <= 0;
                                end if;

                                if (HL = '0' and r_pixel(7 downto 4) >= 4) then
                                    G <= conv_std_logic_vector((conv_integer(unsigned(r_pixel(7 downto 4))) - 4), G'length);
                                elsif (HL = '0' and r_pixel(7 downto 4) < 4) then
                                    G <= 0;
                                end if;

                                if (HL = '0' and r_pixel(3 downto 0) >= 4) then
                                    R <= conv_std_logic_vector((conv_integer(unsigned(r_pixel(3 downto 0))) - 4), R'length);
                                elsif (HL = '0' and r_pixel(3 downto 0) < 4) then
                                    R <= 0;
                                end if;

                                w_data <= B & G & R;
                        
                        else
                            
                            filter_state <= ended;

                        end if;

                            

                        when ended =>
                                start <= '0';
                                done <= '1';

                                filter_state <= idle
                            end if;
                        end case;
                    end if;
        end process;
end arch_brightness;