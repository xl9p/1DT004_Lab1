--Cyclic scheduler with a watchdog:

--  with Ada.Calendar;
--  package Cal renames Ada.Calendar;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO;   use Ada.Text_IO;

procedure cyclic_wd is

   Message : constant String := "Cyclic scheduler";

   StartTime : constant Time := Clock;

   F1NextWakeup    : Time := StartTime;
   F1CyclePeriod   : constant Time_Span := Microseconds (1E6);
   F1TimeGridIndex : Integer := 0;

   procedure f1 is
      Message : constant String := "f1 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (To_Duration (Clock - StartTime)));
   end f1;

   procedure f2 is
      Message : constant String := "f2 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (To_Duration (Clock - StartTime)));
   end f2;

   procedure f3 is
      Message : constant String := "f3 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (To_Duration (Clock - StartTime)));

      delay 0.77;
   end f3;

   task Watchdog is
      entry Start;
      entry Stop;
   end Watchdog;

   task body Watchdog is
      F3Start : Time;
      Elapsed : Time_Span;
   begin
      loop
         select
            accept Start do
               F3Start := Clock;
            end Start;
         or
            accept Stop do
               Elapsed := Clock - F3Start;
               if Elapsed > Microseconds (5E5) then
                  Put_Line
                    ("Warning: f3 Missed Deadline: "
                     & Duration'Image (To_Duration (Elapsed)));
               end if;
            end Stop;
         or
            terminate;
         end select;
      end loop;
   end Watchdog;

begin
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

      --  A way of solving the drift is to use a principle similar to the one we use for determining when to run F3.
      --  It treats the time since the scheduler's start as a grid with a fixed 1 second spacing.
      --  Each grid cell can then be thought to have an index, starting with 0 from the first grid.
      --  Usually, when F1,F2, and F3 take less than a second to execute they fit in a single 1 second grid cell, which is why simply advancing it by 1 was enough.
      --  But if F3 was to execute longer making the time exceed the grid cell of the current iteration, the fixed 1 increments break.
      --  To solve it we notice that the wake up time for current iteration is basically Tn = T0 + ((i + 1) * Tperiod),
      --  where T0 is the time since the scheduler loop started, i is the index of the current time grid cell, and Tperiod is the period of each time grid cell.
      --  Then i is computed using current time and the period of a single cycle, as i = (Tclock - T0) / Tperiod, it is important that all T variables use the same time unit.
      --  This i computation advances the scheduler to the appropriate time grid cell index automatically whenever needed (such as a result of delays).
      F1TimeGridIndex := ((Clock - StartTime) / F1CyclePeriod) + 1;
      F1NextWakeup := StartTime + (F1TimeGridIndex * F1CyclePeriod);
      delay until F1NextWakeup;
   end loop;
end cyclic_wd;
