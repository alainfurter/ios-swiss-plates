//
//  BCDShareSheet.m
//  BCDShareSheet
//
//  Created by Jake MacMullin on 18/01/12.
//  Copyright (c) 2012 Jake MacMullin.
//

typedef enum {
	BCDEmailService,
    BCDFacebookService,
    BCDTwitterService,
    BCDiTellAFriendService
} BCDService;

NSString * const kEmailServiceTitle = @"Email";
NSString * const kFacebookServiceTitle = @"Facebook";
NSString * const kTwitterServiceTitle = @"Twitter";
NSString * const kiTellAFriendServiceServiceTitle = @"Email";

NSString * const kTitleKey = @"title";
NSString * const kServiceKey = @"service";

NSString * const kFBAccessTokenKey = @"FBAccessTokenKey";
NSString * const kFBExpiryDateKey = @"FBExpirationDateKey";

//#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "BCDShareSheet.h"

#import "BlockActionSheet.h"
#import "iTellAFriend.h"

typedef void (^CompletionBlock)(BCDResult);

@interface BCDShareSheet()

@property (nonatomic, retain) BCDShareableItem *item; // the item that will be shared
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, retain) NSMutableArray *availableSharingServices; // services available for sharing
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic) BOOL waitingForFacebookAuthorisation;

- (void)determineAvailableSharingServices;

- (void)shareViaEmail;
- (void)shareViaFacebook;
- (void)shareViaTwitter;
- (void)shareViaiTellAFriend;

// Facebook integration
- (void)initialiseFacebookIfNeeded;
- (BOOL)checkIfFacebookIsAuthorised;
- (void)showFacebookShareDialog;

@end


@implementation BCDShareSheet

@synthesize rootViewController = _rootViewController;
@synthesize facebookAppID = _facebookAppID;
@synthesize appName = _appName;
@synthesize hashTag = _hashTag;
@synthesize item = _item;
@synthesize completionBlock = _completionBlock;
@synthesize availableSharingServices = _availableSharingServices;
@synthesize facebook = _facebook;
@synthesize waitingForFacebookAuthorisation = _waitingForFacebookAuthorisation;

+ (BCDShareSheet *)sharedSharer {
    static BCDShareSheet *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    [self setItem:nil];
    [self setFacebook:nil];
    [self setFacebookAppID:nil];
    [self setRootViewController:nil];
    [self setCompletionBlock:nil];
    
    [super dealloc];
}
/*
- (void) setRootViewController:(UIViewController *)rootViewController {
    
}
*/

//- (UIActionSheet *)sheetForSharing:(BCDShareableItem *)item completion:(void (^)(BCDResult))completionBlock {
- (BlockActionSheet *)sheetForSharing:(BCDShareableItem *)item  iTellAFriend:(BOOL)iTellAFriend completion:(void (^)(BCDResult))completionBlock {
    [self setItem:item];
    
    [self setCompletionBlock:completionBlock];
    
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:NSLocalizedString(@"Share via", @"Share action sheet, share via sheet title")];
    
    [self determineAvailableSharingServices];
    
    for (NSDictionary *serviceDictionary in self.availableSharingServices) {
        
        int selectedServiceCheck = [[serviceDictionary valueForKey:kServiceKey] intValue];
        if (iTellAFriend) {
            if (!(selectedServiceCheck == BCDEmailService)) {
                [sheet addButtonWithTitle:[serviceDictionary valueForKey:kTitleKey] block:^{
                    
                    #ifdef kLoggingIsOn
                        NSLog(@"Share action sheet button clicked");
                    #endif
                    
                    int selectedService = [[serviceDictionary valueForKey:kServiceKey] intValue];
                    
                    switch (selectedService) {
                        case BCDEmailService:
                            [self shareViaEmail];
                            break;
                            
                        case BCDFacebookService:
                            [self shareViaFacebook];
                            break;
                            
                        case BCDTwitterService:
                            [self shareViaTwitter];
                            break;
                            
                        case BCDiTellAFriendService:
                            [self shareViaiTellAFriend];
                            break;
                            
                        default:
                            break;
                    }
                    
                }];

            }
        } else {
            if (!(selectedServiceCheck == BCDiTellAFriendService)) {
                [sheet addButtonWithTitle:[serviceDictionary valueForKey:kTitleKey] block:^{
                    
                    #ifdef kLoggingIsOn
                        NSLog(@"Share action sheet button clicked");
                    #endif
                    
                    int selectedService = [[serviceDictionary valueForKey:kServiceKey] intValue];
                    
                    switch (selectedService) {
                        case BCDEmailService:
                            [self shareViaEmail];
                            break;
                            
                        case BCDFacebookService:
                            [self shareViaFacebook];
                            break;
                            
                        case BCDTwitterService:
                            [self shareViaTwitter];
                            break;
                            
                        case BCDiTellAFriendService:
                            [self shareViaiTellAFriend];
                            break;
                            
                        default:
                            break;
                    }
                    
                }];
                
            }

        }
    }
    
    [sheet setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Share action sheet, share via sheet cancel button") block:^{
        if (self.completionBlock!=nil) {
            self.completionBlock(BCDResultCancel);
        }
    }];

    //[sheet autorelease];
    
    //-------------- OLD
    /*    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Share via", @"Share action sheet, share via sheet title")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    //[sheet setBackgroundColor: [UIColor blackColor]];
    
    [self determineAvailableSharingServices];
    for (NSDictionary *serviceDictionary in self.availableSharingServices) {
        [sheet addButtonWithTitle:[serviceDictionary valueForKey:kTitleKey]];
    }
    
    [sheet setCancelButtonIndex:[sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Share action sheet, share via sheet cancel button")]];
    
    [sheet autorelease];
    */
     //-------------- OLD
    
    return sheet;
}

