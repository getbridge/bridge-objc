#import <Foundation/Foundation.h>
#import "bridge-mac/bridge.h"

@interface AuthObj : NSObject<BridgeObject> {
  Bridge* bridge;
}

-(id) initWithBridge:(Bridge*)theBridge;
-(void) joinWriteable:(NSString*)name :(NSString*)password :(NSString*)room :(BridgeRemoteObject*)chatObj :(BridgeRemoteObject*)callback;

@end

@implementation AuthObj

- (id)initWithBridge:(Bridge *)theBridge
{
  self = [super init];
  if (self) {
    // Initialization code here.
    bridge = theBridge;
  }
  
  return self;
}

-(void)join:(NSString *)channelName :(BridgeRemoteObject *)chatObj :(BridgeRemoteObject *)callback
{
  NSLog(@"HELLO");
    [bridge joinChannel:channelName withHandler:chatObj isWriteable:NO andCallback:callback];

}

-(void)joinWriteable:(NSString *)channelName :(NSString *)secretWord :(BridgeRemoteObject *)chatObj :(BridgeRemoteObject *)callback
{
  if([secretWord isEqualToString:@"secret123"])
  {
    [bridge joinChannel:channelName withHandler:chatObj isWriteable:YES andCallback:callback];
  }
}

@end

int main (int argc, const char * argv[])
{
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  Bridge* bridge = [[Bridge alloc] initWithAPIKey:@"myprivkey"];
  [bridge publishService:@"auth" withHandler:[[AuthObj alloc] initWithBridge:bridge]];
  [bridge connect];
  
  [[NSRunLoop currentRunLoop] run];
  dispatch_main();
  [pool drain];
  return 0;
}