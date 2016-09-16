//
//  AICollectionTool.m
//  anbang_ios
//
//  Created by rooter on 15-5-7.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import "AICollectionTool.h"
#import "AIItemModel.h"
#import "AINavigationController.h"
#import "AIControllersTool.h"
#import "AICurrentContactController.h"

@implementation AICollectionTool

+ (void)registerNotificationsInController:(UIViewController *)viewController
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:viewController selector:@selector(deleteCollectionSucceed:) name:@"AI_Collection_Delete_Return" object:nil];
    [center addObserver:viewController selector:@selector(deleteCollectionError:) name:@"AI_Collection_Delete_Error" object:nil];
    [center addObserver:viewController selector:@selector(deleteCollectionsSucceed:) name:@"AI_Collections_Delete_Return" object:nil];
    [center addObserver:viewController selector:@selector(deleteCollectionsError:) name:@"AI_Collections_Delete_Error" object:nil];
    [center addObserver:viewController selector:@selector(getCollectionReturn:) name:@"AI_Collection_List_Return" object:nil];
    [center addObserver:viewController selector:@selector(getCollectionError:) name:@"AI_Collection_List_Error" object:nil];
}

+ (void)removeNotificationsInContorller:(UIViewController *)viewContorller
{
     NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:viewContorller name:@"AI_Collection_Delete_Return" object:nil];
    [center removeObserver:viewContorller name:@"AI_Collection_Delete_Error" object:nil];
    [center removeObserver:viewContorller name:@"AI_Collections_Delete_Return" object:nil];
    [center removeObserver:viewContorller name:@"AI_Collections_Delete_Error" object:nil];
    [center removeObserver:viewContorller name:@"AI_Collection_List_Return" object:nil];
    [center removeObserver:viewContorller name:@"AI_Collection_List_Error" object:nil];
}

+ (void)retweet:(NSArray *)collections presentDetailControllerWithController:(UIViewController *)aController
{
    NSMutableArray *resultset = [NSMutableArray array];
    for (AIItemModel *model in collections) {
        
        AICollection *collection = model.collection;
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        
        [item setObject:collection.message forKey:@"text"];
        switch (collection.messageType) {
            case AIMessageTypeText:
                [item setObject:@"chat" forKey:@"subject"];
                break;
                
            case AIMessageTypePicture:
                [item setObject:@"image" forKey:@"subject"];
                break;
                
            default:
                break;
        }
        [resultset addObject:item];
    }
    AICurrentContactController *controller = [[AICurrentContactController alloc] init];
    controller.fromUserName = @"collection";
    controller.messages = resultset;
    AINavigationController *navigation = [[AINavigationController alloc] initWithRootViewController:controller];
    [aController presentViewController:navigation animated:YES completion:nil];
}

+ (void)trash:(NSArray *)collections loadingInViewController:(UIViewController *)controller
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Collections_Delete"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kStoreupNameSpace];
        
        for (AIItemModel *item in collections) {
            AICollection *collection = item.collection;
            
            NSXMLElement *storeup = [NSXMLElement elementWithName:@"storeUp"];
            [storeup addAttributeWithName:@"id" stringValue:collection.serviceId];
            [storeup addAttributeWithName:@"do" stringValue:@"delete"];
            
            [query addChild:storeup];
        }
        
        [iq addChild:query];
        [[XMPPServer xmppStream] sendElement:iq];
        
        JLLog_I(@"collection delete (iq=%@)", iq);
    });
    
    [AIControllersTool loadingViewShow:controller];
}

+ (void)getCollectionList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *ver = [[NSUserDefaults standardUserDefaults] objectForKey:kMy_Collection_Ver];
        
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        [iq addAttributeWithName:@"id" stringValue:@"AI_Get_Collection_List"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:kStoreupNameSpace];
        [query addAttributeWithName:@"ver" stringValue:ver];
        
        [iq addChild:query];
        
        [[XMPPServer xmppStream] sendElement:iq];
        
        JLLog_I(@"collection get list = %@", iq);
    });
}

@end
