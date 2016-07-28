

#import <Foundation/Foundation.h>
/*
 the net state ...
 */
/*
 1. 收到消息
 2. 连接状态
 
 */
enum CHSessionNetState
{
    CHSessionNetState_NONE,
    CHSessionNetState_2G,// 3G, 4G
    CHSessionNetState_WIFI,
    CHSessionNetState_MAX
};
enum CHSessionManagerState
{
    CHSessionManagerState_NONE,
    CHSessionManagerState_GETSEVERS,//no use
    CHSessionManagerState_CONNECTED,
    CHSessionManagerState_CONNECT_FAIL,// no use
    CHSessionManagerState_CONNECT_MISS,
    CHSessionManagerState_NET_FAIL,
    CHSessionManagerState_NET_OK,
    CHSessionManagerState_MAX
};
@protocol BirdSessionManagerInterface <NSObject>
@optional
-(void)sessionManagerStateNotice :(enum CHSessionManagerState)sessionManagerState;
-(void)parseMessageData:(NSDictionary*)data :(NSString*)messageType;
@end
