//
//  newsCell.h
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUTNews.h"

@protocol SwipeableCellDelegate <NSObject>
@optional
- (void)favoriteButtonAction:(UITableViewCell*) sender;
- (void)cellDidOpen:(UITableViewCell *) sender;
- (void)cellDidClose:(UITableViewCell *) sender;
@end

@interface NewsCell : UITableViewCell

@property (nonatomic, weak) id <SwipeableCellDelegate> delegate;

@property (nonatomic, strong) TUTNews* newsItem;
@property (nonatomic, readonly, assign) BOOL isSwipeOpen;

- (void) closeSwipe;

- (void) setButtonImage:(UIImage*) image;

- (void)setImage:(UIImage *)image;

@end


