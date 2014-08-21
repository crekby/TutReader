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

@property (nonatomic,strong) NSString* abbr;

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
    
    if ([elementName isEqualToString:@"currency"])
    {
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
        if ([elementName isEqualToString:@"name"]) {
            self.currency.name = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        if ([elementName isEqualToString:@"abbr"]) {
            self.abbr = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.currency.name = [self.currency.name stringByAppendingString:[NSString stringWithFormat:@" (%@)", self.abbr]];
        }
        if ([elementName isEqualToString:@"exch_buy"]) {
            self.currency.exchangeBuy = [[self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingString:@" руб."];
            
        }
        if ([elementName isEqualToString:@"exch_sell"]) {
            self.currency.exchangeSell = [[self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingString:@" руб."];
        }
        if ([elementName isEqualToString:@"updown_exch_buy"]) {
            self.currency.buyArrow = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].integerValue;
        }
        if ([elementName isEqualToString:@"updown_exch_sell"]) {
            self.currency.sellArrow = [self.currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].integerValue;
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
