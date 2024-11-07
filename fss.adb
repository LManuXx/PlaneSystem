with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time;        use Ada.Real_Time;
with System;               use System;

with tools;         use tools;
with devicesFSS_V1; use devicesFSS_V1;

package body fss is

   -- Implementación de la tarea Background
   procedure Background is
   begin
      loop
         null; -- Tarea de ejemplo, implementa la lógica según tus necesidades
      end loop;
   end Background;

   -- Objeto protegido para gestionar el estado de la aeronave
   protected type Status_Record is
      procedure Update_Status (Alt : Altitude_Samples_Type; Speed : Speed_Samples_Type; 
                               Pitch : Pitch_Samples_Type; Roll : Roll_Samples_Type; Power : Power_Samples_Type);
      procedure Get_Status (Alt : out Altitude_Samples_Type; Speed : out Speed_Samples_Type; 
                            Pitch : out Pitch_Samples_Type; Roll : out Roll_Samples_Type; Power : out Power_Samples_Type);
   private
      Current_Altitude : Altitude_Samples_Type := 8000;
      Current_Speed    : Speed_Samples_Type := 0;
      Current_Pitch    : Pitch_Samples_Type := 0;
      Current_Roll     : Roll_Samples_Type := 0;
      Current_Power    : Power_Samples_Type := 0;
   end Status_Record;

   protected body Status_Record is
      procedure Update_Status (Alt : Altitude_Samples_Type; Speed : Speed_Samples_Type; 
                               Pitch : Pitch_Samples_Type; Roll : Roll_Samples_Type; Power : Power_Samples_Type) is
      begin
         Current_Altitude := Alt;
         Current_Speed    := Speed;
         Current_Pitch    := Pitch;
         Current_Roll     := Roll;
         Current_Power    := Power;
      end Update_Status;

      procedure Get_Status (Alt : out Altitude_Samples_Type; Speed : out Speed_Samples_Type; 
                            Pitch : out Pitch_Samples_Type; Roll : out Roll_Samples_Type; Power : out Power_Samples_Type) is
      begin
         Alt := Current_Altitude;
         Speed := Current_Speed;
         Pitch := Current_Pitch;
         Roll := Current_Roll;
         Power := Current_Power;
      end Get_Status;
   end Status_Record;

   Status : Status_Record;

   protected type Attitude_Data is
      procedure Get_Attitude (Pitch : out Pitch_Samples_Type; Roll : out Roll_Samples_Type);
      procedure Set_Attitude (Pitch : Pitch_Samples_Type; Roll : Roll_Samples_Type);
   private
      Pitch_Value : Pitch_Samples_Type := 0;
      Roll_Value : Roll_Samples_Type := 0;
   end Attitude_Data;

   protected body Attitude_Data is
      procedure Get_Attitude (Pitch : out Pitch_Samples_Type; Roll : out Roll_Samples_Type) is
      begin
         Pitch := Pitch_Value;
         Roll := Roll_Value;
      end Get_Attitude;

      procedure Set_Attitude (Pitch : Pitch_Samples_Type; Roll : Roll_Samples_Type) is
      begin
         Pitch_Value := Pitch;
         Roll_Value := Roll;
      end Set_Attitude;
   end Attitude_Data;

   Attitude : Attitude_Data;
   Shared_Velocidad : Float := 0.0;
   contador_colisiones : Integer := 0;

   procedure desvio_automatico is
      altitud : Altitude_Samples_Type := Read_Altitude;
      cabeceo : Pitch_Samples_Type;
      alabeo : Roll_Samples_Type;
   begin
      Attitude.Get_Attitude(cabeceo, alabeo);
      if (contador_colisiones < 12) then
         if (Integer(altitud) <= 8500) then
            Attitude.Set_Attitude(20, alabeo);
         else
            Attitude.Set_Attitude(cabeceo, 45);
         end if;
      else
         Attitude.Set_Attitude(0, 0);
         contador_colisiones := 0;
      end if;
   end desvio_automatico;

   task control_velocidad is 
      pragma Priority(5);
   end control_velocidad;

   task riesgos is
      pragma Priority(1);
   end riesgos;

   task altitud_cabeceo is
      pragma Priority(4);
   end altitud_cabeceo;

   task alabeo is
      pragma Priority(3);
   end alabeo;

   task colision is
      pragma Priority(3);
   end colision;

   task visualizacion is
      pragma Priority(2);
   end visualizacion;

   task body control_velocidad is
      potencia_actual : Power_Samples_Type;
      velocidad_actual : Float;
      siguiente_instante : Time := Clock + Milliseconds(300);
      altitud : Altitude_Samples_Type;
      cabeceo : Pitch_Samples_Type;
      alabeo : Roll_Samples_Type;
   begin
      loop
         Read_Power(potencia_actual);
         velocidad_actual := Float(potencia_actual) * 1.2;

         if (velocidad_actual <= 1000.0 and velocidad_actual >= 300.0) then
            Set_Speed(Speed_Samples_Type(velocidad_actual));
         elsif (velocidad_actual < 300.0) then 
            Set_Speed(300);
            velocidad_actual := 300.0;
         else
            Set_Speed(1000);
            velocidad_actual := 1000.0;
         end if;

         Shared_Velocidad := velocidad_actual;
         Attitude.Get_Attitude(cabeceo, alabeo);
         altitud := Read_Altitude;
         Status.Update_Status(altitud, Speed_Samples_Type(velocidad_actual), 
                              cabeceo, alabeo, potencia_actual);
         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(300);
      end loop;
   end control_velocidad;

   task body riesgos is
      velocidad : Float;
      cabeceo : Pitch_Samples_Type;
      alabeo : Roll_Samples_Type;
      potencia : Power_Samples_Type;
      siguiente_instante : Time := Clock + Milliseconds(300);
      altitud : Altitude_Samples_Type;
   begin
      loop
         Attitude.Get_Attitude(cabeceo, alabeo);
         velocidad := Shared_Velocidad;
         Read_Power(potencia);
         altitud := Read_Altitude;

         if (velocidad = 1000.0 or velocidad <= 300.0) then
            Light_2(On);
         end if;

         if (cabeceo > 0 and velocidad < 1000.0) then
            if (velocidad + 150.0 <= 1000.0) then
               Set_Speed(Speed_Samples_Type(velocidad + 150.0));
               velocidad := velocidad + 150.0;
            else
               Set_Speed(1000);
               velocidad := 1000.0;
            end if;
         end if;

         if (alabeo > 0 and potencia < 1000) then
            if (potencia + 100 <= 1000) then
               Set_Speed(Speed_Samples_Type(Float(potencia + 100) * 1.2));
               velocidad := Float(potencia + 100) * 1.2;
            else
               Set_Speed(1000);
               velocidad := 1000.0;
            end if;
         end if;

         Shared_Velocidad := velocidad;
         Status.Update_Status(altitud, Speed_Samples_Type(velocidad), 
                              cabeceo, alabeo, potencia);
         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(300);
      end loop;
   end riesgos;

   task body altitud_cabeceo is
      altitud : Altitude_Samples_Type;
      cabeceo : Pitch_Samples_Type;
      alabeo : Roll_Samples_Type;
      siguiente_instante : Time := Clock + Milliseconds(200);
   begin
      loop
         Attitude.Get_Attitude(cabeceo, alabeo);
         altitud := Read_Altitude;

         if (cabeceo < -30) then
            Attitude.Set_Attitude(-30, alabeo);
         elsif (cabeceo > 30) then
            Attitude.Set_Attitude(30, alabeo);
         end if;

         if (Float(altitud) < 2500.0 or Float(altitud) > 9500.0) then
            Light_1(On);
         end if;

         if (Float(altitud) <= 2000.0 or Float(altitud) >= 10000.0) then
            Attitude.Set_Attitude(0, 0);
         end if;

         Status.Update_Status(altitud, 0, cabeceo, alabeo, 0);
         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(200);
      end loop;
   end altitud_cabeceo;

   task body alabeo is
      cabeceo : Pitch_Samples_Type;
      alabeo : Roll_Samples_Type;
      siguiente_instante : Time := Clock + Milliseconds(200);
   begin
      loop
         Attitude.Get_Attitude(cabeceo, alabeo);

         if (alabeo < -35 or alabeo > 35) then
            Display_Message("ALERTA, ALABEO PELIGROSO");
         end if;

         if (alabeo < -45) then
            Attitude.Set_Attitude(cabeceo, -45);
         elsif (alabeo > 45) then
            Attitude.Set_Attitude(cabeceo, 45);
         end if;

         Status.Update_Status(0, 0, cabeceo, alabeo, 0);
         Display_Roll(alabeo);
         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(200);
      end loop;
   end alabeo;

   task body colision is
      golondrina : Distance_Samples_Type;
      tiempo_colision : Float;
      siguiente_instante : Time := Clock + Milliseconds(250);
      visual_piloto : Light_Samples_Type;
   begin
      loop
         Read_Distance(golondrina);
         if (Shared_Velocidad /= 0.0) then
            tiempo_colision := Float(golondrina) / Shared_Velocidad;
         end if;

         Read_Light_Intensity(visual_piloto);

         if (tiempo_colision <= 10.0) then
            Alarm(4);
            if (tiempo_colision <= 5.0) then
               desvio_automatico;
            end if;
         end if;

         if ((Read_PilotPresence = 1) or (Integer(visual_piloto) < 500)) then
            if (tiempo_colision <= 15.0) then
               Alarm(4);
               if (tiempo_colision <= 10.0) then
                  desvio_automatico;
               end if;
            end if;
         end if;

         Status.Update_Status(0, 0, 0, 0, 0);
         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(250);
      end loop;
   end colision;

   task body visualizacion is
      siguiente_instante : Time := Clock + Seconds(1);
      altitud : Altitude_Samples_Type;
      velocidad : Speed_Samples_Type;
      cabeceo : Pitch_Samples_Type;
      alabeo : Roll_Samples_Type;
      potencia : Power_Samples_Type;
   begin
      loop
         -- Obtener el estado actual de la aeronave
         Status.Get_Status(altitud, velocidad, cabeceo, alabeo, potencia);

         -- Mostrar los datos en el display
         Display_Altitude(altitud);
         Display_Speed(velocidad);
         Display_Pitch(cabeceo);
         Display_Roll(alabeo);
         Display_Pilot_Power(potencia);

         -- Mostrar la posición del joystick
         declare
            joystick_pos : Joystick_Samples_Type;
         begin
            Read_Joystick(joystick_pos);
            Display_Joystick(joystick_pos);
         end;

         -- Retraso hasta la siguiente actualización de visualización
         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Seconds(1);
      end loop;
   end visualizacion;

begin
   null; -- Cuerpo principal del paquete
end fss;
