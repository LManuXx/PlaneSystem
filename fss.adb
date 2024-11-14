with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time;        use Ada.Real_Time;
with System;               use System;
with tools;         use tools;
with devicesFSS_V1; use devicesFSS_V1;

package body fss is

   procedure Background is
   begin
      loop
         null;
      end loop;
   end Background;

   protected type Altitude_Data is
      procedure Get_Altitude (Roll : out Roll_Samples_Type; Pitch : out Pitch_Samples_Type);
      procedure Set_Altitude (Roll : in Roll_Samples_Type; Pitch : in Pitch_Samples_Type);
   private
      Pitch_Value : Pitch_Samples_Type := 0;
      Roll_Value : Roll_Samples_Type := 0;
   end Altitude_Data;

   protected body Altitude_Data is
      procedure Get_Altitude (Roll : out Roll_Samples_Type; Pitch : out Pitch_Samples_Type) is
      begin
         Pitch := Pitch_Value;
         Roll := Roll_Value;
      end Get_Altitude;

      procedure Set_Altitude (Roll : in Roll_Samples_Type; Pitch : in Pitch_Samples_Type) is
      begin
         Set_Aircraft_Pitch(Pitch);
         Set_Aircraft_Roll(Roll);
         Pitch_Value := Pitch;
         Roll_Value := Roll;
      end Set_Altitude;
   end Altitude_Data;

   protected type Status_Record is
      procedure Get_Altitude(Altitude : out Altitude_Samples_Type);
      procedure Get_Joystick(J : out Joystick_Samples_Type);
      procedure Get_Power(Power : out Power_Samples_Type);
      procedure Get_Speed(Speed : out Speed_Samples_Type);
      procedure Get_Plane_Position(Nx : out Pitch_Samples_Type; Ny : out Roll_Samples_Type);
   end Status_Record;

   protected body Status_Record is
      procedure Get_Altitude(Altitude : out Altitude_Samples_Type) is
      begin
         Altitude := Read_Altitude;
      end Get_Altitude;

      procedure Get_Joystick(J : out Joystick_Samples_Type) is
      begin
         Read_Joystick(J);
      end Get_Joystick;

      procedure Get_Power(Power : out Power_Samples_Type) is
      begin
         Read_Power(Power);
      end Get_Power;

      procedure Get_Speed(Speed : out Speed_Samples_Type) is
      begin
         Speed := Read_Speed;
      end Get_Speed;

      procedure Get_Plane_Position(Nx : out Pitch_Samples_Type; Ny : out Roll_Samples_Type) is
      begin
         Nx := Read_Pitch;
         Ny := Read_Roll;
      end Get_Plane_Position;
   end Status_Record;

   -- Variables Globales
   Altitude : Altitude_Data;
   Display : Status_Record;
   Shared_Velocidad : Float := 0.0;
   contador_colisiones : Integer := 0;

   -- Modo del Sistema: Automático (True) o Manual (False)
   protected System_Mode is
      procedure Toggle_Mode;
      function Is_Automatic return Boolean;
   private
      Automatic_Mode : Boolean := True;  -- El sistema arranca en modo automático
   end System_Mode;

   protected body System_Mode is
      procedure Toggle_Mode is
      begin
         Automatic_Mode := not Automatic_Mode;
      end Toggle_Mode;

      function Is_Automatic return Boolean is
      begin
         return Automatic_Mode;
      end Is_Automatic;
   end System_Mode;

   -- Final de Variables Globales

   procedure desvio_automatico is
      altitud : Altitude_Samples_Type := Read_Altitude;
      cabeceo : Pitch_Samples_Type;
      alabeo : Roll_Samples_Type;
   begin
      if System_Mode.Is_Automatic then
         Altitude.Get_Altitude(alabeo, cabeceo);
         if (contador_colisiones < 12) then
            contador_colisiones  := contador_colisiones + 1;
            if (Integer(altitud) <= 8500) then
               Altitude.Set_Altitude(alabeo, 20);
            else
               Altitude.Set_Altitude(45, cabeceo);
            end if;
         else
            contador_colisiones := 0;
            Altitude.Set_Altitude(0, 0);
         end if;
      end if;
   end desvio_automatico;

   task control_velocidad is 
      pragma Priority(5);
   end control_velocidad;

   task riesgos is
      pragma Priority(2);
   end riesgos;

   task altitud_cabeceo is
      pragma Priority(8);
   end altitud_cabeceo;

   task alabeo is
      pragma Priority(7);
   end alabeo;

   task colision is
      pragma Priority(10);
   end colision;

   task visualizacion is
      pragma Priority(1);
   end visualizacion;

   task modo_sistema is
      pragma Priority(3);
   end modo_sistema;

   -- Implementación de las tareas

   -- Tarea de Velocidad
   task body control_velocidad is
      potencia_actual : Power_Samples_Type;
      velocidad_actual : Float;
      siguiente_instante : Time := Big_Bang + Milliseconds(300);
   begin
      loop
         Read_Power(potencia_actual);
         velocidad_actual := Float(potencia_actual) * 1.2;

         if System_Mode.Is_Automatic then
            if velocidad_actual >= 1000.0 then
               Set_Speed(1000);
               velocidad_actual := 1000.0;
            elsif velocidad_actual < 300.0 then
               Set_Speed(300);
               velocidad_actual := 300.0;
            else
               Set_Speed(Speed_Samples_Type(velocidad_actual));
            end if;
         else
            Set_Speed(Speed_Samples_Type(velocidad_actual));
            if velocidad_actual >= 1000.0 then
               Display_Message("ALERTA: Velocidad máxima superada");
            elsif velocidad_actual < 300.0 then
               Display_Message("ALERTA: Velocidad mínima no alcanzada");
            end if;
         end if;

         Shared_Velocidad := velocidad_actual;
         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(300);
      end loop;
   end control_velocidad;
   -- Final de la tarea de velocidad

   -- Tarea de Riesgos
   task body riesgos is
      velocidad : Float;
      cabeceo : Pitch_Samples_Type;
      alabeo : Roll_Samples_Type;
      potencia : Power_Samples_Type;
      siguiente_instante : Time := Big_Bang + Milliseconds(300);
   begin
      loop
         Altitude.Get_Altitude(alabeo, cabeceo);
         velocidad := Shared_Velocidad;
         Read_Power(potencia);

         if (velocidad >= 1000.0 or velocidad <= 300.0) then
            Light_2(On);
         else
            Light_2(Off);
         end if;

         if System_Mode.Is_Automatic then
            if (cabeceo /= 0 and velocidad < 1000.0) then
               if (velocidad + 150.0 <= 1000.0) then
                  Set_Speed(Speed_Samples_Type(velocidad + 150.0));
                  velocidad := velocidad + 150.0;
               else
                  Set_Speed(1000);
                  velocidad := 1000.0;
               end if;
            end if;

            if (alabeo /= 0 and potencia < 1000) then
               if (potencia + 100 <= 1000) then
                  if ((Float(potencia) * 1.2) <= 1000.0) then
                     Read_Power(potencia);
                     Set_Speed(Speed_Samples_Type((Float(potencia + 100)) * 1.2));
                  else
                     Set_Speed(1000);
                     velocidad := 1000.0;
                  end if;
               else
                  Set_Speed(1000);
                  velocidad := 1000.0;
               end if;
            end if;
         else
            -- En modo manual, emitimos avisos si es necesario
            if (cabeceo /= 0 and velocidad < 1000.0) then
               Display_Message("Velocidad insuficiente para maniobra de cabeceo");
            end if;
         end if;

         Shared_Velocidad := velocidad;
         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(300);
      end loop;
   end riesgos;

   -- Fin de la tarea de Riesgos

   -- Tarea de Altitud y Cabeceo
   task body altitud_cabeceo is
      altitud : Altitude_Samples_Type;
      cabeceo : Pitch_Samples_Type;
      alabeo : Roll_Samples_Type;
      jx : Joystick_Samples_Type;
      siguiente_instante : Time := Big_Bang + Milliseconds(200);
   begin
      loop
         Read_Joystick(jx);
         Altitude.Set_Altitude(Roll_Samples_Type(jx(x)), Pitch_Samples_Type(jx(y)));
         Altitude.Get_Altitude(alabeo, cabeceo);

         if (cabeceo < -30) then
            if System_Mode.Is_Automatic then
               Altitude.Set_Altitude(alabeo, -30);
            end if;
         elsif (cabeceo > 30) then
            if System_Mode.Is_Automatic then
               Altitude.Set_Altitude(alabeo, 30);
            end if;
         end if;

         altitud := Read_Altitude;
         if (Float(altitud) < 2500.0 or Float(altitud) > 9500.0) then
            Light_1(On);
         else
            Light_1(Off);
         end if;

         if (Float(altitud) <= 2000.0 or Float(altitud) >= 10000.0) then
            if System_Mode.Is_Automatic then
               Altitude.Set_Altitude(0, 0);
            end if;
         end if;

         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(200);
      end loop;
   end altitud_cabeceo;
   -- Fin de la Tarea de Altitud y Cabeceo

   -- Tarea de Alabeo
   task body alabeo is
      cabeceo : Pitch_Samples_Type;
      alabeo : Roll_Samples_Type;
      siguiente_instante : Time := Big_Bang + Milliseconds(200);
   begin
      loop
         Altitude.Get_Altitude(alabeo, cabeceo);

         if (alabeo < -35 or alabeo > 35) then
            Display_Message("ALERTA, ALABEO PELIGROSO");
         end if;

         if System_Mode.Is_Automatic then
            if (alabeo < -45) then
               Altitude.Set_Altitude(-45, cabeceo);
            elsif (alabeo > 45) then
               Altitude.Set_Altitude(45, cabeceo);
            end if;
         end if;

         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(200);
      end loop;
   end alabeo;
   -- Final de la tarea de Alabeo

   -- Tarea de Colision
   task body colision is
      distancia : Distance_Samples_Type;
      tiempo_colision : Float;
      siguiente_instante : Time := Big_Bang + Milliseconds(250);
      visual_piloto : Light_Samples_Type;
   begin
      loop
         Read_Distance(distancia);
         if distancia < 5000 then
            if Shared_Velocidad > 0.0 then
               tiempo_colision := Float(distancia) / Shared_Velocidad;
            end if;
            Read_Light_Intensity(visual_piloto);
            if ((Read_PilotPresence = 0) or (Integer(visual_piloto) < 500)) then
               if (tiempo_colision <= 15.0) then
                  Alarm(4);
                  if (tiempo_colision <= 10.0) and System_Mode.Is_Automatic then
                     desvio_automatico;
                  end if;
               end if;
            end if;
            if (tiempo_colision <= 10.0) then
               Alarm(4);
               if (tiempo_colision <= 5.0) and System_Mode.Is_Automatic then
                  desvio_automatico;
               end if;
            end if;
         end if;
         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(250);
      end loop;
   end colision;
   -- Final de la tarea de Colision

   -- Tarea de Visualizacion
   task body visualizacion is
      siguiente_instante : Time := Big_Bang + Milliseconds(1000);
      altitud : Altitude_Samples_Type;
      velocidad : Speed_Samples_Type;
      power : Power_Samples_Type;
      pitch : Pitch_Samples_Type;
      roll : Roll_Samples_Type;
      j: Joystick_Samples_Type;
   begin
      loop
         Display.Get_Altitude(altitud);
         Display.Get_Speed(velocidad);
         Display.Get_Power(power);
         Display.Get_Plane_Position(pitch, roll);
         Display.Get_Joystick(j);

         if System_Mode.Is_Automatic then
            Display_Message("Modo: Automático");
         else
            Display_Message("Modo: Manual");
         end if;

         Display_Message("Mostrar Datos: ");
         Display_Altitude(altitud);
         Display_Pilot_Power(power);
         Display_Speed(velocidad);
         Display_Joystick(j);
         Display_Pitch(pitch);
         Display_Roll(roll);

         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(1000);
      end loop;
   end visualizacion;
   -- Final de la tarea de Visualizacion

   -- Tarea de Modo Sistema
   task body modo_sistema is
      Previous_State, Current_State: PilotButton_Samples_Type := 0;
      siguiente_instante : Time := Clock;
   begin
      loop
         Current_State := Read_PilotButton;
         if (Current_State = 1) and then (Previous_State = 0) then
            System_Mode.Toggle_Mode;
            if System_Mode.Is_Automatic then
               Display_Message("Modo cambiado a Automático");
            else
               Display_Message("Modo cambiado a Manual");
            end if;
         end if;
         Previous_State := Current_State;
         delay until siguiente_instante;
         siguiente_instante := siguiente_instante + Milliseconds(100);
      end loop;
   end modo_sistema;
   -- Final de la tarea de Modo Sistema
begin
  null;
end fss;
