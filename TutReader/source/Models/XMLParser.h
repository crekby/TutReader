//
//  XMLParser.h
//  TutReader
//
//  Created by crekby on 7/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParser : NSObject <NSXMLParserDelegate>

+ (XMLParser*)instance;

- (void) parseData:(NSData*) data withCallback:(CallbackWithDataAndError) callback;

@end
