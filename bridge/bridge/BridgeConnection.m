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

@implementation BridgeConnection

@synthesize host, port, clientId, secret;

- (id)initWithApiKey:(NSString*) anApiKey reconnect:(BOOL)reconnectOption bridge:(Bridge*)aBridge
{
    self = [super init];
    if (self) {
      host = nil;
      port = -1;
      reconnect = reconnectOption;
      
      apiKey = [anApiKey copy];
      redirectorURL = [[NSURL URLWithString:@"http://redirector.flotype.com/"] retain];
      
      bridge = aBridge;
      responseData = [[NSMutableData dataWithLength:0] retain];
      
      reconnectBackoff = 0.1;
    }
    
    return self;
}

-(void) dealloc
{  
  [host release];
  [secret release];
  [apiKey release];
  [responseData release];
  [super dealloc];
}

/*
 @brief Connect to the Bridge server using the network information provided to initializer
 */
- (void) start
{
  if(host == nil || port == -1){
    [self redirector];
  } else {
    [self establishConnection];
  }
}

-(void) redirector {
  NSURL* connectionURL = [redirectorURL URLByAppendingPathComponent:[NSString stringWithFormat:@"redirect/%@", apiKey]];
  NSLog(@"URL is: %@", connectionURL);
  NSURLRequest *request = [NSURLRequest requestWithURL:connectionURL];
  [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void) establishConnection {
  NSLog(@"Starting TCP connection %@ , %d", host, port);
  
  // Initialize a TCP connection. It will call back once ready.
  [[BridgeTCPSocket alloc] initWithConnection:self];

}

-(void) send:(NSData*) data
{  
  [sock send:data];
}

#pragma mark NSURL delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  // Show error
  NSLog(@"error: %@", [error localizedDescription]);
  [bridge _onError:[error localizedDescription]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  // Once this method is invoked, "responseData" contains the complete result
  NSDictionary* jsonObj = [BridgeJSONCodec parseRedirector:responseData];
  
  NSDictionary* data = [jsonObj objectForKey:@"data"];
  if(data && [data objectForKey:@"bridge_host"] != nil && [data objectForKey:@"bridge_port"] != nil)
  {
    host = [[data objectForKey:@"bridge_host"] copy];
    port = [((NSString*)[data objectForKey:@"bridge_port"]) intValue];
    
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
  NSData* connectString = [BridgeJSONCodec createCONNECTWithId:[bridge clientId] secret:secret apiKey:apiKey];
  
  // Send to the socket directly. Do not buffer
  [socket send:connectString];
}

-(void)onClose
{
  NSLog(@"Connection closed");
  
  [sock release];
  sock = socket_buffer;
  
  SEL connectSelector = @selector(establishConnection);
  NSInvocation* inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:connectSelector]];
  [inv setSelector:connectSelector];
  [inv setTarget:self];
  [NSTimer scheduledTimerWithTimeInterval:reconnectBackoff invocation:inv repeats:NO];
  
  reconnectBackoff *= 2;
  
}

-(void)onConnectMessage:(NSString*)message fromSocket:(id<BridgeSocket>) socket
{
    
  NSArray* chunks = [message componentsSeparatedByString:@"|"];
  
  if ([chunks count] == 2) {
    NSLog(@"client_id received: %@", [chunks objectAtIndex:0]);
    
    [clientId release];
    clientId = [[chunks objectAtIndex:0] retain];
    
    [secret release];
    secret = [[chunks objectAtIndex:1] retain];
    
    [socket_buffer processQueueIntoSocket:socket withClientId:clientId];
    sock = socket;
    
    NSLog(@"Handshake complete");
    
    [bridge _ready];
  } else {
    [self onMessage:message fromSocket:socket];
  }

}

-(void) onMessage:(NSString*)message fromSocket:(id<BridgeSocket>)socket
{
  NSLog(@"received: %@", message);
  NSDictionary* root = [BridgeJSONCodec parseRequestString:message bridge:bridge];
  
  BridgeRemoteObject* destination = [root objectForKey:@"destination"];
  if(destination == nil) {
    NSLog(@"No destination in message %@", message);
  } else {
    NSArray* arguments = [root objectForKey:@"args"];
    [bridge.dispatcher executeUsingReference:destination withArguments:arguments];
  }

}

@end
