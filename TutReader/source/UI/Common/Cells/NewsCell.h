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
- (void)buttonAction:(UITableViewCell*) sender;
- (void)cellDidOpen:(UITableViewCell *) sender;
- (void)cellDidClose:(UITableViewCell *) sender;
@end

@interface NewsCell : UITableViewCell

@property (nonatomic, weak) id <SwipeableCellDelegate> delegate;

@property (nonatomic, strong) TUTNews* newsItem;
#warning ячейки переиспользуются, хранить индекс строки чревато багами
@property (nonatomic) int row;
#warning почему кнопка паблик?
@property (nonatomic, weak) IBOutlet UIButton* shareButton;
#warning почему она паблик?
@property (nonatomic) BOOL isSwipeOpen;

- (void) closeSwipe;

@end


