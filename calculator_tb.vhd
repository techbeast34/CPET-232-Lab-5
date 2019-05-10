--*****************************************************************************
--***************************  VHDL Source Code  ******************************
--*********  Copyright 2011, Rochester Institute of Technology  ***************
--*****************************************************************************
--
--  DESIGNER NAME:  Jeanne Christman
--
--       LAB NAME:  Calculator
--
--      FILE NAME:  calculator_tb.vhd
--
-------------------------------------------------------------------------------
--
--  DESCRIPTION
--
--    This test bench will provide input to test a four function calculator.
--    The calculator function will accept two 4-bit numbers and a 2-bit selection
--    signal that will enable the operations in the table below. The outputs R
--    is the 8 bit result. 
--
--    _______________________________________________________________________
--    | OP signal | Operation        |
--    ================================   
--    |   00      |  Addition        |
--    |   01      |  Subtraction     |
--    |   10      |  Multiplication  |
--    |   11      |  Division        |
-------------------------------------------------------------------------------
--
--  REVISION HISTORY
--
--  _______________________________________________________________________
-- |  DATE    | USER | Ver |  Description                                  |
-- |==========+======+=====+================================================
-- |          |      |     |
-- | 9/19/17  | JWC  | 1.0 | Created

--
--*****************************************************************************
--*****************************************************************************

LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;            


ENTITY calculator_tb IS
END ENTITY calculator_tb;

ARCHITECTURE test OF calculator_tb IS

--the component name MUST match the entity name of the VHDL module being tested   
    COMPONENT Lab5 is
    Port ( a    : 		in   STD_LOGIC_VECTOR(3 downto 0);      --A input
           b    : 		in   STD_LOGIC_VECTOR(3 downto 0);      --B input
           op   : 	  in   STD_LOGIC_VECTOR(1 downto 0);                                   
           r    : 	  out  STD_LOGIC_VECTOR(7 downto 0));                                       
    end COMPONENT;


    -- testbench signals.  These do not need to be modified
    SIGNAL a_tb          : std_logic_vector(3 DOWNTO 0);
    SIGNAL b_tb          : std_logic_vector(3 DOWNTO 0);
    SIGNAL op_tb        : std_logic_vector(1 downto 0);
    --
    SIGNAL R_tb          : std_logic_vector(7 DOWNTO 0);
    SIGNAL test_signed_8b : SIGNED(7 DOWNTO 0);
