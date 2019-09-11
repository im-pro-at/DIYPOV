// ----------------------------------------------------------------------------
// DIY POV Dsiplay
// (c) 2019      Patrick Knöbel
// ----------------------------------------------------------------------------

#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <WebSocketsServer.h>

#include "index.html.h"
#include "favicon.ico.h"

 
// Globals
AsyncWebServer server(80);
WebSocketsServer webSocket = WebSocketsServer(1337);
char msg_buf[10];
int led_state = 0;
 
/***********************************************************
 * Functions
 */
 
// Callback: receiving any WebSocket message
void onWebSocketEvent(uint8_t client_num,
                      WStype_t type,
                      uint8_t * payload,
                      size_t length) {
 
  // Figure out the type of WebSocket event
  switch(type) {
 
    // Client has disconnected
    case WStype_DISCONNECTED:
      Serial.printf("[%u] Disconnected!\n", client_num);
      break;
 
    // New client has connected
    case WStype_CONNECTED:
      {
        IPAddress ip = webSocket.remoteIP(client_num);
        Serial.printf("[%u] Connection from ", client_num);
        Serial.println(ip.toString());
      }
      break;
 
    // Handle text messages from client
    case WStype_TEXT:
 
      // Print out raw message
      Serial.printf("[%u] Received text: %s\n", client_num, payload);
 
      // Toggle LED
      if ( strcmp((char *)payload, "toggleLED") == 0 ) {
//        led_state = led_state ? 0 : 1;
        Serial.printf("Toggling LED to %u\n", 1);
        //digitalWrite(led_pin, led_state);
 
      // Report the state of the LED
      } else if ( strcmp((char *)payload, "getLEDState") == 0 ) {
        sprintf(msg_buf, "%d", 1);
        Serial.printf("Sending to [%u]: %s\n", client_num, msg_buf);
        webSocket.sendTXT(client_num, msg_buf);
 
      // Message not recognized
      } else {
        Serial.println("[%u] Message not recognized");
      }
      break;
 
    // For everything else: do nothing
    case WStype_BIN:
      Serial.printf("[%u] get binary length: %u\n", num, length);
    case WStype_ERROR:
    case WStype_FRAGMENT_TEXT_START:
    case WStype_FRAGMENT_BIN_START:
    case WStype_FRAGMENT:
    case WStype_FRAGMENT_FIN:
    default:
        Serial.printf("WUPS ...\n");
      break;
  }
}
 
 
/***********************************************************
 * Main
 */
 
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
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
    request->send(200, "text/html", INDEX_HTML);
  });
  server.on("/favicon.ico", HTTP_GET, [](AsyncWebServerRequest *request) {
    AsyncWebServerResponse *response = request->beginResponse_P(200, "image/x-icon", FAVICON_ICON, FAVICON_ICON_LEN);
    request->send(response);
  });
  // Handle requests for pages that do not exist
  server.onNotFound( [](AsyncWebServerRequest *request) {
    request->send(404, "text/plain", "Not found");
  });
 
  // Start web server
  server.begin();
 
  // Start WebSocket server and assign callback
  webSocket.begin();
  webSocket.onEvent(onWebSocketEvent);
  
}
 
void loop() {
  
  // Look for and handle WebSocket data
  webSocket.loop();
}
