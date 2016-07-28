

#import <Foundation/Foundation.h>
#import "BirdSocketManager.h"
#import "BirdMessageManager.h"
#import "BirdSessionManagerInterface.h"
#import "Reachability.h"
#import "BirdHttpManager.h"

#import "AFHTTPRequestOperation.h"


/*
 每一个消息都附带一个messageClass
 2016-18: 加入消息缓存
 author : Naval
 */

#define HTTP_OR_MESSAGE

#ifdef  HTTP_OR_MESSAGE
     #define HTTP_DEFAULT  1
#else
     #define HTTP_DEFAULT  0
#endif


@interface BirdSessionManager : NSObject<BirdSocketInterface,BirdHttpInterface>
{
    NSMutableDictionary *messageObservers;
    NSMutableArray *observerArray;
    enum CHSessionManagerState sessionManagerState;
    
    Reachability *reachability;
    NetworkStatus m_netStatus;
    enum CHSessionNetState netState;// net state
    
    BirdSocketManager *socketManager; // socket manager.
    
    BirdHttpManager   *httpManager;
    
}

+(id)sharedSessionManager;
-(void)sendMessage:(NSDictionary*)message;
-(void)registerObserver:(id<BirdSessionManagerInterface>)observer;
-(void)unRegisterObserver:(id<BirdSessionManagerInterface>)observer;

-(void)registerMessageObserver:(id<BirdSessionManagerInterface>)observer :(NSString*)messageClass;
-(void)unRegisterMessageObserver:(NSString*)messageClass;

- (enum CHSessionManagerState)getSessionState;
-(enum CHSessionNetState)getSessionNetState;
-(void)createSessionConnect;
-(void)distroySessionConnect;

/*  下载文件  */

- (AFHTTPRequestOperation *)downloadFileWithURL:(NSURL *)URL
                                     saveToPath:(NSString *)filePath
                                    WithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
