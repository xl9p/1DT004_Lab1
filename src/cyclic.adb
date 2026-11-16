with Ada.Calendar;
with Ada.Text_IO;
use Ada.Calendar;
use Ada.Text_IO;

procedure cyclic is
   Message    : constant String := "Cyclic scheduler";
   -- change/add your declarations here
   d          : Duration := 1.0;
   Start_Time : Time := Clock;
   s          : Integer := 0;
   f1_Next : Time := Start_Time;

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
   end f3;

begin
   loop
      -- change/add your code inside this loop
      f1;
      f2;

      if s mod 2 = 0 then
         delay until f1_Next + 0.5;
         f3;
      end if;

      s := s + 1;
      f1_Next := f1_Next + 1.0;
      delay until f1_Next;

   end loop;
end cyclic;
