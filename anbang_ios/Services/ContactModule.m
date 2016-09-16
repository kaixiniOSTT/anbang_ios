//
//  ContactModule.m
//  anbang_ios
//
//  Created by fighting on 14-5-27.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ContactModule.h"
#import "AddressBookCRUD.h"
#import "PinYinForObjc.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static ContactModule *singleton = nil;


@interface ContactModule(private)

-(id)init;
-(id)initWithDispatchQueue:(dispatch_queue_t)queue;
@end

@implementation ContactModule (private)


-(id)init
{
    self = [super init];
    return self;
}

-(id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    self = [super initWithDispatchQueue:queue];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isUploadAddressBook) name:@"NNC_AddressBook_Change" object:nil];

    }
    return self;
}

@end

@implementation ContactModule


+(id)shareContactModule
{
    @synchronized(self){
        if (singleton == nil) {
            singleton = [[self alloc] initWithDispatchQueue:dispatch_get_main_queue()];
        }
    }
    return singleton;
}




+(id)allocWithZone:(NSZone *)zone{
    
    @synchronized(self){
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}


//获取通讯录
-(void) getContacts{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    XMPPElement *query = (XMPPElement*)[XMPPElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/contacts"];
    XMPPElement *contact = [XMPPElement elementWithName:@"contact"];
    NSString *version =  [[NSUserDefaults standardUserDefaults]stringForKey:@"contact_version"];
    [contact addAttributeWithName:@"ver" stringValue:version];
    
    [query addChild:contact];
    [iq addChild:query];
    
    [xmppStream sendElement:iq];
//    NSLog(@"send xml:%@",iq);

}
//typedef void (*ABExternalChangeCallback)(ABAddressBookRef addressBook, CFDictionaryRef info, void *context);
//
//AB_EXTERN void ABAddressBookRegisterExternalChangeCallback(ABAddressBookRef addressBook, ABExternalChangeCallback callback, void *context);
//注册通讯录监听
-(void)registerCallback {
    
   
    if (!addressBooks) {
        addressBooks = ABAddressBookCreate();
         ABAddressBookRegisterExternalChangeCallback(addressBooks, MyAddressBookExternalChangeCallback, NULL);
    }else{
        ABAddressBookRegisterExternalChangeCallback(addressBooks, MyAddressBookExternalChangeCallback, NULL);

    }
}
//注销监听
- (void)unregisterCallback {
        ABAddressBookUnregisterExternalChangeCallback(addressBooks, MyAddressBookExternalChangeCallback, NULL);
}
//手机通讯里发生改变 回调方法
void MyAddressBookExternalChangeCallback (ABAddressBookRef addressBook,CFDictionaryRef info,void *context)
{
    [[NSUserDefaults standardUserDefaults]setObject:@"changeUploadAddressBook" forKey:@"changeUploadAddressBook"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    //这里可以写你想做的事
   
 
}
-(void)isUploadAddressBook{
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NNC_AddressBook_Change" object:nil];
    NSString *changeAddressBook=[[NSUserDefaults standardUserDefaults]objectForKey:@"changeUploadAddressBook"];
    if ([@"changeUploadAddressBook" isEqualToString:changeAddressBook]) {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"changeUploadAddressBook"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        //silencesky upd
        //NSMutableArray *arrphonenum= [[NSMutableArray alloc]init];
        NSMutableArray *addressBookTemps=[[NSMutableArray alloc]init];
        //----------------xiong 访问通讯录------------------------
         ABAddressBookRef addressBookRef = nil;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        {
            addressBookRef =  ABAddressBookCreateWithOptions(NULL, NULL);
            //获取通讯录权限
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
                dispatch_semaphore_signal(sema);
                accessGranted=granted;
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            //        dispatch_release(sema);
        }
        else
        {
            addressBookRef = ABAddressBookCreate();
        }

        //获取通讯录中的所有人
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        //通讯录中人数
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBookRef);
        //NSString *myUserName=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
        //循环，获取每个人的个人信息
        for (NSInteger i = 0; i < nPeople; i++)
        {
            //新建一个addressBook model类
            TKAddressBook *tkAddressBook = [[TKAddressBook alloc] init];
            //获取个人
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            //获取个人名字
            CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            CFStringRef abFullName = ABRecordCopyCompositeName(person);
            NSString *nameString = (__bridge NSString *)abName;
            NSString *lastNameString = (__bridge NSString *)abLastName;
            if ((__bridge id)abFullName != nil) {
                nameString = (__bridge NSString *)abFullName;
            } else {
                if ((__bridge id)abLastName != nil)
                {
                    nameString = [NSString stringWithFormat:@"%@%@", nameString, lastNameString];
                }
            }
            if ((__bridge id)abFullName == nil&&(__bridge id)abLastName == nil) {
                nameString=@"";
            }
            tkAddressBook.name = nameString;
            //通讯录中文名字转拼音
            NSString *outputPinyin=[PinYinForObjc chineseConvertToPinYin:nameString];
            tkAddressBook.sortKey=outputPinyin;
            tkAddressBook.recordID = (int)ABRecordGetRecordID(person);;
            ABPropertyID multiProperties[] = {
                kABPersonPhoneProperty,
                kABPersonEmailProperty
            };
            NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
            for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
                ABPropertyID property = multiProperties[j];
                ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
                NSInteger valuesCount = 0;
                if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
                
                if (valuesCount == 0) {
                    //silencesky upd
                    if (valuesRef)
                    CFRelease(valuesRef);
                    continue;
                }
                //获取电话号码和email
                for (NSInteger k = 0; k < valuesCount; k++) {
                    CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                    switch (j) {
                        case 0: {// Phone number
                            tkAddressBook.tel = (__bridge NSString*)value;
                            break;
                        }
                        case 1: {// Email
                            tkAddressBook.email = (__bridge NSString*)value;
                            break;
                        }
                    }
                    CFRelease(value);
                }
                CFRelease(valuesRef);
            }
            //将个人信息添加到数组中，循环完成后tkAddressBookTemp中包含所有联系人的信息
            [addressBookTemps addObject:tkAddressBook];
            if (abName) CFRelease(abName);
            if (abLastName) CFRelease(abLastName);
            if (abFullName) CFRelease(abFullName);
            //[tkAddressBook release];
        }
        //silencesky upd
        //arrphonenum =[AddressBookCRUD selectAddressBookPhoneNum:MY_JID];
        //    [AddressBookCRUD deleteAddressBookMyJid:myUserName];
        
        //silencesky upd
        if (allPeople) {
            CFRelease(allPeople);
        }
        
        NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/contacts"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        NSXMLElement *contact=[NSXMLElement elementWithName:@"contact"];
//        if (arrphonenum!=nil) {
//            if ([arrphonenum count]!=0) {
//                BOOL isHave=NO;
//                for (int i=0; i<[arrphonenum count]; i++) {
//                    isHave=NO;
//                    NSString *phonenum=[arrphonenum objectAtIndex:i];
//                    for (int j=0; j<[addressBookTemps count]; j++) {
//                        TKAddressBook *book=[addressBookTemps objectAtIndex:j];
//                        if ([book.tel isEqualToString:phonenum]) {
//                            isHave=YES;
//                        }
//                        if (isHave==NO) {
//                            NSXMLElement *item=[NSXMLElement elementWithName:@"item"];
//                            [item addAttributeWithName:@"phone" stringValue:phonenum];
//                            [item addAttributeWithName:@"remove" stringValue:@"true"];
//                            [contact addChild:item];
//                        }
//                    }
//                }
//            }
//        }
        for (int i=0; i<[addressBookTemps count]; i++) {
            NSXMLElement *item=[NSXMLElement elementWithName:@"item"];
            TKAddressBook *book=[addressBookTemps objectAtIndex:i];
            [item addAttributeWithName:@"phone" stringValue:book.tel];
            [item addAttributeWithName:@"name" stringValue:book.name];
            [item addAttributeWithName:@"sortKey" stringValue:book.sortKey];
            [contact addChild:item];
        }
        [contact addAttributeWithName:@"countryCode" stringValue:@"+86"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"ChangeUpload"];
        
        [queryElement addChild:contact];
        [iq addChild:queryElement];
//        NSLog(@"组装后的xml:%@",iq);
        [[XMPPServer xmppStream]sendElement:iq];
       // NSLog(@"%d,%d",[arrphonenum retainCount],[addressBookTemps retainCount]);
        //[arrphonenum release];
       // [addressBookTemps release];
        
        
        //silencesky upd
        if (addressBookRef) {
            CFRelease(addressBookRef);
        }
    }
   
 
}


#pragma mark--XmppStream Delegate

//请求通讯录（ver不同 插入数据库）
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
   
    dispatch_async(dispatch_get_main_queue(),^(void){
        NSXMLElement *query = [iq elementForName:@"query" xmlns:@"http://www.nihualao.com/xmpp/contacts"];
        
        if([query.xmlns isEqualToString:@"http://www.nihualao.com/xmpp/contacts"]){
            
    
        if (![iq isErrorIQ]) {
            if (query != nil && ([iq.type isEqualToString:@"set"] || [iq.type isEqualToString:@"result"] )) {
                //服务端通讯录通知，做插入数据库操作
                XMPPElement * contacts = (XMPPElement*)[query elementForName:@"contact"];
                if (contacts != nil) {
                      //通讯录最新的版本号
                      NSString *version = [contacts attributeStringValueForName:@"ver"];
                    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"contact_version"]; //保存通讯录最新版本号
                    
                    //后面，数据库相关操作，小熊实现
                    NSArray *items = [contacts children];
                    if ([items count]!=0) {
                        if ([items count]!=0) {
                            //NSString *myUserName=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
                            NSMutableArray *arr= [AddressBookCRUD selectAddressBookPhoneNum:MY_JID];
                            if ([arr count]!=0) {
                              //silencesky 修改
                              //[AddressBookCRUD deleteAddressBookMyJid:MY_JID];
                            }
                        }
                        for (NSXMLElement *item in items) {         //服务器通讯录
                            NSString *name=[[item attributeForName:@"name"] stringValue];
                            if (name!=nil) {
                               // NSString *myjid=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
                                NSString *phone=[[item attributeForName:@"phone"] stringValue];
                                NSString *jid=[[item attributeForName:@"jid"] stringValue];
                                if (jid==nil) {
                                    jid=@"";
                                }
                                [AddressBookCRUD insertServerAddressBookMyJid:MY_JID name:name phoneNum:phone jid:jid ver:version];
                            }else{   //<item phone=”” remove=”true”/>
                                NSString *phone=[[item attributeForName:@"phone"] stringValue];
                                [AddressBookCRUD deleteAddressBookPhoneNum:phone];
                            }
                        }
                    }
                }
            }
        }
            
            
        }
        // return 1;
    });
    return YES;

}

