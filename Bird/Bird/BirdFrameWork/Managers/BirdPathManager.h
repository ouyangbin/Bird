
#import <Foundation/Foundation.h>

@interface BirdPathManager : NSObject
{
    NSString *userIconServerPath;
}

+ (BirdPathManager *)sharedManager;

-(NSString*)getDocumentPath;
-(NSString*)getDBPath;

-(NSString*)getUserIconLocalPath;

- (NSString*)getServerUserIcon;

- (NSString*)getMessageImagePath;

- (NSString *)getSystemPath;

- (NSString*)getUserFoldPath;  //可能改成userid动态文件名

- (NSString*)getUserDatabasePath;

- (NSString *)getchatImagePath;

@end
