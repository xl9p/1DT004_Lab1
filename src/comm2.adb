--  Protected types: Ada lab part 4

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;

procedure comm2 is
   Message : constant String := "Protected Object";

   type Int_Limit is range 0 .. 20;
   type Size is range 1 .. 10;
   type Int_Array is array (Size) of Int_Limit;

   protected buffer is
      entry Push (X : Int_Limit);
      entry Pop (X : out Int_Limit);
   private
      Arr   : Int_Array := (others => 0);
      Count : Natural := 0;
   end buffer;

   task producer is
      entry Shutdown;
   end producer;

   task consumer is
   end consumer;

   protected body buffer is
      entry Push (X : in Int_Limit) when Count < Arr'Length is
      begin
         Count := Count + 1;
         Arr (Size (Count)) := X;
      end Push;

      entry Pop (X : out Int_Limit) when Count > 0 is
      begin
         X := Arr (Size (Count));
         Count := Count - 1;
      end Pop;
   end buffer;

   task body producer is
      Message        : constant String := "Producer executing";
      package Random_Int is new Ada.Numerics.Discrete_Random (Int_Limit);
      IntGen         : Random_Int.Generator;
      FloatGen       : Ada.Numerics.Float_Random.Generator;
      GeneratedValue : Int_Limit;
      Run            : Boolean := true;
   begin
      Random_Int.Reset (IntGen);
      Ada.Numerics.Float_Random.Reset (FloatGen);

      Put_Line (Message);
      while Run loop
         GeneratedValue := Random_Int.Random (IntGen);

         if GeneratedValue > 0 then
            buffer.push (GeneratedValue);
            Put_Line ("Producer produced:" & Int_Limit'Image (GeneratedValue));
         end if;

         select
            accept Shutdown do
               Run := false;
            end Shutdown;
         or
            delay Duration (Ada.Numerics.Float_Random.Random (FloatGen));
         end select;
      end loop;
      Put_Line ("Producer shutting down");
   end producer;

   task body consumer is
      Message        : constant String := "Consumer executing";
      FloatGen       : Ada.Numerics.Float_Random.Generator;
      ExtractedValue : Int_Limit;
      SumValue       : Integer := 0;
   begin
      Ada.Numerics.Float_Random.Reset (FloatGen);

      Put_Line (Message);
      loop
         buffer.pop (ExtractedValue);
         Put_Line ("Consumer extracted:" & Int_Limit'Image (ExtractedValue));

         SumValue := SumValue + Integer (ExtractedValue);
         exit when SumValue > 100;

         delay Duration (Ada.Numerics.Float_Random.Random (FloatGen));
      end loop;

      producer.Shutdown;

      Put_Line ("Consumer shutting down");
   end consumer;
begin
   Put_Line (Message);
end comm2;
