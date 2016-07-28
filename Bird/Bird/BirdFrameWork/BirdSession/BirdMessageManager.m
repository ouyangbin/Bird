

#import "BirdMessageManager.h"
#import "BirdSessionManager.h"
//#import "UIToastAlert.h"

@implementation BirdMessageManager
-(void)registerMessageManager:(BirdMessageManager*)messageManager :(NSString*)messageClass
{
     [[BirdSessionManager sharedSessionManager] registerMessageObserver :messageManager : messageClass];
}

-(void)sendMessage:(NSDictionary*)message
{
    enum CHSessionManagerState state = [[BirdSessionManager sharedSessionManager]getSessionState];
//    if ( CHSessionManagerState_NET_FAIL == state || CHSessionManagerState_CONNECT_FAIL == state ||
//        CHSessionManagerState_CONNECT_MISS == state) //网络不可用
//    {
//        if ([SVProgressHUD isActivty])
//        {
//            [SVProgressHUD popActivity];
//            NSString *str = nil;
//            if (CHSessionManagerState_NET_FAIL == state)
//            {
//                str = [NSString stringWithFormat:@"网络不可用 请检查网络！"];
//            }
//            else
//            {
//                str = [NSString stringWithFormat:@"服务器连接失败！"];
//            }
//          //  UIToastAlert *toast = [UIToastAlert shortToastForMessage:str atPosition:UIToastAlertPositionBottom];
//          //  toast._tintColor = [UIColor grayColor];
//          //  [toast show:[UIApplication sharedApplication].keyWindow.rootViewController.view];
//        }
//        
//        //CHSessionManagerState_NONE == state
//        NSLog(@"net fault");
//    }
//    else
    {
        [[BirdSessionManager sharedSessionManager] sendMessage:message];
        //[SVProgressHUD showWithMaskType:1];
        NSLog(@"send message");
    }
}


-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

/*   发送重要缓存信息   */
-(void)sendImportantMessage
{
    NSMutableDictionary *mutableDic = [self getStoreMessageWithDic];
    if(mutableDic != nil)
    {
        [self sendMessage:mutableDic];
    }
}
-(BOOL)messageProcessorCB:(NSDictionary*)message
{
    BOOL result = NO;
    [self importantMessageCB:message];
    return result;
}
/*  */
-(void)importantMessageCB:(NSDictionary*)message

{
    NSString *importantMessage = [message objectForKey:ImportantMessage];
    if(importantMessage != nil && [importantMessage isEqualToString:@"YES"])
    {
        NSString *messageID = [message objectForKey:@"messageID"];
        
        NSString *result = [message objectForKey:@"statusCode"];
        
        if([ result isEqualToString:@"0"])
        {
            [self deleteMessageByID:[messageID intValue]];
            [self sendImportantMessage];
        }
        else
        {
            [self updateMessageStateByID:[messageID intValue] :MessageStatus_Responsed_Fail];
        }
        
    }


    
    
}
/*  创建 MessageTable */
-(void)createMessageTable
{
   
    
    //  NSLog(@"########创建 金币表 result: %d",result);
}
/*   消息处理   */
-(void)execSql:(NSString*)sql
{

}
-(int)storeMessage:(NSDictionary *)message  :(NSString*)discirption
{
    
    return 1;
    
    // NSLog(@"########加金币操作 result: %d ,ID is %lld",result,id);
    
}
-(void)deleteMessageByID:(int) ID
{
   
}
-(void)updateMessageStateByID:(int) ID :(MessageStatus)messageStatus
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date ] ];
    // [_dbHelper openDB];
   
    
}
-(NSMutableDictionary*)getStoreMessageWithDic
{
        return nil;
    
}

@end
