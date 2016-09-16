//
//  InviteUtil.m
//  testxml
//
//  Created by fighting on 14-5-26.
//  Copyright (c) 2014年 figting. All rights reserved.
//

#import "InviteUtil.h"
#import "ASIHTTPRequest.h"

static InviteUtil *instance = nil;

@implementation InviteUtil

+(InviteUtil *)instance{
  
    if (instance == nil) {
        instance = [[InviteUtil alloc]init];
    }
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        self.mData = [[NSMutableDictionary alloc]initWithCapacity:0];
        //找到本地test.xml文件
        NSString*path = [[NSBundle mainBundle]   pathForResource:@"ResourceRules"ofType:@"plist"];
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
        NSData *data = [file readDataToEndOfFile];
        //开始解析
        NSXMLParser* xmlRead = [[NSXMLParser alloc] initWithData:data];//初始化NSXMLParser对象
        
        JLLog_I("(xmlRead = %@)",xmlRead);
        
        [xmlRead setDelegate:self];//设置NSXMLParser对象的解析方法代理
        [xmlRead parse];//调用代理解析NSXMLParser对象，看解析是否成功
    }
    return self;
}

//检测task元素
-(void)checkTask{
    NSString* task = [self.mData objectForKey:@"task"];
    if (task==nil) {
        return;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:task forKey:@"task"];
    }
}


//自动注册流程
-(BOOL)isAutoRegister{
    if ([self.mData objectForKey:@"register"] == nil) {
        return NO;
    }else
    {
        return YES;
    }
}

//动态打包的服务器地址
-(BOOL)isServersUrl{
    if ([self.mData objectForKey:@"address-servers"] == nil) {
        return NO;
    }else
    {
        return YES;
    }
}

//自动登录流程
//如果文件里包含code元素 并根据code 获取到用户名跟密码，并序列化到nsuserdefault
-(BOOL)isAutoLogin{
    NSString* code = [self.mData objectForKey:@"code"];
    
    if (code == nil) {
        return NO;
    }
    code = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableString * reqUrl = [NSMutableString stringWithFormat:@"%@/retrieve-auth?code=%@",httpRequset,code];
    NSURL *url = [NSURL URLWithString:reqUrl ];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSData *resp = [request responseData];
        NSError* error;
        NSJSONSerialization * json  = [ NSJSONSerialization JSONObjectWithData:resp options:NSJSONReadingMutableContainers error:&error];
        if (error == nil) {
            //
            NSString* username = [json valueForKey:@"username"];
            NSString* password = [json valueForKey:@"password"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         
            [defaults setObject:username forKey:@"userName"];
            [defaults setObject:password forKey:@"password"];
            //短信和二维码安装时密码系统生成，称为一次性密码；
            [defaults setObject:password forKey:@"oncePassword"];
            [defaults setObject:code forKey:@"code"];
            return YES;
        }
        else
            return NO;
    }
    else
        return NO;
}

//标准流程
-(BOOL)isStandardLogin{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDefault valueForKey:@"userName"];
    NSString* password = [userDefault valueForKey:@"password"];
    if (username && password) {
        return YES;
    }
    else
        return NO;
}


//检则apk是否有效
-(BOOL)checkApkidIsvalid{
    NSString* apkId = [self.mData objectForKey:@"apkId"];
    if (apkId == nil) {
        return NO;
    }
   
     apkId = [apkId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[NSUserDefaults standardUserDefaults] setObject:apkId forKey:@"apkId"];
    NSMutableString * reqUrl = [NSMutableString stringWithFormat:@"%@/apk-check?apkId=%@",httpRequset,apkId];
    NSURL *url = [NSURL URLWithString:reqUrl ];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSData *resp = [request responseData];
        NSError* error;
        NSJSONSerialization * json  = [ NSJSONSerialization JSONObjectWithData:resp options:NSJSONReadingMutableContainers error:&error];
        if (error == nil) {
            //
            BOOL isValid = NO;
            NSString* valid = [json valueForKey:@"valid"];
            isValid = [valid boolValue];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            [defaults setObject:valid forKey:@"NSUD_Valid"];
         
            
           
            return isValid;
        }
        else
            return NO;
    }
    else
        return NO;
    
}


-(NSString*) objectForkey:(NSString*) key{
    return [_mData objectForKey:key];
}


#pragma mark XMLDELEGATE

//开始解析前，在这里可以做一些初始化工作
// 假设已声明有实例变量 dataDict，parserObject
- (void)parserDidStartDocument:(NSXMLParser *)parser {
   
    
}




//当解析器对象遇到xml的开始标记时，调用这个方法。
//获得结点头的值
//解析到一个开始tag，开始tag中可能会有properpies，例如<book catalog="Programming">
//所有的属性都存储在attributeDict中
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    mType = elementName;
    if([mType isEqualToString:@"entry"]) {
        mKey = nil;
        mValue = nil;
        mKey = [attributeDict objectForKey:@"key"];
        
        
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if([mType isEqualToString:@"entry"]) {
        if (mValue == nil) {
            mValue = [NSMutableString stringWithString:string];
        }else{
            [mValue appendString:string];
        }
        
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if([mType isEqualToString:@"entry"]) {
        [self.mData setObject:mValue forKey:mKey];
    }
}




- (void)parserDidEndDocument:(NSXMLParser *)parser{
//    NSLog(@"resut:%@",self.mData);
}

-(void) showAlert:(NSString*)msg
{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"调试" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alertView show];
    //[alertView release];
}
@end
