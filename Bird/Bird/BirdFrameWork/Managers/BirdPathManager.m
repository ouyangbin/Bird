

#import "BirdPathManager.h"

#define kUserDataBase @"CH.sqlite"

static BirdPathManager *pathManager = nil;

#define DB_NAME @"hmsapp.sqlite"


@implementation BirdPathManager

+ (BirdPathManager *)sharedManager
{
    if (pathManager == nil)
    {
        pathManager = [[super allocWithZone:NULL] init];
        [pathManager managerInit];
    }
    return pathManager;
}

-(void)managerInit
{
     userIconServerPath = @"/userIcon/";
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"_expression_cn"ofType:@"plist"]] forKey:@"FaceMap"];
}
-(NSString*)getUserIconLocalPath
{
    NSString *userIconPath = [[self getDocumentPath]stringByAppendingPathComponent:@"userIcon.png"];
    return userIconPath;
}
- (NSString*)getServerUserIcon
{
    return  userIconServerPath;
}

- (NSString*)getMessageImagePath
{
    return @"/messageImage/";
}


- (NSString *)getSystemPath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *CHPath = [documentPath stringByAppendingPathComponent:@"PALMPAD"];
    return CHPath;
}

-(NSString*)getDocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //[paths release];
    //NSLog(documentsDirectory);
    return documentsDirectory;
}
-(NSString*)getDBPath
{
    return [[self getDocumentPath]stringByAppendingPathComponent:kUserDataBase];
}

- (NSString*)getUserFoldPath  //可能改成userid动态文件名
{
    NSString *systemPath = [self getSystemPath];
    NSString *userFolderPath = [systemPath stringByAppendingPathComponent:@"userDatabase"];//possible change userid
    return userFolderPath;
}

- (NSString*)getUserDatabasePath
{
    NSString *userFolderPath = [self getUserFoldPath];
    NSString *userDatabasePath = [userFolderPath stringByAppendingPathComponent:kUserDataBase];
    return userDatabasePath;
}

- (NSString *)getchatImagePath
{
    NSString *systemPath = [self getSystemPath];
    NSString *chatImagePath = [systemPath stringByAppendingPathComponent:@"PPImage"];
    return chatImagePath;
}

//- (void)dealloc
//{
//    [super dealloc];
//}

@end
