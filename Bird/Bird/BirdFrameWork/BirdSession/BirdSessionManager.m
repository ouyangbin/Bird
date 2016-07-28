
#import "BirdSessionManager.h"

#import "AppDelegate.h"

//#import "CJSONDeserializer.h"

@implementation BirdSessionManager
static BirdSessionManager *sessionManager = nil;
+ (id)sharedSessionManager
{
    if (sessionManager == nil)
    {
        sessionManager = [[super allocWithZone:NULL] init];
        [sessionManager managerInit];
    }
    return sessionManager;
}
- (void)managerInit
{
    
    sessionManagerState = CHSessionManagerState_NONE;
    observerArray = [[NSMutableArray alloc]initWithCapacity:0];
    messageObservers = [[NSMutableDictionary alloc]initWithCapacity:0];
    [messageObservers retain];
    
    if (HTTP_DEFAULT)
    {
        httpManager = [BirdHttpManager shareBirdHttpManager];
        [httpManager registerObserver:self];
    }
    else
    {
        socketManager = [[BirdSocketManager alloc]init];
        [socketManager registerObserver:self];
    }
    
    netState = [self getNetState];
    [self registerNetStateManager];
}

/**###----net Manager------###*/
- (void)registerNetStateManager
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    reachability = [[Reachability reachabilityWithHostName:@"www.baidu.com"] retain];
    [reachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability * curReach = [note object];
    NetworkStatus tem = [curReach currentReachabilityStatus];
    if(m_netStatus != tem)
    {
        m_netStatus = tem;
        if (m_netStatus == NotReachable)
        {
            netState = CHSessionNetState_NONE;
            sessionManagerState = CHSessionManagerState_NET_FAIL;
            dispatch_async(dispatch_get_main_queue(),^{
            [self NoticeStateToDelegate:CHSessionManagerState_NET_FAIL];
                
            NSLog(@"网络连接失败");
                
        });
            if (!HTTP_DEFAULT)
            {
                [self distroySessionConnect];
            }
        }
        else
        {
            if(ReachableViaWiFi == m_netStatus)
            {
                 netState = CHSessionNetState_WIFI;
            }
            else
            {
                 netState = CHSessionNetState_2G;
            }
            sessionManagerState = CHSessionManagerState_NET_OK;
            dispatch_async(dispatch_get_main_queue(),^{
                [self NoticeStateToDelegate:CHSessionManagerState_NET_OK];
            });
            if (!HTTP_DEFAULT)
            {
                [self createSessionConnect];
            }
        //[[TKAlertCenter defaultCenter] postAlertWithMessage:@"网络正常"];
        }
    }
}

/*   这个外部调用很少*/
- (NetworkStatus)getNetState
{
    //    if[self getSocketStatus]
   // return m_netStatus;
    Reachability * curReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status_now = [curReach currentReachabilityStatus];
    return status_now;
}

- (void)NoticeStateToDelegate :(enum CHSessionManagerState)sessionState
{
    //debug zhangXX
    for(id<BirdSessionManagerInterface>observer in observerArray)
    {
        if([observer respondsToSelector:@selector(sessionManagerStateNotice:)])
        {
               [observer sessionManagerStateNotice:sessionState];
        }
    }
}
-(void)errorBlock:(NSDictionary*)data :(NSString*)msg
{
    NSString *messageType = [data objectForKey:@"messageType"];
    NSString *messageClass = [data objectForKey:@"messageClass"];
    NSString *messageID = [data objectForKey:@"messageID"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:data];
    [dic setObject:@"NO" forKey:@"statusCode"];
    [dic setObject:msg forKey:@"msg"];
    
    [self dispatchMessage:dic :messageClass :messageType :messageID];
}
//-(void)callCBUseLocalData:(NSDictionary*)data
//{
//    NSString *messageType = [data objectForKey:@"messageType"];
//    NSString *messageClass = [data objectForKey:@"messageClass"];
//    NSString *messageID = [data objectForKey:@"messageID"];
//    
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:@"NO" forKey:@"statusCode"];
//    [dic setObject:ERROR_CODE_USE_LOCAL forKey:@"msg"];
//    
//    [self dispatchMessage:dic :messageClass :messageType :messageID];
//}
- (void)sendMessage:(NSDictionary*)message
{
    
    if (HTTP_DEFAULT)
    {
        if(httpManager == nil)
            return;
        /*  使用本地测试数据  */
        NSString *useLocalData = [message objectForKey:USE_LOCALHOST_DATA];
       
        if(useLocalData != nil && [useLocalData isEqualToString:@"YES"])
        {
          //  [self performSelector:@selector(callCBUseLocalData:) withObject:message afterDelay:0.5];
          //   [self performSelector:@selector(errorBlock::) withObject:message withObject:ERROR_CODE_USE_LOCAL];
           
            return;
        }
        /*   使用缓存数据    */
        
        NSString *useCacheData = [message objectForKey:USE_CACHE_DATA];
        if(useCacheData != nil && [useCacheData isEqualToString:@"YES"])
        {
         ///   [self performSelector:@selector(errorBlock::) withObject:message withObject:ERROR_CODE_USE_CACHE];
        }
        
        if(netState == CHSessionNetState_NONE)
           {
            //    [self performSelector:@selector(errorBlock::) withObject:message withObject:ERROR_CODE_NO_NET];
                return;
           }
        
        if(self)
        {
           [httpManager sendMessageWithDictionary:message];
        }
    }
    else
    {
        if(socketManager == nil || [socketManager getSocketStatus] != CHSocketState_CONNECTED)
            return;
    }
    
//    NSError *error = nil;
//    NSData *data = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&error];
//    if (!error)
//    {
//        NSLog(@"Process JSON data is sucessed...");
//    }
//    else
//    {
//        NSLog(@"Process JSON data has error...");
//    }
//    if (data)
//    {
//        if (HTTP_DEFAULT)
//        {
//            [httpManager sendMessage:data];
//        }
//        else
//        {
//            [socketManager sendMessage:data];
//        }
//    }
//    else
//    {
//        return;
//    }
    
    
}

