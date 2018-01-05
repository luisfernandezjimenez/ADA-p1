-- Work carried out by Luis Fernández Jiménez

package body Word_Lists is

    procedure Free is new
		
	    Ada.Unchecked_Deallocation (Cell, Word_List_Type);
	
    procedure Add_Word (List: in out Word_List_Type;
                        Word: in ASU.Unbounded_String) is
    
        Finish: Boolean := False;
	
	begin
    	
    	while not Finish loop
    	
    	    begin
--Si la palabra coincide con una de la lista suma 1 al contador
--Extension 2 --> misma palabra con letras en mayusculas y/o minusculas
        		if ACH.To_Lower(ASU.To_String(List.all.Word)) = 
        		   ACH.To_Lower(ASU.To_String(Word)) then 
        			
        			List.all.Count := List.all.Count + 1;
        			Finish := True;

        		elsif List.all.Next /= Null then
        			
        			List := List.Next;
--Si llega a Null => Relleno lista
        		else

        			if ASU.To_String(List.all.Word) /= "" then
--Tengo una lista creada inicialmente y esta vacia, la compruebo para no crear una nueva
--el resto de veces se crea la lista, se apunta a dicha direccion de memoria y se rellena
    			        List.all.Next := new Cell;
    			        List := List.all.Next;
        			
        			end if;
        			
        			List.all.Word := ASU.To_Unbounded_String(ACH.To_Lower(ASU.To_String(Word)));
    			    List.all.Count := 1;
        			Finish := True;

        		end if;
 		
 		    end;
 		    
 		end loop;
        
    end Add_Word;
    
    procedure Delete_Word (List: in out Word_List_Type;
                           Word: in ASU.Unbounded_String) is
    
        Finish: boolean := False;
        P_Aux: Word_List_Type := List.all.Next; --apunta a un elemento por delante
    
    begin
    
        while not Finish loop
        
            begin
--si la palabra es la primera de la lista la que vamos a borrar
                if ACH.To_Lower(ASU.To_String(Word)) = 
                   ASU.To_String(List.all.Word) then
                    
                    Free(List);
                    List := P_Aux;
                    Finish := True;
--Si lista esta vacia o
--Hay una sola palabra en la lista, que se comprueba antes, y no es la palabra a eliminar                        
                elsif List.all.Next = Null then
                    
                    raise Word_List_Error;
                    
                elsif ACH.To_Lower(ASU.To_String(Word)) = 
                      ASU.To_String(P_Aux.all.Word) then
--Apuntamos el next, del elemento anterior al que vamos a eliminar,
--al siguiente elemento del que se va a eliminar
--Asi enlazamos el elemento anterior con el siguiente y no se rompe continuidad
                    List.all.Next := P_Aux.all.Next; 
                    Free(P_Aux);
                    Finish := True;
                        
                elsif P_Aux.all.Next /= Null then
                 
                    P_Aux := P_Aux.all.Next;
                    List := List.all.Next;

                else
--recorre toda la lista y no coincide ninguna palabra
                    raise Word_List_Error;
                    
                end if;
                
            end;
            
        end loop;
		    	
    end Delete_Word;

    procedure Search_Word (List: in Word_List_Type;
                           Word: in ASU.Unbounded_String;
                           Count: out Natural) is
       
       Finish: Boolean := False;
       P_Aux: Word_List_Type := List;
    
    begin
        
        Count := 0;
    
        while not Finish loop
        	
	        begin
	        
	            if ACH.To_Lower(ASU.To_String(Word)) = 
	               ASU.To_String(P_Aux.all.Word) then
	                
	                Count := P_Aux.all.Count;	                                     
                    Finish := True;
                    
                elsif P_Aux.Next /= Null then
                
                    P_Aux := P_Aux.all.Next;
                    
                elsif P_Aux.Next = Null then
-- count es 0 porque esta he inicializado a 0 y no se cambia en este caso
                    Finish := True;
	        
                end if;
	        
	        end;
	        
        end loop;
    
    end Search_Word;

    procedure Max_Word (List: in Word_List_Type;
                        Word: out ASU.Unbounded_String;
                        Count: out Natural) is

        P_Aux: Word_List_Type := List;
        
    begin

        Count := 0;
--Si elimino todas las palabras de la lista o Si lista vacia despues de leer fichero
        if P_Aux = Null or else 
           (P_Aux.all.Next = Null and ASU.To_String(P_Aux.all.Word) = "") then
        
            raise Word_List_Error;
        
        else
        
            while P_Aux /= Null loop
        	
        	    begin
        	        
        	        if P_Aux.all.Count > Count then
        	            
        	            Count := P_Aux.all.Count;
        	            Word := P_Aux.all.Word;
	                
	                end if;
	                
	                P_Aux := P_Aux.all.Next;
        	    
        	    end;
        	    
	        end loop;

        end if;

    end Max_Word;

    procedure Print_All (List: in Word_List_Type) is
    
    P_Aux: Word_List_Type := List;
	
   	begin
   		 
   		Ada.Text_IO.New_Line(1);
--Si elimino todas las palabras de la lista o Si lista vacia despues de leer fichero
   		if P_Aux = Null or else
   		   (P_Aux.all.Next = Null and ASU.To_String(P_Aux.all.Word) = "") then
   		    
   		    Ada.Text_IO.Put_Line("No words.");
   		    
   		else
   			
   			while P_Aux/= Null loop
   			    
   			    Ada.Text_IO.Put_Line("|" &(ASU.To_String(P_Aux.all.Word)) & 
				                     "| -" & Natural'Image(P_Aux.all.Count));
					
				P_Aux := P_Aux.all.Next;
				
			end loop;
		
		end if;
	
	end Print_All;
--Extension 3 --> liberar la memoria ocupada por la lista de palabras
	procedure Delete_List (List: in out Word_List_Type) is
	    
	    P_Aux : Word_List_Type := List;
	
	begin
	    
        while List /= Null loop
            
            begin
--Elimina elemento a elemento de la lista hasta que la lista esta vacía (Null)            
                List := List.all.Next;
				Free(P_Aux);
				P_Aux := List;
            
            end;
            
        end loop;
        
        if List = Null then
	            
            Ada.Text_IO.Put_Line("Memory occupied by the word list " & 
                                 "has been released.");
        
        end if;
	
	end Delete_List;

end Word_Lists;
