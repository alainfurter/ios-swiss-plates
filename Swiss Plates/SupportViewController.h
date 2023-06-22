//
//  SupportViewController.h
//  Swiss Plates
//
//  Created by Alain Furter on 04.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "UIDevice-Reachability.h"
#import "SupportWebViewController.h"
#import "UIDevice+IdentifierAddition.h"

#import "Swiss_PlatesAppDelegate.h"

#import "IntroViewController.h"

#import "WBErrorNoticeView.h"

#import "ConfigFile.h"

#import <sys/utsname.h>

@class SupportWebViewController;

@interface SupportViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    
}

@property (retain, nonatomic) IBOutlet UILabel *contactTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *recommendAppTitleLabel;
@property (retain, nonatomic) IBOutlet UIButton *recommendButton;
@property (retain, nonatomic) IBOutlet UIButton *makeReviewButton;
@property (retain, nonatomic) IBOutlet UIButton *giftAppButton;
@property (retain, nonatomic) IBOutlet UIButton *followTwitterButton;
@property (retain, nonatomic) IBOutlet UIButton *openIntroButton;
@property (retain, nonatomic) IBOutlet UILabel *showIntroLabel;

- (IBAction) showSupportWebpage: (id) sender;
- (IBAction) sendSupportEmail: (id) sender;
- (IBAction) pushBackController:(id)sender;
- (IBAction)recommendToFriends:(id)sender;
- (IBAction)makeAReview:(id)sender;
- (IBAction)giftThisApp:(id)sender;
- (IBAction)followUsOnTwitter:(id)sender;
- (IBAction)showIntro:(id)sender;

@end
