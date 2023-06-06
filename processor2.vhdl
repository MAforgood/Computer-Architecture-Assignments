library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eight_bit_processor is
    port (
        clk : in std_logic;
        rst : in std_logic;
        instruction : in std_logic_vector(7 downto 0);
        data_in : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        result : out std_logic_vector(7 downto 0)
    );
end entity eight_bit_processor;

architecture behavioral of eight_bit_processor is
    signal pc : unsigned(15 downto 0);
    signal r1 : unsigned(7 downto 0);
    signal r2 : unsigned(7 downto 0);
    signal temp : unsigned(7 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc <= (others => '0');
                r1 <= (others => '0');
                r2 <= (others => '0');
            else
                case instruction is
                    when "00000000" =>  -- ADD
                        temp <= r1 + r2;
                    when "00000001" =>  -- SUB
                        temp <= r1 - r2;
                    when "00000010" =>  -- AND
                        temp <= r1 and r2;
                    when "00000011" =>  -- OR
                        temp <= r1 or r2;
                    when others =>
                        temp <= (others => '0');
                end case;
                r1 <= temp;
                pc <= pc + 1;
            end if;
        end if;
    end process;

    result <= std_logic_vector(temp);
    data_out <= std_logic_vector(r1);

end architecture behavioral;
