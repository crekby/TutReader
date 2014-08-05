//
//  ShareViewController.h
//  TutReader
//
//  Created by crekby on 7/23/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareViewControllerDelegate <NSObject>

@required
//-(void)shareViewController:(UIViewController*)vc didTapOnCancelButton:(id)sender;
@optional
-(void)shareViewController:(UIViewController*)vc mailShareButtonTapped:(id)sender;
-(void)shareViewController:(UIViewController*)vc twitterShareButtonTapped:(id)sender;
-(void)shareViewController:(UIViewController*)vc facebookShareButtonTapped:(id)sender;
-(void)shareViewController:(UIViewController*)vc googlePlusShareButtonTapped:(id)sender;
-(void)shareViewController:(UIViewController*)vc whatsAppShareButtonTapped:(id)sender;
@end


@interface ShareViewController : UIViewController

@property (weak, nonatomic)id <ShareViewControllerDelegate> delegate;

@end
