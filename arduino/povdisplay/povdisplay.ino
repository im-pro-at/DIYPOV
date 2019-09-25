// ----------------------------------------------------------------------------
// DIY POV Dsiplay
// (c) 2019      Patrick Knöbel
// ----------------------------------------------------------------------------

#define SPI_CLK 13
#define SPI_DAT 12
#define WING0 14
#define WING1 27
#define LEDGOUP0 26
#define LEDGOUP1 25

#define I2S_R0 13
#define I2S_R1 12
#define I2S_R2 14
#define I2S_R3 27
#define I2S_G0 26
#define I2S_G1 25
#define I2S_G2 33
#define I2S_G3 32
#define I2S_B0 15
#define I2S_B1 2
#define I2S_B2 4
#define I2S_B3 16
#define I2S_SY 17
#define I2S_CK 5
#define I2S_EN 18

#define TIGGER 19

#include <WiFi.h>
#include <WebServer.h>
#include <img_converters.h>
#include "index.html.h"

#include <ArduinoWebsockets.h>
#include <AutoPID.h>

extern "C" {
#include "common.h"
#include "i2s_parallel.h"
}


using namespace websockets;
// Globals
WebServer server(80);
WebsocketsServer wsserver;
WiFiServer motorServer(9999);

double pid_in=0, pid_out=0, pid_set=0;
AutoPID myPID(&pid_in, &pid_set, &pid_out, 0, 255, 10, 10, 0);

#define B_LEN (131*131+1) //word al.
uint8_t *rgbbufer;
uint16_t buffer[B_LEN];
i2s_parallel_buffer_desc_t bufdesc;
i2s_parallel_config_t cfg;

uint8_t I2S_started=0;
void start_I2S(){
  if(I2S_started==1){
    return; //just start once
  }
  digitalWrite(I2S_EN, HIGH); 
  
  I2S_started=1;
  bufdesc.memory = buffer;
  bufdesc.size = B_LEN*2; //16 bit
  cfg.gpio_bus[ 0] = I2S_R0; //D0 = R0
  cfg.gpio_bus[ 1] = I2S_R1; //D1 = R1
  cfg.gpio_bus[ 2] = I2S_R2; //D2 = R2
  cfg.gpio_bus[ 3] = I2S_R3; //D3 = R3
  cfg.gpio_bus[ 4] = I2S_G0; //D4 = G0
  cfg.gpio_bus[ 5] = I2S_G1; //D5 = G1
  cfg.gpio_bus[ 6] = I2S_G2; //D6 = G2
  cfg.gpio_bus[ 7] = I2S_G3; //D7 = G3
  cfg.gpio_bus[ 8] = I2S_B0; //D8 = B0
  cfg.gpio_bus[ 9] = I2S_B1; //D9 = B1
  cfg.gpio_bus[10] = I2S_B2; //D10= B2
  cfg.gpio_bus[11] = I2S_B3; //D11= B3
  cfg.gpio_bus[12] = I2S_SY; //SYNC
  cfg.gpio_clk = I2S_CK;	// XCK
  cfg.bits = I2S_PARALLEL_BITS_16;
  cfg.clkspeed_hz = 4*1000*1000;//resulting pixel clock = 2MHz
  cfg.buf = &bufdesc;

  i2s_parallel_setup(&I2S1, &cfg);    
}


void SPI_send(uint8_t c){

  for (int i=8; i>=0 ;i--)
  {
    digitalWrite(SPI_DAT, (c&(1<<i))?HIGH:LOW); 
  
    delayMicroseconds(1);                
    digitalWrite(SPI_CLK, HIGH); 

    delayMicroseconds(1);
  
    digitalWrite(SPI_CLK, LOW); 
  }
}

