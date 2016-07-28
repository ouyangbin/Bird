

#import "BirdUserManager.h"
#import "BirdSessionManager.h"
@interface BirdUserManager()<BirdSocketInterface, BirdSessionManagerInterface>
{
    
    enum USERSTATE _userState;
}
@end
@implementation BirdUserManager



static BirdUser* user = nil;
static BirdUserManager* manager = nil;
+(BirdUserManager *)sharedManager
{
    if(manager == nil)
    {
        manager = [[BirdUserManager alloc]init];
    }
    return manager;
}
-(id)init
{
    if(self = [super init])
    {
       
      //  _user = [[BirdUser alloc]init];
        [self getUserForLocal];
        if(user == nil)
        {
           user = [[BirdUser alloc]init];
        }
        _userState = user.m_userState;
        
        [[BirdSessionManager sharedSessionManager]registerObserver:self];
       // [[BirdUserMessageManager sharedManager]registerObserver:self];
    }
    return self;
}
-(void)setNowUserState:(enum USERSTATE)userState
{
    user.m_userState = userState;
    _userState = userState;
}
-(enum USERSTATE)getNowUserState
{
    return user.m_userState;
}
-(BirdUser *)getNowUser
{
    return user;
}
- (void)userLogingOut
{
    if (user) {
        [self setNowUserState:USERSTATE_NONE];
        //user.UserID = nil;
        NSLog(@"注销成功");
    }
}

/*  保存当前用户  */
-(BirdUser*)getUserForLocal
{
    NSData *myEncodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"personInformation"];
    user  = [NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];

    return user;
}
/*  得到当前用户  */
-(void)storeUserToLocal:(BirdUser*)user
{
    NSData *archiveCarPriceData = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:archiveCarPriceData forKey:@"personInformation"];
}
-(USER_ROLE)getNowUserRole
{
    USER_ROLE userRole = USER_ROLE_NONE;
    if(user != nil)
    {
//       if([_user.m_isAdmin isEqualToString:@"1"])
//       {
//           userRole = USER_ROLE_ADMIN;
//       }
//        else
//        {
//            userRole = USER_ROLE_NORMAL;
//        }
    }
    return userRole;
}
-(void)clearUserLocalData
{
   
    
}
@end