- (void)socketStateNotice:(enum CHSocketState)socketManagerType
{
    switch (socketManagerType)
    {
        case CHSocketState_CREATE_CLOSE_FAIL:
            break;
        case  CHSocketState_CONNECT_FAIL:
            sessionManagerState = CHSessionManagerState_NONE;
            [self NoticeStateToDelegate:sessionManagerState];
            [self distroySessionConnect];
            break;
        case CHSocketState_CONNECTED:
            sessionManagerState = CHSessionManagerState_CONNECTED;
             [self NoticeStateToDelegate:sessionManagerState];
            break;
        case CHSocketState_CLOSE_BY_SERVER:
            sessionManagerState = CHSessionManagerState_CONNECT_MISS;
            [self distroySessionConnect];
             [self NoticeStateToDelegate:sessionManagerState];
            break;
        default:
            break;
    }
}

- (enum CHSessionManagerState)getSessionState
{
    return sessionManagerState;
}

- (enum CHSessionNetState)getSessionNetState
{
    return netState;
}

- (void)createSessionConnect
{
    if(socketManager != nil && [socketManager getSocketStatus] == CHSocketState_NONE)
    {
        [socketManager connectServer:SERVER_IP : SERVER_PORT ];
    }
}

- (void)distroySessionConnect
{
     if(socketManager != nil && [socketManager getSocketStatus] != CHSocketState_NONE)
     {
         [socketManager closeSocket:YES];
     }
}

/*  socket回调  */
- (void)socketRecvMessage:(NSData *)data
{
    NSError *error = nil;
    if (data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        

      //  NSDictionary  *dic  =  [ [ CJSONDeserializer  deserializer ]  deserializeAsDictionary : data   error : &error ];
        
        
        
        if (!error) {
            NSString *key = [dic objectForKey:@"messageClass"];
            if(key)
            {
                BirdMessageManager *messageManager = [messageObservers objectForKey:key];
                if(messageManager && [messageManager respondsToSelector:@selector(parseMessageData:)])
                {
                    [messageManager parseMessageData:dic :nil];
                }
            }
        }
        else
        {
            NSLog(@"##############Json数据解析出错1！！！###################");
        }
    }
}
-(void)dispatchMessage:(NSDictionary*) dic :(SessionPacket*)sessionPacket
{
    
    NSString * statusCode = [dic objectForKey:@"statusCode"];

    
    
    if(sessionPacket.m_messageClass)
    {
        NSMutableDictionary *newMessage = [[NSMutableDictionary alloc] init];
        [newMessage setValuesForKeysWithDictionary:dic];
        if(sessionPacket.m_messageID != nil && [sessionPacket.m_messageID length] > 0)
        {
           
            [newMessage setValue:sessionPacket.m_messageID forKey:@"messageID"];
        }
        
        if(sessionPacket.m_useCache != nil && [sessionPacket.m_useCache length] > 0)
        {
            
            [newMessage setValue:sessionPacket.m_useCache forKey:USE_CACHE_DATA];
        }
        
        if(sessionPacket.m_cacheKey != nil && [sessionPacket.m_cacheKey length] > 0)
        {
            
            [newMessage setValue:sessionPacket.m_cacheKey forKey:CACHE_DATA_KEY];
        }
        
        if(sessionPacket.m_importantMessage != nil && [sessionPacket.m_importantMessage isEqualToString:@"YES"])
        {
            [newMessage setValue:sessionPacket.m_importantMessage forKey:ImportantMessage];
        }
        BirdMessageManager *messageManager = [messageObservers objectForKey:sessionPacket.m_messageClass];
        SEL select = NSSelectorFromString([NSString stringWithFormat:@"%@ReplyCB:",sessionPacket.m_messageType]);
        
        if(messageManager && [messageManager respondsToSelector:select])
        {
            // [messageManager parseMessageData:dic :[NSString stringWithFormat:@"%@Reply",messageType]];
            [messageManager performSelector:select withObject:newMessage];
        }
    }

}

