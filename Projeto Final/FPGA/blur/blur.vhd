LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity blur is
    generic (
        WIDTH: integer := 800,
        HEIGHT: integer := 600,
        COLOR_DEPTH := 12 integer
    );
    port (
        clock, reset: in bit;
        HL: in bit;
        done: out bit
     );
 end blur;

 architecture arch_blur of blur is
    
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
    signal x_1, x_2, x_3, x_4, x_5, x_6, x_7, x_8, x_9, y_1, y_2, y_3, y_4, y_5, y_6, y_7, xy8, y_9 : integer := 0;
    signal RW : std_logic;
    signal r_adress_offset, w_adress_offset : std_logic_vector(19 downto 0);
    signal r_data, w_data : std_logic_vector(COLOR_DEPTH-1 downto 0);
    signal r_pixel, w_pixel : std_logic_vector(COLOR_DEPTH-1 downto 0);

    -- Sinais de dados BGR
    signal B, G, R : std_logic_vector(3 downto 0);
    signal B_1, G_1, R_1 : std_logic_vector(3 downto 0);
    signal B_2, G_2, R_2 : std_logic_vector(3 downto 0);
    signal B_3, G_3, R_3 : std_logic_vector(3 downto 0);
    signal B_4, G_4, R_4 : std_logic_vector(3 downto 0);
    signal B_5, G_5, R_5 : std_logic_vector(3 downto 0);
    signal B_6, G_6, R_6 : std_logic_vector(3 downto 0);
    signal B_7, G_7, R_7 : std_logic_vector(3 downto 0);
    signal B_8, G_8, R_8 : std_logic_vector(3 downto 0);
    signal B_9, G_9, R_9 : std_logic_vector(3 downto 0);

    --Sinal de controle
    signal control : integer;
    signal start : bit := '0';

    type state is (idle, read_1, read_2, read_3, read_4, read_5, read_6, read_7, read_8, read_9, average, write, deactivate, ended);
    signal filter_state : state;

    begin

        R_IMAGE: images_register generic map (WIDTH, HEIGHT, COLOR_DEPTH) port map (clock, x, y, RW, r_address_offset, r_data, r_pixel);

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
                            RW <= '0';
                            r_address_offset <= 0;

                            x_1 <= 0; y_1 <= 0;
                            x_2 <= 1; y_2 <= 0;
                            x_3 <= 2; y_3 <= 0;
                            x_4 <= 0; y_4 <= 1;
                            x_5 <= 1; y_5 <= 1;
                            x_6 <= 2; y_6 <= 1;
                            x_7 <= 0; y_7 <= 2;
                            x_8 <= 1; y_8 <= 2;
                            x_9 <= 2; y_9 <= 2;
                            
                            x <= x_1; y <= y_1

                            filter_state <= read_1;
                        else 
                            RW <= '0';
                            r_address_offset <= 0;

                            x_1 <= 0; y_1 <= 0;
                            x_2 <= 1; y_2 <= 0;
                            x_3 <= 2; y_3 <= 0;
                            x_4 <= 0; y_4 <= 1;
                            x_5 <= 1; y_5 <= 1;
                            x_6 <= 2; y_6 <= 1;
                            x_7 <= 0; y_7 <= 2;
                            x_8 <= 1; y_8 <= 2;
                            x_9 <= 2; y_9 <= 2;

                            x <= x_1; y <= y_1

                            done <= '0';
                            start <= '1';
                            filter_state <= idle;
                        end if;

                    when read_1 => 

                        if(x_1 = WIDTH - 3) then
                            x_1 <= 0;
                            y_1 <= y_1 + 1;
                        else
                            x_1 <= x_1 + 1;
                        end if;

                        B_1 <= r_pixel(11 downto 8);
                        G_1 <= r_pixel(7 downto 4);
                        R_1 <= r_pixel(3 downto 0);

                        x <= x_2; y <= y_2;
                        filter_state <= read_2;
                        
                    when read_2 => 

                        if(x_2 = WIDTH - 2) then
                            x_2 <= 1;
                            y_2 <= y_2 + 1;
                        else
                            x_2 <= x_2 + 1;
                        end if;

                        B_2 <= r_pixel(11 downto 8);
                        G_2 <= r_pixel(7 downto 4);
                        R_2 <= r_pixel(3 downto 0);

                        x <= x_3; y <= y_3;
                        filter_state <= read_3;

                    when read_3 => 

                        if(x_3 = WIDTH - 1) then
                            x_3 <= 2;
                            y_3 <= y_3 + 1;
                        else
                            x_3 <= x_3 + 1;
                        end if;
    
                        B_3 <= r_pixel(11 downto 8);
                        G_3 <= r_pixel(7 downto 4);
                        R_3 <= r_pixel(3 downto 0);
    
                        x <= x_4; y <= y_4;
                        filter_state <= read_4;

                    when read_4 => 

                        if(x_4 = WIDTH - 3) then
                            x_4 <= 0;
                            y_4 <= y_4 + 1;
                        else
                            x_4 <= x_4 + 1;
                        end if;
    
                        B_4 <= r_pixel(11 downto 8);
                        G_4 <= r_pixel(7 downto 4);
                        R_4 <= r_pixel(3 downto 0);
    
                        x <= x_5; y <= y_5;
                        filter_state <= read_5;
                        
                    when read_5 => 

                        if(x_5 = WIDTH - 1) then
                            x_5 <= 1;
                            y_5 <= y_5 + 1;
                        else
                            x_5 <= x_5 + 1;
                        end if;
    
                        B_5 <= r_pixel(11 downto 8);
                        G_5 <= r_pixel(7 downto 4);
                        R_5 <= r_pixel(3 downto 0);
    
                        x <= x_6; y <= y_6;
                        filter_state <= read_6;

                    when read_6 => 

                        if(x_6 = WIDTH - 1) then
                            x_6 <= 2;
                            y_6 <= y_6 + 1;
                        else
                            x_6 <= x_6 + 1;
                        end if;
    
                        B_6 <= r_pixel(11 downto 8);
                        G_6 <= r_pixel(7 downto 4);
                        R_6 <= r_pixel(3 downto 0);
    
                        x <= x_7; y <= y_7;
                        filter_state <= read_7;
                        
                    when read_7 => 

                        if(x_7 = WIDTH - 1) then
                            x_7 <= 0;
                            y_7 <= y_7 + 1;
                        else
                            x_7 <= x_7 + 1;
                        end if;
    
                        B_7 <= r_pixel(11 downto 8);
                        G_7 <= r_pixel(7 downto 4);
                        R_7 <= r_pixel(3 downto 0);
    
                        x <= x_8; y <= y_8;
                        filter_state <= read_8;

                    when read_8 => 

                        if(x_8 = WIDTH - 1) then
                            x_8 <= 1;
                            y_8 <= y_8 + 1;
                        else
                            x_8 <= x_8 + 1;
                        end if;
    
                        B_8 <= r_pixel(11 downto 8);
                        G_8 <= r_pixel(7 downto 4);
                        R_8 <= r_pixel(3 downto 0);
    
                        x <= x_9; y <= y_9;
                        filter_state <= read_9;

                    when read_9 => 

                        if(x_3 = WIDTH - 1) then
                            x_3 <= 2;
                            y_3 <= y_2 + 1;
                        else
                            x_3 <= x_3 + 1;
                        end if;
    
                        B_9 <= r_pixel(11 downto 8);
                        G_9 <= r_pixel(7 downto 4);
                        R_9 <= r_pixel(3 downto 0);

                        x <= x_5; y <= y_5;
                        filter_state <= average;

                    when average => 

                        B <= conv_std_logic_vector((conv_integer(unsigned(B_1)) + conv_integer(unsigned(B_2)) + conv_integer(unsigned(B_3)) 
                                                    + conv_integer(unsigned(B_4)) + conv_integer(unsigned(B_5)) + conv_integer(unsigned(B_6))
                                                    + conv_integer(unsigned(B_7)) + conv_integer(unsigned(B_8)) + conv_integer(unsigned(B_9)))/9);
                        
                        G <= conv_std_logic_vector((conv_integer(unsigned(G_1)) + conv_integer(unsigned(G_2)) + conv_integer(unsigned(G_3)) 
                                                    + conv_integer(unsigned(G_4)) + conv_integer(unsigned(G_5)) + conv_integer(unsigned(G_6))
                                                    + conv_integer(unsigned(G_7)) + conv_integer(unsigned(G_8)) + conv_integer(unsigned(G_9)))/9);
                        
                        R <= conv_std_logic_vector((conv_integer(unsigned(R_1)) + conv_integer(unsigned(R_2)) + conv_integer(unsigned(R_3)) 
                                                    + conv_integer(unsigned(R_4)) + conv_integer(unsigned(R_5)) + conv_integer(unsigned(R_6))
                                                    + conv_integer(unsigned(R_7)) + conv_integer(unsigned(R_8)) + conv_integer(unsigned(R_9)))/9);
                          
                        filter_state <= write;

                    when write =>
                        
                        RW <= '1';
                        r_address_offset <= (WIDTH * HEIGHT) + 10; 
                        r_data <= B & G & R;

                        filter_state <= deactivate;
                      

                    when deactivate =>
                        
                        RW <= '0';
                        r_address_offset <= 0; 

                        if (x_5 = WIDTH - 2 and y_5 = HEIGHT - 2) then 
                            filter_state <= ended;
                        else
                            filter_state <= read_1;
                        end if;
                    
                  
                    when ended =>
                        start <= '0';
                        done <= '1';

                        filter_state <= idle
                end case;
            end if  
    end process;
end arch_blur;
          