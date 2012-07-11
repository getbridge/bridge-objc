//
//  BridgeConnection.m
//  bridge
//
//  Created by Sridatta Thatipamala on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "bridge.h"
#import "BridgeConnection.h"
#import "GCDAsyncSocket.h"
#import "BridgeJSONCodec.h"
#import "BridgeDispatcher.h"
#import "BridgeUtils.h"
#import "BridgeSocket.h"
#import "BridgeTCPSocket.h"
#import "BridgeSocketBuffer.h"
#import "BridgeClient.h"

@interface BridgeConnection () {
}
  

@property (nonatomic, assign) Bridge* bridge;

@property (nonatomic, assign) id<BridgeSocket> sock;
@property (nonatomic, retain) BridgeTCPSocket* tcpSock;
@property (nonatomic, retain) BridgeSocketBuffer* socketBuffer;

@property (nonatomic, copy, readwrite) NSString* host;
@property (nonatomic, assign, readwrite) int port;

@property (nonatomic, copy) NSString* clientId;
@property (nonatomic, copy) NSString* secret;
@property (nonatomic, copy) NSString* apiKey;


@property (nonatomic, assign) BOOL secure;
@property (nonatomic, assign) BOOL reconnect;
@property (nonatomic, assign) float reconnectBackoff;

@property (nonatomic, retain) NSURL* redirectorURL;
@property (nonatomic, retain) NSMutableData* responseData;

@end


@implementation BridgeConnection

@synthesize bridge=bridge_;
@synthesize sock=sock_,tcpSock=tcpSock_,socketBuffer=sockBuffer_;
@synthesize host=host_, port=port_;
@synthesize apiKey=apiKey_, clientId=clientId_, secret=secret_;
@synthesize secure=secure_,reconnect=reconnect_,reconnectBackoff=reconnectBackoff_;
@synthesize redirectorURL=redirectorURL_,responseData=responseData_;

- (id)initWithApiKey:(NSString*)anApiKey options:(NSDictionary*)options bridge:(Bridge*)aBridge
{
    self = [super init];
    if (self) {
      [self setBridge:aBridge];
      
      [self setSocketBuffer: [[[BridgeSocketBuffer alloc] init] autorelease] ];
      [self setSock:self.socketBuffer];
      
      [self setHost:[options objectForKey:@"host"]];
      NSNumber* portOption = [options objectForKey:@"port"];
      
      if(portOption == nil) {
        [self setPort:-1];
      } else {
        [self setPort:[portOption intValue]];
      }
      
      [self setApiKey:anApiKey];
      
      NSString* redirectorString = [options objectForKey:@"redirector"];
      
      secure_ = NO;
      if([[options objectForKey:@"secure"] boolValue] == YES) {
        [self setSecure:YES];
        redirectorString = [options objectForKey:@"secureRedirector"];
      }
      [self setReconnect:[[options objectForKey:@"reconnect"] boolValue]];
      [self setReconnectBackoff:0.1];
      
      [self setRedirectorURL:[NSURL URLWithString:redirectorString]];
      [self setResponseData:[NSMutableData dataWithLength:0]];
      
    }
    
    return self;
}

-(void) dealloc
{  
  [self setBridge:nil];
  
  [self setSock:nil];
  [self setSocketBuffer:nil];
  [self setTcpSock:nil];
  
  [self setHost:nil];

  [self setApiKey:nil];
  [self setClientId:nil];
  [self setSecret:nil];
  
  [self setRedirectorURL:nil];
  [self setResponseData:nil];
  
  [super dealloc];
}

/*
 @brief Connect to the Bridge server using the network information provided to initializer
 */
- (void) start
{
  if(self.host == nil || self.port == -1){
    [self redirector];
  } else {
    [self establishConnection];
  }
}

-(void) redirector {
  NSURL* connectionURL = [self.redirectorURL URLByAppendingPathComponent:[NSString stringWithFormat:@"redirect/%@", self.apiKey]];
  NSLog(@"URL is: %@", connectionURL);
  NSURLRequest *request = [NSURLRequest requestWithURL:connectionURL];
  [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void) establishConnection {
  NSLog(@"Starting TCP connection %@ , %d", self.host, self.port);
  
  // Initialize a TCP connection. It will call back once ready.
  BridgeTCPSocket* tcpSock = [[[BridgeTCPSocket alloc] initWithConnection:self isSecure:self.secure] autorelease];
  [self setTcpSock:tcpSock];
}

-(void) send:(NSData*) data
{  
  [self.sock send:data];
}

#pragma mark NSURL delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  // Show error
  NSLog(@"error: %@", [error localizedDescription]);
  [self.bridge _onError:[error localizedDescription]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  // Once this method is invoked, "responseData" contains the complete result
  NSDictionary* jsonObj = [BridgeJSONCodec parseRedirector:self.responseData];
  
  NSDictionary* data = [jsonObj objectForKey:@"data"];
  if(data && [data objectForKey:@"bridge_host"] != nil && [data objectForKey:@"bridge_port"] != nil)
  {
    [self setHost:[data objectForKey:@"bridge_host"]];
    [self setPort:[((NSString*)[data objectForKey:@"bridge_port"]) intValue]];
    
    [self establishConnection];
  } else {
    NSLog(@"Could not find host and port in JSON body");
    return;
  }
}

-(void)onOpenFromSocket:(id<BridgeSocket>)socket
{
  NSLog(@"Beginning handshake");
  // Send a connect message
  NSData* connectString = [BridgeJSONCodec createCONNECTWithId:[self.bridge clientId] secret:self.secret apiKey:self.apiKey];
  
  // Send to the socket directly. Do not buffer
  [socket send:connectString];
}

-(void)onClose
{
  NSLog(@"Connection closed");
  
  [self setSock:self.socketBuffer];
  
  SEL connectSelector = @selector(establishConnection);
  NSInvocation* inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:connectSelector]];
  [inv setSelector:connectSelector];
  [inv setTarget:self];
  [NSTimer scheduledTimerWithTimeInterval:self.reconnectBackoff invocation:inv repeats:NO];
  
  reconnectBackoff_ *= 2;
  
}

-(void)onConnectMessage:(NSString*)message fromSocket:(id<BridgeSocket>) socket
{
    
  NSArray* chunks = [message componentsSeparatedByString:@"|"];
  
  if ([chunks count] == 2) {
    NSLog(@"client_id received: %@", [chunks objectAtIndex:0]);
    
    [self setClientId:[chunks objectAtIndex:0]];
    [self setSecret:[chunks objectAtIndex:1]];
    
    [self.socketBuffer processQueueIntoSocket:socket withClientId:self.clientId];
    [self setSock:socket];
    
    NSLog(@"Handshake complete");
    
    [self.bridge _ready];
  } else {
    [self onMessage:message fromSocket:socket];
  }

}

-(void) onMessage:(NSString*)message fromSocket:(id<BridgeSocket>)socket
{
  NSLog(@"received: %@", message);
  NSDictionary* root = [BridgeJSONCodec parseRequestString:message bridge:self.bridge];
  
  BridgeRemoteObject* destination = [root objectForKey:@"destination"];
  if(destination == nil) {
    NSLog(@"No destination in message %@", message);
    return;
  }
  
  NSString* source = [root objectForKey:@"source"];
  if (source != nil) {
      [self.bridge setContext:[[[BridgeClient alloc] initWithBridge:self.bridge clientId:source] autorelease]];
  }
  
  NSArray* arguments = [root objectForKey:@"args"];
  [self.bridge.dispatcher executeUsingReference:destination withArguments:arguments];

}

@end
