

#import "BirdSocketManager.h"
static BirdSocketManager *socketManager = nil;
@implementation BirdSocketManager
#pragma mark -
#pragma mark ------------Singleton Methods------------
/* signle mode  define  ... */
+(BirdSocketManager*)sharedSocketManager{
    
    if(socketManager == nil)
    {
        
        socketManager = [[BirdSocketManager alloc] init];//[[super allocWithZone:NULL] init] ;
        [socketManager managerInit];
        
    }
    return socketManager;
    
    
}
-(id)init
{
    self = [super init];
    if(self)
    {
        m_socketState = CHSocketState_NONE;
        self.observerArray = [[NSMutableArray arrayWithCapacity:0] retain];
        
        messageQueue = [[NSMutableArray  arrayWithCapacity:0] retain];
    }
    return self;
}

-(void)managerInit
{
    
}

-(void)registerObserver:(id<BirdSocketInterface>)observer
{
     if ([self.observerArray containsObject:observer] == NO)
     {
        // [observer retain];
         [self.observerArray addObject:observer];
     }

    
    
}
-(void)unRegisterObserver:(id<BirdSocketInterface>)observer
{
    if ([self.observerArray containsObject:observer])
    {
        [self.observerArray removeObject:observer];
    }
}

#pragma mark -
#pragma mark ----------------Socket Methods----------------
/*  other check net status */
-(enum CHSocketState)getSocketStatus
{
    return m_socketState;
}

-(void)NoticeSocketStateToDelegate :(enum CHSocketState)socketState
{
    for(id<BirdSocketInterface>observer in self.observerArray)
    {
        if([observer respondsToSelector:@selector(socketStateNotice:)])
        {
             [observer socketStateNotice:m_socketState];
        }
    }
}

/*connectTo server */
-(void)connectServer : (NSString*)serverIP : (int)serverPort
{
    if(m_socketState != CHSocketState_NONE || serverIP == nil)//&& m_socket != 0xffffffff)
        return;
    
    m_socketState = CHSocketState_CONNECTING;
    [self NoticeSocketStateToDelegate :m_socketState ];
    NSLog(@"the system will connect to server : '%@'",serverIP);
    
    CFSocketContext CTX = {0, (__bridge void *)(self), NULL, NULL, NULL};
    m_socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, TCPServerConnectCallBack, &CTX);
    
    if (NULL == m_socket)
    {
        m_socketState = CHSocketState_CREATE_CLOSE_FAIL;
        [self NoticeSocketStateToDelegate:m_socketState];
    }
    else
    {
        struct sockaddr_in addr4;
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        addr4.sin_port = htons(serverPort);//端口
        addr4.sin_addr.s_addr = inet_addr([serverIP UTF8String]);//IP地址
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr4, sizeof(addr4));
        
        CFSocketConnectToAddress(m_socket, address, -1);
        
        CFRunLoopRef cfrl = CFRunLoopGetCurrent();
        //NSLog(@"socket connect , now thread is:%x",cfrl);
        //NSLog(@"socket connect , main thread is :%x",CFRunLoopGetMain());
        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, m_socket, 0);
        CFRunLoopAddSource(cfrl, source, kCFRunLoopCommonModes);
        CFRelease(source);
    }
}

//连接成功以及发送成功接受的回调函数：
static void TCPServerConnectCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    
    NSLog(@"Call Back ...");
    BOOL result = NO;
    BirdSocketManager *socketManager = (BirdSocketManager*)info;
    do{
    if(nil == socketManager)
    {
        result = NO;
        break;
    }
    if([socketManager getSocketStatus]!=CHSocketState_CONNECTING )
    {
        /*  some error */
        result = NO;
        break;
    }
    if (data != NULL) {
       
        result = NO;
    }
    else
    {
        result = YES;
       
    }
    }while(FALSE);
    
    [socketManager connectFinished :result];
}

- (void)connectFinished :(BOOL)result
{
    if(result)
    {
        m_socketState =CHSocketState_CONNECTED;
        /*  open recv thread */
        self.sendThreadRun = YES;
        self.recvThreadRun = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self readStream];
        });
        /* open send thread */
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
            [self sendThread];});
    }
    else{
        m_socketState = CHSocketState_CONNECT_FAIL;
        NSLog(@"connect fail!");
    }
    [self performSelector:@selector(NoticeSocketStateToDelegate:) withObject:nil afterDelay:(0.5)];
    //[self NoticeSocketStateToDelegate:m_socketState];
}

- (void)sendThread
{
    while(self.sendThreadRun)
    {
        @synchronized(messageQueue)
        {
            if([messageQueue count] > 0 && m_socketState == CHSocketState_CONNECTED)
            {
                 NSLog(@"sendThread send Message");
                 NSData *message = [messageQueue objectAtIndex:0];
                 [self sendMessageToSocket:message];
                [messageQueue removeObjectAtIndex:0];
             }
        }
        //sleep(200);
        [NSThread sleepForTimeInterval:0.2];
    }
}

