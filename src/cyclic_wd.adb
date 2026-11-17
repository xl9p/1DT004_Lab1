--Cyclic scheduler with a watchdog:

with Ada.Calendar;
with Ada.Text_IO;

use Ada.Calendar;
use Ada.Text_IO;

with Ada.Numerics.Float_Random;
use Ada.Numerics.Float_Random;

procedure cyclic_wd is
   Message    : constant String := "Cyclic scheduler";
   d          : Duration := 1.0;
   Start_Time : Time := Clock;
   s          : Integer := 0;
   f1_Next : Time := Start_Time;

   Gen : Generator;
   f3_start : Time;
   Elapsed : Duration;

   procedure f1 is
      Message : constant String := "f1 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (Clock - Start_Time));
   end f1;

   procedure f2 is
      Message : constant String := "f2 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (Clock - Start_Time));
   end f2;

   procedure f3 is
      Message : constant String := "f3 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (Clock - Start_Time));
      
      delay Duration (0.6 * Random (Gen));
   end f3;

   task Watchdog is
      entry Start;
      entry Stop;
   end Watchdog;

   task body Watchdog is
   begin
      loop
         select
            accept Start do
               f3_start := Clock;
            end Start;
         or
            terminate;
         end select;

         select
            accept stop;
         or delay until f3_start + 0.5;
            Elapsed := Clock - f3_start;
            Put_Line("WArning: f3 Missed Deadline: " & Duration'Image(Clock - Start_Time));
            accept stop;
         end select;
      end loop;
   end Watchdog;

begin
   Reset(Gen);
   loop
      -- change/add your code inside this loop
      f1;
      f2;

      if s mod 2 = 0 then
         delay until f1_Next + 0.5;

         Watchdog.start;
         f3;
         Watchdog.stop;
      
      end if;

      while Clock > f1_Next loop
         f1_Next := f1_Next + 1.0;
         s := s + 1;
      end loop;

      
      delay until f1_Next;

   end loop;
end cyclic_wd;
