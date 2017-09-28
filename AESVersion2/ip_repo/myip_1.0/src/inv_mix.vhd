LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.ALL;

ENTITY inv_mix IS
PORT(
    d_in     :   IN  std_logic_vector(127 downto 0);
    d_out    :   OUT std_logic_vector(127 downto 0)
    );
END inv_mix ;

ARCHITECTURE beh OF inv_mix IS
    
TYPE matrix_index is array (15 downto 0) of std_logic_vector(7 downto 0); 
TYPE shift_index is array (15 downto 0) of std_logic_vector(8 downto 0); 
SIGNAL matrix, matrix_out, multby_0e, multby_0b,multby_0d,multby_09 : matrix_index;


BEGIN

input_to_matrix:PROCESS(d_in)
BEGIN
    FOR i IN 15 DOWNTO 0 LOOP
	matrix(15-i) <= d_in(8*i+7 downto 8*i);
    END LOOP;
END PROCESS input_to_matrix;

multiply_matrix_by0e:PROCESS(matrix)

   VARIABLE value1,value2,value3 : std_logic_vector(8 downto 0);
BEGIN

    FOR i IN  15 downto 0 LOOP
	value1  := matrix(i) & '0';	
	IF (value1(8)='1') THEN	-- for values exceeding 7 bit field, XOR it with the irreducible vector given in the spec
	   value1(7 downto 0) :=  value1(7 downto 0) XOR "00011011";
	END IF;

     value2 :=value1(7 downto 0) & '0';
    IF (value2(8)='1') THEN
 	    value2(7 downto 0) := value2(7 downto 0) XOR "00011011";
	END IF;
     
     value3:= value2(7 downto 0) & '0';
    IF (value3(8)='1') THEN
 	    value3(7 downto 0) := value3(7 downto 0) XOR "00011011";
	END IF;

    multby_0e(i) <= value1(7 downto 0) XOR value2(7 downto 0) XOR value3(7 downto 0);
    END LOOP;
END PROCESS multiply_matrix_by0e;

-- first multiply by b 
multiply_matrix_by0b:PROCESS(matrix)

    VARIABLE value1, value2, value3 : std_logic_vector(8 downto 0); 
BEGIN

    FOR i IN  15 downto 0 LOOP
	value1  := matrix(i) & '0';	
	IF (value1(8)='1') THEN	-- for values exceeding 7 bit field, XOR it with the irreducible vector given in the spec
	   value1(7 downto 0) :=  value1(7 downto 0) XOR "00011011";
	END IF;

     value2 :=value1(7 downto 0) & '0';
    IF (value2(8)='1') THEN
 	    value2(7 downto 0) := value2(7 downto 0) XOR "00011011";
	END IF;
     
     value3 :=  value2(7 downto 0) & '0';
    IF (value3(8)='1') THEN
 	    value3(7 downto 0) := value3(7 downto 0) XOR "00011011";
	END IF;
     
    multby_0b(i) <= matrix(i) XOR value1(7 downto 0) XOR value3(7 downto 0);
    END LOOP;
END PROCESS multiply_matrix_by0b;

-- first multiply by 0d 
multiply_matrix_by0d:PROCESS(matrix)

    VARIABLE value1, value2, value3 : std_logic_vector(8 downto 0);
BEGIN

    FOR i IN  15 downto 0 LOOP
	value1  := matrix(i) & '0';	
	IF (value1(8)='1') THEN	-- for values exceeding 7 bit field, XOR it with the irreducible vector given in the spec
	   value1(7 downto 0) :=  value1(7 downto 0) XOR "00011011";
	END IF;

     value2 :=value1(7 downto 0) & '0';
    IF (value2(8)='1') THEN
 	    value2(7 downto 0) := value2(7 downto 0) XOR "00011011";
	END IF;
     
     value3 :=  value2(7 downto 0) & '0';
    IF (value3(8)='1') THEN
 	    value3(7 downto 0) := value3(7 downto 0) XOR "00011011";
	END IF;

    multby_0d(i) <= matrix(i) XOR value2(7 downto 0) XOR value3(7 downto 0);
    END LOOP;