char sendBuffer[CH_NET_BUFFER_SIZE] ;
-(void)sendMessageToSocket:(NSData*)message
{
    /* main  context thread changed... */
    if(message == nil)
    {
        NSLog(@"socket 不发送空数据！");/* don't need to report */
        return;
    }
    memset(sendBuffer, 0, CH_NET_BUFFER_SIZE);
    if(m_socketState != CHSocketState_CONNECTED)
    {
        NSLog(@"error : socket is null\n");
        return;
    }
    int messageLength = 0;
    const char *dataStr = [message bytes];
    messageLength = htonl([message length] + 4);
//    NSLog(@"message legth is :%d",[message length] + 5);
    memset(sendBuffer,0,sizeof(sendBuffer));
    memcpy(sendBuffer, (char*)&messageLength, 4);
    memcpy(sendBuffer + 4, dataStr  , [message length]);
    
    int length = 0;
    int index = 0;
    int dataLength = (int)strlen(sendBuffer + 4) + 4;
    NSString *logInfo = [NSString stringWithFormat:@"######sendingMessage######:\n%@",[[NSString alloc]initWithData:message encoding:NSUTF8StringEncoding]];
    
    NSLog(@"######sendingMessage######:\n%@",logInfo);
    
    //    if(m_socketState != CHSocketState_CONNECTED )
    //    {
    //        [self NoticeStateToDelegate:CHSocketManagerType_SendMessageError];
    //    }
    while(index < dataLength && m_socket)
    {
        length =  (int)send(CFSocketGetNative(m_socket), sendBuffer + index, dataLength - index, 0);
        index += length;
    }
}

/* close socket, but should do something for close BY server  */
-(void)closeSocket:(BOOL)closeByClient
{
//    if(closeByClient)
//        NSLog(@"close socket by client!\n");
//    else
//        NSLog(@"close socket by server!\n");
    m_socketState = CHSocketState_NONE;
   _recvThreadRun = NO;
    self.sendThreadRun = NO;
    if (m_socket != nil) {
        CFSocketInvalidate(m_socket);
        m_socket = 0;
    }
  //  [[BirdSocketManager sharedSocketManager] NoticeSocketStateToDelegate:m_socketState];
    
}


/*   发送消息   */

-(void)sendMessage:(NSData *)data
{
    @synchronized(messageQueue)
    {
    [messageQueue addObject:data];
    return;
    }
}


/*  清理掉缓存池里面的数据    */

-(void)throwNowPacket :(int) packetSize
{
    if(packetSize < 0)
        return;
    char *temData = malloc(packetSize);
    int length = 0;
    while(length < packetSize && m_socket && temData)
    {
        length += recv(CFSocketGetNative(m_socket), temData, packetSize - length,0);
    }
    free(temData);
    
}
/*  收到消息处理器   */

char buffer[CH_NET_BUFFER_SIZE];
NSMutableData *recvData = nil;
NSString *recvInfo = nil;
-(void)readStream{
    
//    NSLog(@"Read Stream...");
    //  NSLog(@"socket connect , now thread is:%x",CFRunLoopGetCurrent);
    // NSLog(@"socket connect , main thread is :%x",CFRunLoopGetMain());
    // NSLog(@"now readStream thread is %x,and socket is :%x",CFRunLoopGetCurrent(),socket);
    /* recvThreadRun  = BOOL */
  
    int length = 0;
    int index = -1;
    BOOL running = true;
    int packet = 0;
    int packetLength = 0;
    
    while (_recvThreadRun)
    {
       
        
        running = YES;/* open the while recv  */
        index =  0;
        packet = 0;
        length = 0;
        packetLength = 0;
        
        // memset(buffer, NGO_NET_BUFFER_SIZE, 0);
        length = (int)recv(CFSocketGetNative(m_socket), buffer, 4,0);
//        if(recvData != nil)
//        {
//            [recvData release];
//            recvData = nil;
//        }
        recvData =[NSMutableData data];
        index += length;
        if(length <= 0 )//&&  self.disconnectByPhone == 1)
        {
            self.disconnectByPhone = 0;
            NSLog(@"####################应用程序自身，关闭socket！！！######################");
            running = NO;

            break;
            
        }
        else if(length <= 0 &&  self.disconnectByPhone == 0)
        {
            /* server error */
            NSLog(@"####################服务器故障，关闭socket！！！######################");
            m_socketState = CHSocketState_CLOSE_BY_SERVER;
            for(id<BirdSocketInterface>observer in self.observerArray)
            {
                if([observer respondsToSelector:@selector(socketStateNotice:)])
                {
                    [observer socketStateNotice:m_socketState];
                }
            }
            running = NO;
            
            break;
        }
        else{
            /* get the datas length */
            memcpy((char*)&packet, buffer, 4);
            packetLength = ntohl(packet);
            if(packetLength >= CH_NET_BUFFER_SIZE)
            {
                NSLog(@"  error: 系统不支持改数据容量！！！");
                [self throwNowPacket :packetLength - 4];
                running = NO;
                
            }
        }
        
        while(running)
        {
            
            /* get this packet length */
            
            if(m_socket)
            {
                memset(buffer,0,sizeof(buffer));

                length = (int)recv(CFSocketGetNative(m_socket), buffer, packetLength - index,0);
                
//                NSLog(@"get packet data count is :%d,length is %d",packetLength,length);
                
//                [recvData appendBytes:buffer length:length];
                [recvData appendData:[NSData dataWithBytes:buffer length:length]];
                //strlen(buffer + (index == 0?4:0)) ];
                index += length;
                
             
                if( index >=  packetLength )
                {
                    //[recvData appendBytes:'\0' length:1];
                    running = NO;
                }
                else
                {
                    continue;
                    
                }
                if(nil == recvData)
                {
                    NSLog(@"################get datas error!");
                }
               
                recvInfo = [NSString stringWithFormat:@"recv is %@",[[NSString alloc] initWithData:recvData encoding:NSUTF8StringEncoding] ];
                //[recvData retain];
              //  NSLog(@"%@",recvInfo);
                
                dispatch_async(dispatch_get_main_queue(),^{
                    for(id<BirdSocketInterface>observer in self.observerArray)
                    {
                        if([observer respondsToSelector:@selector(socketRecvMessage:)])
                        {
                            [observer socketRecvMessage:recvData];
                        }
                    }
                });
                
                [NSThread sleepForTimeInterval:0.3];
            
               //[recvData release];
            }
            
        }
        
        
    }
    
}
@end
