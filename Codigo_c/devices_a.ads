
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;

Package devices_a is 

-----------------------------------------------------
--    IMPORTAMOS LA LIBRERÍA DE DISPOSITIVOS DE C
-----------------------------------------------------

 type Sensor_Vector is array (1..8) of integer; 
        
 function Init_Devices_A return integer;
 pragma Import (C, Init_Devices_A,"init_devices");

 procedure read_all_ADC_sensors_A (ADCsensors: out Sensor_Vector);
 pragma Import (C, read_all_ADC_sensors_A, "read_all_ADC_sensors");

 function read_single_ADC_sensor_A (channel_number: in integer) return integer;
 pragma Import (C, read_single_ADC_sensor_A,"read_single_ADC_sensor");


 function read_button_A return integer;
 pragma Import (C, read_button_A, "read_button");
 
 function read_infrared_A return integer;
 pragma Import (C, read_infrared_A, "read_infrared");
 

 function set_led_1_A (Led_1: in integer) return integer;
 pragma Import (C, set_led_1_A,"set_led_1");

 function set_led_2_A (Led_2: in integer) return integer;
 pragma Import (C, set_led_2_A,"set_led_2");

 
 function moveServo_A (angle: in integer) return integer;
 pragma Import (C, moveServo_A,"moveServo");
 

 function Read_Gyroscope_X_A return integer;
 pragma Import (C, Read_Gyroscope_X_A, "Read_Gyroscope_X");
 
 function Read_Gyroscope_Y_A return integer;
 pragma Import (C, Read_Gyroscope_Y_A, "Read_Gyroscope_Y");
 
 function getDistance_A return float;
 pragma Import (C, getDistance_A, "getDistance");
 

 function close_devices_A return integer;
 pragma Import (C, close_devices_A,"close_devices");


-----------------------------------------------------  
 
end devices_a;




