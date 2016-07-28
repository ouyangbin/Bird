

#import <Foundation/Foundation.h>
#import "BirdHttpInterface.h"
#import "ASIFormDataRequest.h"

#import "BirdSystemConfig.h"

@interface BirdHttpManager : NSObject<ASIHTTPRequestDelegate>
{
}

@property (nonatomic,retain) NSMutableArray  *observerArray;

+(BirdHttpManager *)shareBirdHttpManager;

-(void)registerObserver:(id<BirdHttpInterface>)observer;
-(void)unRegisterObserver:(id<BirdHttpInterface>)observer;

- (void)sendMessage:(NSData*)message;
- (void)sendMessageWithDictionary:(NSDictionary*)message;

@end
