

#import <Foundation/Foundation.h>
/*  状态  */
enum CHSocketState{
    CHSocketState_NONE,
    CHSocketState_CONNECTING,
    CHSocketState_CONNECTED,//连接成功
    CHSocketState_CONNECT_FAIL,//连接失败
    CHSocketState_CREATE_CLOSE_FAIL,//创建失败
    CHSocketState_CLOSE_BY_CLIENT,//客户端关闭
    CHSocketState_CLOSE_BY_SERVER,//服务器关闭
    CHSocketState_MAX
};
@protocol BirdSocketInterface <NSObject>
@optional
-(void)socketStateNotice :(enum CHSocketState) socketState;
-(void)socketRecvMessage:(NSData *)data;
@end
