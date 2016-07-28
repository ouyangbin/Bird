
#import "BirdHttpManager.h"

//#define  HTTP_REQ_URL  @"http://192.168.1.6:8080/Auction/messageProcessor?"
//#define  HTTP_REQ_URL  @"http://113.106.93.214:8088/Auction/messageProcessor?"
#define  HTTP_REQ_URL  @"http://zpw123.cn/messageProcessor?"
//#define  HTTP_REQ_URL @"http://115.29.176.110:80/Auction/messageProcessor?"

@implementation SessionPacket



@end

static BirdHttpManager  *httpManager = nil;
@implementation BirdHttpManager

+ (BirdHttpManager*)shareBirdHttpManager
{
    if(httpManager == nil)
    {
        httpManager = [[BirdHttpManager alloc] init];
        [httpManager managerInit];
    }
    return httpManager;
}

- (void)managerInit
{
    self.observerArray = [[NSMutableArray arrayWithCapacity:0] retain];
}


- (void)registerObserver:(id<BirdHttpInterface>)observer
{
    if ([self.observerArray containsObject:observer] == NO)
    {
        [self.observerArray addObject:observer];
    }
}

- (void)unRegisterObserver:(id<BirdHttpInterface>)observer
{
    if ([self.observerArray containsObject:observer])
    {
        [self.observerArray removeObject:observer];
    }
}
//  cigna post data to server...#########
- (void)sendMessageWithDictionary:(NSDictionary*)message
{
    NSString *URL = [message objectForKey:@"URL"];
    ASIFormDataRequest *m_request = nil;
#ifndef HTTP_METHOD_GET
    m_request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:URL]];
#endif
    
   // NSMutableString * requestURL = [NSMutableString stringWithString:URL];
    
    NSMutableString *logURL = nil;//[NSMutableString stringWithString:URL];
    #ifndef HTTP_METHOD_GET
         logURL = [NSMutableString stringWithString:URL];
    #endif
    NSArray *keys = [message allKeys];
    int index = 0;
    if(keys != nil && keys.count > 0)
    {
        for(NSString *key in keys)
        {
            NSString *value = nil;
            if([key isEqualToString:@"URL"] == NO)
            {
                
                
                NSArray *keyArrayTem = [key componentsSeparatedByString:@"##"];
                
               if([keyArrayTem count] == 1)
               {
                   /*     上传数据    */
                value = [message objectForKey:key];
#ifdef HTTP_METHOD_GET
                if(index == 0)
                    
                    [requestURL appendString:[NSString stringWithFormat:@"?%@=%@",key,value]];
                else
                    [requestURL appendString:[NSString stringWithFormat:@"&%@=%@",key,value]];
#else
                /*  log  */
                if(index == 0)
                    
                    [logURL appendString:[NSString stringWithFormat:@"?%@=%@",key,value]];
                else
                    [logURL appendString:[NSString stringWithFormat:@"&%@=%@",key,value]];
                 /*  for  log */
                [m_request setPostValue:value forKey:key];
#endif
               }
               else if([keyArrayTem count] == 2)
                {
                    /*  上传文件  */
                    value = [message objectForKey:key];
                    [m_request addFile:value forKey:[keyArrayTem objectAtIndex:1]];
                    if([[keyArrayTem objectAtIndex:0] isEqualToString:@"image"])
                    {
                    NSLog(@"########上传图片，key为%@,图片本地路径为：%@",[keyArrayTem objectAtIndex:1],value);
                    }
                    else
                    {
                    NSLog(@"########上传文件，key为%@,文件本地路径为：%@",[keyArrayTem objectAtIndex:1],value);
                    }
                    
                    
                }
                index++;
            }
        }
    }
    
#ifdef HTTP_METHOD_GET
    m_request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
#endif
    
#ifdef HTTP_METHOD_GET
    m_request.requestMethod = @"GET";
#else
    m_request.requestMethod = @"POST";
#endif
    #ifdef HTTP_METHOD_GET
    NSLog(@"######### send message, content is %@",requestURL);
    #else
    NSLog(@"######### send message, content is %@",logURL);
    #endif
    
    m_request.m_messageClass = [message objectForKey:@"messageClass"];
    m_request.m_messageType =[message objectForKey:@"messageType"];
    
    m_request.m_messageID = [message objectForKey:@"messageID"];
    
    m_request.m_useCache = [message objectForKey:USE_CACHE_DATA];
    m_request.m_cacheKey = [message objectForKey:CACHE_DATA_KEY];
    
    m_request.m_importantMessage = [message objectForKey:ImportantMessage];
    
   
   // [message removeObjectForKey:@"messageType"];
    [m_request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
    m_request.defaultResponseEncoding = NSUTF8StringEncoding;
    [m_request setDelegate:self];
    [m_request startAsynchronous];

    
}


/*   数据发送  */
- (void)sendMessage:(NSData*)message
{
    NSString *jsonString = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",[NSString stringWithFormat:@"%@%@",HTTP_REQ_URL,jsonString]);
    ASIFormDataRequest *m_request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:HTTP_REQ_URL]];
    [m_request setPostValue:jsonString forKey:@"messageContent"];
    m_request.requestMethod = @"POST";
    [m_request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
    m_request.defaultResponseEncoding = NSUTF8StringEncoding;
    [m_request setDelegate:self];
    [m_request startAsynchronous];
    [jsonString release];
}

#pragma mark -ASIHTTPRequestDelegate Methods
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *result = [request responseString];
    NSLog(@"receive data = %@",result);


    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(),^{
        for(id<BirdHttpInterface>observer in self.observerArray)
        {
            
            SessionPacket *sessionPacket = [[SessionPacket alloc] init];
            sessionPacket.m_messageClass = request.m_messageClass;
            sessionPacket.m_messageType = request.m_messageType;
            sessionPacket.m_messageID = request.m_messageID;
            sessionPacket.m_useCache = request.m_useCache;
            sessionPacket.m_cacheKey = request.m_cacheKey;
            sessionPacket.m_importantMessage = request.m_importantMessage;
            if([observer respondsToSelector:@selector(receiveHttpMessage::)])
            {
                [observer receiveHttpMessage:data  :sessionPacket];
            }
        }
    });
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    
    NSError *error1 = [request error];
    NSLog(@"url:%@,error:%@",request.url,error1);
    
    
    NSString *result = [request responseString];
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    [resultDic setObject:@"NO" forKey:@"statusCode"];
   // [resultDic setObject:ERROR_CODE_TIME_OUT forKey:@"msg"];
    
        NSError *error = nil;
      NSData *data =   [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
        if (!error)
        {
            NSLog(@"Process JSON data is sucessed...");
        }
        else
        {
            NSLog(@"Process JSON data has error...");
        }

    
    dispatch_async(dispatch_get_main_queue(),^{
        for(id<BirdHttpInterface>observer in self.observerArray)
        {
            SessionPacket *sessionPacket = [[SessionPacket alloc] init];
            sessionPacket.m_messageClass = request.m_messageClass;
            sessionPacket.m_messageType = request.m_messageType;
            sessionPacket.m_messageID = request.m_messageID;
            sessionPacket.m_useCache = request.m_useCache;
            sessionPacket.m_cacheKey = request.m_cacheKey;
            sessionPacket.m_importantMessage = request.m_importantMessage;
            if([observer respondsToSelector:@selector(receiveHttpMessage::)])
            {
                [observer receiveHttpMessage:data :sessionPacket];
            }
        }
    });
    NSLog(@"%@",result);
}



@end
