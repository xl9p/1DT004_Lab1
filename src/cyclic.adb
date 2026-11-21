--  Cyclic scheduler:

with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO;  use Ada.Text_IO;

procedure cyclic is
   Message : constant String := "Cyclic scheduler";

   SchedulerStartTime   : constant Time := Clock;
   SchedulerCycleIndex  : Integer := 0;
   SchedulerCyclePeriod : constant Duration := 1.0;
   SchedulerNextRelease : Time := SchedulerStartTime;

   procedure f1 is
      Message : constant String := "f1 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (Clock - SchedulerStartTime));
   end f1;

   procedure f2 is
      Message : constant String := "f2 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (Clock - SchedulerStartTime));
   end f2;

   procedure f3 is
      Message : constant String := "f3 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (Clock - SchedulerStartTime));
   end f3;

begin
   Put_Line (Message);
   loop
      f1;
      f2;

      if SchedulerCycleIndex mod 2 = 0 then
         delay until SchedulerNextRelease + 0.5;
         f3;
      end if;

      SchedulerCycleIndex := SchedulerCycleIndex + 1;
      SchedulerNextRelease := SchedulerNextRelease + SchedulerCyclePeriod;
      delay until SchedulerNextRelease;
   end loop;
end cyclic;
