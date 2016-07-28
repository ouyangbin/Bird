

#ifndef CHFramework_CHSystemConfig_h
#define CHFramework_CHSystemConfig_h
/*    socket Define */
#define SERVER_TYPE "BS"// "AS"
#define SERVER_AS ""
#define SERVER_IP @"112.124.46.13"
//#define SERVER_IP @"192.168.1.114"

#define SERVER_PORT 9001
#define CH_NET_BUFFER_SIZE 2*1024*1024



//   使用本地数据,用于模拟网络接口访问
#define USE_LOCALHOST_DATA @"userLocalHostData"
//   使用缓存开关
#define USE_CACHE_DATA @"useCacheData"
#define CACHE_DATA_KEY @"cacheDataKey"

//是否为重要消息
#define ImportantMessage @"importantMessage"



/*  server   */

/*   定义HTTP 接口使用 GET ，还是POST  */
//#define HTTP_METHOD_GET


#endif
