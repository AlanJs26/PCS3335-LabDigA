library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;
use ieee.NUMERIC_STD_UNSIGNED.all;

entity contrast is
    generic (
        WIDTH: integer := 800;
        HEIGHT: integer := 600;
        COLOR_DEPTH: integer := 24
    );
    port (
        clock, reset: in bit;
        HL: in bit;
        done: out bit
     );
 end contrast;

architecture arch_contrast of contrast is

    component images_register is
        generic (
            WIDTH : integer := 800;
            HEIGHT : integer := 600;
            COLOR_DEPTH : integer := 24
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
    signal B, G, R : std_logic_vector(7 downto 0);

    --Sinal de controle
    signal control : integer;
    signal start : bit := '0';

    type state is (idle, read_write, calculate_delta, ended);
    signal filter_state : state;
    
    begin

        R_IMAGE: images_register generic map (WIDTH, HEIGHT, COLOR_DEPTH) port map (clock, x, y, '0', r_address_offset, r_data, r_pixel);
        W_IMAGE: images_register generic map (WIDTH, HEIGHT, COLOR_DEPTH) port map (clock, x, y, RW, w_address_offset, w_data, w_pixel);


        process (reset, clock) is
        begin

            if (reset = '1') then
                RW <= '0';
                r_address_offset <= 0;

                done <= '0';
                filter_state <= idle;
            end if;

            elsif (rising_edge(clock)) then
                case filter_state is
                    when idle =>
                        if (start = '1') then
                            RW <= '1';
                            w_address_offset <= (WIDTH * HEIGHT) + 10;

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

                            for i in 0 to (HEIGHT - 1) loop
                                for j in 0 to (WIDTH - 1) loop
                                x <= i;
                                y <= j;

                                if (HL = '1' and r_pixel(23 downto 16) <= 127 and r_pixel(23 downto 16) >= 64) then
                                    B <= r_pixel(23 downto 16) + 3*(r_pixel(23 downto 16) - 128) + 128;
                                elsif (HL = '1' and r_pixel(23 downto 16) > 127) then
                                    B <= 255;
                                elsif (HL = '1' and r_pixel(23 downto 16) < 64) then
                                    B <= 0;
                                end if;

                                if (HL = '1' and r_pixel(15 downto 8) <= 127 and r_pixel(15 downto 8) >= 64) then
                                    G <= r_pixel(15 downto 8) + 3*(r_pixel(15 downto 8) - 128) + 128;
                                elsif (HL = '1' and r_pixel(15 downto 8) > 127) then
                                    G <= 255;
                                elsif (HL = '1' and r_pixel(15 downto 8) < 64) then
                                    G <= 0;
                                end if;

                                if (HL = '1' and r_pixel(7 downto 0) <= 127 and r_pixel(7 downto 0) >= 64) then
                                    R <= r_pixel(7 downto 0) + 3*(r_pixel(7 downto 0) - 128) + 128;
                                elsif (HL = '1' and r_pixel(7 downto 0) > 127) then
                                    R <= 255;
                                elsif (HL = '1' and r_pixel(7 downto 0) < 64) then
                                    R <= 0;
                                end if;

                                if (HL = '0' and r_pixel(23 downto 16) <= 127) then
                                    B <= r_pixel(23 downto 16) + ((r_pixel(23 downto 16) - 128)/3) + 128;
                                elsif (HL = '1' and r_pixel(23 downto 16) > 127) then
                                    B <= 255;
                                end if;

                                if (HL = '0' and r_pixel(15 downto 8) <= 127) then
                                    G <= r_pixel(15 downto 8) + ((r_pixel(15 downto 8) - 128)/3) + 128;
                                elsif (HL = '1' and r_pixel(15 downto 8) > 127) then
                                    G <= 255;
                                end if;

                                if (HL = '0' and r_pixel(7 downto 0) <= 127) then
                                    R <= r_pixel(7 downto 0) + ((r_pixel(7 downto 0) - 128)/3) + 128;
                                elsif (HL = '1' and r_pixel(7 downto 0) > 127) then
                                    R <= 255;
                                end if;
                            
                                w_data <= B & G & R;

                            end loop;

                            if (x = HEIGHT - 1 and y = WIDTH - 1) then
                                RW <= '0';
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
end arch_contrast;