//
//  ImageUtility.h
//  anbang_ios
//
//  Created by silenceSky  on 14-6-18.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtility : NSObject


+(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 threeImage:(UIImage *)image3 four:(UIImage *)image4;
+(UIImage *)getGroupAvatar:(NSArray *)imageArray;
+(UIImage *)reDrawImage:(UIImage *)image1;
+(UIImage *)imgAddText:(UIImage *)img img:(UIImage*)img2 text:(NSString *)mark;
+(UIImage *)addText:(UIImage *)img text:(NSString *)text1;
+(UIImage *)addImageLogo:(UIImage *)img text:(UIImage *)logo;
//加半透明的水印
+(UIImage *)addImage:(UIImage *)useImage addImage1:(UIImage *)addImage1;

+(UIImage *)fixOrientation:(UIImage *)aImage;
+(UIImage *)fixOrientation:(UIImage *)aImage withOrientation:(UIImageOrientation) orientation;

//截取图片的某一部分
+(UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect;
+(UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize;
@end
