#define LEDS 5
#define MOTOR 4
#define TASTER 14

#include <ESP8266WiFi.h>

void setup() {
  // Start Serial port
  Serial.begin(115200);
  
  pinMode(BUILTIN_LED, OUTPUT);
  digitalWrite(BUILTIN_LED, HIGH); 
  pinMode(LEDS, OUTPUT);
  digitalWrite(LEDS, LOW); 
  pinMode(MOTOR, OUTPUT);
  digitalWrite(MOTOR, LOW); 
  pinMode(TASTER, INPUT_PULLUP);
  
  delay(1000);
  
  Serial.println("Hallo!");
}

uint8_t running=0;
WiFiClient motorClient;
unsigned long lastUpdate=0;
IPAddress dest_addr( 192, 168, 4, 1 );

void loop() {  

  if(lastUpdate<millis()){
    analogWrite(MOTOR,0);            
  }
        
  if(digitalRead(TASTER)==LOW){
    if(running){
      running=0;
      Serial.println("OFF!");
      WiFi.disconnect();
      digitalWrite(BUILTIN_LED, HIGH);
      digitalWrite(LEDS, LOW); 
      Serial.println("delay 5000");
      delay(5000);      
    }
    else{
      running=1;
      Serial.println("Connecting ... ");
      digitalWrite(BUILTIN_LED, LOW);
      digitalWrite(LEDS, HIGH); 
      WiFi.mode(WIFI_STA);
      WiFi.begin("POV Display");
      Serial.println("delay 5000");
      delay(5000);      
    }
    
  }
  
  if(running){
      if (WiFi.status() != WL_CONNECTED) 
      {
        Serial.println("Wait for Wifi ...");
        delay(100);      
      }
      else if(motorClient.connected()){
        if(motorClient.available()){
          //get data from the telnet client and push it to the UART
          if(motorClient.available()){
            uint8_t pwm=0;
            while(motorClient.available()) pwm=motorClient.read();
            Serial.printf("PWM: %d\n",pwm);
            analogWrite(MOTOR,pwm*4);            
            lastUpdate= millis()+200; // we should get a pwm update ever 100ms to 200ms is too long 
          }
        }            
      }
      else{
        Serial.println("Connecting TCP ...");
        analogWrite(MOTOR,0);     // this can take some time => play it save!       
        if (!motorClient.connect(dest_addr,9999)) {
            Serial.println("connection failed");
            delay(100);      
        }     
        else{
          Serial.println("Connected TCP!");          
        }
      }
        
  }
}
