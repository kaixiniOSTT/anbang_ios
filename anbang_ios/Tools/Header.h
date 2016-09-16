//
//  Header.h
//  EZLEARING
//
//  Created by he on 13-7-23.
//  Copyright (c) 2013年 midea. All rights reserved.
//

#ifndef EZLEARING_Header_h
#define EZLEARING_Header_h
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define viewHight (iPhone5?568:480)

#define WENXINTISHI    @"温馨提示"

#endif
