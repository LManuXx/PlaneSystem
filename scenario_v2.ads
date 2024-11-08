
with Ada.Real_Time; use Ada.Real_Time;
with devicesfss_v1; use devicesfss_v1;

package Scenario_V2 is

    WCET_Distance: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);
    WCET_Light: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);
    WCET_Joystick: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);
    WCET_PilotPresence: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);
    WCET_PilotButton: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);
    WCET_Power: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(2);
    WCET_Speed: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Altitude: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(9);
    WCET_Pitch: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(10);
    WCET_Roll: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(9);
    WCET_Display: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(7);
    WCET_Alarm: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);

    cantidad_datos_Distancia: constant := 100;
    type Indice_Secuencia_Distancia is mod cantidad_datos_Distancia;
    type tipo_Secuencia_Distancia is array (Indice_Secuencia_Distancia) of Distance_Samples_Type;

    Distance_Simulation: tipo_Secuencia_Distancia :=  
            ( 6000,6000,6000,6000,6000, 6000,6000,6000,6000,6000,  --1s
              5000,5000,5000,5000,5000, 5000,5000,5000,5000,5000,  --2s
              4000,4000,4000,4000,4000, 3000,3000,3000,3000,3000,  --3s
              2500,2500,2500,2500,2500, 2000,2000,2000,2000,2000,  --4s
              1500,1500,1500,1500,1500, 1000,1000,1000,1000,1000, --5s
              500,500,500,500,500, 400,400,400,400,400,    --6s
              300,300,300,300,300, 200,200,200,200,200,    --7s
              100,100,100,100,100, 50,50,50,50,50,    --8s
              6000,6000,6000,6000,6000, 6000,6000,6000,6000,6000,  --9s
              6000,6000,6000,6000,6000, 6000,6000,6000,6000,6000);  --10s


    cantidad_datos_Light: constant := 100;
    type Indice_Secuencia_Light is mod cantidad_datos_Light;
    type tipo_Secuencia_Light is array (Indice_Secuencia_Light) of Light_Samples_Type;

    Light_Intensity_Simulation: tipo_Secuencia_Light :=  
                 ( 500,500,500,500,500, 500,500,500,500,500,   --1s
                   600,600,600,600,600, 700,700,700,700,700,   --2s
                   800,800,800,800,800, 900,900,900,900,900,   --3s
                   1000,1000,1000,1000,1000, 1021,1021,1021,1021,1021,   --4s
                   900,900,900,900,900, 950,950,950,950,950,  --5s
                   1010,1010,1010,1010,1010, 990,990,990,990,990,    --6s
                   700,700,700,700,700, 600,600,600,600,600,    --7s
                   500,500,500,500,500, 400,400,400,400,400,    --8s
                   450,450,450,450,450, 350,350,350,350,350,    --9s
                   300,300,300,300,300, 250,250,250,250,250);   --10s
 
    cantidad_datos_Joystick: constant := 100;
    type Indice_Secuencia_Joystick is mod cantidad_datos_Joystick;
    type tipo_Secuencia_Joystick is array (Indice_Secuencia_Joystick) of Joystick_Samples_Type;

    Joystick_Simulation: tipo_Secuencia_Joystick :=  
                ((+00,+00),(+10,+10),(+20,+20),(+30,+30),(+40,+40),   
                 (+50,+50),(+60,+60),(+70,+70),(+80,+80),(+90,+90),  --1s
                 
                 (+90,+90),(+85,+85),(+80,+80),(+70,+70),(+60,+60),   
                 (+50,+50),(+40,+40),(+30,+30),(+20,+20),(+10,+10),   --2s

                 (+00,+00),(+00,+00),(-10,-10),(-20,-20),(-30,-30),  
                 (-40,-40),(-50,-50),(-60,-60),(-70,-70),(-80,-80),   --3s

                 (-90,-90),(-85,-85),(-85,-85),(-80,-80),(-70,-70),   
                 (-60,-60),(-50,-50),(-40,-40),(-30,-30),(-20,-20),   --4s

                 (-10,-10),(+00,+00),(+00,+00),(+00,+00),(+00,+00),   
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,+00),   --5s

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,+00),   
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,+00),   --6s

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,+00),    --7s
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,+00),
                 
                 (-90,-90),(-90,-90),(-85,-85),(-80,-80),(-70,-70),   --8s
                 (-60,-60),(-50,-50),(-40,-40),(-30,-30),(-20,-20),

                 (+90,+90),(+85,+85),(+80,+80),(+70,+70),(+60,+60),   --9s
                 (+50,+50),(+40,+40),(+30,+30),(+20,+20),(+10,+10), 

                 (+00,+00),(+00,+00),(-10,-10),(-20,-20),(-30,-30),  --10s
                 (-40,-40),(-50,-50),(-60,-60),(-70,-70),(-80,-80));  

    cantidad_datos_Power: constant := 100;
    type Indice_Secuencia_Power is mod cantidad_datos_Power;
    type tipo_Secuencia_Power is array (Indice_Secuencia_Power) of Power_Samples_Type;

    Power_Simulation: tipo_Secuencia_Power :=  
                 ( 200, 200, 200, 200, 200, 243, 243, 243, 243, 243,    --1s
                    287, 287, 287, 287, 287, 330, 330, 330, 330, 330,    --2s
                    373, 373, 373, 373, 373, 417, 417, 417, 417, 417,    --3s
                    460, 460, 460, 460, 460, 503, 503, 503, 503, 503,    --4s
                    547, 547, 547, 547, 547, 590, 590, 590, 590, 590,    --5s
                    633, 633, 633, 633, 633, 676, 676, 676, 676, 676,    --6s
                    720, 720, 720, 720, 720, 763, 763, 763, 763, 763,    --7s
                    806, 806, 806, 806, 806, 850, 850, 850, 850, 850,    --8s
                    893, 893, 893, 893, 893, 936, 936, 936, 936, 936,    --9s
                    980, 980, 980, 980, 980, 1023, 1023, 1023, 1023, 1023 );--10s

    
    cantidad_datos_PilotPresence: constant := 100;
    type Indice_Secuencia_PilotPresence is mod cantidad_datos_PilotPresence;
    type tipo_Secuencia_PilotPresence is array (Indice_Secuencia_PilotPresence) of PilotPresence_Samples_Type;
    PilotPresence_Simulation: tipo_Secuencia_PilotPresence :=  -- 1 muestra cada 100ms.
                 ( 1,1,1,1,1, 1,1,1,1,1,   -- 1s. 
                   1,1,1,1,1, 1,1,1,1,1,   -- 2s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 3s.
                   1,1,1,1,1, 1,1,0,1,0,   -- 4s. 
                   1,1,1,1,1, 1,1,1,1,1,   -- 5s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 6s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 7s.
                   1,1,1,1,1, 1,1,1,1,1,   -- 8s. 
                   1,1,0,0,1, 1,1,1,1,1,   -- 9s.
                   1,1,1,1,1, 1,1,1,1,1);   -- 10s.

    cantidad_datos_PilotButton: constant := 100;
    type Indice_Secuencia_PilotButton is mod cantidad_datos_PilotButton;
    type tipo_Secuencia_PilotButton is array (Indice_Secuencia_PilotButton) of PilotButton_Samples_Type;
    PilotButton_Simulation: tipo_Secuencia_PilotButton :=  -- 1 muestra cada 100ms.
                 ( 0,0,0,0,0, 0,0,0,0,0,   -- 1s. 
                   0,0,0,0,0, 1,1,1,0,0,   -- 2s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 3s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 4s. 
                   1,1,1,1,0, 0,0,0,0,0,   -- 5s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 6s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 7s.
                   0,0,0,0,0, 0,0,0,0,0,   -- 8s. 
                   0,0,0,0,0, 0,0,0,0,0,   -- 9s.
                   0,0,0,0,0, 0,0,0,0,0);  -- 10s. 
end Scenario_V2;
