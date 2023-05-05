
	-- Add your library and packages declaration here ...

entity multiply_struct_tb is
end multiply_struct_tb;

architecture TB_ARCHITECTURE of multiply_struct_tb is
	-- Component declaration of the tested unit
	component multiply_struct
	port(
		A : in BIT_VECTOR(1 downto 0);
		B : in BIT_VECTOR(1 downto 0);
		P : buffer BIT_VECTOR(3 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal A : BIT_VECTOR(1 downto 0);
	signal B : BIT_VECTOR(1 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal P : BIT_VECTOR(3 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : multiply_struct
		port map (
			A => A,
			B => B,
			P => P
		);

	-- Add your stimulus here ...
	Force:process
constant period: time := 20 ns;
begin
A <= "00";
B <= "00";
wait for period;

A <= "00";
B <= "01";
wait for period;

A <= "00";
B <= "10";
wait for period;

A <= "00";
B <= "11";
wait for period;

A <= "01";
B <= "00";
wait for period;

A <= "01";
B <= "01";
wait for period;

A <= "01";
B <= "10";
wait for period;

A <= "01";
B <= "11";
wait for period;

A <= "10";
B <= "00";
wait for period;

A <= "10";
B <= "01";
wait for period;

A <= "10";
B <= "10";
wait for period;

A <= "10";
B <= "11";
wait for period;

A <= "11";
B <= "00";
wait for period;

A <= "11";
B <= "01";
wait for period;

A <= "11";
B <= "10";
wait for period;

A <= "11";
B <= "11";
wait for period;
wait;
end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_multiply_struct of multiply_struct_tb is
	for TB_ARCHITECTURE
		for UUT : multiply_struct
			use entity work.multiply_struct(structural);
		end for;
	end for;
end TESTBENCH_FOR_multiply_struct;

