//
//  RoyaDialViewDelegate.h
//  anbang_ios
//
//  Created by seeko on 14-4-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RoyaDialView;
@protocol RoyaDialViewDelegate <NSObject>
@optional
-(void)onDialView:(RoyaDialView*) view makePhoneCall:(NSString *) phoneNum;
-(void)onDialView:(RoyaDialView*) view dialNumber:(NSString *)phoneNum withKey:(NSInteger)key;
-(void)txtNum:(NSString *)num;

@end
