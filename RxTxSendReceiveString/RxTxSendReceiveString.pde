/*
  UDPSendReceive.pde:
 This sketch receives UDP message strings, prints them to the serial port
 and sends an "acknowledge" string back to the sender
 
 A Processing sketch is included at the end of file that can be used to send 
 and received messages for testing with a computer.
 
 created 21 Aug 2010
 by Michael Margolis
 
 This code is in the public domain.
 */
#include <SPI.h>
#include <SoftEasyTransfer.h>

/*   For Arduino 1.0 and newer, do this:   */
#include <NewSoftSerial.h>

NewSoftSerial mySerial(14, 16);

#define base 20
#define DEBUG
#define packetlen 32
// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
SoftEasyTransfer ET; 

struct SEND_DATA_STRUCTURE{
  //put your variable definitions here for the data you want to send
  //THIS MUST BE EXACTLY THE SAME ON THE OTHER ARDUINO
  char  Buffer[packetlen];
};
SEND_DATA_STRUCTURE mydata;

int   count;
int raypin[30] ={29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0};
               //30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1
void setup() {
  // start the Ethernet and UDP:
  count = 0;
  for (int i=0; i < 30; i++) 
  { 
    pinMode(i+base, INPUT);
  }
  mySerial.begin(9600);
  //start the library, pass in the data details and the name of the serial port.
  ET.begin(details(mydata), &mySerial);
  Serial.begin(9600);
}

void loop() 
{
  if (Serial.available() > 0) 
  {
    // read the incoming byte:
    mydata.Buffer[count++] = Serial.read();
    delay(2);
  }
  else if( mydata.Buffer[0] != 0 )
  {
    #ifdef DEBUG
    Serial.println( mydata.Buffer );
    #endif
    ET.sendData();
    // if there's data available, read a packet
    memset(mydata.Buffer,0,packetlen);
    count = 0;
    //delay(10);  //原本33，後改為10，反應速度更好
  }
  else
  {
    for (int i=0; i < 30; i++) 
    {
      int sensorValue = digitalRead(i+base);
      mydata.Buffer[raypin[i]] = sensorValue + '0';
    }
    mydata.Buffer[30] = 0; 
  }
}


/*
  Processing sketch to run with this example
 =====================================================
 
 // Processing UDP example to send and receive string data from Arduino 
 // press any key to send the "Hello Arduino" message
 
 
 import hypermedia.net.*;
 
 UDP udp;  // define the UDP object
 
 
 void setup() {
 udp = new UDP( this, 6000 );  // create a new datagram connection on port 6000
 //udp.log( true ); 		// <-- printout the connection activity
 udp.listen( true );           // and wait for incoming message  
 }
 
 void draw()
 {
 }
 
 void keyPressed() {
 String ip       = "192.168.1.177";	// the remote IP address
 int port        = 8888;		// the destination port
 
 udp.send("Hello World", ip, port );   // the message to send
 
 }
 
 void receive( byte[] data ) { 			// <-- default handler
 //void receive( byte[] data, String ip, int port ) {	// <-- extended handler
 
 for(int i=0; i < data.length; i++) 
 print(char(data[i]));  
 println();   
 }
 */


