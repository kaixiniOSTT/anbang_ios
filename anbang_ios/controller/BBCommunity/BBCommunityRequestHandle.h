//
//  RequestHandle.h
//  DoBan
//
//  Created by
//  Copyright (c) 2015年  All rights reserved.
//

#import <Foundation/Foundation.h>
@class BBCommunityRequestHandle;

@protocol BBCommunityRequestHandleDelegate <NSObject>

- (void)requestHandle:(BBCommunityRequestHandle*)requestHandle RequestSuccessWithResponse:(NSHTTPURLResponse*)response;
- (void)requestHandle:(BBCommunityRequestHandle*)requestHandle RequestSuccessWithData:(NSData*)data;
- (void)requestHandle:(BBCommunityRequestHandle*)requestHandle RequestSuccessWithError:(NSError*)error;

@end



@interface BBCommunityRequestHandle : NSObject <NSURLConnectionDataDelegate>
@property (nonatomic, assign) id<BBCommunityRequestHandleDelegate> delegate;
@property (nonatomic, retain) NSMutableData* data;
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSHTTPURLResponse* response;

- (id)initWithURLString:(NSString*)URLString
                  Param:(NSString*)paramString
                 Method:(NSString*)method
                 Header:(NSDictionary*)header
               Delegate:(id<BBCommunityRequestHandleDelegate>)delegate;

-(void)closeConnect;
@end
