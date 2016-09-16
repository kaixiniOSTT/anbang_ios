//
//  UIImageViewTap.m
//  Momento
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import "MWTapDetectingImageView.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

const NSString *MWImageViewLongPressNotification = @"MWImageViewLongPressNotification";

@implementation MWTapDetectingImageView {
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    UIActionSheet *_actionSheet;
}

- (void)setupMe {
    self.userInteractionEnabled = YES;
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(postLongPressNotification:)];
        [self addGestureRecognizer:_longPressGestureRecognizer];
    }
}

- (void)postLongPressNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)MWImageViewLongPressNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
        [self setupMe];
	}
	return self;
}

- (id)initWithImage:(UIImage *)image {
	if ((self = [super initWithImage:image])) {
		[self setupMe];
	}
	return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
	if ((self = [super initWithImage:image highlightedImage:highlightedImage])) {
		[self setupMe];
	}
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = touch.tapCount;
	switch (tapCount) {
		case 1:
			[self handleSingleTap:touch];
			break;
		case 2:
			[self handleDoubleTap:touch];
			break;
		case 3:
			[self handleTripleTap:touch];
			break;
		default:
			break;
	}
	[[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
	if ([_tapDelegate respondsToSelector:@selector(imageView:singleTapDetected:)])
		[_tapDelegate imageView:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
	if ([_tapDelegate respondsToSelector:@selector(imageView:doubleTapDetected:)])
		[_tapDelegate imageView:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
	if ([_tapDelegate respondsToSelector:@selector(imageView:tripleTapDetected:)])
		[_tapDelegate imageView:self tripleTapDetected:touch];
}

@end
