

#import <Foundation/Foundation.h>
#import "BirdSessionManagerInterface.h"
#import "BirdSocketInterface.h"

#import "BirdSystemConfig.h"

#define MessageTable @"messageTable"
/*  加分消息状态 */
typedef enum MessageStatus{
    MessageStatus_NONE = -1,
    MessageStatus_Init,//初始化状态
    MessageStatus_Resquesing,//请求中
    MessageStatus_Responsed_OK,//消息发送成功
    MessageStatus_Responsed_Fail,//消息发送失败
    MessageStatus_MAX
    
}MessageStatus;

#define ProgressNullPointer(value) ((NSNull*)value == [NSNull null])?@"":value


@interface BirdMessageManager : NSObject<BirdSessionManagerInterface,BirdSocketInterface>
{
}

@property (nonatomic,retain) NSMutableArray *observerArray;

-(void)registerMessageManager:(BirdMessageManager*)messageManager :(NSString*)messageClass;
-(void)sendMessage:(NSDictionary*)message;
-(NSString*)DataTOjsonString:(id)object;

/*   发送重要缓存信息   */
-(void)sendImportantMessage;
-(void)importantMessageCB:(NSDictionary*)message;

-(BOOL)messageProcessorCB:(NSDictionary*)message;

-(void)createMessageTable;
-(int)storeMessage:(NSDictionary *)message  :(NSString*)discirption;
-(void)updateMessageStateByID:(int) ID :(MessageStatus)messageStatus;
-(NSMutableDictionary*)getStoreMessageWithDic;
-(void)deleteMessageByID:(int) ID;
@end