unsigned long last_shwon = 0;
uint8_t pos=0;
uint8_t color=0;
const uint8_t ledgrouplength[] ={5,6,8,14};
void show_test_pattern(){
  if(I2S_started==1){
    return; //no Testpattern we have I2S running
  }
  
  for(uint8_t wing=0;wing<4;wing++){
    digitalWrite(WING0, (wing%2)?HIGH:LOW); 
    digitalWrite(WING1, (wing/2)?HIGH:LOW); 
    uint8_t counter=0;
    for(uint8_t goup=0;goup<4;goup++){
      digitalWrite(LEDGOUP0, (goup%2)?HIGH:LOW); 
      digitalWrite(LEDGOUP1, (goup/2)?HIGH:LOW); 
      delayMicroseconds(1);
      // Start Frame 
      SPI_send(0x00);  
      SPI_send(0x00);
      SPI_send(0x00);
      SPI_send(0x00); 
      for(uint8_t length=0;length<ledgrouplength[goup];length++){
        uint8_t rgb[]= {0,0,0};
        if(counter==pos){
          rgb[color%3]=50;
        }
        SPI_send(0xFF);  // Maximum global brightness
        SPI_send(rgb[0]);
        SPI_send(rgb[1]);
        SPI_send(rgb[2]);          
        counter++;
      }
      // Reset frame - Only needed for SK9822, has no effect on APA102
      SPI_send(0x00);  
      SPI_send(0x00);
      SPI_send(0x00);
      SPI_send(0x00);    
      // End frame: 8+8*(leds >> 4) clock cycles    
      for (uint8_t i=0; i<ledgrouplength[goup]; i+=16)
      {
        SPI_send(0x00);  // 8 more clock cycles
      }      
 
  }
    
  }
  if((unsigned long)(millis() - last_shwon) > 1000){
    last_shwon = millis();
    pos++;
    if(pos>33){
      pos=0;
    }
  }
}

volatile uint64_t last_tigger= 0;
volatile uint32_t d_tigger=0;
void IRAM_ATTR tigger_ISR(){
  static uint64_t last_trigger_time=0;
  uint64_t trigger_time= esp_timer_get_time();
  if(trigger_time-last_trigger_time<(500*1000) && trigger_time-last_trigger_time>(10*1000)) //min 2 RPS /max 100 RPS => max 500ms /min 10ms
  {
    d_tigger=trigger_time-last_trigger_time;
    last_tigger=last_trigger_time;
  }
  color++; // change test pattern
  Serial.print("T");
  last_trigger_time=trigger_time;
}

void setup() {
  // Start Serial port
  Serial.begin(115200);

  //init buffers
  rgbbufer = (uint8_t *) heap_caps_calloc(B_LEN, 3, MALLOC_CAP_8BIT);
  Serial.printf("rgbbufer %ld\n",rgbbufer);
  Serial.printf("buffer %ld\n",buffer);
  
  // Start access point
  WiFi.softAP("POV Display");
 
  // Print our IP address
  Serial.println();
  Serial.println("AP running");
  Serial.print("My IP address: ");
  Serial.println(WiFi.softAPIP());
 
  // On HTTP request for root, provide index.html file
  server.on("/", HTTP_GET, []() {
    server.send_P(200, "text/html", INDEX_HTML);
  });  

  // Handle requests for pages that do not exist
  server.onNotFound( []() {
    server.send(200, "text/html", INDEX_HTML);
  });
 
  // Start web server
  server.begin();
  
  pinMode(SPI_CLK, OUTPUT); //clock
  pinMode(SPI_DAT, OUTPUT); //data
  pinMode(WING0, OUTPUT); 
  pinMode(WING1, OUTPUT); 
  pinMode(LEDGOUP0, OUTPUT); 
  pinMode(LEDGOUP1, OUTPUT); 
  pinMode(I2S_EN, OUTPUT); 
  
  pinMode(TIGGER, INPUT_PULLDOWN);
  attachInterrupt(digitalPinToInterrupt(TIGGER), tigger_ISR, RISING);  

  motorServer.begin();
  motorServer.setNoDelay(true);
  
  myPID.setBangBang(10);
  myPID.setTimeStep(10);  
  
}

WebsocketsClient client;
unsigned long laststatus=0;

