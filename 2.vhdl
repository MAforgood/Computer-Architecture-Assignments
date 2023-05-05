library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity multiplier is
    port (
        a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        product : out std_logic_vector(63 downto 0)
    );
end entity;

architecture behavioral of multiplier is 
begin
    process(a,b)
	variable V_Product :std_logic_vector( 63 downto 0) := (others=>'0'); 
	variable V_Multiplier : std_logic_vector(31 downto 0):=(others=>'0');
    begin
		--V_Multiplier := a;
		--V_Product(31 downto 0):=b(31 downto 0);
        if b(31)='1' then
           V_Product(31 downto 0):= not(b(31 downto 0))+'1';
		   else V_Product(31downto 0):=b;
        end if;
        if a(31)='1' then
            V_multiplier:=not(a)+'1';
		else 
			   V_Multiplier:=a;
        end if;
        --temp <= (others => '0');
		--product<=std_logic_vector(temp) & b;
        for i in 0 to 31 loop
			--V_product := product(63 downto 32);
            if b(i) = '1' then
                --temp <= temp + a;
				V_product(63 downto 32) := V_product(63 downto 32)+V_Multiplier(31 downto 0);
				--product<=std_logic_vector(temp) & b; 
				--product<='0'& V_product(31 downto 0) & product(31 downto 1);
			--else
			--	   product<='0'& V_product(31 downto 0) & product(31 downto 1);
            end if;
			V_Product:='0' & V_Product(63 downto 1);
        end loop;
		if((a(31)xor b(31))='1')then
    		product<=not(V_Product)+1	;
		else 
			product<=V_Product;
		end if;						   
          
    end process; 
end architecture;  




library ieee;
use ieee.std_logic_1164.all;

entity multiplier_tb is
end entity;

architecture testbench of multiplier_tb is
    component multiplier is
        port (
            a : in std_logic_vector(31 downto 0);
            b : in std_logic_vector(31 downto 0);
            product : inout std_logic_vector(63 downto 0)
        );
    end component;
    
    signal a : std_logic_vector(31 downto 0);
    signal b : std_logic_vector(31 downto 0);
    signal product : std_logic_vector(63 downto 0);
    
    constant CLOCK_PERIOD : time := 100 ns;
begin
    uut : multiplier
        port map (
            a => a,
            b => b,
            product => product
        );
    
    stim_proc : process
    begin
        -- Test 1: Multiplying 2 and 4
        a <= (others=> '1');
        b <= x"00000001";
        wait for CLOCK_PERIOD;
        assert product /= x"00000008" report "Test 1 failed" severity error;
       
		  a <= x"00000001";
    	  b <= x"00000001";
    wait for 100 ns;
    assert product /= x"00000001"
      report "Test 2 failed" severity error;
       
        
        -- Test 3: Multiplying 0 and 10
        a <= x"00000000";
        b <= x"0000000A";
        wait for CLOCK_PERIOD;
        assert product /= x"00000000" report "Test 3 failed" severity error;
        
        -- Test 4: Multiplying 7 and 14
        a <= x"00000007";
        b <= x"0000000E";
        wait for CLOCK_PERIOD;
        assert product /= x"0000005E" report "Test 4 failed" severity error;
        
        wait;
    end process;
end architecture;