- (BOOL)openURL:(NSURL *)url {
    if ([[url absoluteString] hasPrefix:@"fb"]) {
        return [self.facebook handleOpenURL:url];
    } else {
        return NO;
    }
}

#pragma mark -
#pragma mark Action Sheet Delegate Methods
/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"Share action sheet button clicked");
    
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        if (self.completionBlock!=nil) {
            self.completionBlock(BCDResultCancel);
        }
        return;
    }
    
    int selectedService = [[[self.availableSharingServices objectAtIndex:buttonIndex] valueForKey:kServiceKey] intValue];
    
    switch (selectedService) {
        case BCDEmailService:
            [self shareViaEmail];
            break;
            
        case BCDFacebookService:
            [self shareViaFacebook];
            break;
            
        case BCDTwitterService:
            [self shareViaTwitter];
            break;
            
        default:
            break;
    }
}
*/
#pragma mark -
#pragma mark MFMailComposeViewController Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    //[self.rootViewController dismissModalViewControllerAnimated:YES];
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
                            if (error!=nil) {
                                if (self.completionBlock!=nil) {
                                    self.completionBlock(BCDResultFailure);
                                }
                            } else {
                                if (self.completionBlock!=nil) {
                                    self.completionBlock(BCDResultSuccess);
                                }
                            }
}


#pragma mark -
#pragma mark FBSessionDelegate Methods

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:kFBAccessTokenKey];
    [defaults setObject:[self.facebook expirationDate] forKey:kFBExpiryDateKey];
    [defaults synchronize];
    
    if (self.waitingForFacebookAuthorisation == YES) {
        [self setWaitingForFacebookAuthorisation:NO];
        [self showFacebookShareDialog];
    }
}
     
#pragma mark -
#pragma mark Private Methods

- (void)determineAvailableSharingServices {
    if (self.availableSharingServices==nil) {
        
        NSMutableArray *services = [NSMutableArray array];
        
        // Check to see if email if available
        if ([MFMailComposeViewController canSendMail]) {
            
            #ifdef kLoggingIsOn
                NSLog(@"BCD sharing: mail available");
            #endif
            
            NSDictionary *mailService = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:BCDEmailService], kServiceKey, 
                                         kEmailServiceTitle, kTitleKey,
                                         nil];
            [services addObject:mailService];
        }
        
        if ([[iTellAFriend sharedInstance] canTellAFriend]) {
            
            #ifdef kLoggingIsOn
                NSLog(@"BCD sharing: iTellAFriend available");
            #endif
            
            NSDictionary *iTellAFriendService = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:BCDiTellAFriendService], kServiceKey, 
                                         kiTellAFriendServiceServiceTitle, kTitleKey,
                                         nil];
            [services addObject:iTellAFriendService];
        }
        
        /*
        NSLog(@"BCD sharing: Facebook init");
        NSDictionary *facebookService = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:BCDFacebookService], kServiceKey, 
                                     kFacebookServiceTitle, kTitleKey,
                                     nil];
        [services addObject:facebookService];
         */

        // Twitter is only available on iOS5 or later
        //if([TWTweetComposeViewController class]) {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
            
            #ifdef kLoggingIsOn
                NSLog(@"BCD sharing: Twitter iOS5 available");
            #endif
            
            NSDictionary *twitterService = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInt:BCDTwitterService], kServiceKey, 
                                            kTwitterServiceTitle, kTitleKey,
                                            nil];
            [services addObject:twitterService];
        }
        
        [self setAvailableSharingServices:services];
    }
}

#pragma mark - iTellAFriend
- (void)shareViaiTellAFriend {
    #ifdef kLoggingIsOn
        NSLog(@"Share sheet: share via iTellAFriend");
    #endif
        
    [[iTellAFriend sharedInstance] setMessageTitle: self.item.title];
    [[iTellAFriend sharedInstance] setMessage: self.item.description];
    
    UINavigationController* tellAFriendController = [[iTellAFriend sharedInstance] tellAFriendController];
    //[self.rootViewController presentModalViewController:tellAFriendController animated:YES];
    [self.rootViewController presentViewController:tellAFriendController animated:YES completion:nil];
}
         
