library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_Queue is
    generic (
        BUFFER_SIZE : integer := 16;  -- Total number of elements in the FIFO
        DATA_SIZE   : integer := 8    -- Size of each data element in bits
    );
    port (
        clk     : in  std_logic;               -- Clock input
        reset   : in  std_logic;               -- Reset input
        enqueue : in  std_logic;               -- Enqueue control input
        dequeue : in  std_logic;               -- Dequeue control input
        data_in : in  std_logic_vector(DATA_SIZE - 1 downto 0);  -- Data input
        data_out: out std_logic_vector(DATA_SIZE - 1 downto 0);  -- Data output
        queue_size : out integer range 0 to BUFFER_SIZE;          -- Queue size output
        queue_empty: out std_logic;                               -- Queue empty output
        queue_full : out std_logic                                -- Queue full output
    );
end FIFO_Queue;

architecture behavioral of FIFO_Queue is
    type fifo_mem is array (0 to BUFFER_SIZE - 1) of std_logic_vector(DATA_SIZE - 1 downto 0);
    signal queue : fifo_mem;
    signal read_ptr  : integer range 0 to BUFFER_SIZE - 1 := 0;
    signal write_ptr : integer range 0 to BUFFER_SIZE - 1 := 0;
    signal size      : integer range 0 to BUFFER_SIZE   := 0;
begin
    process (clk, reset)
    begin
        if reset = '1' then  -- Reset the queue
            read_ptr  <= 0;
            write_ptr <= 0;
            size      <= 0;
        elsif rising_edge(clk) then
            -- Update read pointer and size when dequeuing
            if dequeue = '1' then
                if size > 0 then
                    read_ptr <= (read_ptr + 1) mod BUFFER_SIZE;
                    size     <= size - 1;
                end if;
            end if;
            
            -- Update write pointer and size when enqueueing
            if enqueue = '1' then
                if size < BUFFER_SIZE then
                    queue(write_ptr) <= data_in;
                    write_ptr <= (write_ptr + 1) mod BUFFER_SIZE;
                    size      <= size + 1;
                end if;
            end if;
        end if;
    end process;

    -- Output signals
    queue_size <= size;
    queue_empty <= '1' when size = 0 else '0';
    queue_full <= '1' when size = BUFFER_SIZE else '0';
    data_out <= queue(read_ptr);
end behavioral;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_queue_tb is
	-- Generic declarations of the tested unit
	generic (
		BUFFER_SIZE : INTEGER := 16;
		DATA_SIZE   : INTEGER := 8
	);
end fifo_queue_tb;

architecture TB_ARCHITECTURE of fifo_queue_tb is
	-- Component declaration of the tested unit
	component fifo_queue
		generic (
			BUFFER_SIZE : INTEGER := 16;
			DATA_SIZE   : INTEGER := 8
		);
		port (
			clk         : in  STD_LOGIC;
			reset       : in  STD_LOGIC;
			enqueue     : in  STD_LOGIC;
			dequeue     : in  STD_LOGIC;
			data_in     : in  STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
			data_out    : out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
			queue_size  : out INTEGER range 0 to BUFFER_SIZE;
			queue_empty : out STD_LOGIC;
			queue_full  : out STD_LOGIC
		);
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of the tested entity
	signal clk       : STD_LOGIC := '0';
	signal reset     : STD_LOGIC := '0';
	signal enqueue   : STD_LOGIC := '0';
	signal dequeue   : STD_LOGIC := '0';
	signal data_in   : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0) := (others => '0');
	-- Observed signals - signals mapped to the output ports of the tested entity
	signal data_out  : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
	signal queue_size: INTEGER range 0 to BUFFER_SIZE;
	signal queue_empty: STD_LOGIC;
	signal queue_full : STD_LOGIC;

begin

	-- Unit Under Test port map
	UUT : fifo_queue
		generic map (
			BUFFER_SIZE => BUFFER_SIZE,
			DATA_SIZE   => DATA_SIZE
		)
		port map (
			clk         => clk,
			reset       => reset,
			enqueue     => enqueue,
			dequeue     => dequeue,
			data_in     => data_in,
			data_out    => data_out,
			queue_size  => queue_size,
			queue_empty => queue_empty,
			queue_full  => queue_full
		);

	-- Clock process
	process
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process;

	-- Stimulus process
	process
	begin
		reset <= '1';
		enqueue <= '0';
		dequeue <= '0';
		data_in <= (others => '0');
		wait for 10 ns;
		reset <= '0';

		-- Enqueue data
		for i in 0 to 9 loop
			enqueue <= '1';
			data_in <= std_logic_vector(to_unsigned(i, DATA_SIZE));
			wait for 10 ns;
		end loop;

		-- Dequeue data
		for i in 0 to 4 loop
			dequeue <= '1';
			wait for 10 ns;
		end loop;

		wait for 10 ns;
		enqueue <= '0';
		dequeue <= '0';
		wait;
	end process;

	-- Assertion for queue size
	assert queue_size <= BUFFER_SIZE
		report "Queue size exceeds buffer size"
		severity error;

	

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_fifo_queue of fifo_queue_tb is
	for TB_ARCHITECTURE
		for UUT : fifo_queue
			use entity work.fifo_queue(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_fifo_queue;
