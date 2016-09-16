//
//  AsynImageView.h
//  AsynImage
//
//  Created by administrator on 13-3-5.
//  Copyright (c) 2013年 enuola. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsynImageView : UIImageView<NSURLConnectionDataDelegate>
{
    NSURLConnection *connection;
    NSMutableData *loadData;
}
//图片对应的缓存在沙河中的路径
@property (nonatomic, retain) NSString *fileName;

//指定默认未加载时，显示的默认图片
@property (nonatomic, retain) UIImage *placeholderImage;
//请求网络图片的URL
@property (nonatomic, retain) NSString *imageURL;

//下载完成，将文件保存到沙河里面
-(void)connectionDidFinishLoading:(NSURLConnection *)theConnection;
@end
