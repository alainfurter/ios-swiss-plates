//
//  SupportWebViewController.h
//  Tweet Clock
//
//  Created by Alain Furter on 21.02.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
//#import "SupportViewController.h"

//@class SupportViewController;

@interface SupportWebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webView;

	//SystemSoundID waveSoundID;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UILabel *loadingLabel;
@property (retain, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)pushBackController:(id)sender;

- (void) pushback;

- (void) loadWebURL:(NSString *)urlString;

@end
