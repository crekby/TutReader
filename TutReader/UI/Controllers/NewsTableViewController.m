//
//  NewsTableViewController.m
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "NewsTableViewController.h"
#import "webViewController.h"
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

- (NSArray*) makeFetchRequest
{
    NSLog(@"request");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"NEWS"
                                      inManagedObjectContext:managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:@"Master"];
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    else
    {
        return self.fetchedResultsController.fetchedObjects;
    }
    return nil;
}

- (void)initOnlineNewsList
{
    [self setTitle:@"Online"];
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
    [self setTitle:@"Favorites"];
    newsTableContent = [NSMutableArray new];
    
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.title isEqualToString:@"Favorites"]) {
        NSArray* requestResult = [self makeFetchRequest];
        if (requestResult) {
            newsTableContent = [NSMutableArray new];
            for (NSManagedObject* object in requestResult) {
                TUTNews* favoriteNews = [[TUTNews alloc] initWithManagedObject:object];
                [newsTableContent insertObject:favoriteNews atIndex:newsTableContent.count];
            }
            [self.newsTableView reloadData];
        }
    }
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
            [currentElementValue replaceOccurrencesOfString:@"\n\t\t" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(0,currentElementValue.length)];
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
                if (currentElementValue.length>3) {
                    [currentElementValue replaceOccurrencesOfString:@"\n\t\t" withString:[NSString new] options:NSLiteralSearch range:NSMakeRange(0,15)];
                    news.text = currentElementValue;
                }
            }
            [newsTableContent insertObject:news atIndex:newsTableContent.count];
        }
    }
    currentElementValue=nil;
    
}

-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    [self checkForFavorites];
    [self.newsTableView reloadData];
}

- (void) checkForFavorites
{
    NSArray* requestResult = [self makeFetchRequest];
    if (requestResult) {
        for (TUTNews* object in newsTableContent) {
            for (NSManagedObject* temp in requestResult) {
                if ([object.newsTitle isEqualToString:[temp valueForKey:@"title"]]) {
                    object.isFavorite = YES;
                }
            }
        }
        
    }
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
    cell.row = indexPath.row;
    if (!newsToShow.image) {
        [cell.imageView setImage:[UIImage imageNamed:@"No Image"]];
        if (newsToShow.imageURL!=nil) {
            NSURL* imgUrl = [NSURL URLWithString:newsToShow.imageURL];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage* thumb = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [cell.imageView setImage:thumb];
                    newsToShow.image=thumb;
                    [cell setNeedsLayout];
                });
            });
        }
    }
    else
    {
        cell.imageView.image = newsToShow.image;
    }
        return cell;
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    newsCell* cell = (newsCell*)sender;
    [(webViewController*)[segue destinationViewController] initWithNews:[newsTableContent objectAtIndex:cell.row]];
}

@end
