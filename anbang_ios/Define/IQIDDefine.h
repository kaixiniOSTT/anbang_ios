//
//  IQIDDefine.h
//  anbang_ios
//
//  Created by silenceSky  on 14-6-9.
//  Copyright (c) 2014年 ch. All rights reserved.
//


#define IQID_Group_Upd_Name  @"Group_Upd_Name"
#define IQID_GroupMember_Upd_Name  @"GroupMember_Upd_Name"
#define IQID_Group_Delete_GroupMember  @"Group_Delete_GroupMember"

#define kBaseNameSpace @"http://www.nihualao.com/xmpp"

/**
 * Anonymous Namespace
 */

#define Namespace(xmlns)        [NSString xmlnsWithDefine:xmlns]

#define kUserInfoNameSpace Namespace(@"/userinfo") // userinfo
#define kIQRosterNameSpace @"jabber:iq:roster"

#define kPhoneValidateNameSpace Namespace(@"/anonymous/phone/validate")   //通过手机获取验证码


#define kEmailValidateNameSpace Namespace(@"/anonymous/email/validate")   //通过邮箱获取验证码

#define kResetPasswordNamesPace Namespace(@"/anonymous/resetPassword" )   //重新设置密码

#define kPhoneValidateCodeNameSpace  Namespace(@"/anonymous/phone/validateCode")   //校验验证码

#define kStoreupNameSpace Namespace(@"/storeup") // 收藏
#define kOrganizationSpace Namespace(@"/organization") //组织架构
#define kSearchSpace Namespace(@"/search") //搜索
#define kBadgeValueNamepace Namespace(@"/badge")

#define kCircleDetailNameSpace Namespace(@"/circle/information")
#define kXmppValidateNameSpace Namespace(@"/validate")

