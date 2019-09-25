#define LEDS 1
#define MOTOR 2
#define TASTER 2

#include <WiFi.h>

void setup() {
  // Start Serial port
  Serial.begin(115200);
  
  pinMode(LEDS, OUTPUT);
  digitalWrite(LEDS, LOW); 
  pinMode(MOTOR, OUTPUT);
  digitalWrite(MOTOR, LOW); 
  pinMode(TASTER, INPUT_PULLUP);
}

uint8_t running=0;
WiFiClient client;
unsigned long lastUpdate=0;

void loop() {  

  if(lastUpdate<millis()){
    analogWrite(MOTOR,0);            
  }
        
  if(digitalRead()==LOW){
    if(running){
      running=0;
      Serial.println("OFF!");
      WiFi.disconnect();
      digitalWrite(LEDS, LOW); 
      delay(1000);      
    }
    else{
      running=1;
      Serial.println("Connecting ... ");
      digitalWrite(LEDS, HIGH); 
      WiFi.begin("POV Display");
      delay(1000);      

    }
    
  }
  
  if(running){
      if (WiFi.status() != WL_CONNECTED) 
      {
          Serial.println("Wait for Wifi ...");
          delay(100);      
      }
      else if(motorClient && motorClient.connected()){
        if(motorClient.available()){
          //get data from the telnet client and push it to the UART
          if(motorClient.available()){
            uint8_t pwm=0
            while(motorClient.available()) pwm=motorClient.read();
            Serial.printf("PWM: %d",pwm);
            analogWrite(MOTOR,pwm*2);            
            lastUpdate= millis()+200; // we should get a pwm update ever 100ms to 200ms is too long 
          }
        }            
      }
      else{
        Serial.println("Connecting TCP ...");
        analogWrite(MOTOR,0);     // this can take some time => lay it save!       
        if (!client.connect("192.168.4.1", 9999)) {
            Serial.println("connection failed");
            delay(100);      
        }     
        else{
          Serial.println("Connected TCP!");          
        }
      }

      Serial.println("");
      Serial.println("WiFi connected");
      Serial.println("IP address: ");
      Serial.println(WiFi.localIP());
      
    
  }
}


/*
 *  This sketch sends data via HTTP GET requests to data.sparkfun.com service.
 *
 *  You need to get streamId and privateKey at data.sparkfun.com and paste them
 *  below. Or just customize this script to talk to other HTTP servers.
 *
 */

void setup()
{
    Serial.begin(115200);
    delay(10);

    // We start by connecting to a WiFi network

    Serial.println();
    Serial.println();
}

int value = 0;
 WiFiClient client;
void loop()
{
    delay(5000);
    ++value;

    Serial.print("connecting to ");
    Serial.println(host);

    // Use WiFiClient class to create TCP connections
    WiFiClient client;
    const int httpPort = 80;
    if (!client.connect(host, httpPort)) {
        Serial.println("connection failed");
        return;
    }

    // We now create a URI for the request
    String url = "/input/";
    url += streamId;
    url += "?private_key=";
    url += privateKey;
    url += "&value=";
    url += value;

    Serial.print("Requesting URL: ");
    Serial.println(url);

    // This will send the request to the server
    client.print(String("GET ") + url + " HTTP/1.1\r\n" +
                 "Host: " + host + "\r\n" +
                 "Connection: close\r\n\r\n");
    unsigned long timeout = millis();
    while (client.available() == 0) {
        if (millis() - timeout > 5000) {
            Serial.println(">>> Client Timeout !");
            client.stop();
            return;
        }
    }

    // Read all the lines of the reply from server and print them to Serial
    while(client.available()) {
        String line = client.readStringUntil('\r');
        Serial.print(line);
    }

    Serial.println();
    Serial.println("closing connection");
}