--========================================================================================
    -- this is a function used in the self check feature
    -- converts a std_logic_vector into a hex string. Taken from txt_util package. Package obtained from http://www.stefanvhdl.com/
     function hstr(slv: std_logic_vector) return string is
       variable hexlen: integer;
       variable longslv : std_logic_vector(67 downto 0) := (others => '0');
       variable hex : string(1 to 16);
       variable fourbit : std_logic_vector(3 downto 0);
     begin
       hexlen := (slv'left+1)/4;
       if (slv'left+1) mod 4 /= 0 then
         hexlen := hexlen + 1;
       end if;
       longslv(slv'left downto 0) := slv;
       for i in (hexlen -1) downto 0 loop
         fourbit := longslv(((i*4)+3) downto (i*4));
         case fourbit is
           when "0000" => hex(hexlen -I) := '0';
           when "0001" => hex(hexlen -I) := '1';
           when "0010" => hex(hexlen -I) := '2';
           when "0011" => hex(hexlen -I) := '3';
           when "0100" => hex(hexlen -I) := '4';
           when "0101" => hex(hexlen -I) := '5';
           when "0110" => hex(hexlen -I) := '6';
           when "0111" => hex(hexlen -I) := '7';
           when "1000" => hex(hexlen -I) := '8';
           when "1001" => hex(hexlen -I) := '9';
           when "1010" => hex(hexlen -I) := 'A';
           when "1011" => hex(hexlen -I) := 'B';
           when "1100" => hex(hexlen -I) := 'C';
           when "1101" => hex(hexlen -I) := 'D';
           when "1110" => hex(hexlen -I) := 'E';
           when "1111" => hex(hexlen -I) := 'F';
           when "ZZZZ" => hex(hexlen -I) := 'z';
           when "UUUU" => hex(hexlen -I) := 'u';
           when "XXXX" => hex(hexlen -I) := 'x';
           when others => hex(hexlen -I) := '?';
         end case;
       end loop;
       return hex(1 to hexlen);
     end hstr;
--========================================================================================
   
BEGIN
--this must match component above
    UUT : Lab5 PORT MAP (  
        a => a_tb,
        b => b_tb,
        op => op_tb,
        r => R_tb
        );

    ---------------------------------------------------------------------------
    -- NAME: Stimulus
    --
    -- DESCRIPTION:
    --    This process will apply the stimulus to the UUT
    ---------------------------------------------------------------------------
    stimulus : PROCESS
      VARIABLE temp_slv_8b : STD_LOGIC_VECTOR(7 DOWNTO 0);
      VARIABLE temp_signed_8b : SIGNED(7 DOWNTO 0);
      VARIABLE temp_unsigned_8b : UNSIGNED(7 DOWNTO 0);
    BEGIN
      FOR k in 0 to 3 Loop
        op_tb <= std_logic_vector(to_unsigned(k,2));
        FOR i IN 0 TO 15 LOOP
          a_tb <= std_logic_vector(to_unsigned(i,4));        
              FOR j IN 0 TO 15 LOOP
                if (k = 3) and (j = 0) then  --skip over divide by zero
                  next;
                else 
                  b_tb <= std_logic_vector(to_unsigned(j,4));
                end if;

              WAIT FOR 10 ns;
              
--========================================================================================
--              THIS IS THE SELF TEST SECTION
--======================================================================================== 
              Case k is
        
               WHEN 0 =>
                  temp_signed_8b := resize(SIGNED(a_tb),r_tb'LENGTH) + resize(SIGNED(b_tb),r_tb'LENGTH);
                  ASSERT r_tb = std_logic_vector(temp_signed_8b)
                   REPORT "Sum operation failed. "&LF&
                           "A="&integer'image(to_integer(signed(a_tb)))&", B="&integer'image(to_integer(signed(b_tb)))&", R="&integer'image(to_integer(signed(r_tb)))&LF&
                           "Result should be "& integer'image(to_integer(temp_signed_8b))
                      SEVERITY error;
                WHEN 1 =>
                    temp_signed_8b := resize(SIGNED(a_tb),r_tb'LENGTH) - resize(SIGNED(b_tb),r_tb'LENGTH);
                    ASSERT r_tb = std_logic_vector(temp_signed_8b)
                     REPORT "Subtraction operation failed. "&LF&
                            "A="&integer'image(to_integer(signed(a_tb)))&", B="&integer'image(to_integer(signed(b_tb)))&", R="&integer'image(to_integer(signed(r_tb)))&LF&
                            "Result should be "& integer'image(to_integer(temp_signed_8b))
                       SEVERITY error;
                WHEN 2 =>
                  temp_signed_8b := resize(SIGNED(a_tb) * SIGNED(b_tb),r_tb'LENGTH);
                  ASSERT r_tb = std_logic_vector(temp_signed_8b)
                    REPORT "Multiply operation failed. "&LF&
                           "A="&integer'image(to_integer(signed(a_tb)))&", B="&integer'image(to_integer(signed(b_tb)))&", R="&integer'image(to_integer(signed(r_tb)))&LF&
                           "Result should be "& integer'image(to_integer(temp_signed_8b))
                      SEVERITY error;
                WHEN 3 =>
                  temp_signed_8b := resize(SIGNED(a_tb),r_tb'LENGTH) / resize(SIGNED(b_tb),r_tb'LENGTH);
                  ASSERT r_tb = std_logic_vector(temp_signed_8b)
                    REPORT "Division operation failed. "&LF&
                           "A="&integer'image(to_integer(signed(a_tb)))&", B="&integer'image(to_integer(signed(b_tb)))&", R="&integer'image(to_integer(signed(r_tb)))&LF&
                           "Result should be "& integer'image(to_integer(temp_signed_8b))
                      SEVERITY error;

                WHEN OTHERS => NULL;
              END CASE;
              test_signed_8b <= temp_signed_8b;
--==========================================================================================
            END LOOP;
          END LOOP;
        END LOOP;
        
        
         REPORT LF&"Simulation Completed" Severity Note;
        -- -----------------------------------------------------------------------
        -- -- This last WAIT statement needs to be here to prevent the PROCESS
        -- -- sequence from restarting.
        -- -----------------------------------------------------------------------
        WAIT;
    END PROCESS stimulus;


END test;
