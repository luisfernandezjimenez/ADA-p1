-- Work carried out by Luis Fernández Jiménez

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Word_Lists;
with Ada.Strings.Maps;
with Ada.Characters.Handling;

procedure Words is

    package ASU renames Ada.Strings.Unbounded;
    package ACL renames Ada.Command_Line;
    package WL renames Word_Lists;
    package ACH renames Ada.Characters.Handling;
-------------------------------------------------------------------------------
-- OBTENCIÓN Y AGREGACIÓN DE PALABRAS DEL FICHERO A LA LISTA  
-------------------------------------------------------------------------------
    procedure Read_Fich (Pointer: in out WL.Word_List_Type; 
                         List: in WL.Word_List_Type;
                         End_of_Program : in out Boolean) is
        
        Fich_Name: ASU.Unbounded_String;
        Fich: Ada.Text_IO.File_Type;
   		Finish_Fich: Boolean := False;
   		Finish_Line: Boolean := False;
   		Line: ASU.Unbounded_String;
   		Word: ASU.Unbounded_String;
		Word_Size: Natural := 0; 
		
    begin
-- nombre del fichero siempre es el ultimo argumento
        Fich_Name := ASU.To_Unbounded_String(ACL.Argument(ACL.Argument_Count));        
        Ada.Text_IO.Open(Fich, Ada.Text_IO.In_File, ASU.To_String(Fich_Name));

        while not Finish_Fich loop
            
            begin
                
                Line := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line(Fich));
                Finish_Line := False;
          
                while not Finish_Line loop
                    
                    begin
                        
                        Pointer := List;
