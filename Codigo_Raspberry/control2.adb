with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;    use Ada.Float_Text_IO;
with Ada.Real_Time;        use Ada.Real_Time;
with Devices_A;            use Devices_A;

procedure control2 is

   --------------------------------------------------------------------------
   -- Control de Sistemas de Navegación y Seguridad (FSS)
   -- Integrado en un único archivo control2.adb
   -- Se incluye la lógica de FSS y se invoca desde el main
   -- Aquí se asume que ya tienes configurado el entorno, makefile, devices_a.ads
   -- y devices.c. Solo tendrás que hacer 'make' para compilar.
   --------------------------------------------------------------------------

   -- Definición de tipos
   subtype Pitch_Samples_Type is Integer range -30 .. 30;
   subtype Roll_Samples_Type  is Integer range -45 .. 45;
   subtype Altitude_Samples_Type is Integer range 0 .. 10230;
   subtype Speed_Samples_Type is Integer range 0 .. 1200;
   subtype Power_Samples_Type is Integer range 0 .. 1023;
   subtype Light_Samples_Type is Integer range 0 .. 1023;
   subtype Joystick_Samples_Type is Integer range -90 .. 90;
   subtype Distance_Samples_Type is Float;

   type Mode_Type is (Automatic, Manual);

   -- Intervalos de las tareas
   Pitch_Alt_Period  : constant Time_Span := Milliseconds(200);
   Roll_Period       : constant Time_Span := Milliseconds(200);
   Speed_Period      : constant Time_Span := Milliseconds(300);
   Obstacle_Period   : constant Time_Span := Milliseconds(250);
   Display_Period    : constant Time_Span := Milliseconds(1000);

   -- Definición de objetos protegidos
   protected type Aircraft_State is
      procedure Set_Pitch(P: in Pitch_Samples_Type);
      function Get_Pitch return Pitch_Samples_Type;
      procedure Set_Roll(R: in Roll_Samples_Type);
      function Get_Roll return Roll_Samples_Type;
      procedure Set_Altitude(A: in Altitude_Samples_Type);
      function Get_Altitude return Altitude_Samples_Type;
      procedure Increment_Altitude(D: in Integer);
      procedure Set_Speed(S: in Speed_Samples_Type);
      function Get_Speed return Speed_Samples_Type;
   private
      Current_Pitch    : Pitch_Samples_Type    := 0;
      Current_Roll     : Roll_Samples_Type     := 0;
      Current_Altitude : Altitude_Samples_Type := 8000;
      Current_Speed    : Speed_Samples_Type    := 300;
   end Aircraft_State;

   protected body Aircraft_State is
      procedure Set_Pitch(P: in Pitch_Samples_Type) is
      begin
         if P > 30 then
            Current_Pitch := 30;
         elsif P < -30 then
            Current_Pitch := -30;
         else
            Current_Pitch := P;
         end if;
      end Set_Pitch;

      function Get_Pitch return Pitch_Samples_Type is
      begin
         return Current_Pitch;
      end Get_Pitch;

      procedure Set_Roll(R: in Roll_Samples_Type) is
      begin
         if R > 45 then
            Current_Roll := 45;
         elsif R < -45 then
            Current_Roll := -45;
         else
            Current_Roll := R;
         end if;
      end Set_Roll;

      function Get_Roll return Roll_Samples_Type is
      begin
         return Current_Roll;
      end Get_Roll;

      procedure Set_Altitude(A: in Altitude_Samples_Type) is
      begin
         if A > 10230 then
            Current_Altitude := 10230;
         elsif A < 0 then
            Current_Altitude := 0;
         else
            Current_Altitude := A;
         end if;
      end Set_Altitude;

      function Get_Altitude return Altitude_Samples_Type is
      begin
         return Current_Altitude;
      end Get_Altitude;

      procedure Increment_Altitude(D: in Integer) is
         New_Alt : Altitude_Samples_Type;
      begin
         New_Alt := Altitude_Samples_Type(Integer(Current_Altitude) + D);
         if New_Alt > 10230 then
            New_Alt := 10230;
         elsif New_Alt < 0 then
            New_Alt := 0;
         end if;
         Current_Altitude := New_Alt;
      end Increment_Altitude;

      procedure Set_Speed(S: in Speed_Samples_Type) is
      begin
         if S > 1000 then
            Current_Speed := 1000;
         elsif S < 300 then
            Current_Speed := 300;
         else
            Current_Speed := S;
         end if;
      end Set_Speed;

      function Get_Speed return Speed_Samples_Type is
      begin
         return Current_Speed;
      end Get_Speed;
   end Aircraft_State;

   protected type Global_State is
      procedure Set_Pilot_Power(P: in Power_Samples_Type);
      function Get_Pilot_Power return Power_Samples_Type;

      procedure Set_Visibility(V: in Light_Samples_Type);
      function Get_Visibility return Light_Samples_Type;

      procedure Set_Joystick(X, Y: in Joystick_Samples_Type);
      procedure Get_Joystick(X, Y: out Joystick_Samples_Type);

      procedure Set_Pilot_Button(B: in Integer);
      function Get_Pilot_Button return Integer;

      procedure Set_Pilot_Presence(P: in Integer);
      function Get_Pilot_Presence return Integer;

      procedure Set_Distance(D: in Distance_Samples_Type);
      function Get_Distance return Distance_Samples_Type;

      procedure Toggle_Mode;
      function Get_Mode return Mode_Type;
   private
      Pilot_Power     : Power_Samples_Type  := 512;
      Visibility      : Light_Samples_Type  := 500;
      JX, JY          : Joystick_Samples_Type := 0;
      Pilot_Button    : Integer := 0;
      Pilot_Presence  : Integer := 1;
      Distance_Obs    : Distance_Samples_Type := 6000.0;
      Current_Mode    : Mode_Type := Automatic;
   end Global_State;

   protected body Global_State is
      procedure Set_Pilot_Power(P: in Power_Samples_Type) is
      begin
         Pilot_Power := P;
      end Set_Pilot_Power;

      function Get_Pilot_Power return Power_Samples_Type is
      begin
         return Pilot_Power;
      end Get_Pilot_Power;

      procedure Set_Visibility(V: in Light_Samples_Type) is
      begin
         Visibility := V;
      end Set_Visibility;

      function Get_Visibility return Light_Samples_Type is
      begin
         return Visibility;
      end Get_Visibility;

      procedure Set_Joystick(X, Y: in Joystick_Samples_Type) is
      begin
         JX := X;
         JY := Y;
      end Set_Joystick;

      procedure Get_Joystick(X, Y: out Joystick_Samples_Type) is
      begin
         X := JX;
         Y := JY;
      end Get_Joystick;

      procedure Set_Pilot_Button(B: in Integer) is
      begin
         if B = 1 and Pilot_Button = 0 then
            Toggle_Mode;
         end if;
         Pilot_Button := B;
      end Set_Pilot_Button;

      function Get_Pilot_Button return Integer is
      begin
         return Pilot_Button;
      end Get_Pilot_Button;

      procedure Set_Pilot_Presence(P: in Integer) is
      begin
         Pilot_Presence := P;
      end Set_Pilot_Presence;

      function Get_Pilot_Presence return Integer is
      begin
         return Pilot_Presence;
      end Get_Pilot_Presence;

      procedure Set_Distance(D: in Distance_Samples_Type) is
      begin
         Distance_Obs := D;
      end Set_Distance;

      function Get_Distance return Distance_Samples_Type is
      begin
         return Distance_Obs;
      end Get_Distance;

      procedure Toggle_Mode is
      begin
         if Current_Mode = Automatic then
            Current_Mode := Manual;
         else
            Current_Mode := Automatic;
         end if;
      end Toggle_Mode;

      function Get_Mode return Mode_Type is
      begin
         return Current_Mode;
      end Get_Mode;
   end Global_State;

   A_State : Aircraft_State;
   G_State : Global_State;

   procedure Set_LED_1(On_Off: Boolean) is
      aux : Integer;
   begin
      if On_Off then
         aux := set_led_1_A(1);
      else
         aux := set_led_1_A(0);
      end if;
   end Set_LED_1;

   procedure Set_LED_2(On_Off: Boolean) is
      aux : Integer;
   begin
      if On_Off then
         aux := set_led_2_A(1);
      else
         aux := set_led_2_A(0);
      end if;
   end Set_LED_2;

   -- Procedimientos para ajustar pitch y roll
   procedure Adjust_Pitch(P: Pitch_Samples_Type) is
      aux : Integer;
   begin
      A_State.Set_Pitch(P);
      aux := moveServo_A(Integer(P));
      declare
         p_val : Pitch_Samples_Type := A_State.Get_Pitch;
      begin
         if p_val > 5 and p_val < 15 then
            A_State.Increment_Altitude(20);
         elsif p_val >= 15 and p_val < 30 then
            A_State.Increment_Altitude(40);
         elsif p_val >= 30 then
            A_State.Increment_Altitude(60);
         elsif p_val < -5 and p_val > -15 then
            A_State.Increment_Altitude(-20);
         elsif p_val <= -15 and p_val > -30 then
            A_State.Increment_Altitude(-40);
         elsif p_val <= -30 then
            A_State.Increment_Altitude(-60);
         end if;
      end;
   end Adjust_Pitch;

   procedure Adjust_Roll(R: Roll_Samples_Type) is
      aux : Integer;
   begin
      A_State.Set_Roll(R);
      aux := moveServo_A(Integer(R));
   end Adjust_Roll;

   -- Procedimiento para ajustar velocidad
   procedure Adjust_Speed(PilotPower: Power_Samples_Type; IncreasePitch: Boolean; IncreaseRoll: Boolean) is
      Factor : constant Float := 1.2;
      DesiredSpeed : Integer := Integer(Float(PilotPower)*Factor);
      CurrentSpeed : Speed_Samples_Type := A_State.Get_Speed;
      NewSpeed     : Speed_Samples_Type := DesiredSpeed;
   begin
      if IncreasePitch and IncreaseRoll and (CurrentSpeed < 1000) then
         NewSpeed := DesiredSpeed + 250;
      elsif IncreasePitch and (CurrentSpeed < 1000) then
         NewSpeed := DesiredSpeed + 150;
      elsif IncreaseRoll and (CurrentSpeed < 1000) then
         NewSpeed := DesiredSpeed + 100;
      end if;

      if NewSpeed > 1000 then
         NewSpeed := 1000;
      elsif NewSpeed < 300 then
         NewSpeed := 300;
      end if;

      A_State.Set_Speed(NewSpeed);

      if NewSpeed >= 1000 or NewSpeed <= 300 then
         Set_LED_2(True);
      else
         Set_LED_2(False);
      end if;
   end Adjust_Speed;

   -- Procedimiento para chequear condiciones de altitud
   procedure Check_Altitude_Conditions is
      Alt : Altitude_Samples_Type := A_State.Get_Altitude;
   begin
      if Alt < 2500 then
         Set_LED_1(True);
      else
         Set_LED_1(False);
      end if;

      if Alt <= 2000 then
         Adjust_Pitch(0);
      end if;

      if Alt > 9500 then
         Set_LED_1(True);
      else
         Set_LED_1(False);
      end if;

      if Alt >= 10000 then
         Adjust_Pitch(0);
      end if;
   end Check_Altitude_Conditions;

   -- Procedimiento para chequear condiciones de roll
   procedure Check_Roll_Conditions is
      R : Roll_Samples_Type := A_State.Get_Roll;
   begin
      if R > 35 or R < -35 then
         Put_Line("ADVERTENCIA: Alabeo supera ±35 grados");
      end if;
   end Check_Roll_Conditions;

   -- Procedimiento para chequear obstáculos y actuar
   procedure Check_Obstacle_And_Act is
      Dist : Distance_Samples_Type := G_State.Get_Distance;
      Sp   : Speed_Samples_Type    := A_State.Get_Speed;
      Vis  : Light_Samples_Type    := G_State.Get_Visibility;
      PP   : Integer := G_State.Get_Pilot_Presence;
      M    : Mode_Type := G_State.Get_Mode;

      Time_To_Collision : Float;
      Threshold_Alarm   : Float := 10.0;
      Threshold_Manoeuv : Float := 5.0;
   begin
      if Dist > 5000.0 then
         return;
      end if;

      if Vis < 500 or PP = 0 then
         Threshold_Alarm := 15.0;
         Threshold_Manoeuv := 10.0;
      end if;

      declare
         Speed_ms : Float := Float(Sp)*0.27778;
      begin
         if Speed_ms <= 0.0 then
            return;
         end if;
         Time_To_Collision := Dist / Speed_ms;
      end;

      if Time_To_Collision < Threshold_Alarm then
         Put_Line("ALERTA: Objeto a menos de " & Float'Image(Time_To_Collision) & " s");
      end if;

      if M = Automatic and Time_To_Collision < Threshold_Manoeuv then
         declare
            Alt : Altitude_Samples_Type := A_State.Get_Altitude;
         begin
            if Alt <= 8500 then
               Adjust_Pitch(20);
               delay 3.0;
               Adjust_Pitch(0);
            else
               Adjust_Roll(45);
               delay 3.0;
               Adjust_Roll(0);
            end if;
         end;
      end if;
   end Check_Obstacle_And_Act;

   -- Tareas del sistema FSS

   -- Task para leer sensores
   task Sensors_Reading is
      pragma Priority(20);
   end Sensors_Reading;

   task body Sensors_Reading is
      Next_Time : Time := Clock;
      ADCs : Sensor_Vector; -- Asegúrate de que Sensor_Vector esté definido en Devices_A.ads
   begin
      loop
         read_all_ADC_sensors_A(ADCs);
         G_State.Set_Pilot_Power(ADCs(1));
         G_State.Set_Visibility(ADCs(2));
         G_State.Set_Pilot_Button(read_button_A);
         G_State.Set_Pilot_Presence(read_infrared_A);
         G_State.Set_Distance(getDistance_A);
         G_State.Set_Joystick(Read_Gyroscope_X_A, Read_Gyroscope_Y_A);
         Next_Time := Next_Time + Milliseconds(100);
         delay until Next_Time;
      end loop;
   end Sensors_Reading;

   -- Task para controlar pitch y altitud
   task Pitch_Altitude_Control is
      pragma Priority(15);
   end Pitch_Altitude_Control;

   task body Pitch_Altitude_Control is
      Next_Time : Time := Clock;
   begin
      loop
         Next_Time := Next_Time+ Pitch_Alt_Period;
         declare
            Jx, Jy : Joystick_Samples_Type;
            Alt    : Altitude_Samples_Type := A_State.Get_Altitude;
            M      : Mode_Type := G_State.Get_Mode;
         begin
            G_State.Get_Joystick(Jx, Jy);

            if Alt <= 2000 and Jy < 0 then
               Adjust_Pitch(0);
            elsif Alt >= 10000 and Jy > 0 then
               Adjust_Pitch(0);
            else
               if Jy > 30 then
                  Adjust_Pitch(30);
               elsif Jy < -30 then
                  Adjust_Pitch(-30);
               else
                  if Jy <= 3 and Jy >= -3 then
                     Adjust_Pitch(0);
                  else
                     Adjust_Pitch(Jy);
                  end if;
               end if;
            end if;

            Check_Altitude_Conditions;
         end;
         delay until Next_Time;
      end loop;
   end Pitch_Altitude_Control;

   -- Task para controlar roll
   task Roll_Control is
      pragma Priority(14);
   end Roll_Control;

   task body Roll_Control is
      Next_Time : Time := Clock;
   begin
      loop
         Next_Time := Next_Time+ Roll_Period;
         declare
            Jx, Jy : Joystick_Samples_Type;
         begin
            G_State.Get_Joystick(Jx, Jy);
            if Jx > 45 then
               Adjust_Roll(45);
            elsif Jx < -45 then
               Adjust_Roll(-45);
            else
               if Jx <= 3 and Jx >= -3 then
                  Adjust_Roll(0);
               else
                  Adjust_Roll(Jx);
               end if;
            end if;
            Check_Roll_Conditions;
         end;
         delay until Next_Time;
      end loop;
   end Roll_Control;

   -- Task para controlar velocidad
   task Speed_Control is
      pragma Priority(13);
   end Speed_Control;

   task body Speed_Control is
      Next_Time : Time := Clock;
   begin
      loop
         Next_Time := Next_Time+ Speed_Period;
         declare
            P        : Power_Samples_Type := G_State.Get_Pilot_Power;
            PitchVal : Pitch_Samples_Type := A_State.Get_Pitch;
            RollVal  : Roll_Samples_Type := A_State.Get_Roll;
            IncPitch : Boolean := (PitchVal > 0);
            IncRoll  : Boolean := (RollVal /= 0);
         begin
            Adjust_Speed(P, IncPitch, IncRoll);
         end;
         delay until Next_Time;
      end loop;
   end Speed_Control;

   -- Task para manejar obstáculos
   task Obstacle_Control is
      pragma Priority(12);
   end Obstacle_Control;

   task body Obstacle_Control is
      Next_Time : Time := Clock;
   begin
      loop
         Next_Time := Next_Time+ Obstacle_Period;
         Check_Obstacle_And_Act;
         delay until Next_Time;
      end loop;
   end Obstacle_Control;

   -- Task para mostrar datos
   task Display_Control is
      pragma Priority(10);
   end Display_Control;

   task body Display_Control is
      Next_Time : Time := Clock;
   begin
      loop
         Next_Time := Next_Time+ Display_Period;
         declare
            Alt : Altitude_Samples_Type := A_State.Get_Altitude;
            Spd : Speed_Samples_Type := A_State.Get_Speed;
            Pwr : Power_Samples_Type := G_State.Get_Pilot_Power;
            Jx, Jy : Joystick_Samples_Type;
            Pt : Pitch_Samples_Type := A_State.Get_Pitch;
            Rl : Roll_Samples_Type := A_State.Get_Roll;
            M  : Mode_Type := G_State.Get_Mode;
            Vis : Light_Samples_Type := G_State.Get_Visibility;
            Dist: Distance_Samples_Type := G_State.Get_Distance;
            Pres: Integer := G_State.Get_Pilot_Presence;

            -- Variables para strings
            Mode_String : String(1 .. 10) := (others => ' ');
            Pres_String : String(1 .. 8) := (others => ' ');
         begin
            -- Obtener Joystick
            G_State.Get_Joystick(Jx, Jy);

            -- Convertir Mode a string
            if M = Automatic then
               Mode_String := "Automático";
            else
               Mode_String := "Manual   ";
            end if;

            -- Convertir Presencia Piloto a string
            if Pres = 1 then
               Pres_String := "Presente";
            else
               Pres_String := "Ausente ";
            end if;

            -- Mostrar datos
            Put_Line("---- ESTADO DE LA AERONAVE ----");
            Put_Line("Modo: " & Mode_String);
            Put_Line("Altitud: " & Integer'Image(Alt));
            Put_Line("Potencia Piloto (ADC): " & Integer'Image(Pwr));
            Put_Line("Velocidad: " & Integer'Image(Spd));
            Put_Line("Joystick: X=" & Integer'Image(Jx) & " Y=" & Integer'Image(Jy));
            Put_Line("Pitch: " & Integer'Image(Pt));
            Put_Line("Roll: " & Integer'Image(Rl));
            Put_Line("Visibilidad (ADC): " & Integer'Image(Vis));
            Put_Line("Distancia Objeto: " & Float'Image(Dist));
            Put_Line("Presencia Piloto: " & Pres_String);
            Put_Line("-------------------------------");
         end;
         delay until Next_Time;
      end loop;
   end Display_Control;

   -- Procedimiento para lanzar tareas (no necesario, ya que las tareas se inician automáticamente)
   procedure Lanza_Tareas is
   begin
      Put_Line("Cuerpo del procedimiento Lanza_Tareas: las tareas del FSS ya están en ejecución");
      -- Las tareas se inician automáticamente al declarar los tasks.
   end Lanza_Tareas;

   -- Variables para recibir valores de funciones
   n: integer;
   aux : Integer;
   Dummy_Close : Integer;

begin
   -- Inicio del programa
   Put_Line("Arranca programa principal (control2)");

   -- Inicializar dispositivos
   n := Init_Devices_A;
   Put("Inicializados los dispositivos: "); Put(n, 3); New_Line;

   -- Lanzar tareas
   Lanza_Tareas;

   -- Bucle principal, las tareas trabajan en segundo plano.
   loop
      delay 1.0;
   end loop;

   -- Cerrar dispositivos (no alcanzado debido al loop infinito)
   Dummy_Close := close_devices_A;

end control2;
