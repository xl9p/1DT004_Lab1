--Process communication: Ada lab part 3

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure comm1 is

   type Int_Limit is range 0 .. 20;
   type Size is range 1 .. 10;

   Message : constant String := "Process communication";
   task buffer is
      entry push (X : Int_Limit);
      entry pop (Z : out Int_Limit);
   end buffer;

   task producer is
      -- add your task entries for communication
   end producer;

   task consumer is
      -- add your task entries for communication
   end consumer;

   task body buffer is
      Message : constant String := "buffer executing";
      type My_Int_Array is array (Size) of Int_Limit;

      Arr   : My_Int_Array := (others => 0);
      Count : Natural := 0;
   begin
      Put_Line (Message);
      loop
         select
            when Count < Arr'Length =>
               accept push (X : in Int_Limit) do
                  Put_Line("random" & X'Image);
                  Count := Count + 1;
                  Arr (Size (Count)) := Int_Limit (X);
               end push;
         or
            when Count > 0 =>
               accept pop (Z : out Int_Limit) do
                  Z := Int_Limit (Arr (Size (Count)));
                  Put_Line("random" & Z'Image);
                  Count := Count - 1;
               end pop;
         or
            terminate;
         end select;
      end loop;
   end buffer;

   task body producer is
      Message : constant String := "producer executing";
      package Random_Int is new Ada.Numerics.Discrete_Random (Int_Limit);

      Gen : Random_Int.Generator;

      -- change/add your local declarations here
   begin
      Put_Line (Message);
      loop
         buffer.push(Random_Int.Random(Gen));
         
      end loop;
   end producer;

   task body consumer is
      Message : constant String := "consumer executing";
      -- change/add your local declarations here
      Test : Int_Limit;
   begin
      Put_Line (Message);
      Main_Cycle : loop
      buffer.pop(Test);
      Put_Line("OUTTT" & Test'Image);
      end loop Main_Cycle;

   -- add your code to stop executions of other tasks
   exception
      when TASKING_ERROR =>
         Put_Line ("Buffer finished before producer");
         Put_Line ("Ending the consumer");
   end consumer;
begin
   Put_Line (Message);
end comm1;
 