// ----------------------------------------------------------------------------
// DIY POV Dsiplay
// (c) 2019      Patrick Knöbel
// ----------------------------------------------------------------------------

#include <ArduinoWebsockets.h>
#include <WiFi.h>
#include <WebServer.h>
#include <img_converters.h>
#include "index.html.h"

using namespace websockets;
 
// Globals
WebServer server(80);

WebsocketsServer wsserver;
 
/***********************************************************
 * Functions
 */
  
 
/***********************************************************
 * Main
 */
uint8_t rgbbufer[(131*131+1)*3];
void setup() {
 
  // Start Serial port
  Serial.begin(115200);
 
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
  
  //i2s:
  i2s_config_t i2s_config = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX),
    .sample_rate =  2000000,              
    .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT, 
    .channel_format = I2S_CHANNEL_FMT_ONLY_RIGHT,
    .communication_format = I2S_COMM_FORMAT_I2S,
    .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
    .dma_buf_count = 8,
    .dma_buf_len = 64,
    .use_apll = false,
    .tx_desc_auto_clear = false,
    .fixed_mclk = 0
  };
  static const i2s_pin_config_t pin_config = {
    .bck_io_num = 26,
    .ws_io_num = 25,
    .data_out_num = 22,
    .data_in_num = I2S_PIN_NO_CHANGE
  };   
  i2s_driver_install(I2S_NUM_0, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_NUM_0, &pin_config);
   
}

WebsocketsClient client;
unsigned long laststatus;
void loop() {  
  server.handleClient();

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
          client.send("STATUS:25.2");
          laststatus= millis()+1000;
        }
        else{
          client.send("OK");          
        }
        if(msg.isText()){
          //settings
          Serial.printf("Steeings: %s\n",msg.data().c_str());
        }
        if(msg.isBinary()){
          //Image
          //decode:
          unsigned long start = micros();
          fmt2rgb888((uint8_t*)msg.data().c_str(),msg.data().length(),PIXFORMAT_JPEG,rgbbufer);
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
