LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity part1_6 is
    port(
        clock  : in std_logic;
        w      : in std_logic;
        reset  : in std_logic;
        z      : out std_logic;
        state   : out std_logic_vector(8 downto 0)  -- Output for state
    );
end part1_6;

architecture behavior of part1_6 is

    type State_type is (A, B, C, D, E, F, G, H, I);
    signal y_Q, Y_D : State_type;

begin

    -- Process for state transition
    process(w, y_Q)
    begin
        case y_Q is
            when A =>
                state <= "000000001";
                z <= '0';
                if (w = '0') then
                    Y_D <= B;  -- Go to B
                else
                    Y_D <= F;  -- Go to F
                end if;

            when B =>
                state <= "000000010";
                z <= '0';
                if (w = '0') then
                    Y_D <= C;
                else
                    Y_D <= F;
                end if;

            when C =>
                state <= "000000100";
                z <= '0';
                if (w = '0') then
                    Y_D <= D;
                else
                    Y_D <= F;
                end if;

            when D =>
                state <= "000001000";
                z <= '0';
                if (w = '0') then
                    Y_D <= E;
                else
                    Y_D <= F;
                end if;

            when E =>
                state <= "000010000";
                z <= '1';  -- z is high in state E
                if (w = '0') then
                    Y_D <= E;  -- Stay in E
                else
                    Y_D <= F;
                end if;

            when F =>
                state <= "000100000";
                z <= '0';
                if (w = '1') then
                    Y_D <= G;  -- Go to G
                else
                    Y_D <= B;  -- Go back to B
                end if;

            when G =>
                state <= "001000000";
                z <= '0';
                if (w = '1') then
                    Y_D <= H;
                else
                    Y_D <= B;
                end if;

            when H =>
                state <= "010000000";
                z <= '0';
                if (w = '1') then
                    Y_D <= I;
                else
                    Y_D <= B;
                end if;

            when I =>
                state <= "100000000";
                z <= '1';  -- z is high in state I
                if (w = '1') then
                    Y_D <= I;  -- Stay in I
                else
                    Y_D <= B;
                end if;

            when others =>
                Y_D <= A;  -- Default state
        end case;
    end process;

    -- Process for updating state on clock edge
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                y_Q <= A;  -- Reset to state A
            else
                y_Q <= Y_D;  -- Update to next state
            end if;
        end if;
    end process;

    -- Output assignments
    -- Removed direct assignment to z from here

end behavior;
