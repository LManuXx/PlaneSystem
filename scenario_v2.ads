with Ada.Real_Time; use Ada.Real_Time;
with devicesfss_v1; use devicesfss_v1;

package Scenario_V2 is

    WCET_Distance: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Light: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Joystick: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_PilotPresence: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_PilotButton: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Power: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);
    WCET_Speed: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(7);
    WCET_Altitude: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(18);
    WCET_Pitch: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(20);
    WCET_Roll: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(18);
    WCET_Display: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(15);
    WCET_Alarm: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);

    cantidad_datos_Distancia: constant := 200;
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
              6000,6000,6000,6000,6000, 6000,6000,6000,6000,6000  --10s
);

    cantidad_datos_Light: constant := 200;
    type Indice_Secuencia_Light is mod cantidad_datos_Light;
    type tipo_Secuencia_Light is array (Indice_Secuencia_Light) of Light_Samples_Type;

    Light_Intensity_Simulation: tipo_Secuencia_Light :=  
                 ( 500,500,500,500,500, 500,500,500,500,500,   --1s
                   600,600,600,600,600, 700,700,700,700,700,   --2s
                   800,800,800,800,800, 900,900,900,900,900,   --3s
                   1000,1000,1000,1000,1000, 1100,1100,1100,1100,1100,   --4s
                   1200,1200,1200,1200,1200, 1300,1300,1300,1300,1300,  --5s
                   1400,1400,1400,1400,1400, 1500,1500,1500,1500,1500,    --6s
                   1600,1600,1600,1600,1600, 1700,1700,1700,1700,1700,    --7s
                   1800,1800,1800,1800,1800, 1900,1900,1900,1900,1900,    --8s
                   2000,2000,2000,2000,2000, 2100,2100,2100,2100,2100,    --9s
                   2200,2200,2200,2200,2200, 2300,2300,2300,2300,2300,    --10s
 );

    cantidad_datos_Joystick: constant := 200;
    type Indice_Secuencia_Joystick is mod cantidad_datos_Joystick;
    type tipo_Secuencia_Joystick is array (Indice_Secuencia_Joystick) of Joystick_Samples_Type;

    Joystick_Simulation: tipo_Secuencia_Joystick :=  
                ((+00,+00),(+10,+10),(+20,+20),(+30,+30),(+40,+40),   
                 (+50,+50),(+60,+60),(+70,+70),(+80,+80),(+90,+90),  --1s
                 
                 (+100,+100),(+90,+90),(+80,+80),(+70,+70),(+60,+60),   
                 (+50,+50),(+40,+40),(+30,+30),(+20,+20),(+10,+10),   --2s

                 (+00,+00),(+00,+00),(-10,-10),(-20,-20),(-30,-30),  
                 (-40,-40),(-50,-50),(-60,-60),(-70,-70),(-80,-80),   --3s

                 (-90,-90),(-100,-100),(-90,-90),(-80,-80),(-70,-70),   
                 (-60,-60),(-50,-50),(-40,-40),(-30,-30),(-20,-20),   --4s

                 (-10,-10),(+00,+00),(+00,+00),(+00,+00),(+00,+00),   
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,+00),   --5s

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,+00),   
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,+00),   --6s

                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,+00)    --7s
                 (+00,+00),(+00,+00),(+00,+00),(+00,+00),(+00,+00),
                 
                 (-90,-90),(-100,-100),(-90,-90),(-80,-80),(-70,-70),   --8s
                 (-60,-60),(-50,-50),(-40,-40),(-30,-30),(-20,-20),

                 (+100,+100),(+90,+90),(+80,+80),(+70,+70),(+60,+60),   --9s
                 (+50,+50),(+40,+40),(+30,+30),(+20,+20),(+10,+10), 

                 (+00,+00),(+00,+00),(-10,-10),(-20,-20),(-30,-30),  --10s
                 (-40,-40),(-50,-50),(-60,-60),(-70,-70),(-80,-80), 
                 );  

    cantidad_datos_Power: constant := 200;
    type Indice_Secuencia_Power is mod cantidad_datos_Power;
    type tipo_Secuencia_Power is array (Indice_Secuencia_Power) of Power_Samples_Type;

    Power_Simulation: tipo_Secuencia_Power :=  
                 ( 500,500,500,500,500, 600,600,600,600,600,   --1s
                   700,700,700,700,700, 800,800,800,800,800,   --2s
                   900,900,900,900,900, 1000,1000,1000,1000,1000,   --3s
                   1100,1100,1100,1100,1100, 1200,1200,1200,1200,1200,  --4s 
                   1300,1300,1300,1300,1300, 1400,1400,1400,1400,1400,  --5s
                   1500,1500,1500,1500,1500, 1600,1600,1600,1600,1600,    --6s
                   1700,1700,1700,1700,1700, 1800,1800,1800,1800,1800,    --7s
                   1900,1900,1900,1900,1900, 2000,2000,2000,2000,2000,    --8s
                   2100,2100,2100,2100,2100, 2200,2200,2200,2200,2200,    --9s
                   2300,2300,2300,2300,2300, 2400,2400,2400,2400,2400 );  --10s

end Scenario_V2;
