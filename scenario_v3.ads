with Ada.Real_Time; use Ada.Real_Time;
with devicesfss_v1; use devicesfss_v1;

package Scenario_V3 is

    ---------------------------------------------------------------------
    -- Tiempo máximo de ejecución para los datos de simulación
    ---------------------------------------------------------------------
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

    ---------------------------------------------------------------------
    -- Simulación de Altitud
    ---------------------------------------------------------------------
    cantidad_datos_Altitud: constant := 100;
    type Indice_Secuencia_Altitud is mod cantidad_datos_Altitud;
    type tipo_Secuencia_Altitud is array (Indice_Secuencia_Altitud) of Altitude_Samples_Type;

    Altitude_Simulation: tipo_Secuencia_Altitud :=  
        ( 8000, 8000, 8000, 8000, 8000,  7900, 7900, 7900, 7900, 7900,   --1s
          7800, 7800, 7800, 7800, 7800,  7700, 7700, 7700, 7700, 7700,   --2s
          7600, 7600, 7600, 7600, 7600,  7500, 7500, 7500, 7500, 7500,   --3s
          7400, 7400, 7400, 7400, 7400,  7300, 7300, 7300, 7300, 7300,   --4s
          7200, 7200, 7200, 7200, 7200,  7100, 7100, 7100, 7100, 7100,   --5s
          7000, 7000, 7000, 7000, 7000,  6900, 6900, 6900, 6900, 6900,   --6s
          6800, 6800, 6800, 6800, 6800,  6700, 6700, 6700, 6700, 6700,   --7s
          6600, 6600, 6600, 6600, 6600,  6500, 6500, 6500, 6500, 6500,   --8s
          6400, 6400, 6400, 6400, 6400,  6300, 6300, 6300, 6300, 6300,   --9s
          6200, 6200, 6200, 6200, 6200,  6100, 6100, 6100, 6100, 6100);  --10s

    ---------------------------------------------------------------------
    -- Simulación de Velocidad
    ---------------------------------------------------------------------
    cantidad_datos_Velocidad: constant := 100;
    type Indice_Secuencia_Velocidad is mod cantidad_datos_Velocidad;
    type tipo_Secuencia_Velocidad is array (Indice_Secuencia_Velocidad) of Speed_Samples_Type;

    Speed_Simulation: tipo_Secuencia_Velocidad :=  
        ( 500, 510, 520, 530, 540,  550, 560, 570, 580, 590,   --1s
          600, 610, 620, 630, 640,  650, 660, 670, 680, 690,   --2s
          700, 710, 720, 730, 740,  750, 760, 770, 780, 790,   --3s
          800, 810, 820, 830, 840,  850, 860, 870, 880, 890,   --4s
          900, 910, 920, 930, 940,  950, 960, 970, 980, 990,   --5s
          1000, 1010, 1020, 1030, 1040,  1050, 1060, 1070, 1080, 1090,   --6s
          1100, 1090, 1080, 1070, 1060,  1050, 1040, 1030, 1020, 1010,   --7s
          1000, 990, 980, 970, 960,  950, 940, 930, 920, 910,   --8s
          900, 890, 880, 870, 860,  850, 840, 830, 820, 810,   --9s
          800, 790, 780, 770, 760,  750, 740, 730, 720, 710);  --10s

    ---------------------------------------------------------------------
    -- Simulación de Potencia
    ---------------------------------------------------------------------
    cantidad_datos_Power: constant := 100;
    type Indice_Secuencia_Power is mod cantidad_datos_Power;
    type tipo_Secuencia_Power is array (Indice_Secuencia_Power) of Power_Samples_Type;

    Power_Simulation: tipo_Secuencia_Power :=  
        ( 200, 210, 220, 230, 240,  250, 260, 270, 280, 290,   --1s
          300, 310, 320, 330, 340,  350, 360, 370, 380, 390,   --2s
          400, 410, 420, 430, 440,  450, 460, 470, 480, 490,   --3s
          500, 510, 520, 530, 540,  550, 560, 570, 580, 590,   --4s
          600, 610, 620, 630, 640,  650, 660, 670, 680, 690,   --5s
          700, 710, 720, 730, 740,  750, 760, 770, 780, 790,   --6s
          800, 790, 780, 770, 760,  750, 740, 730, 720, 710,   --7s
          700, 690, 680, 670, 660,  650, 640, 630, 620, 610,   --8s
          600, 590, 580, 570, 560,  550, 540, 530, 520, 510,   --9s
          500, 490, 480, 470, 460,  450, 440, 430, 420, 410);  --10s

end Scenario_V3;
