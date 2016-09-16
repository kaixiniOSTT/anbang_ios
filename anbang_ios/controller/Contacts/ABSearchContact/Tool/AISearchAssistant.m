//
//  AISearchAssistant.m
//  anbang_ios
//
//  Created by rooter on 15-5-13.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AISearchAssistant.h"

@implementation AISearchAssistant

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    
    [desc appendFormat:@"book=%@,", self.selectedBook];
    [desc appendFormat:@"agency=%@,", self.selectedAgency];
    [desc appendFormat:@"branch=%@,", self.selectedBranch];
    [desc appendFormat:@"key=%@,", self.searchKey];
    [desc appendFormat:@"after=%@,", self.after];
    [desc appendFormat:@"lever=%d", self.lavel];
    
    return [NSString stringWithFormat:@"<%@, %p> {%@}", [self class], self, desc];
}

- (void)sendSearchIQ
{
    JLLog_I(@"%@", self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Search_AB_Contact"];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kSearchSpace];
        [query addAttributeWithName:@"ver" stringValue:@"0"];
        
        NSXMLElement *set = [NSXMLElement elementWithName:@"set"];
        NSXMLElement *after = [NSXMLElement elementWithName:@"after" stringValue:(self.after ? self.after : @"")];
        NSXMLElement *max = [NSXMLElement elementWithName:@"max" stringValue:@"20"];
        [set addChild:after];
        [set addChild:max];
        
        NSXMLElement *keyType = [NSXMLElement elementWithName:@"keytype" stringValue:@"ABContacts"];
        NSXMLElement *key = [NSXMLElement elementWithName:@"key" stringValue:self.searchKey];
        NSXMLElement *book = [NSXMLElement elementWithName:@"book" stringValue:self.selectedBook];
        NSXMLElement *agency = [NSXMLElement elementWithName:@"agency" stringValue:self.selectedAgency];
        NSXMLElement *branch = [NSXMLElement elementWithName:@"branch" stringValue:self.selectedBranch];
        
        [query addChild:set];
        [query addChild:key];
        [query addChild:keyType];
        [query addChild:book];
        [query addChild:agency];
        [query addChild:branch];
        
        [iq addChild:query];
        
        JLLog_I(@"<seach contact IQ=%@>", iq);
        [[XMPPServer xmppStream] sendElement:iq];
    });
}

-(void)sendABContactInfoIQ:(NSString*)userName
{
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
            NSString *jid = [NSString stringWithFormat:@"%@@%@", userName, OpenFireHostName];
            
            NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
            [iq addAttributeWithName:@"id" stringValue:@"AI_Contact_Info"];
            [iq addAttributeWithName:@"type" stringValue:@"get"];
            
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kUserInfoNameSpace];
            NSXMLElement *user = [NSXMLElement elementWithName:@"user"];
            [user addAttributeWithName:@"jid" stringValue:jid];
            
            [query addChild:user];
            [iq addChild:query];
            
            JLLog_I(@"Contact info=%@", iq);
            [[XMPPServer xmppStream] sendElement:iq];
//        });
}

- (BOOL)canSendSearchIQ
{
    return ![StrUtility isBlankString:self.selectedBook] || ![StrUtility isBlankString:self.selectedAgency]
    || ![StrUtility isBlankString:self.selectedBranch] || ![StrUtility isBlankString:self.searchKey];
}

- (BOOL)canGoback
{
    return self.lavel > AIOrganizationLavelBook;
}

- (void)goBack:(void(^)(NSInteger lever))block
{
    switch (self.lavel) {
        case AIOrganizationLavelBook:
            break;
            
        case AIOrganizationLavelAgency:
            self.selectedAgency = @"";
            self.selectedBook = @"";    // 在返回到第一层的时候，一同把第一层的数据清除
            break;
            
        case AIOrganizationLavelBranch:
            self.selectedBranch = @"";
            break;
            
        default:
            break;
    }
    
    --self.lavel;
    block(self.lavel);
}

- (BOOL)canGoForward
{
    return self.lavel < AIOrganizationLavelBranch;
}

@end
