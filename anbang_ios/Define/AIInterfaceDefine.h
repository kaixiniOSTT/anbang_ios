//
//  AIInterfaceDefine.h
//  anbang_ios
//
//  Created by rooter on 15-3-23.
//  Copyright (c) 2015年 ch. All rights reserved.
//

#ifndef anbang_ios_AIInterfaceDefine_h
#define anbang_ios_AIInterfaceDefine_h

// App normal

#define Color(HexString)       [UIColor colorFromHexString:HexString]
#define ColorWithAlpha(HexString, Alpha)       [UIColor colorFromHexString:HexString alpha:Alpha]

#define AB_Black_Color          Color(@"#403b36")
#define AB_Blue_Color           Color(@"#1774e6")
#define AB_Gray_Color           Color(@"#9c958a")
#define AB_White_Color          Color(@"#ffffff")
#define Normal_Border_Color     Color(@"#d1c0a5")
#define AB_Red_Color            Color(@"#e55a39")
#define Controller_View_Color   Color(@"#f6f2ed")
#define Label_Back_Color        Color(@"#e7e2dd")
#define Notice_Font_Color       Color(@"#5b5752")
#define SearchBar_Tint_Color    Label_Back_Color
#define Table_View_Cell_Selection_Color   Label_Back_Color
#define Table_View_Separator_Color Color(@"#f6f3ee")
#define LINK_Color Color(@"#1774e6")

// Chat input field

#define AB_Input_Field_Back_Color      Color(@"#efe8df")
#define AB_Release_Back_Color          Color(@"#ddd4c9")
#define AB_Input_Field_Top_Separator_Color   Color(@"#cbc7be")

// Chat Buddy
#define Buddy_Table_Separator_color   Color(@"#e7e2dd")

// User Center
#define UserCenter_Table_Separator_Color    Color(@"#f4f0eb")

#define AB_Color_403b36 Color(@"#403b36")
#define AB_Color_1774e6 Color(@"#1774e6")
#define AB_Color_9c958a Color(@"#9c958a")
#define AB_Color_ffffff Color(@"#ffffff")
#define AB_Color_d1c0a5 Color(@"#d1c0a5")
#define AB_Color_e55a39 Color(@"#e55a39")
#define AB_Color_f6f2ed Color(@"#f6f2ed")
#define AB_Color_c6502c Color(@"#c6502c")
#define AB_Color_e7e2dd Color(@"#e7e2dd")
#define AB_Color_5b5752 Color(@"#5b5752")
#define AB_Color_f6f3ee Color(@"#f6f3ee")
#define AB_Color_efe8df Color(@"#efe8df")
#define AB_Color_ddd4c9 Color(@"#ddd4c9")
#define AB_Color_cbc7be Color(@"#cbc7be")
#define AB_Color_e7e2dd Color(@"#e7e2dd")
#define AB_Color_f4f0eb Color(@"#f4f0eb")
#define AB_Color_7ac141 Color(@"#7ac141")
#define AB_Color_68af2f Color(@"#68af2f")
#define AB_Color_c3bdb4 Color(@"#c3bdb4")
#define AB_Color_fffdf5 Color(@"#fffdf5")
#define AB_Color_d3d1cd Color(@"#d3d1cd")
#define AB_Color_1774e6 Color(@"#1774e6")
#define AB_Color_fe0000 Color(@"#fe0000")
#define AB_Color_222222 Color(@"#222222")

#define AB_FONT_12 [UIFont systemFontOfSize:12]
#define AB_FONT_12_B [UIFont boldSystemFontOfSize:12]
#define AB_FONT_13 [UIFont systemFontOfSize:13]
#define AB_FONT_14 [UIFont systemFontOfSize:14]
#define AB_FONT_15 [UIFont systemFontOfSize:15]
#define AB_FONT_16 [UIFont systemFontOfSize:16]
#define AB_FONT_17 [UIFont systemFontOfSize:17]
#define AB_FONT_18 [UIFont systemFontOfSize:18]
#define AB_FONT_18_B [UIFont boldSystemFontOfSize:18]
#define AB_FONT_16_B [UIFont boldSystemFontOfSize:16]
#define AB_FONT_24 [UIFont systemFontOfSize:24]


#define kChatAvatarWidth 42.0f*kScreenScale
#define kChatAvatarPadding 8.0f*kScreenScale
#define kChatXPadding 29.0f*kScreenScale
#define kChatYPadding 18.0f*kScreenScale
#define MAX_WIDTH (Screen_Width - 150*kScreenScale)
#define kBubbleViewWidth (Screen_Width-116*kScreenScale)
#define kMsgPaddingRight 17.0f*kScreenScale
#define kMsgPaddingLeft 12.0f*kScreenScale
#define kPhonePadding 20.0f*kScreenScale
#define kTextHeight [UIFont systemFontOfSize:17].lineHeight
#define kSize(s, w, h, f) [s boundingRectWithSize:CGSizeMake(w, h) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:f]} context:nil].size

#endif
