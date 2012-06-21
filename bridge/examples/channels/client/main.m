#import <Foundation/Foundation.h>
#import "bridge-mac/bridge.h"

@interface ChatObj : NSObject <BridgeObject>
-(void)message:(NSString*)sender :(NSString*)msg;
@end

@implementation ChatObj

-(void)message:(NSString*)sender :(NSString*)msg
{
  NSLog(@"%@ : %@", sender, msg);
}

@end

int main (int argc, const char * argv[])
{
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  Bridge* bridge = [[Bridge alloc] initWithAPIKey:@"mypubkey"];
  
  BridgeRemoteObject* remoteAuth = [bridge getService:@"auth"];
  BridgeCallback* callback = [BridgeCallback callbackWithBlock:^(NSArray* args){
    // First argument is the name of the sender
    NSString* roomName = [args objectAtIndex:0];
    // Second argument is the message
    BridgeRemoteObject* channel = [args objectAtIndex:1];
    
    NSLog(@"Joined channel: %@", roomName);
    [channel message:@"steve" :@"This should not work."]; 
  }];
  
  [remoteAuth join:@"flotype-lovers" :[ChatObj new] :callback];
  [bridge connect];
  
  [[NSRunLoop currentRunLoop] run];
  dispatch_main();
  [pool drain];
  return 0;
}