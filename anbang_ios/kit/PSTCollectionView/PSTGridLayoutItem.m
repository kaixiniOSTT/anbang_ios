//
//  PSTGridLayoutItem.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTGridLayoutItem.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation PSTGridLayoutItem

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p itemFrame:%@>", NSStringFromClass(self.class), self, NSStringFromCGRect(self.itemFrame)];
}

@end
