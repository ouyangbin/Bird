

#import "BirdUserMessageManager.h"
#import "BirdUserManager.h"


//#import "CJSONDeserializer.h"

#define CHUserCentreMessageClass @"userCentreMessageManager"


@implementation BirdUserMessageManager
#pragma mark - 初始化与注册代理
static BirdUserMessageManager *instance = nil;

+ (BirdUserMessageManager*)sharedManager
{
    if(nil == instance)
    {
        instance = [[BirdUserMessageManager alloc]init];
        [instance initManager];
    }
    return instance;
}

- (void)initManager
{
    self.observerArray = [[NSMutableArray alloc]initWithCapacity:0];
    [self registerMessageManager:self :CHUserCentreMessageClass];
    [[BirdSessionManager sharedSessionManager] registerObserver:self];
    
    [self createMessageTable];
}

- (void)registerObserver:(id<BirdUserMessageInterface>)observer
{
    if ([self.observerArray containsObject:observer] == NO)
    {
        // [observer retain];
        [self.observerArray addObject:observer];
    }
}
-(void)removeRegisterObserver:(id<BirdUserMessageInterface>)observer
{
    if ([self.observerArray containsObject:observer]) {
        [self.observerArray removeObject:observer];
    }
}

- (void)unRegisterObserver:(id<BirdUserMessageInterface>)observer
{
    [self performSelector:@selector(removeRegisterObserver:) withObject:observer afterDelay:0.5];
    
}
#pragma mark - 发送网络请求
#define CHServerDomain @"http://210.5.30.221/cigna_community"  //UAT
- (void)sendMessage:(NSMutableDictionary *)message
{
    [message setObject:CHUserCentreMessageClass forKey:@"messageClass"];
    NSString *messageType = [message objectForKey:@"messageType"];
    NSString *userID = [message objectForKey:@"userID"];
    NSString *sessionID = [message objectForKey:@"sessionID"];
    NSString *URL = nil;
    if(userID != nil && [userID length] > 0)
    {
        [message removeObjectForKey:@"userID"];
        // [message removeObjectForKey:@"messageType"];
        [message removeObjectForKey:@"sessionID"];
        URL = [NSString stringWithFormat:@"%@/%@/%@/%@",CHServerDomain,userID,sessionID,messageType];
    }
    else
    {
       URL = [NSString stringWithFormat:@"%@/%@",CHServerDomain,messageType];
    }
    [message setObject:URL forKey:@"URL"];
    [super sendMessage:message];
}

// 登录接口
-(void)userLogin:(NSString*)phoneID :(NSString*)verifyCode
{
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    [message setObject:@"login" forKey:@"messageType"];
    
    

    //  [message setObject:userID forKey:@"userID"];
    //  [message setObject:session forKey:@"sessionID"];
    

    // 手机号
    // 设备号
    NSString * deviceCode = @"122222";
    // encode
    NSString * encodeStr = @"3333333";
    
    [message setObject:encodeStr forKey:@"encode"];
    [message setObject:phoneID forKey:@"phoneID"];
    [message setObject:deviceCode forKey:@"deviceCode"];
    [message setObject:verifyCode forKey:@"verifyCode"];
    [message setObject:@"2" forKey:@"from"];
    // 打开使用本地数据开关
    //  [message setObject:@"YES" forKey:USE_LOCALHOST_DATA];
    
    // #################
    [self sendMessage:message];


}

-(void)loginReplyCB:(NSDictionary*)data
{
    NSString* result = [data objectForKey:@"statusCode"];
    NSString *reason = [data objectForKey:@"msg"];
    NSDictionary *dataDic = [data objectForKey:@"data"];
    
    BirdUser *user = [[BirdUserManager sharedManager] getNowUser];
    
    if([result isEqualToString:@"0"])
    {
        }
    for (id<BirdUserMessageInterface> interface in self.observerArray) {
        if ([interface respondsToSelector:@selector(userLoginCB:::)]) {
            [interface userLoginCB:result :reason :user];
        }
    }

}

@end