// will Cancel
-(void)dispatchMessage:(NSDictionary*) dic :(NSString*)messageClass :(NSString*)messageType :(NSString*)messageID
{
    
   // NSString *key = messageClass;//[dic objectForKey:@"messageClass"];
    
    
    
    if(messageClass)
    {
        if(messageID != nil && [messageID length] > 0)
        {
            NSMutableDictionary *newMessage = [[NSMutableDictionary alloc] init];
            [newMessage setValuesForKeysWithDictionary:dic];
            [newMessage setValue:messageID forKey:@"messageID"];
            dic = newMessage;
          //  [dic setValue:messageID forKey:@"messageID"];
        }
        BirdMessageManager *messageManager = [messageObservers objectForKey:messageClass];
        SEL select = NSSelectorFromString([NSString stringWithFormat:@"%@ReplyCB:",messageType]);
        
        if(messageManager && [messageManager respondsToSelector:select])
        {
            // [messageManager parseMessageData:dic :[NSString stringWithFormat:@"%@Reply",messageType]];
            [messageManager performSelector:select withObject:dic];
        }
    }

}
/*  http信息接收回调   */
- (void)receiveHttpMessage:(NSData*)data :(SessionPacket*)sessionPacket
//- (void)receiveHttpMessage:(NSData*)data :(NSString*)messageClass :(NSString*)messageType :(NSString*)messageID
{
    NSError *error = nil;
    if (data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        // NSDictionary  *dic  =  [ [ CJSONDeserializer  deserializer ]  deserializeAsDictionary : data   error : &error ];
        if (!error) {
            
           // [self dispatchMessage:dic :sessionPacket.m_messageClass :sessionPacket.m_messageType :sessionPacket.m_messageID];
            [self dispatchMessage:dic :sessionPacket];
                    }
        else
        {
            
            /*  post ERROR_CODE_SERVER_BUSY message 
    
             */
            NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
            [message setValue:sessionPacket.m_messageType forKey:@"messageType"];
            [message setValue:sessionPacket.m_messageClass forKey:@"messageClass"];
            if(sessionPacket.m_messageID != nil && [sessionPacket.m_messageID length] > 0)
            {
                [message setValue:sessionPacket.m_messageID forKey:@"messageID"];
            }
             if(sessionPacket.m_importantMessage != nil && [sessionPacket.m_importantMessage isEqualToString:@"YES"])
             {
                 [message setValue:sessionPacket.m_importantMessage forKey:ImportantMessage];
             }
           // [self performSelector:@selector(errorBlock::) withObject:message withObject:ERROR_CODE_SERVER_BUSY];
            NSLog(@"##############Json数据解析出错！！！###################");
            
        }
    }
}

- (void)registerObserver:(id<BirdSessionManagerInterface>)observer
{
   if(![observerArray containsObject:observer])
   {
       [observerArray addObject:observer];
   }
}

- (void)unRegisterObserver:(id<BirdSessionManagerInterface>)observer
{
    if([observerArray containsObject:observer])
    {
        [observerArray removeObject:observer];
    }
}

- (void)registerMessageObserver:(id<BirdSessionManagerInterface>)observer :(NSString*)messageClass
{
     if([messageObservers objectForKey:messageClass] == nil)
     {
         [messageObservers setObject:observer forKey:messageClass];
     }
}

- (void)unRegisterMessageObserver:(NSString*)messageClass
{
    if([messageObservers objectForKey:messageClass] != nil)
    {
        [messageObservers removeObjectForKey:messageClass];
    }
}
- (AFHTTPRequestOperation *)downloadFileWithURL:(NSURL *)URL
                                     saveToPath:(NSString *)filePath
                                    WithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [operation setCompletionBlockWithSuccess:success failure:failure];
    //    [operation start];
    [[NSOperationQueue mainQueue] addOperation:operation];
    return operation;
}

@end
