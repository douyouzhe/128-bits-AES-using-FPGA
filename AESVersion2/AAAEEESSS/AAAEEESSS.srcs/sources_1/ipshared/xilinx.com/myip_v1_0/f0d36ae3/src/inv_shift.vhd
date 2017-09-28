LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.ALL;

ENTITY inv_shift IS
PORT(
    d_in     :   IN  std_logic_vector(127 downto 0);
    d_out    :   OUT std_logic_vector(127 downto 0)
    );
END inv_shift;

ARCHITECTURE beh OF inv_shift IS

TYPE block_index IS array (15 downto 0) OF std_logic_vector(7 downto 0);
SIGNAL matrix1, matrix2 : block_index;

BEGIN

vector_to_matrix2: PROCESS(d_in)
BEGIN
    FOR i IN 15 downto 0 LOOP
	matrix2(15-i) <= d_in(8*i+7 downto 8*i);
    END LOOP;
END PROCESS vector_to_matrix2;

matrix1(0)  <=  matrix2(0);
matrix1(5)  <=  matrix2(1) ;
matrix1(10) <=  matrix2(2) ;
matrix1(15) <=  matrix2(3) ;
matrix1(4)  <=  matrix2(4);
matrix1(9)  <=  matrix2(5);  
matrix1(14) <=  matrix2(6);    
matrix1(3)  <=  matrix2(7);    
matrix1(8)  <=  matrix2(8);    
matrix1(13) <=  matrix2(9);    
matrix1(2)  <=  matrix2(10);   
matrix1(7)  <=  matrix2(11);   
matrix1(12) <=  matrix2(12);  
matrix1(1)  <=  matrix2(13);  
matrix1(6)  <=  matrix2(14);  
matrix1(11) <=  matrix2(15);  

matrix1_to_vector: PROCESS(matrix1)
BEGIN
    FOR i IN 15 downto 0 LOOP
	d_out(8*i+7 DOWNTO 8*i) <= matrix1(15-i);
    END LOOP;
END PROCESS matrix1_to_vector;

END beh;		