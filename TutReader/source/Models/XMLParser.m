//
//  XMLParser.m
//  TutReader
//
//  Created by crekby on 7/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "XMLParser.h"
#import "TUTNews.h"

@interface XMLParser ()

@property NSMutableString* currentElementValue;
@property NSMutableArray* items;
@property NSMutableArray* newsItemsList;
@property TUTNews* news;

@end


@implementation XMLParser
{
    CallbackWithDataAndError globalCallback;
}

SINGLETON(XMLParser)

- (void) parseData:(NSData*) data withCallback:(CallbackWithDataAndError) callback
{
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    self.newsItemsList = [NSMutableArray new];
    globalCallback = callback;
    [parser parse];
}

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    
    if ([elementName isEqualToString:XML_ITEM])
    {
        self.items = [NSMutableArray new];
        self.news = [TUTNews new];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!self.currentElementValue)
        self.currentElementValue = [[NSMutableString alloc] initWithString:string];
    else
        [self.currentElementValue appendString:string];
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (self.items) {
        if ([elementName isEqualToString:XML_TITLE]) {
            [self.currentElementValue replaceOccurrencesOfString:@"\n\t\n\t\t" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(0,self.currentElementValue.length)];
            self.news.newsTitle = self.currentElementValue;
        }
        if ([elementName isEqualToString:XML_NEWS_URL])
        {
            [self.currentElementValue replaceOccurrencesOfString:@"\n\t\t" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(0,self.currentElementValue.length)];
            self.news.newsURL = self.currentElementValue;
        }
        if ([elementName isEqualToString:XML_NEWS_TEXT]) {
            if (self.currentElementValue.length>3) {
                [self.currentElementValue replaceOccurrencesOfString:@"<br clear=\"all\" />" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(self.currentElementValue.length-20,20)];
                if ([self.currentElementValue rangeOfString:@"http"].location!=NSNotFound) {
                    NSInteger startLink = [self.currentElementValue rangeOfString:@"http"].location;
                    NSInteger lengthLink = [self.currentElementValue rangeOfString:@"\" width"].location-startLink;
                    self.news.imageURL = [self.currentElementValue substringWithRange:NSMakeRange(startLink, lengthLink)];
                }
                if ([self.currentElementValue rangeOfString:@"\" />"].location!=NSNotFound) {
                    NSInteger startDescr = [self.currentElementValue rangeOfString:@"\" />"].location+4;
                    NSInteger lengthDescr = self.currentElementValue.length - startDescr;
                    self.news.text = [self.currentElementValue substringWithRange:NSMakeRange(startDescr, lengthDescr)];
                }
                else
                {
                    if (self.currentElementValue.length>3) {
                        [self.currentElementValue replaceOccurrencesOfString:@"\n\t\t" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(0,15)];
                        self.news.text = self.currentElementValue;
                    }
                }
            }
        }
        if ([elementName isEqualToString:XML_PUBLICATION_DATE]) {
            NSDateFormatter* formater = [NSDateFormatter new];
            [formater setDateFormat:XML_DATE_FORMAT];
            NSDate* date = [formater dateFromString:self.currentElementValue];
            self.news.pubDate = date;
            if (![self.news.newsURL isEqual:HOME_PAGE]) {
                [self.newsItemsList insertObject:self.news atIndex:self.newsItemsList.count];
            }
        }
    }
    self.currentElementValue=nil;
    
}

-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    if (globalCallback) {
        globalCallback(self.newsItemsList,nil);
    }
}


@end
