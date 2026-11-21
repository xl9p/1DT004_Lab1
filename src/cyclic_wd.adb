--  Cyclic scheduler with a watchdog:

with Ada.Real_Time;             use Ada.Real_Time;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

procedure cyclic_wd is
   Message : constant String := "Cyclic scheduler";

   SchedulerStartTime   : constant Time := Clock;
   SchedulerCycleIndex  : Integer := 0;
   SchedulerCyclePeriod : constant Time_Span := Milliseconds (1E3);
   SchedulerNextRelease : Time := SchedulerStartTime;

   Gen : Generator;

   procedure f1 is
      Message : constant String := "f1 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (To_Duration (Clock - SchedulerStartTime)));
   end f1;

   procedure f2 is
      Message : constant String := "f2 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (To_Duration (Clock - SchedulerStartTime)));
   end f2;

   procedure f3 is
      Message : constant String := "f3 executing, time is now";
      F3Delay : Duration;
   begin
      Put (Message);
      Put_Line (Duration'Image (To_Duration (Clock - SchedulerStartTime)));

      F3Delay := Duration (5.0 * Random (Gen));
      Put_Line
        ("f3 was executing for" & Duration'Image (F3Delay) & " seconds.");
      delay F3Delay;
   end f3;

   task Watchdog is
      entry Start;
      entry Stop;
   end Watchdog;

   task body Watchdog is
      F3Start : Time;
   begin
      loop
         select
            accept Start do
               F3Start := Clock;
            end Start;
         or
            terminate;
         end select;

         select
            accept stop;
         or
            delay until F3Start + Milliseconds (500);
            Put_Line
              ("Warning: f3 Missed Deadline"
               & Duration'Image (To_Duration (Clock - SchedulerStartTime)));
            accept stop;
         end select;
      end loop;
   end Watchdog;

begin
   Reset (Gen);
   Put_Line (Message);
   loop
      f1;
      f2;

      if SchedulerCycleIndex mod 2 = 0 then
         delay until SchedulerNextRelease + Milliseconds (500);

         Watchdog.start;
         f3;
         Watchdog.stop;
      end if;

      SchedulerCycleIndex :=
        ((Clock - SchedulerStartTime) / SchedulerCyclePeriod) + 1;

      --  Time is relative to the start of the scheduler.
      Put_Line
        ("Current time:"
         & Duration'Image (To_Duration (Clock - SchedulerStartTime))
         & "; Planned release time:"
         & Duration'Image
             (To_Duration
                ((SchedulerNextRelease - SchedulerStartTime)
                 + SchedulerCyclePeriod))
         & "; New release time:"
         & Duration'Image
             (To_Duration (SchedulerCycleIndex * SchedulerCyclePeriod)));

      SchedulerNextRelease :=
        SchedulerStartTime + (SchedulerCycleIndex * SchedulerCyclePeriod);
      delay until SchedulerNextRelease;
   end loop;
end cyclic_wd;
