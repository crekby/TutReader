//
//  WeatherCell.h
//  TutReader
//
//  Created by crekby on 8/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel* dateLabel;
@property (nonatomic, weak) IBOutlet UILabel* TempLabel;
@property (nonatomic, strong) IBOutlet UIImageView* weatherIcon;
@property (nonatomic, weak) IBOutlet UILabel* descriptionLabel;

@end