#pragma mark - Email
- (void)shareViaEmail {
    #ifdef kLoggingIsOn
        NSLog(@"Share sheet: share via email");
    #endif
    
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    [mailComposeViewController setMailComposeDelegate:self];
    [mailComposeViewController setSubject:self.item.title];
    
    NSMutableString *body = [NSMutableString string];
    
    if (self.item.description!=nil) {
        [body appendFormat:@"%@", self.item.description];
    }
    
    if (self.appName!=nil) {        
        [body appendFormat:@"\n\nSent from %@", self.appName];
    }

    if (self.item.itemURLString!=nil) {
        [body appendFormat:@"\n\nPowered by:\n%@\n", self.item.itemURLString];
    }
    
    
    [mailComposeViewController setMessageBody:body isHTML:NO];
    //[self.rootViewController presentModalViewController:mailComposeViewController animated:YES];
    [self.rootViewController presentViewController:mailComposeViewController animated:YES completion:nil];
    [mailComposeViewController release];
}

#pragma mark - Facebook
- (void)shareViaFacebook {
    
    #ifdef kLoggingIsOn
        NSLog(@"Share sheet: share via Facebook");
    #endif
    
    [self initialiseFacebookIfNeeded];
    
    BOOL isFacebookAuthorised = [self checkIfFacebookIsAuthorised];
    if (isFacebookAuthorised == YES) {
        // share
        [self showFacebookShareDialog];
    } else {
        // request authorisation
        // ask for 'offline access' so that the credentials don't
        // expire.
        NSArray *permissions = [NSArray arrayWithObjects:@"offline_access", nil];
        [self.facebook authorize:permissions];
        [self setWaitingForFacebookAuthorisation:YES];
    }
}

- (void)initialiseFacebookIfNeeded {
    if (self.facebook == nil) {
        Facebook *facebook = [[Facebook alloc] initWithAppId:self.facebookAppID andDelegate:self];
        [self setFacebook:facebook];
        [facebook release];
    }
}

- (BOOL)checkIfFacebookIsAuthorised {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defaults valueForKey:kFBAccessTokenKey];
    NSDate *expirationDate = [defaults valueForKey:kFBExpiryDateKey];
    if (accessToken!=nil && expirationDate!=nil) {
        [self.facebook setAccessToken:accessToken];
        [self.facebook setExpirationDate:expirationDate];
    }
    
    return [self.facebook isSessionValid];
}

- (void)showFacebookShareDialog {    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.item.title!=nil) {
        [params setValue:self.item.title forKey:@"name"];
        [params setValue:self.item.title forKey:@"caption"];
    }
    if (self.item.imageURLString!=nil) {
        [params setValue:self.item.imageURLString forKey:@"picture"];
    }
    if (self.item.description!=nil) {
        [params setValue:self.item.description forKey:@"description"];
    }
    if (self.item.itemURLString!=nil) {
        [params setValue:self.item.itemURLString forKey:@"link"];
    }
    [self.facebook dialog:@"feed" andParams:params andDelegate:self];
}
    

#pragma mark - FaceBook Dialog Delegate

- (void)dialog:(FBDialog *)dialog didFailWithError:(NSError *)error {
    if (self.completionBlock!=nil) {
        self.completionBlock(BCDResultFailure);
    }
}

- (void)dialogDidComplete:(FBDialog *)dialog {
    if (self.completionBlock!=nil) {
        self.completionBlock(BCDResultSuccess);
    }
}

- (void)dialogDidNotComplete:(FBDialog *)dialog {
    if (self.completionBlock!=nil) {
        self.completionBlock(BCDResultFailure);
    }
}


#pragma mark - Twitter

- (void)shareViaTwitter {
    
    #ifdef kLoggingIsOn
        NSLog(@"Share sheet: share via Twitter");
    #endif
    
    NSMutableString *tweetText = [NSMutableString string];
    
    [tweetText appendString:self.item.title];
    
    if (self.item.shortDescription!=nil) {
        [tweetText appendFormat:@" / %@", self.item.shortDescription];
    }
    
    if (self.hashTag!=nil) {
        [tweetText appendFormat:@" #%@", self.hashTag];
    }
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                if (self.completionBlock!=nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.completionBlock(BCDResultFailure);
                    });
                    
                }
            } else {
                if (self.completionBlock!=nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.completionBlock(BCDResultSuccess);
                    });
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.rootViewController dismissViewControllerAnimated:NO completion:^{
                    //[controller release];
                }];
            });
        };
        
        controller.completionHandler =myBlock;
        
        //Adding the Text to the facebook post value from iOS
        [controller setInitialText:tweetText];
        
        //Adding the URL to the facebook post value from iOS
        
        [controller addURL:[NSURL URLWithString:self.item.itemURLString]];
        
        //Adding the Image to the facebook post value from iOS
        
        UIImage *twitterImage = [UIImage imageNamed: self.item.imageNameFromBundle];        
        [controller addImage:twitterImage];
                
        [self.rootViewController presentViewController:controller animated:YES completion:nil];
    }
    else{
        NSLog(@"UnAvailable");
    }
}

@end
