--Cyclic scheduler with a watchdog:

with Ada.Real_Time;
with Ada.Text_IO;

use Ada.Real_Time;
use Ada.Text_IO;

with Ada.Numerics.Float_Random;
use Ada.Numerics.Float_Random;

procedure cyclic_wd is
   Message    : constant String := "Cyclic scheduler";
   d          : Duration := 1.0;
   Start_Time : Time := Clock;
   F1TimeGridIndex : Integer := 0;
   F1NextWakeup : Time := Start_Time;
   F1CyclePeriod : constant Time_Span := Microseconds(1E6); 

   Gen : Generator;
   f3_start : Time;
   Elapsed : Duration;

   procedure f1 is
      Message : constant String := "f1 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (To_Duration(Clock - Start_Time)));
   end f1;

   procedure f2 is
      Message : constant String := "f2 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (To_Duration(Clock - Start_Time)));
   end f2;

   procedure f3 is
      Message : constant String := "f3 executing, time is now";
      test : Duration;
   begin
      Put (Message);
      Put_Line (Duration'Image (To_Duration(Clock - Start_Time)));
      
      test := Duration(5.1 * Random (Gen));
      Put_Line(Duration'Image(test));
      delay test;

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
         or delay until f3_start + Milliseconds(500);
            Elapsed := To_Duration(Clock - f3_start);
            Put_Line("WArning: f3 Missed Deadline: " & Duration'Image (To_Duration(Clock - Start_Time)));
            Put_Line(Duration'Image(Elapsed));
            accept stop;
         end select;
      end loop;
   end Watchdog;

begin
   Reset(Gen);
   Put_Line (Message);
   loop
      f1;
      f2;

      if F1TimeGridIndex mod 2 = 0 then
         delay until F1NextWakeup + Microseconds (5E5);

         Watchdog.start;
         f3;
         Watchdog.stop;
      end if;

      F1TimeGridIndex := ((Clock - Start_Time) / F1CyclePeriod) + 1;
      F1NextWakeup := Start_Time + (F1TimeGridIndex * F1CyclePeriod);
      delay until F1NextWakeup;

   end loop;
end cyclic_wd;