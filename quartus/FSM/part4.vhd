LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

entity part4 is
    Port (
        clock   : in std_logic;
        reset   : in std_logic;        -- Asynchronous reset
        start   : in std_logic;        -- Start signal (KEY1)
        letter  : in std_logic_vector(2 downto 0);  -- SW2-0 for letter selection
        led     : out std_logic        -- Output for LED
    );
end part4;

architecture behavior of part4 is

    type state_type is (IDLE, INIT, DOT, DASH, PAUSE);
    signal current_state, next_state : state_type;

    signal pulse_counter : integer := 0;          -- Counter for timing
    signal morse_seq     : std_logic_vector(3 downto 0); -- Morse code for letters A to H
    signal position_counter : integer := 0;       -- Tracks the current bit position in morse_seq
    signal seq_length    : integer := 0;          -- Length of the Morse sequence for the letter

    constant DOT_LENGTH : integer := 25000000;    -- 0.5 seconds (25000000 clock cycles)
    constant DASH_LENGTH : integer := 75000000;   -- 1.5 seconds (75000000 clock cycles)
    constant PAUSE_LENGTH : integer := 25000000;  -- 0.5 seconds pause

    -- Function to retrieve Morse code pattern
    function get_morse_seq(letter : std_logic_vector(2 downto 0)) return std_logic_vector is
    begin
        case letter is
            when "000" => return "0100"; -- A: .-
            when "001" => return "1000"; -- B: -...
            when "010" => return "1010"; -- C: -.-.
            when "011" => return "1000"; -- D: -..
            when "100" => return "0001"; -- E: .
            when "101" => return "0010"; -- F: ..-.
            when "110" => return "1100"; -- G: --.
            when "111" => return "0000"; -- H: ....
            when others => return "0000"; -- Default
        end case;
    end get_morse_seq;

    -- Function to retrieve the length of the Morse code sequence
    function get_seq_length(letter : std_logic_vector(2 downto 0)) return integer is
    begin
        case letter is
            when "000" => return 2; -- A: .-
            when "001" => return 4; -- B: -...
            when "010" => return 4; -- C: -.-.
            when "011" => return 3; -- D: -..
            when "100" => return 1; -- E: .
            when "101" => return 4; -- F: ..-.
            when "110" => return 3; -- G: --.
            when "111" => return 4; -- H: ....
            when others => return 0; -- Default
        end case;
    end get_seq_length;

begin

    -- State transition and output logic
    process(clock, reset)
    begin
        if reset = '0' then
            current_state <= IDLE;
            pulse_counter <= 0;
            led <= '0';
            morse_seq <= "0000";
            position_counter <= 0;
            seq_length <= 0;
				
        elsif rising_edge(clock) then
            case current_state is
                when IDLE =>
                    led <= '0';  -- LED off
                    if start = '0' then
                        morse_seq <= get_morse_seq(letter);  -- Carregar sequência Morse
                        seq_length <= get_seq_length(letter);  -- Carregar comprimento da sequência
                        position_counter <= 0;  -- Resetar contador de posição
                        pulse_counter <= 0;  -- Resetar contador de pulsos
                        current_state <= INIT; -- Ir para o estado INIT para sincronizar a sequência
                    end if;

                when INIT =>
                    -- Estado de inicialização que lê o primeiro bit de `morse_seq`
                    if morse_seq(3) = '1' then
                        current_state <= DASH;
                    else
                        current_state <= DOT;
                    end if;

                when DOT =>
                    led <= '1';  -- LED ligado para ponto
                    if pulse_counter < DOT_LENGTH then
                        pulse_counter <= pulse_counter + 1;
                    else
                        pulse_counter <= 0;  -- Reset do contador
                        position_counter <= position_counter + 1;  -- Avança para a próxima posição
                        current_state <= PAUSE;  -- Vai para a pausa após ponto
                    end if;

                when DASH =>
                    led <= '1';  -- LED ligado para traço
                    if pulse_counter < DASH_LENGTH then
                        pulse_counter <= pulse_counter + 1;
                    else
                        pulse_counter <= 0;
                        position_counter <= position_counter + 1;
                        current_state <= PAUSE;  -- Vai para a pausa após traço
                    end if;

                when PAUSE =>
                    led <= '0';  -- LED desligado durante a pausa
                    if pulse_counter < PAUSE_LENGTH then
                        pulse_counter <= pulse_counter + 1;  -- Conta até atingir o tempo da pausa
                    else
                        pulse_counter <= 0;  -- Reset do contador
                        if position_counter < seq_length then
                            -- Verifica o próximo bit na sequência Morse
                            if morse_seq(3 - position_counter) = '1' then
                                current_state <= DASH;
                            else
                                current_state <= DOT;
                            end if;
                        else
                            current_state <= IDLE;  -- Sequência completa
                        end if;
                    end if;

                when others =>
                    current_state <= IDLE;  -- Estado padrão
            end case;
        end if;
    end process;

end behavior;
