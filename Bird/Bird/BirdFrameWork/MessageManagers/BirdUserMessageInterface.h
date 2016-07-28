

#import <Foundation/Foundation.h>
#import "BirdUser.h"
/***********获得个人信息***********/
//@class CHUser;
@class AppVersionInfo;
@protocol BirdUserMessageInterface <NSObject>



-(void)userLoginCB:(NSString*)result :(NSString*)msg :(BirdUser*)user;

-(void)updateUserInfoCB:(NSString*)result :(NSString*)msg :(NSString*)iconURL;
-(void)getUserInfoCB:(NSString*)result :(NSString*)msg :(BirdUser*)user;
-(void)getVersionUpdateCB :(NSString*)result :(NSString*)msg :(AppVersionInfo*)appVersionInfo;

-(void)addUserSuggestCB:(NSString*)result :(NSString*)msg;

-(void)addHealthScoreCB:(NSString*)result msg:(NSString*)msg dicData:(NSDictionary*)dicData :(NSString*)messageID;

- (void)sendVerifyCodeCB:(NSString*)result :(NSString*)msg;

-(void)updatePhoneNoCB:(NSString*)result :(NSString*)msg :(NSString*)token;

-(void)getHealthScoreDetailCB:(NSString*)result :(NSString*)msg :(NSArray*)scoreRecords;
@end
