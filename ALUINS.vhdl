library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    generic (
        BUFFER_SIZE : integer := 16;  -- Total number of elements in the FIFO
        DATA_SIZE   : integer := 8    -- Size of each data element in bits
    );
    port (
        clk       : in  std_logic;               -- Clock input
        reset     : in  std_logic;               -- Reset input
        enqueue   : in  std_logic;               -- Enqueue control input
        dequeue   : in  std_logic;               -- Dequeue control input
        data_in   : in  std_logic_vector(DATA_SIZE - 1 downto 0);  -- Data input
        instruction: in  std_logic_vector(1 downto 0);             -- Instruction input
        data_out  : out std_logic_vector(DATA_SIZE - 1 downto 0);  -- Data output
        queue_size: out integer range 0 to BUFFER_SIZE;             -- Queue size output
        queue_empty: out std_logic;                                 -- Queue empty output
        queue_full: out std_logic                                   -- Queue full output
    );
end ALU;

architecture behavioral of ALU is
    type fifo_mem is array (0 to BUFFER_SIZE - 1) of std_logic_vector(DATA_SIZE - 1 downto 0);
    signal queue : fifo_mem;
    signal read_ptr  : integer range 0 to BUFFER_SIZE - 1 := 0;
    signal write_ptr : integer range 0 to BUFFER_SIZE - 1 := 0;
    signal size      : integer range 0 to BUFFER_SIZE   := 0;
    signal data_buffer : std_logic_vector(DATA_SIZE - 1 downto 0);
begin
    process (clk, reset)
    begin
        if reset = '1' then  -- Reset the ALU and the queue
            read_ptr  <= 0;
            write_ptr <= 0;
            size      <= 0;
            data_buffer <= (others => '0');
        elsif rising_edge(clk) then
            -- Update read pointer and size when dequeuing
            if dequeue = '1' then
                if size > 0 then
                    read_ptr <= (read_ptr + 1) mod BUFFER_SIZE;
                    size     <= size - 1;
                end if;
            end if;

            -- Update write pointer, size, and enqueue data when enqueueing
            if enqueue = '1' then
                if size < BUFFER_SIZE then
                    queue(write_ptr) <= data_in;
                    write_ptr <= (write_ptr + 1) mod BUFFER_SIZE;
                    size      <= size + 1;
                end if;
            end if;
            
            -- ALU operations based on the instruction
            if size > 0 then
                case instruction is
                    when "00" =>  -- Srl (Shift Right Logical)
                        data_buffer <= queue(read_ptr)(DATA_SIZE - 2 downto 0) & '0';
                    when "01" =>  -- Sll (Shift Left Logical)
                        data_buffer <= '0' & queue(read_ptr)(DATA_SIZE - 1 downto 1);
                    when "10" =>  -- Xor
                        data_buffer <= queue(read_ptr) xor data_buffer;
                    when "11" =>  -- And
                        data_buffer <= queue(read_ptr) and data_buffer;
                    when others =>  -- Invalid instruction
                        data_buffer <= (others => '0');
                end case;
            else
                data_buffer <= (others => '0');
            end if;
        end if;
    end process;

    -- Output signals
    queue_size <= size;
    queue_empty <= '1' when size = 0 else '0';
    queue_full <= '1' when size = BUFFER_SIZE else '0';
    data_out <= data_buffer;
end behavioral;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
    generic (
        BUFFER_SIZE : INTEGER := 16;
        DATA_SIZE : INTEGER := 8
    );
end alu_tb;

architecture TB_ARCHITECTURE of alu_tb is
    component alu is
        generic (
            BUFFER_SIZE : INTEGER := 16;
            DATA_SIZE : INTEGER := 8
        );
        port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            enqueue : in STD_LOGIC;
            dequeue : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
            instruction : in STD_LOGIC_VECTOR(1 downto 0);
            data_out : out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
            queue_size : out INTEGER range 0 to BUFFER_SIZE;
            queue_empty : out STD_LOGIC;
            queue_full : out STD_LOGIC
        );
    end component;

    signal clk : STD_LOGIC;
    signal reset : STD_LOGIC;
    signal enqueue : STD_LOGIC;
    signal dequeue : STD_LOGIC;
    signal data_in : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal instruction : STD_LOGIC_VECTOR(1 downto 0);
    signal data_out : STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
    signal queue_size : INTEGER range 0 to BUFFER_SIZE;
    signal queue_empty : STD_LOGIC;
    signal queue_full : STD_LOGIC;

begin
    UUT : alu
        generic map (
            BUFFER_SIZE => BUFFER_SIZE,
            DATA_SIZE => DATA_SIZE
        )
        port map (
            clk => clk,
            reset => reset,
            enqueue => enqueue,
            dequeue => dequeue,
            data_in => data_in,
            instruction => instruction,
            data_out => data_out,
            queue_size => queue_size,
            queue_empty => queue_empty,
            queue_full => queue_full
        );

    clk_process: process
    begin
        while now < 100 ns loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process clk_process;

    reset_process: process
    begin
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        wait;
    end process reset_process;

    stimulus_process: process
    begin
        wait for 20 ns;

        -- Enqueue data and instructions
        enqueue <= '1';
        data_in <= "11001100";     -- Example data
        instruction <= "00";       -- Srl instruction
        wait for 10 ns;
      
        enqueue <= '1';
        data_in <= "10101010";     -- Example data
        instruction <= "01";       -- Sll instruction
        wait for 10 ns;

        -- Dequeue data and instructions
        dequeue <= '1';
        wait for 10 ns;

        -- Verify the results
        assert data_out = "00011001"
            report "Srl operation result does not match expected value"
            severity error;
      
        assert data_out = "01010100"
            report "Sll operation result does not match expected value"
            severity error;

        wait;
    end process stimulus_process;
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_alu of alu_tb is
    for TB_ARCHITECTURE
        for UUT : alu
            use entity work.alu(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_alu;
