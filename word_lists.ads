-- Work carried out by Luis Fernández Jiménez

with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Characters.Handling;
with Ada.Unchecked_Deallocation;

package Word_Lists is

    package ASU renames Ada.Strings.Unbounded;
--Extension 2 --> misma palabra con letras en mayusculas y/o minusculas
    package ACH renames Ada.Characters.Handling;

    type Cell;
    type Word_List_Type is access Cell;
    type Cell is record
        
        Word: ASU.Unbounded_String;
        Count: Natural := 0;
        Next: Word_List_Type;

    end record;

    Word_List_Error: exception;

    procedure Add_Word (List: in out Word_List_Type;
                        Word: in ASU.Unbounded_String);

    procedure Delete_Word (List: in out Word_List_Type;
                           Word: in ASU.Unbounded_String);

    procedure Search_Word (List: in Word_List_Type;
                           Word: in ASU.Unbounded_String;
                           Count: out Natural);

    procedure Max_Word (List: in Word_List_Type;
                        Word: out ASU.Unbounded_String;
                        Count: out Natural);

    procedure Print_All (List: in Word_List_Type);
--Extension 3 --> Liberar memoria ocupada por la lista al finalizar    
    procedure Delete_List (List: in out Word_List_Type);

end Word_Lists;