--Extension 1 --> Separadores de palabras caracteres no alfanuméricos
                        Word_Size := ASU.Index(Line, Ada.Strings.Maps.To_Set
		             (" ªº\!¡'·$%&/()=?¿^*¨`+´[]{}_-.:,;><|@#~¬" & """"));
--Cuando lo primero es un caractere no deseado
				        if Word_Size = 1 then 
--Nos quedamos con lo siguiente al espacio
				            Line := ASU.Tail (Line, ASU.Length(Line)-Word_Size);
--Cuando no hay mas caracteres no desdeados, la palabra es lo que queda de linea
			            elsif Word_Size = 0 then
--Evitamos guardar strings vacios 						 
					        if ASU.To_String(Line) /= "" then 

					            Word := Line;
						        WL.Add_Word(Pointer, Word);
					
					        end if;
							
					        Finish_Line := True;
					
				        else --Forma una palabra y guarda como linea el resto

					        Word := ASU.Head (Line, Word_Size - 1);
					        Line := ASU.Tail (Line, ASU.Length(Line)-Word_Size);
			
					        if ASU.To_String(Word) /= "" then
			
					        	WL.Add_Word(Pointer, Word);
					            
					        end if;							
			
				        end if;
                        
                    exception
                    
                        when Ada.IO_Exceptions.End_Error =>
                            
                            Finish_Line := True;

                    end;    

                end loop;
                
                exception
                    
                    when Ada.IO_Exceptions.End_Error =>
                        
                        Finish_Fich := True;
        
                end;
                
            end loop;

        Ada.Text_IO.Close(Fich);

    exception
    
        when Ada.IO_Exceptions.Name_Error =>
    
            Ada.Text_IO.New_Line(1);
            Ada.Text_IO.Put_Line(ASU.To_String(Fich_Name) & ": file not found");
            End_of_Program := True; -- se detiene el programa
    
    end Read_Fich;
--------------------------------------------------------------------------------
-- PROCEDIMIENTOS DEL MENU INTERACTIVO 
--------------------------------------------------------------------------------	
	procedure Add_Word (Pointer: in out WL.Word_List_Type; 
                        List: in out  WL.Word_List_Type) is
	
	    New_Word: ASU.Unbounded_String;
	
	begin
        
        Ada.Text_IO.New_Line(1);
        Ada.Text_IO.Put("Word? ");
        New_Word := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
        
        WL.Add_Word(Pointer, New_Word);
        Pointer := List;
        
        Ada.Text_IO.Put_Line("Word |" & ASU.To_String(New_Word) & "| added.");
	
--al borrar todas las palabras de la lista y se intenta añadir palabra
	exception
    
        when Constraint_Error =>
            
            List := new WL.Cell;
            Pointer := List;
            WL.Add_Word(Pointer, New_Word);
            Ada.Text_IO.Put_Line("Word |" & ASU.To_String(New_Word) & "| added.");
            
	end Add_Word;
	
	procedure Delete_Word (Pointer: in out WL.Word_List_Type; 
                           List: in out WL.Word_List_Type) is
	
	    Deleted_Word: ASU.Unbounded_String;
	
	begin
        
        Ada.Text_IO.New_Line(1);
        Ada.Text_IO.Put("Word? ");
        Deleted_Word := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
--Si la palabra a eliminar es la primera de la lista        
        if ACH.To_Lower(ASU.To_String(Deleted_Word)) = 
           ASU.To_String(List.all.Word) then
--Elimina lista y apuntamos List a la siguiente lista que sera la primera ahora            
            WL.Delete_Word(Pointer, Deleted_Word);
            List := Pointer;
            
        else
--Cualquier otro caso se elimina la lista y ponemos el puntero a nuestra primera lista         
            WL.Delete_Word(Pointer, Deleted_Word);
            Pointer := List;
	    
	    end if;
	    
	    Ada.Text_IO.Put_Line("Word |" & 
	                         ACH.To_Lower(ASU.To_String(Deleted_Word)) &                                          
                             "| deleted.");
	    
	exception
	        
        when WL.Word_List_Error | Constraint_Error =>

            Ada.Text_IO.Put_Line("Word |" & 
            ACH.To_Lower(ASU.To_String(Deleted_Word)) & 
            "| not stored in the list");
	        
	end Delete_Word;
	
	procedure Search_Word (Pointer: in out WL.Word_List_Type;
	                       Count: in out Natural) is
	
	    Searched_Word: ASU.Unbounded_String;
	
	begin
        
        Ada.Text_IO.New_Line(1);
        Ada.Text_IO.Put("Word? ");
        Searched_Word := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
        
        WL.Search_Word(Pointer, Searched_Word, Count);
        
        Ada.Text_IO.Put_Line("|" & (ASU.To_String(Searched_Word)) & "| -" & 
                             Natural'Image(Count));
	
--al borrar todas las palabras de la lista, si se intenta buscar palabra
	exception
    
        when Constraint_Error =>

            Ada.Text_IO.Put_Line("|" & (ASU.To_String(Searched_Word)) & "| -" & 
	                                     Natural'Image(Count));
            
	end Search_Word;
	
	procedure Max_Word (Pointer: in out WL.Word_List_Type;
                        Word: in out ASU.Unbounded_String;
                        Count: in out Natural) is
	
	begin
        
        WL.Max_Word(Pointer, Word, Count);
        
        Ada.Text_IO.New_Line(1);
        Ada.Text_IO.Put_Line("The most frequent word is: |" & 
				             (ASU.To_String(Word)) & "| -" & 
				             Natural'Image(Count));

    exception
	    
	    when WL.Word_List_Error =>
	    
	    	Ada.Text_IO.New_Line(1);
	    	Ada.Text_IO.Put_Line("Empty list. No words.");
	        
	end Max_Word;
--------------------------------------------------------------------------------
-- MENU INTERACTIVO
--------------------------------------------------------------------------------
	procedure Interactive_Menu (Pointer: in out WL.Word_List_Type;
	                            List: in out WL.Word_List_Type;
	                            Word: in out ASU.Unbounded_String;
	                            Count: in out Natural) is
	    
	    Option: Natural range 1..5 := 1;

	begin
	
	    while Option /= 5 loop
	        
	        begin
            
                Ada.Text_IO.New_Line(1);
	            Ada.Text_IO.Put_Line("Options: ");
	            Ada.Text_IO.Put_Line("1 Add Word");
	            Ada.Text_IO.Put_Line("2 Delete Word");
	            Ada.Text_IO.Put_Line("3 Search Word");
	            Ada.Text_IO.Put_Line("4 Show all words");
	            Ada.Text_IO.Put_Line("5 Quit");
	            Ada.Text_IO.New_Line(1);
	            Ada.Text_IO.Put("Your option? ");
		            
	            Option := Natural'Value(Ada.Text_IO.Get_Line);
	            
	            case Option is
	            
	                when 1 =>
	                
                        Add_Word (Pointer, List);
	                
	                when 2 =>
	                
	                    Delete_Word (Pointer, List);
	                
	                when 3 =>
	                
	                    Search_Word (Pointer, Count);
	                
	                when 4 =>
	                
	                    WL.Print_All (Pointer);
	                
	                when 5 =>
	                    
	                    Max_Word(Pointer, Word, Count);
	               
                end case;
	            
            exception
    
                when Constraint_Error =>
    
                    Ada.Text_IO.New_Line(1);
                    Ada.Text_IO.Put_Line("Incorrect Option.");
                    Ada.Text_IO.Put_Line("It must introduce a number " & 
                                         "understood between 1 and 5.");
	
            end;
        
        end loop;
	
	end Interactive_Menu;
-------------------------------------------------------------------------------
-- PROGRAMA PRINCIPAL
-------------------------------------------------------------------------------
	List_Words: WL.Word_List_Type := new WL.Cell' (ASU.To_Unbounded_String(""), 0, Null);
	P_Aux: WL.Word_List_Type := List_Words;
    Word: ASU.Unbounded_String;
    Count: Natural := 0;
    Usage_Error: exception;
-- si el nombre de fichero no existe se detiene el programa
    End_of_Program: boolean := False;

begin
    
    if (ACL.Argument_Count /= 1 and ACL.Argument_Count /= 2) or else
       (ACL.Argument_Count = 1 and ACL.Argument(1) = "-i") or else
       (ACL.Argument_Count = 2 and ACL.Argument(1) /= "-i") then
        
        raise Usage_Error;
    
    else
        
        Read_Fich(P_aux, List_Words, End_of_Program);

    end if;
    
    if ACL.Argument_Count = 1 and not End_of_Program then
            
        Max_Word(P_Aux, Word, Count);     
        
    elsif ACL.Argument_Count = 2 and not End_of_Program then
        
        Interactive_Menu(P_Aux, List_Words, Word, Count);

    end if;
--Extension 3 --> libero la memoria ocupada por la lista de palabras
    WL.Delete_List(List_Words);

exception

    when Usage_Error =>

        Ada.Text_IO.New_Line(1);
        Ada.Text_IO.Put_Line("Usage: " & ACL.Command_Name & " [-i] <filename>");

end Words;
