//
//  RequestHandle.m
//  DoBan
//
//  Created by 
//  Copyright (c) 2015年 All rights reserved.
//

#import "BBCommunityRequestHandle.h"
#import "BBCommunityVC.h"

@implementation BBCommunityRequestHandle




- (id)initWithURLString:(NSString*)URLString
                  Param:(NSString*)paramString
                 Method:(NSString*)method
                 Header:(NSDictionary*)header
               Delegate:(id<BBCommunityRequestHandleDelegate>)delegate{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        NSURL* url = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        
        if(header){
            for(NSString *key in header.allKeys){
                [request setValue:header[key] forHTTPHeaderField:key];
            }
        }

        if ([method isEqualToString:@"GET"]) {
            self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        }else if([method isEqualToString:@"POST"]){
            [request setHTTPMethod:@"POST"];
            
            if (![StrUtility isBlankString:paramString]) {
                [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
             self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        }
        
        
    }
    
    return self;
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.response = (NSHTTPURLResponse*)response;
    if([self.delegate respondsToSelector:@selector(requestHandle:RequestSuccessWithResponse:)]){
        [self.delegate requestHandle:self RequestSuccessWithResponse:self.response];
    }
    self.data = [NSMutableData data];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if([self.delegate respondsToSelector:@selector(requestHandle:RequestSuccessWithData:)]){
        [self.delegate requestHandle:self RequestSuccessWithData:_data];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(requestHandle:RequestSuccessWithError:)]) {
        [self.delegate requestHandle:self RequestSuccessWithError:error];
    }
}

-(void)closeConnect{
    [self.connection cancel];
}

-(void)dealloc{
    self.connection = nil;
    self.data = nil;
}
@end
