

#import <Foundation/Foundation.h>
#import "BirdInclude.h"
#import "BirdSocketInterface.h"

#import <sys/socket.h>
#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <netdb.h>
#import <netinet/in.h>


@interface BirdSocketManager : NSObject
{
    enum CHSocketState m_socketState;
    CFSocketRef m_socket;/*  socket referce */
    NSMutableArray *messageQueue;
  
   // NSMutableSet observerArray;/*  关注网络状态，和socket状态的  */
   
}
@property (nonatomic,retain) NSMutableArray *observerArray;
@property (nonatomic,assign) BOOL recvThreadRun;
@property (nonatomic,assign) BOOL sendThreadRun;
@property (nonatomic,assign) BOOL disconnectByPhone;


+(BirdSocketManager*)sharedSocketManager;
-(void)registerObserver:(id<BirdSocketInterface>)observer;
-(void)unRegisterObserver:(id<BirdSocketInterface>)observer;

-(void)connectServer : (NSString*)serverIP : (int)serverPort;
-(void)closeSocket:(BOOL)closeByClient;

-(enum CHSocketState)getSocketStatus;
-(void)NoticeSocketStateToDelegate :(enum CHSocketState)socketState;
-(void)sendMessage:(NSData *)data;
-(void)readStream;
-(void)connectFinished:(BOOL)success;

@end
