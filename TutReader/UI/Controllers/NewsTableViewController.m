//
//  NewsTableViewController.m
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "NewsTableViewController.h"
#import "TUTNews.h"
#import "newsCell.h"

@interface NewsTableViewController ()

@end

@implementation NewsTableViewController
{
    NSMutableArray* content;
    NSMutableString* currentElementValue;
    NSMutableArray* items;
    NSMutableArray* newsTableContent;
    TUTNews* news;
}

#pragma mark - Imitializers

- (void)initOnlineNewsList
{
    NSURL* url = [NSURL URLWithString:RSS_URL];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode==200 && !connectionError) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
            NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
            [parser setDelegate:self];
            newsTableContent = [NSMutableArray new];
            [parser parse];
        }
    }];
}

- (void)initFavoritesNewsList
{
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    
    if ([elementName isEqualToString:@"item"])
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
        if ([elementName isEqualToString:@"title"]) {
            [currentElementValue replaceOccurrencesOfString:@"\n\t\n\t\t" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(0,currentElementValue.length)];
            news.newsTitle = currentElementValue;
        }
        if ([elementName isEqualToString:@"link"])
        {
            news.newsURL = currentElementValue;
        }
        if ([elementName isEqualToString:@"description"]) {
            [currentElementValue replaceOccurrencesOfString:@"<br clear=\"all\" />" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(currentElementValue.length-20,20)];
            if ([currentElementValue rangeOfString:@"http"].location!=NSNotFound) {
                int startLink = [currentElementValue rangeOfString:@"http"].location;
                int lengthLink = [currentElementValue rangeOfString:@"\" width"].location-startLink;
                news.imageURL = [currentElementValue substringWithRange:NSMakeRange(startLink, lengthLink)];
            }
            if ([currentElementValue rangeOfString:@"\" />"].location!=NSNotFound) {
                int startDescr = [currentElementValue rangeOfString:@"\" />"].location+4;
                int lengthDescr = currentElementValue.length - startDescr;
                news.text = [currentElementValue substringWithRange:NSMakeRange(startDescr, lengthDescr)];
            }
            else
            {
                [currentElementValue replaceOccurrencesOfString:@"\n\t\t" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(0,15)];
                news.text = currentElementValue;
            }
            [newsTableContent insertObject:news atIndex:newsTableContent.count];
        }
    }
    currentElementValue=nil;
    
}

-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    [self.newsTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return newsTableContent.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    newsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell" forIndexPath:indexPath];
    
    TUTNews* newsToShow = [newsTableContent objectAtIndex:indexPath.row];
    
    cell.newsTitle.text = newsToShow.newsTitle;
    cell.newsDescription.text = newsToShow.text;
    [cell.imageView setImage:[UIImage imageNamed:@"No Image"]];
    if (newsToShow.imageURL!=nil) {
        NSURL* imgUrl = [NSURL URLWithString:newsToShow.imageURL];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage* thumb = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [cell.imageView setImage:thumb];
                [cell setNeedsLayout];
            });
        });
    }
    return cell;
}

@end