END PROCESS multiply_matrix_by0d;

-- first multiply by 9 
multiply_matrix_by09:PROCESS(matrix)

    VARIABLE value1, value2, value3 : std_logic_vector(8 downto 0);
BEGIN

    FOR i IN  15 downto 0 LOOP
	value1  := matrix(i) & '0';	
	IF (value1(8)='1') THEN	-- for values exceeding 7 bit field, XOR it with the irreducible vector given in the spec
	   value1(7 downto 0) :=  value1(7 downto 0) XOR "00011011";
	END IF;

     value2 :=value1(7 downto 0) & '0';
    IF (value2(8)='1') THEN
 	    value2(7 downto 0) := value2(7 downto 0) XOR "00011011";
	END IF;
     
     value3:= value2(7 downto 0) & '0';
    IF (value3(8)='1') THEN
 	    value3(7 downto 0) := value3(7 downto 0) XOR "00011011";
	END IF;

    multby_09(i) <= matrix(i) XOR value3(7 downto 0);
    END LOOP;
END PROCESS multiply_matrix_by09;

-- 4X4 matrix multiplication & mix column
--row one
matrix_out(0)  <= multby_0e(0)  XOR multby_0b(1)  XOR multby_0d(2)  XOR multby_09(3);
matrix_out(4)  <= multby_0e(4)  XOR multby_0b(5)  XOR multby_0d(6)  XOR multby_09(7);
matrix_out(8)  <= multby_0e(8)  XOR multby_0b(9)  XOR multby_0d(10) XOR multby_09(11);
matrix_out(12) <= multby_0e(12) XOR multby_0b(13) XOR multby_0d(14) XOR multby_09(15);
--row two
matrix_out(1)  <= multby_09(0)  XOR multby_0e(1)  XOR multby_0b(2)  XOR multby_0d(3); 
matrix_out(5)  <= multby_09(4)  XOR multby_0e(5)  XOR multby_0b(6)  XOR multby_0d(7); 
matrix_out(9)  <= multby_09(8)  XOR multby_0e(9)  XOR multby_0b(10) XOR multby_0d(11); 
matrix_out(13) <= multby_09(12) XOR multby_0e(13) XOR multby_0b(14) XOR multby_0d(15); 
--row three
matrix_out(2)  <= multby_0d(0)  XOR multby_09(1)  XOR multby_0e(2)  XOR multby_0b(3);
matrix_out(6)  <= multby_0d(4)  XOR multby_09(5)  XOR multby_0e(6)  XOR multby_0b(7);
matrix_out(10) <= multby_0d(8)  XOR multby_09(9)  XOR multby_0e(10) XOR multby_0b(11);
matrix_out(14) <= multby_0d(12) XOR multby_09(13) XOR multby_0e(14) XOR multby_0b(15);
--row four
matrix_out(3)  <= multby_0b(0)  XOR multby_0d(1)  XOR multby_09(2)  XOR multby_0e(3);
matrix_out(7)  <= multby_0b(4)  XOR multby_0d(5)  XOR multby_09(6)  XOR multby_0e(7);
matrix_out(11) <= multby_0b(8)  XOR multby_0d(9)  XOR multby_09(10) XOR multby_0e(11);
matrix_out(15) <= multby_0b(12) XOR multby_0d(13) XOR multby_09(14) XOR multby_0e(15);

--mapping back to a vector

matrix_to_vector:PROCESS(matrix_out)
BEGIN
    FOR i IN 15 downto 0 LOOP
	d_out(8*i+7 downto 8*i) <= matrix_out(15-i);
    END LOOP;
END PROCESS matrix_to_vector;

END beh;	