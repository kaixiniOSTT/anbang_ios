//
//  ImageUtility.m
//  anbang_ios
//
//  Created by silenceSky  on 14-6-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "ImageUtility.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

@implementation ImageUtility

+(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 threeImage:(UIImage *)image3 four:(UIImage *)image4
{
    
    //UIGraphicsBeginImageContext(image1.size);
    CGSize itemSize = CGSizeMake(90, 90);
    UIGraphicsBeginImageContext(itemSize);
    
    
    
    //Draw image2
    if (image2==nil && image3==nil && image4==nil) {
        
        [image1 drawInRect:CGRectMake(23, 23, 45, 45)];
    }else{
        [image1 drawInRect:CGRectMake(0, 0, 45, 45)];
    }
    //Draw image1
    [image2 drawInRect:CGRectMake(48, 0, 45, 45)];
    
    [image3 drawInRect:CGRectMake(0, 48, 45, 45)];
    
    
    [image4 drawInRect:CGRectMake(48, 48, 45, 45)];
    
    //    NSLog(@"****image1:%@",image1.description);
    //    NSLog(@"****image2:%@",image2.description);
    //    NSLog(@"****image3:%@",image3.description);
    //    NSLog(@"****image4:%@",image4.description);
    
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    
    return resultImage;
}

+ (UIImage*) getGroupAvatar:(NSArray*)avatarArray
{
    //NSTimeInterval t1 = [[NSDate date] timeIntervalSince1970];
    CGSize itemSize = CGSizeMake(98, 98);
    UIGraphicsBeginImageContext(itemSize);

    UIImageView *photoView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
    UIImage *placeHolderImage = [UIImage imageNamed:@"defaultUser.png"];
    int maxSize = 9;
    int j = 0;
    
    for (int i = 0; i < avatarArray.count; i ++) {
        NSString *avatar = nil;
        if([avatarArray[i] isKindOfClass: [NSDictionary class]]){
            avatar = [avatarArray[i] objectForKey:@"avatar"];
        } else if([avatarArray[i] isKindOfClass: [NSString class]]){
            avatar = avatarArray[i];
        }
        if([StrUtility isBlankString:avatar]) continue;
        NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ResourcesURL, avatar]];
        [photoView setImageWithURL:url placeholderImage:placeHolderImage];
        [photoView.image drawInRect:CGRectMake(32*(i%3)+2, 32*((int)i/3)+2, 30, 30)];
        if (++ j == maxSize) {
            break;
        }
    }

    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //NSTimeInterval t2 = [[NSDate date] timeIntervalSince1970];
    //JLLog_D(@"generateGroupAvatarByMemberArray spent %f ms", t2-t1);
    return resultImage;
}


+(UIImage *)reDrawImage:(UIImage *)image1{
    
    //UIGraphicsBeginImageContext(image1.size);
    CGSize itemSize = CGSizeMake(90, 90);
    UIGraphicsBeginImageContext(itemSize);
    
    [image1 drawInRect:CGRectMake(0, 0, 90, 90)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}



+ (UIImage *) imgAddText:(UIImage *)img img:(UIImage*)img2 text:(NSString *)mark {
    int w = img.size.width;
    int h = img.size.height;
    UIGraphicsBeginImageContext(img.size);
    
    [[UIColor blackColor] set];
    [img drawInRect:CGRectMake(0, 0, w, h-30)];
    [img2 drawInRect:CGRectMake(w/2-30/2, w/2-48/2, 20, 20)];
    
    //[mark drawInRect:CGRectMake(14, 135, 150, 20) withFont:[UIFont systemFontOfSize:16]];
    [mark drawInRect:CGRectMake(0, h-40, 150, 50) withFont:[UIFont systemFontOfSize:10] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aimg;
}


+(UIImage *)addText:(UIImage *)img text:(NSString *)text1
{
    //get image width and height
    int w = img.size.width;
    int h = img.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, 1);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextSetRGBFillColor(context, 0.0, 1.0, 1.0, 1);
    char* text = (char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];
    CGContextSelectFont(context, "Georgia", 30, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 255, 0, 0, 1);
    CGContextShowTextAtPoint(context, 10, h, text, strlen(text));
    //Create image ref from the context
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    return image;
}


+(UIImage *)addImageLogo:(UIImage *)img text:(UIImage *)logo
{
    //get image width and height
    int w = img.size.width;
    int h = img.size.height;
    UIGraphicsBeginImageContext(img.size);
    [[UIColor blackColor] set];
    [img drawInRect:CGRectMake(0, 0, w, h)];
    //[mark drawInRect:CGRectMake(14, 135, 150, 20) withFont:[UIFont systemFontOfSize:16]];
    [logo drawInRect:CGRectMake(w/2-35/2, w/2-35/2, 25, 25)];
    UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aimg;
    
}

//加半透明的水印
+ (UIImage *)addImage:(UIImage *)useImage addImage1:(UIImage *)addImage1
{
    UIGraphicsBeginImageContext(useImage.size);
    [useImage drawInRect:CGRectMake(0, 0, useImage.size.width, useImage.size.height)];
    [addImage1 drawInRect:CGRectMake(0, useImage.size.height-addImage1.size.height, addImage1.size.width, addImage1.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)fixOrientation:(UIImage *)aImage withOrientation:(UIImageOrientation) orientation {
    
    // No-op if the orientation is already correct
    if (orientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//截取图片的某一部分
+(UIImage *)clipImage:(UIImage*)image inRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbScale;
}

//压缩图片
+(UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

@end
