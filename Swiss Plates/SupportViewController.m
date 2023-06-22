//
//  SupportViewController.m
//  Swiss Plates
//
//  Created by Alain Furter on 04.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import "SupportViewController.h"
#import "iTellAFriend.h"
#import "BCDShareSheet.h"
#import "BCDShareableItem.h"

@implementation SupportViewController
@synthesize contactTitleLabel;
@synthesize recommendAppTitleLabel;
@synthesize recommendButton;
@synthesize makeReviewButton;
@synthesize giftAppButton;
@synthesize followTwitterButton;
@synthesize openIntroButton;
@synthesize showIntroLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    if ((self = [super initWithNibName: (([UIDevice currentResolution] == UIDevice_iPhoneTallerHiRes)?@"SupportViewController-568h":@"SupportViewController") bundle:nil]))
	{
		
	}
	return self;
}

- (NSString *) machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
	
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (NSString *) iPhoneDevice
{
	NSString *deviceType = [NSString stringWithString: [self machineName]];
	
	//NSLog(@"Device: %@", deviceType);
    
    if ([deviceType isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([deviceType isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([deviceType isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([deviceType isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([deviceType isEqualToString:@"iPhone3,3"]) return @"Verizon iPhone 4";
    if ([deviceType isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([deviceType isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (GSM/LTE US&CA)";
    if ([deviceType isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (CDMA/LTE or GSM/LTE Int)";
    if ([deviceType isEqualToString:@"iPhone5,3"]) return @"iPhone 5 (CDMA/LTE or GSM/LTE Int)";
    if ([deviceType isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceType isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceType isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceType isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceType isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([deviceType isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceType isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceType isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceType isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMAV)";
    if ([deviceType isEqualToString:@"iPad2,4"])      return @"iPad 2 (CDMAS)";
    if ([deviceType isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceType isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceType isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceType isEqualToString:@"iPad3,1"])      return @"iPad-3G (WiFi)";
    if ([deviceType isEqualToString:@"iPad3,2"])      return @"iPad-3G (4G GSM)";
    if ([deviceType isEqualToString:@"iPad3,3"])      return @"iPad-3G (4G CDMA)";
    if ([deviceType isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceType isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceType isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceType isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceType isEqualToString:@"x86_64"])       return @"Simulator";
    
    return (@"Unknown device");
}

- (NSString *) systemVersion
{
    return ([[UIDevice currentDevice] systemVersion]);
}

- (IBAction) sendSupportEmail: (id) sender
{
	//AudioServicesPlaySystemSound (clickSoundID);
    
    if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailController=  [[[MFMailComposeViewController alloc] init] autorelease];
		mailController.mailComposeDelegate = self;
		[mailController setSubject: NSLocalizedString(@"Swiss Plates support", @"Swiss Plates settings support email subject")];
        
        NSString *messageId;
        messageId = [[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
		[mailController setMessageBody: [NSString stringWithFormat: @"%@\n\n\n\n\n\n\n\n\n\n\nMessage id: %@\niPhone: %@\niOS Version: %@\nApp version: %@\nLanguage: %@",NSLocalizedString(@"Dear Support, ", @"Swiss Plates settings support email draft text"), messageId, [self iPhoneDevice], [self systemVersion], kUTControllerAppName, [[NSLocale currentLocale] localeIdentifier]] isHTML:NO];
		[mailController setToRecipients:  [NSArray arrayWithObject: kSupportEmail]];
		//[self presentModalViewController:mailController animated:YES];
        [self presentViewController:mailController animated:YES completion:nil];
	} else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"No direct email", @"No direct email alert view title")
                                                        message: NSLocalizedString(@"The direct emailing function is not available on this iPhone/iOS version. Please send us manually an email to: support@zerooneapps.com", @"No direct email alert view message")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Ok", @"No direct email alert view cancel button")
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
}

- (IBAction)pushBackController:(id)sender {
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController*) mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	//AudioServicesPlaySystemSound (clickSoundID);
	
	[self becomeFirstResponder];
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) showSupportWebpage: (id) sender
{
	//AudioServicesPlaySystemSound (clickSoundID);
    
    if (!([UIDevice networkAvailable])) 
    {
        #ifdef  kLoggingIsOn
            NSLog(@"No network available");
        #endif
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No network", @"No network available alert view title") message:NSLocalizedString(@"There is no WiFi or cellular network available. Please check or try again later.", @"No network available alert view message")];
        [notice show];
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        return;
    }
	
	SupportWebViewController *supportView = [[[SupportWebViewController alloc] init] autorelease];
    
    //[self presentModalViewController:supportView animated:YES];
    [self presentViewController:supportView animated:YES completion:nil];
	
	//[self.navigationController pushViewController: supportView animated:YES];	
    
    NSString *languageCode = [NSString stringWithString: [[NSLocale preferredLanguages] objectAtIndex:0]];
    
    if ((![languageCode isEqualToString:@"en"]) && (![languageCode isEqualToString:@"de"]) && !([languageCode isEqualToString:@"fr"]) && (![languageCode isEqualToString:@"it"])) {
        languageCode = @"en";
    }
    
    NSString *webURL = [NSString stringWithFormat: @"http://www.zonezeroapps.com/swissplates/support/%@/index.html", languageCode];
	
	[supportView loadWebURL: webURL];
}

- (void)dealloc
{
    [contactTitleLabel release];
    [recommendAppTitleLabel release];
    [recommendButton release];
    [makeReviewButton release];
    [giftAppButton release];
    [followTwitterButton release];
    [openIntroButton release];
    [showIntroLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [recommendAppTitleLabel setText: NSLocalizedString(@"Recommend this app", @"Recommend this app support title")];
    [contactTitleLabel setText: NSLocalizedString(@"Contact", @"Contact support title")];
    [recommendButton setTitle: NSLocalizedString(@"Recommend to friends", @"Recommend support button") forState: UIControlStateNormal];
    [makeReviewButton setTitle: NSLocalizedString(@"Make a review", @"Review support button") forState: UIControlStateNormal];
    [giftAppButton setTitle: NSLocalizedString(@"Gift this app", @"Gift support button") forState: UIControlStateNormal];
    [followTwitterButton setTitle: NSLocalizedString(@"Follow us on Twitter", @"Follow support button") forState: UIControlStateNormal];
    [openIntroButton setTitle: NSLocalizedString(@"Show intro again", @"Intro support button") forState: UIControlStateNormal];
    [showIntroLabel setText: NSLocalizedString(@"Help / intro", @"Intro support title")];
}

- (void)viewDidUnload
{
    [self setContactTitleLabel:nil];
    [self setRecommendAppTitleLabel:nil];
    [self setRecommendButton:nil];
    [self setMakeReviewButton:nil];
    [self setGiftAppButton:nil];
    [self setFollowTwitterButton:nil];
    [self setOpenIntroButton:nil];
    [self setShowIntroLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)recommendToFriends:(id)sender {

    BCDShareableItem *item = [[BCDShareableItem alloc] initWithTitle:NSLocalizedString(@"Swiss Plates", @"Recommend Swiss Plates Share Item Title")];
    [item setDescription:NSLocalizedString(@"Check out this app!", @"Recommend Swiss Plates Share Item Description")];
    [item setShortDescription:NSLocalizedString(@"Check out this app!", @"Recommend Swiss Plates Share Item Description")];
    
    [item setItemURLString: AppStoreURLShort];
    
    [item setImageURLString:kITellAFriendImageURLSmall];
    [item setImageNameFromBundle: kBundleIconImage];
    
    UIActionSheet *sheet = [[BCDShareSheet sharedSharer] sheetForSharing:item iTellAFriend:YES completion:^(BCDResult result) {
        if (result==BCDResultSuccess) { 
            
            #ifdef kLoggingIsOn
                NSLog(@"Yay!");
            #endif
        }
    }];
    [[BCDShareSheet sharedSharer] setRootViewController: self];
    [sheet showInView: self.view];
    [item release];
}

- (BOOL)openTwitterClientForUserName:(NSString*)userName {
    NSArray *urls = [NSArray arrayWithObjects:
                     @"twitter:@{username}", // Twitter
                     @"tweetbot:///user_profile/{username}", // TweetBot
                     @"tweetie://user?screen_name={username}", //Tweetie
                     @"echofon:///user_timeline?{username}", // Echofon              
                     @"twit:///user?screen_name={username}", // Twittelator Pro
                     @"x-seesmic://twitter_profile?twitter_screen_name={username}", // Seesmic
                     @"x-birdfeed://user?screen_name={username}", // Birdfeed
                     @"tweetings:///user?screen_name={username}", // Tweetings
                     @"simplytweet:?link=http://twitter.com/{username}", // SimplyTweet
                     @"icebird://user?screen_name={username}", // IceBird
                     @"fluttr://user/{username}", // Fluttr
                     /** uncomment if you don't have a special handling for no registered twitter clients */
                     //@"http://twitter.com/{username}", // Web fallback, 
                     nil];
    
    UIApplication *application = [UIApplication sharedApplication];
    for (NSString *candidate in urls) {
        candidate = [candidate stringByReplacingOccurrencesOfString:@"{username}" withString:userName];
        NSURL *url = [NSURL URLWithString:candidate];
        if ([application canOpenURL:url]) {
            [application openURL:url];
            return YES;
        }
    }
    return NO;
}


- (IBAction)makeAReview:(id)sender {
    
    if (!([UIDevice networkAvailable])) 
    {
        #ifdef  kLoggingIsOn
            NSLog(@"No network available");
        #endif
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No network", @"No network available alert view title") message:NSLocalizedString(@"There is no WiFi or cellular network available. Please check or try again later.", @"No network available alert view message")];
        [notice show];
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        return;
    }
    
    [[iTellAFriend sharedInstance] rateThisApp];
}

- (IBAction)giftThisApp:(id)sender {
    
    if (!([UIDevice networkAvailable])) 
    {
        #ifdef  kLoggingIsOn
            NSLog(@"No network available");
        #endif
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No network", @"No network available alert view title") message:NSLocalizedString(@"There is no WiFi or cellular network available. Please check or try again later.", @"No network available alert view message")];
        [notice show];
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        return;
    }
    
    [[iTellAFriend sharedInstance] giftThisApp];
}

- (IBAction)followUsOnTwitter:(id)sender {
    if (!([UIDevice networkAvailable])) 
    {
        #ifdef  kLoggingIsOn
            NSLog(@"No network available");
        #endif
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No network", @"No network available alert view title") message:NSLocalizedString(@"There is no WiFi or cellular network available. Please check or try again later.", @"No network available alert view message")];
        [notice show];
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        return;
    }
    
    [self openTwitterClientForUserName: kTwitterUsername];
}

- (IBAction)showIntro:(id)sender {
    
    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    IntroViewController *introViewController = [[[IntroViewController alloc] init] autorelease];
    
    //[self presentModalViewController:introViewController animated:YES];
    [appDelegate.customTabBarViewController pushDownViewController: nil];
    //[appDelegate.customTabBarViewController presentModalViewController:introViewController animated:YES];
    [appDelegate.customTabBarViewController presentViewController:introViewController animated:YES completion:nil];
}
@end
