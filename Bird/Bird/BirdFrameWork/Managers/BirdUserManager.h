

#import <Foundation/Foundation.h>
#import "BirdUser.h"


@interface BirdUserManager : NSObject
+(BirdUserManager*)sharedManager;


/*  得到现在用户的状态  */
- (enum USERSTATE)getNowUserState;
- (void)setNowUserState:(enum USERSTATE)userState;

/*  得到当前的用户 */
- (BirdUser*)getNowUser;

/*  注销  */
- (void)userLogingOut;

/*  得到当前用户的角色  */
-(USER_ROLE)getNowUserRole;


/*  保存当前用户  */
-(BirdUser*)getUserForLocal;
/*  得到当前用户  */
-(void)storeUserToLocal:(BirdUser*)user;

-(void)clearUserLocalData;
@end
