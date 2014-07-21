//
//  XMLParser.m
//  TutReader
//
//  Created by crekby on 7/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser
{
    NSMutableString* currentElementValue;
    NSMutableArray* items;
    NSMutableArray* newsItemsList;
    CallbackWithDataAndError globalCallback;
    TUTNews* news;
}

SINGLETON(XMLParser)

- (void) parseData:(NSData*) data withCallback:(CallbackWithDataAndError) callback
{
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    newsItemsList = [NSMutableArray new];
    globalCallback = callback;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [parser parse];
    });
}

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    
    if ([elementName isEqualToString:XML_ITEM])
    {
        items = [NSMutableArray new];
        news = [TUTNews new];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!currentElementValue)
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    else
        [currentElementValue appendString:string];
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (items) {
        if ([elementName isEqualToString:XML_TITLE]) {
            [currentElementValue replaceOccurrencesOfString:@"\n\t\n\t\t" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(0,currentElementValue.length)];
            news.newsTitle = currentElementValue;
        }
        if ([elementName isEqualToString:XML_NEWS_URL])
        {
            [currentElementValue replaceOccurrencesOfString:@"\n\t\t" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(0,currentElementValue.length)];
            news.newsURL = currentElementValue;
        }
        if ([elementName isEqualToString:XML_NEWS_TEXT]) {
            [currentElementValue replaceOccurrencesOfString:@"<br clear=\"all\" />" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(currentElementValue.length-20,20)];
            if ([currentElementValue rangeOfString:@"http"].location!=NSNotFound) {
                NSInteger startLink = [currentElementValue rangeOfString:@"http"].location;
                NSInteger lengthLink = [currentElementValue rangeOfString:@"\" width"].location-startLink;
                news.imageURL = [currentElementValue substringWithRange:NSMakeRange(startLink, lengthLink)];
            }
            if ([currentElementValue rangeOfString:@"\" />"].location!=NSNotFound) {
                NSInteger startDescr = [currentElementValue rangeOfString:@"\" />"].location+4;
                NSInteger lengthDescr = currentElementValue.length - startDescr;
                news.text = [currentElementValue substringWithRange:NSMakeRange(startDescr, lengthDescr)];
            }
            else
            {
                if (currentElementValue.length>3) {
                    [currentElementValue replaceOccurrencesOfString:@"\n\t\t" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(0,15)];
                    news.text = currentElementValue;
                }
            }
        }
        if ([elementName isEqualToString:XML_PUBLICATION_DATE]) {
            NSDateFormatter* formater = [NSDateFormatter new];
            [formater setDateFormat:XML_DATE_FORMAT];
            NSDate* date = [formater dateFromString:currentElementValue];
            news.pubDate = date;
            if (![news.newsURL isEqual:HOME_PAGE]) {
                [newsItemsList insertObject:news atIndex:newsItemsList.count];
            }
        }
    }
    currentElementValue=nil;
    
}

-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    if (globalCallback) {
        globalCallback(newsItemsList,nil);
    }
}


@end
