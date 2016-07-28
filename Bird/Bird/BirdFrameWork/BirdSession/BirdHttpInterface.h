

#import <Foundation/Foundation.h>

@interface SessionPacket : NSObject
@property (retain) NSString *m_messageClass;
@property (retain) NSString *m_messageType;
@property (retain) NSString *m_messageID;

@property (retain) NSString *m_useCache;// 使用缓存
@property (retain) NSString *m_cacheKey;//缓存KEY

@property (retain) NSString *m_importantMessage;//是否为重要消息
@end


@protocol BirdHttpInterface <NSObject>

@optional

- (void)receiveHttpMessage:(NSData*)data :(SessionPacket*)sessionPacket;


@end
