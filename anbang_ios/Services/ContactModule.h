//
//  ContactModule.h
//  anbang_ios
//
//  Created by fighting on 14-5-27.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "XMPPModule.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "TKAddressBook.h"
@interface ContactModule : XMPPModule
{
    BOOL _hasRegister;
    ABAddressBookRef addressBooks;
    //-通讯录----------------
    NSMutableArray *addressBookTemp;
    TKAddressBook *addressBook;
    __block BOOL accessGranted;
    NSMutableArray *arrPhoneNum;
    //-----------------------
   
}


+(id)shareContactModule;
-(void) getContacts;
-(void)registerCallback;
-(void)unregisterCallback;
@end
