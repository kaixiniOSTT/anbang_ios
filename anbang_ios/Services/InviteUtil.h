//
//  InviteUtil.h
//  testxml
//
//  Created by fighting on 14-5-26.
//  Copyright (c) 2014年 figting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InviteUtil : NSObject <NSXMLParserDelegate>{
    NSString* mType;
    NSString* mKey;
    NSMutableString* mValue;
   
   
}
@property(nonatomic,retain) NSMutableDictionary* mData;
+(InviteUtil *)instance;

//自动注册流程
-(BOOL)isAutoRegister;

//自动登录流程
-(BOOL)isAutoLogin;

//标准流程
-(BOOL)isStandardLogin;

//检测apkid是否可用
-(BOOL)checkApkidIsvalid;

-(void)checkTask;

//动态打包的服务器地址
-(BOOL)isServersUrl;

-(NSString*) objectForkey:(NSString*) key;




@end
