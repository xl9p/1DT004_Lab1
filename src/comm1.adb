--  Process communication: Ada lab part 3

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;

procedure comm1 is
   Message : constant String := "Process communication";

   type Int_Limit is range 0 .. 20;
   type Size is range 0 .. 9;
   type Int_Array is array (Size) of Int_Limit;

   task buffer is
      entry Push (X : Int_Limit);
      entry Pop (X : out Int_Limit);
      entry Shutdown;
   end buffer;

   task producer is
      entry Shutdown;
   end producer;

   task consumer is
   end consumer;

   task body buffer is
      Message     : constant String := "Buffer executing";
      Arr         : Int_Array := (others => 0);
      PushIndex   : Natural := 0;
      PopIndex    : Natural := 0;
      NumElements : Natural := 0;
      Run         : Boolean := true;
   begin
      Put_Line (Message);
      while Run loop
         select
            when NumElements < Arr'Length =>
            accept Push (X : in Int_Limit) do
               Arr (Size (PushIndex)) := X;
               PushIndex := (PushIndex + 1) mod Arr'Length;
               NumElements := NumElements + 1;
            end Push;
         or
            when NumElements > 0=>
            accept Pop (X : out Int_Limit) do
               X := Arr (Size (PopIndex));
               NumElements := NumElements - 1;
               PopIndex := (PopIndex + 1) mod Arr'Length;
            end Pop;
         or
            accept Shutdown do
               Run := false;
            end Shutdown;
         end select;
      end loop;
      Put_Line ("Buffer shutting down");
   end buffer;

   task body producer is
      Message        : constant String := "Producer executing";
      package Random_Int is new Ada.Numerics.Discrete_Random (Int_Limit);
      IntGen         : Random_Int.Generator;
      FloatGen       : Ada.Numerics.Float_Random.Generator;
      GeneratedValue : Int_Limit := 0;
      Run            : Boolean := true;
   begin
      Random_Int.Reset (IntGen);
      Ada.Numerics.Float_Random.Reset (FloatGen);

      Put_Line (Message);
      while Run loop
         GeneratedValue := Random_Int.Random (IntGen);

         if GeneratedValue > 0 then
            buffer.Push (GeneratedValue);
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
      ExtractedValue : Int_Limit := 0;
      SumValue       : Integer := 0;
   begin
      Ada.Numerics.Float_Random.Reset (FloatGen);

      Put_Line (Message);
      loop
         buffer.Pop (ExtractedValue);
         Put_Line ("Consumer extracted:" & Int_Limit'Image (ExtractedValue));

         SumValue := SumValue + Integer (ExtractedValue);
         exit when SumValue > 100;

         delay Duration (Ada.Numerics.Float_Random.Random (FloatGen));
      end loop;

      --  Want to make sure producer is terminated before buffer to avoid shutting down the latter while producer is being blocked on buffer.Push, thus triggering a TASKING_ERROR exception
      producer.Shutdown;
      buffer.Shutdown;

      Put_Line ("Consumer shutting down");
   exception
      when TASKING_ERROR =>
         Put_Line ("Buffer finished before producer");
         Put_Line ("Ending the consumer");
   end consumer;
begin
   Put_Line (Message);
end comm1;