//接受服务器消息：上传通讯录
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    XMPPElement* pros = (XMPPElement*)[message elementForName:@"properties" xmlns:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
    
    NSMutableDictionary* properties = [[NSMutableDictionary alloc]initWithCapacity:0];
    if (pros != nil) {
        NSArray* arr = [pros children];
        for (NSXMLElement* item in arr) {
            NSString* key = [item elementForName:@"name"].stringValue;
            NSString* value = [item elementForName:@"value"].stringValue ;
            [properties setObject:value forKey:key];
           
        }
       
    }
    NSString* action = [properties valueForKey:@"_type"];
    if ([@"upload_contacts" isEqualToString:action]) {
        //上传通讯录code
        dispatch_async(dispatch_get_main_queue(),^(void){
            [self loadAddressBook];
            [self oneUploadAddressBook];
        });
    }
  }

//获取通讯录权限 本地通讯录
-(void)loadAddressBook{
    addressBookTemp=[[NSMutableArray alloc]initWithObjects: nil];
    //----------------xiong 访问通讯录------------------------
//    ABAddressBookRef addressBooks = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
        //获取通讯录权限
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){
            dispatch_semaphore_signal(sema);
            accessGranted=granted;
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //silencesky upd
       // dispatch_release(sema);
    }
    else
    {
        addressBooks = ABAddressBookCreate();
    }
    if ((([[[NSUserDefaults standardUserDefaults]objectForKey:@"ver"]isEqualToString:@"0"]||[[NSUserDefaults standardUserDefaults]objectForKey:@"ver"]==nil)&&accessGranted==YES)) {
        //获取通讯录中的所有人
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
        //通讯录中人数
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
        
        //循环，获取每个人的个人信息
        for (NSInteger i = 0; i < nPeople; i++)
        {
            //新建一个addressBook model类
            addressBook = [[TKAddressBook alloc] init];
            //获取个人
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            //获取个人名字
            CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            CFStringRef abFullName = ABRecordCopyCompositeName(person);
            NSString *nameString = (__bridge NSString *)abName;
            NSString *lastNameString = (__bridge NSString *)abLastName;
            if ((__bridge id)abFullName != nil) {
                nameString = (__bridge NSString *)abFullName;
            } else {
                if ((__bridge id)abLastName != nil)
                {
                    nameString = [NSString stringWithFormat:@"%@%@", nameString, lastNameString];
                }
            }
            if ((__bridge id)abFullName == nil&&(__bridge id)abLastName == nil) {
                nameString=@"";
            }
            addressBook.name = nameString;
            //通讯录中文名字转拼音
            NSString *outputPinyin=[PinYinForObjc chineseConvertToPinYin:nameString];
            addressBook.sortKey=outputPinyin;
            addressBook.recordID = (int)ABRecordGetRecordID(person);;
            ABPropertyID multiProperties[] = {
                kABPersonPhoneProperty,
                kABPersonEmailProperty
            };
            NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
            for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
                ABPropertyID property = multiProperties[j];
                ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
                NSInteger valuesCount = 0;
                if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
                
                if (valuesCount == 0) {
                    //silencesky upd
                    if (valuesRef) {
                    CFRelease(valuesRef);
                    }
                    continue;
                }
                //获取电话号码和email
                for (NSInteger k = 0; k < valuesCount; k++) {
                    CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                    switch (j) {
                        case 0: {// Phone number
                            addressBook.tel = (__bridge NSString*)value;
                            break;
                        }
                        case 1: {// Email
                            addressBook.email = (__bridge NSString*)value;
                            break;
                        }
                    }
                    CFRelease(value);
                }
                CFRelease(valuesRef);
            }
            //将个人信息添加到数组中，循环完成后addressBookTemp中包含所有联系人的信息
            [addressBookTemp addObject:addressBook];
            if (abName) CFRelease(abName);
            if (abLastName) CFRelease(abLastName);
            if (abFullName) CFRelease(abFullName);
            //[addressBook release];
        }
        //silencesky upd
        if (allPeople) {
            CFRelease(allPeople);
        }
    }

}



