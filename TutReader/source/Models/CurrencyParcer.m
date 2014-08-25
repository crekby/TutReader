//
//  CurrencyParcer.m
//  TutReader
//
//  Created by crekby on 8/21/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "CurrencyParcer.h"
#import "Currency.h"

@interface CurrencyParcer() <NSXMLParserDelegate>

@property NSMutableString* currentElementValue;
@property NSMutableArray* items;
@property (nonatomic, strong) CallbackWithDataAndError globalCallback;
@property (nonatomic, strong) Currency* currency;
@property (nonatomic,strong) NSString* currencyID;

@end

@implementation CurrencyParcer

SINGLETON(CurrencyParcer)

- (void) parseData:(NSData*) data withCallback:(CallbackWithDataAndError) callback
{
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    _globalCallback = callback;
    self.items = [NSMutableArray new];
    [parser parse];
}

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    
    if ([elementName isEqualToString:@"Currency"])
    {
        self.currency = [Currency new];
        self.currencyID = [attributeDict valueForKey:@"Id"];
    }
    if ([elementName isEqualToString:@"Record"]) {
        self.currency = [Currency new];
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
    if (self.currency) {
        if (self.currencyID) {
            self.currency.currencyID = self.currencyID;
        }
        if ([elementName isEqualToString:@"CharCode"]) {
            self.currency.charCode = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        if ([elementName isEqualToString:@"QuotName"]) {
            self.currency.name = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
        }
        if ([elementName isEqualToString:@"Rate"]) {
            self.currency.exchangeRate = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.items insertObject:self.currency atIndex:self.items.count];
        }
        self.currentElementValue=nil;
    }
}

-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    if (_globalCallback) {
        _globalCallback(self.items,nil);
    }
}

@end
