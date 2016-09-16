//
//  PublicDefine.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-29.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#define __THIS_FILE__ [@__FILE__ lastPathComponent]

#ifdef __OBJC__

#define JLLog_D(format, ...) \
    NSLog(@"[Debug]%@/Line-%d/ " format, __THIS_FILE__,__LINE__, ##__VA_ARGS__)

#define JLLog_I(format, ...) \
    NSLog(@"[Infos]%@/Line-%d/ "  format, __THIS_FILE__,__LINE__, ##__VA_ARGS__)

#define JLLog_E(format, ...) \
    NSLog(@"[Error]%@/Line-%d/ " format, __THIS_FILE__,__LINE__, ##__VA_ARGS__)

#endif

#define iOS_Version [[UIDevice currentDevice].systemVersion doubleValue]
#define IS_iOS7     (iOS_Version >= 7.0)
#define IS_iOS8     (iOS_Version >= 8.0)
#define Is_iOS6 [[UIDevice currentDevice] systemVersion].doubleValue < 7.0 ? YES : NO

#define Screen_Bounds [[UIScreen mainScreen] bounds]
#define Screen_Width  Screen_Bounds.size.width
#define Screen_Height Screen_Bounds.size.height

#define kScreenScale Screen_Width/375.0f

#define Status_Bar_Height 20
#define Navigation_Bar_Height 44
#define Both_Bar_Height (Status_Bar_Height + Navigation_Bar_Height)

#define kText_Font  [UIFont systemFontOfSize:13.0]

#define IS_FourInch (Screen_Height == 568)
#define IS_3_5Inch  (Screen_Height == 480)

#define kNew_Feature_Hide  @"__New_Feature_Hide"
#define kFirst_Time_Load   @"__First_Time_Load"
#define kMy_Collection_Ver @"__My_Collection_Ver"
#define kBool_Voice_Mode_Play_Record @"__Voice_Play_mode_Record"
#define kOrganization_Contact_Ver @"__Organization_Contact"
#define kNew_Friends_List_Ver @"__New_Friends_List"

#define IWColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define KCurrHeight [UIScreen mainScreen].bounds.size.height

#define KCurrWidth [UIScreen mainScreen].bounds.size.width

#define MY_USER_NAME [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"]

#define MY_JID [NSString stringWithFormat:@"%@@%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"], OpenFireHostName]

#define MY_JID2 [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] stringByAppendingFormat:@"@%@/%@",OpenFireHostName,@"Hisuper"]

#define kIsiPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define kIsIPhone5 ([[UIScreen mainScreen] bounds].size.height == 568)

#define kIOS_VERSION [[UIDevice currentDevice].systemVersion doubleValue]

#define kIsiPhone4 ([[UIScreen mainScreen] bounds].size.height == 480)

#define kIsPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define kIsiPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define kIsiPhone6p ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)



#define CHAT_BEGIN_FLAG @"["

#define CHAT_END_FLAG @"]"

//数据库地址
#define SQLITE_DB_PATH [NSString stringWithFormat:@"%@_%@",@"NSUD_SQLite_DB_Path",[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"]]

//公用数据库地址
#define SQLITE_PUBLIC_DB_PATH @"NSUD_SQLite_Public_DB_Path" 

//国际化
#define kLanguage [[NSUserDefaults standardUserDefaults] setValue:currentLanguage forKey:@"NSUD_language"]

/*风格基调为红色*/
#define kAppStyleColor [UIColor colorWithRed:(222/255.0) green:(24/255.0) blue:(20/255.0) alpha:1]

//主要色调
//蓝色
#define  kMainColor [UIColor colorWithRed:0.0 green:0.4 blue:0.8 alpha:1]
//#define  kMainColor [UIColor colorFromHexString:@"#FF4500"]

//蓝色2
#define  kMainColor_1 [UIColor colorWithRed:0.0 green:0.4 blue:1 alpha:1]

//灰色
#define  kMainColor4 [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0]

//橙色
#define  kMainColor5 [UIColor colorFromHexString:@"#2196f3"]

//黑色
#define  kMainColor6 [UIColor blackColor]

//灰色
#define  kMainColor7 [UIColor colorWithRed:156.0/255.0 green:149.0/255.0 blue:138.0/255.0 alpha:1]
//灰色
#define  kMainColor7_1 [UIColor colorFromHexString:@"#eaeaea"]
//灰色
#define  kMainColor7_2 [UIColor colorFromHexString:@"#cccccc"]

//红色
#define  kMainColor8 [UIColor colorWithRed:229.0/255.0 green:90.0/255.0 blue:57.0/255.0 alpha:1]