//首次上传通讯录
-(void)oneUploadAddressBook{
    /*<iq type=”set”>
     <query xmlns=”http://www.nihualao.com/xmpp/contacts”>
     <contact countryCode=”默认国家码”>
     <!--删除现有的通讯录条目-->
     <item phone=”” remove=”true”/> <!--新增或修改条目,修改条目可以是修改通讯录备注与 sortKey-->
     <item phone=”” name=”” sortKey=””/>
     </contact> </query>
     </iq>*/
    
    NSXMLElement *queryElement=[NSXMLElement elementWithName:@"query" xmlns:@"http://www.nihualao.com/xmpp/contacts"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *contact=[NSXMLElement elementWithName:@"contact"];
    
    for (int i=0; i<[addressBookTemp count]; i++) {
        NSXMLElement *item=[NSXMLElement elementWithName:@"item"];
        TKAddressBook *book=[addressBookTemp objectAtIndex:i];
        [item addAttributeWithName:@"phone" stringValue:book.tel];
        [item addAttributeWithName:@"name" stringValue:book.name];
        [item addAttributeWithName:@"sortKey" stringValue:book.sortKey];
        [contact addChild:item];
    }
    [contact addAttributeWithName:@"countryCode" stringValue:@"+86"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"oneUploadAddressBook"];
    [queryElement addChild:contact];
    [iq addChild:queryElement];
//    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream]sendElement:iq];
    [addressBookTemp removeAllObjects];
   // [addressBookTemp release];
}
-(void)dealloc{
   // [super dealloc];
}
@end