unsigned long motorupdate=0;
WiFiClient motorClient;

void loop() {  

  server.handleClient();
  
  show_test_pattern();
  
  if(pid_set==0){
    last_tigger=esp_timer_get_time();
    d_tigger=0;
  }
  
  if((last_tigger + 3*1000*1000)<esp_timer_get_time()){ // no trigger for 3 secound => tun motor off!!!
    pid_in=100;    //simulate high spinning motor => pid_out =0
  }
  else{
    if(d_tigger==0){
      pid_in=0;
    }
    else{
      pid_in=1000000.0/d_tigger;      
    }
  }
  myPID.run();
  
  if(motorClient && motorClient.connected()){
    if(motorServer.hasClient()){
      motorServer.available().stop();
    } 
    if(motorClient.available()){
      //get data from the telnet client and push it to the UART
      while(motorClient.available()) Serial.printf("ESP8266: %d \n",motorClient.read());
    }    
    if(motorupdate<millis()){  
      Serial.printf("Motor: Rps IN %f SET %f OUT %f \n",pid_in,pid_set,pid_out);  
      motorClient.write((uint8_t)pid_out);                
      motorupdate= millis()+100;
    }
  }
  else if(motorServer.hasClient()){
    if(motorClient){
      motorClient.stop();      
    }
    motorClient = motorServer.available();
    last_tigger=esp_timer_get_time();
    d_tigger=0;
    Serial.println("ESP8266 connected!");
  }

  if(client.available()) {
    client.poll();    
  }
  else if(wsserver.available()){
    if(wsserver.poll()){
      Serial.println("New Connection");
      client.close();
      client = wsserver.accept();
      client.onMessage([](WebsocketsClient& client, WebsocketsMessage msg) {
        Serial.printf("Message T%d B%d Pi%d Po%d C%d stream%d length: %u\n", msg.isText(), msg.isBinary(), msg.isPing(), msg.isPong(), msg.isClose(),msg.isPartial(), msg.data().length());
        if(laststatus<millis()){
          char buffer[20];
          snprintf(buffer, sizeof(buffer) - 1, "STATUS:%.2f",pid_in==100?-1:pid_in);
          client.send(buffer);
          laststatus= millis()+1000;
        }
        else{
          client.send("OK");          
        }
        if(msg.isText()){
          //settings
          const char * settings =msg.data().c_str();
          settings = strchr(settings,':')+1;
          pid_set = atof(settings);
          Serial.printf("Steeings: %s => set_d: %f \n",msg.data().c_str(),pid_set);
        }
        if(msg.isBinary()){
          //Image
          //decode:
          unsigned long start = micros();
          fmt2rgb888((uint8_t*)msg.data().c_str(),msg.data().length(),PIXFORMAT_JPEG,rgbbufer);
                    
          buffer[1]=((rgbbufer[0]&0xF0)>>4) | ((rgbbufer[1]&0xF0)) | ((rgbbufer[2]&0xF0)<<4) | (1<<12);
          buffer[0]=((rgbbufer[3]&0xF0)>>4) | ((rgbbufer[4]&0xF0)) | ((rgbbufer[5]&0xF0)<<4);
          
          uint32_t j=6;
          for(uint32_t i=2;i<B_LEN;i+=2){    
            buffer[i+1]=((rgbbufer[j+0]&0xF0)>>4) | ((rgbbufer[j+1]&0xF0)) | ((rgbbufer[j+2]&0xF0)<<4);
            buffer[i+0]=((rgbbufer[j+3]&0xF0)>>4) | ((rgbbufer[j+4]&0xF0)) | ((rgbbufer[j+5]&0xF0)<<4);
            j+=6;
          }

          start_I2S();

          unsigned long ende = micros();
          Serial.printf("Convert took %lu us \n",ende-start);
           
          Serial.println(ESP.getFreeHeap());
        }
        
      });      
    }
  }
  else {
    Serial.println("Start Server");
    wsserver.listen(8080);
  }

}
