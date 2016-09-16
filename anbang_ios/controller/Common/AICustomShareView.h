//
//  AICustomShareView.h
//  anbang_ios
//
//  Created by Kim on 15/7/28.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    AISharePlatformBBFriends,
    AISharePlatformBBCircle,
} AISharePlatform;

@interface AICustomShareView : NSObject

- (void)shareWithContent:(NSDictionary*)publishContent complete:(void(^)(AISharePlatform platform, NSDictionary *publishContent))completedBlock;//自定义分享界面

@end
