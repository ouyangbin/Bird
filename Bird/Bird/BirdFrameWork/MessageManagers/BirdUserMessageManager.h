

#import "BirdMessageManager.h"
#import "BirdSessionManager.h"
#import "BirdUserMessageInterface.h"

/***********个人信息相关操作***********/
@interface BirdUserMessageManager : BirdMessageManager
+ (BirdUserMessageManager*)sharedManager;
- (void)registerObserver:(id<BirdUserMessageInterface>)observer;
- (void)unRegisterObserver:(id<BirdUserMessageInterface>)observer;
/*  ##########接口部分##########*/

// 登录接口
-(void)userLogin:(NSString*)phoneID :(NSString*)verifyCode ;



@end
