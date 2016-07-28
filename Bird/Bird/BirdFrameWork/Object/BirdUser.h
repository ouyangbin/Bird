//  Created by Naval on 16/7/28.
//  Copyright © 2016年 Naval. All rights reserved.
//  GitHub address: https://github.com/ouyangbin

#import <Foundation/Foundation.h>
//  用户角色
typedef enum  USER_ROLE{
    USER_ROLE_NONE,
    USER_ROLE_NORMAL,
    USER_ROLE_ADMIN,
    USER_ROLE_MAX
}USER_ROLE;

// 记录用户状态
enum USERSTATE{
    USERSTATE_NONE,
    USERSTATE_NO_ACCOUNT,//没有帐号，密码
    USERSTATE_NO_LOGIN_HAVE_ACCOUNT_LOGINOUT,// 因为注销而没有登录
    USERSTATE_NO_LOGIN_HAVE_ACCOUNT_NOTNET,//因为没有网络而没有登录
    USERSTATE_NO_LOGIN_TOKENEXPIRED,//token失效
    USERSTATE_LOGIN,//登录成功
    USERSTATE_LOGIN_FAILED_LOGINED_BY_OTHER_PHONE,//
    USERSTATE_LOGIN_FAILED, //登录失败
    USERSTATE_MAX
};


@interface BirdUser : NSObject
@property(nonatomic,copy)NSString * m_userID;/*  用户ID*/
@property(nonatomic,copy)NSString * m_userIcon;/*  用户Icon */
@property(nonatomic,copy)NSString * m_phoneNumber;//手机号
@property(nonatomic,assign)enum USERSTATE m_userState;//用户状态
@property(nonatomic,assign)enum USER_ROLE m_userRole;//用户角色
@property(nonatomic,copy)NSString *m_token;//用户Token，用于认证
@property(nonatomic,copy)NSString *m_sessionID;//用户SessionID，用于认证码。。。。。
@end
