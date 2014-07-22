//
//  RemoteFacade.m
//  TutReader
//
//  Created by crekby on 7/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "RemoteFacade.h"

@implementation RemoteFacade

SINGLETON(RemoteFacade)

#pragma mark - Get Data From RSS Server

- (void) getOnlineNewsDataWithCallback:(CallbackWithDataAndError) callback
{
    NSURL* url = [NSURL URLWithString:RSS_URL];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode==HTTP_OK && !connectionError) {
            if (callback) {
                callback(data,nil);
            }
        }
        else
        {
            if (callback) {
                callback(nil,connectionError);
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    }];
}
@end
