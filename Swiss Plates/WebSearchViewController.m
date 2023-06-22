//
//  WebSearchViewController.m
//  Swiss Plates
//
//  Created by Alain Furter on 05.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import "WebSearchViewController.h"

#define CreateRegex(regexString)  [NSRegularExpression regularExpressionWithPattern: regexString options:NSRegularExpressionCaseInsensitive error:NULL]
#define RegexMatch(regexExpression, stringToSearch) [regexExpression firstMatchInString: stringToSearch options:0 range:NSMakeRange(0, [stringToSearch length])]
#define GetMatchString(regexMatch, stringToSearch) [stringToSearch substringWithRange: [regexMatch rangeAtIndex:1]]
#define CheckRegexMatch(regexExpression, stringToSearch) ![regexExpression numberOfMatchesInString:stringToSearch options:0 range:NSMakeRange(0, [stringToSearch length])]


@implementation WebSearchViewController

@synthesize numberLabel;
@synthesize searchView;
@synthesize waitWithAddinsView;
@synthesize waitWithAddinsLabel;
@synthesize enterCaptchaCodeLabel;
@synthesize vehicleSelectionScrollView;
@synthesize vehicleSelectionImagesView;
@synthesize bigSearchButton;
@synthesize normalBackgroundView;
@synthesize maskBackgroundView;
@synthesize numberTextField;
@synthesize explanationView, explanationLabel, explanationButton, explanationViewOnScreen;
@synthesize searchViewOnScreen, waitWithAddinsViewOnScreen, captchaViewOnScreen;
@synthesize  searchViewWasOnScreen, captchaViewWasOnScreen;

@synthesize cantonLabel, cantonImage, captchaView, captchaImage, captchaTextField;
@synthesize cantonCode, flagName;
@synthesize viacarCanton, viacarSessionID, viacarAuthID, viacarViewState, viacarEventValidation, viacarCarNumber, viacarJpegID, viacarInputFieldName, viacarIndID;
@synthesize carOwners;

@synthesize getCookieWaitingAlertView, getCookieWaitingAlertViewOnScreen;
@synthesize cariCanton,cariCarNumber, cariCarType;

@synthesize currentGetRequest, currentPostRequest;

@synthesize resultTableView, ownersList, tableCell, controlCell;
@synthesize phoneNumberCache;
@synthesize viewAppearsFromCustomTabbarPush;

@synthesize controlRowIndexPath, tappedIndexPath;

NSIndexPath *selectedCellIndexPath;  
NSIndexPath *previousSelectedCellIndexPath;

NSInteger selectedCellRow;
NSInteger previousCellRow;


- (void) testCodeGetCookieResultSuccess {

#ifdef  kLoggingIsOn
    NSLog(@"Disable searchViewWasOnScreen");
#endif
    
    self.searchViewWasOnScreen = NO; 
    
    [self removeBaseAlertView];
    self.currentGetRequest = nil;
    
    [self moveCaptchaViewOnScreen];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}

- (void) testCodeExecuteGetCookieResultSuccess {
    [self performSelector:@selector(testCodeGetCookieResultSuccess) withObject:nil afterDelay: 2.0];
}

-(CAAnimationGroup*)animationGroupForward:(BOOL)_forward {
    // Create animation keys, forwards and backwards
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, 15.0f*M_PI/180.0f, 1, 0, 0);
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = t1.m34;
    t2 = CATransform3DTranslate(t2, 0, [self parentTarget].frame.size.height*-0.08, 0);
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:t1];
    animation.duration = kSemiModalAnimationDuration/2;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.toValue = [NSValue valueWithCATransform3D:(_forward?t2:CATransform3DIdentity)];
    animation2.beginTime = animation.duration;
    animation2.duration = animation.duration;
    animation2.fillMode = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:animation.duration*2];
    [group setAnimations:[NSArray arrayWithObjects:animation,animation2, nil]];
    return group;
}

-(UIView*)parentTarget {
    // To make it work with UINav & UITabbar as well
    UIViewController * target = self;
    while (target.parentViewController != nil) {
        target = target.parentViewController;
    }
    return target.view;
}

-(void)presentSemiViewController:(UIViewController*)vc {
    [self presentSemiView:vc.view];
}

-(void)presentSemiView:(UIView*)vc {
    // Determine target
    UIView * target = [self parentTarget];
    
    if (![target.subviews containsObject:vc]) {
        // Calulate all frames
        CGRect sf = vc.frame;
        CGRect vf = target.frame;
        CGRect f  = CGRectMake(0, vf.size.height-sf.size.height, vf.size.width, sf.size.height);
        CGRect of = CGRectMake(0, 0, vf.size.width, vf.size.height-sf.size.height);
        
        // Add semi overlay
        UIView * overlay = [[UIView alloc] initWithFrame:target.bounds];
        overlay.backgroundColor = [UIColor blackColor];
        
        // Take screenshot and scale
        UIGraphicsBeginImageContext(target.bounds.size);
        [target.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIImageView * ss = [[UIImageView alloc] initWithImage:image];
        [overlay addSubview:ss];
        [target addSubview:overlay];
        
        // Dismiss button
        // Don't use UITapGestureRecognizer to avoid complex handling
        UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissButton addTarget:self action:@selector(dismissSemiModalView) forControlEvents:UIControlEventTouchUpInside];
        dismissButton.backgroundColor = [UIColor clearColor];
        dismissButton.frame = of;
        [overlay addSubview:dismissButton];
        
        // Begin overlay animation
        [ss.layer addAnimation:[self animationGroupForward:YES] forKey:@"pushedBackAnimation"];
        [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
            ss.alpha = 0.5;
        }];
        
        // Present view animated
        vc.frame = CGRectMake(0, vf.size.height, vf.size.width, sf.size.height);
        [target addSubview:vc];
        vc.layer.shadowColor = [[UIColor blackColor] CGColor];
        vc.layer.shadowOffset = CGSizeMake(0, -2);
        vc.layer.shadowRadius = 5.0;
        vc.layer.shadowOpacity = 0.8;
        [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
            vc.frame = f;
        }];
    }
}

-(void)dismissSemiModalView {
    UIView * target = [self parentTarget];
    UIView * modal = [target.subviews objectAtIndex:target.subviews.count-1];
    UIView * overlay = [target.subviews objectAtIndex:target.subviews.count-2];
    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
        modal.frame = CGRectMake(0, target.frame.size.height, modal.frame.size.width, modal.frame.size.height);
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        [modal removeFromSuperview];
    }];
    
    // Begin overlay animation
    UIImageView * ss = (UIImageView*)[overlay.subviews objectAtIndex:0];
    [ss.layer addAnimation:[self animationGroupForward:NO] forKey:@"bringForwardAnimation"];
    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
        ss.alpha = 1;
    }];
}

- (void)phoneNumberWasResolved:(NSString *) phoneNumber rowEntry:(int)rowEntry {
    
    #ifdef  kLoggingIsOn
        NSLog(@"Phone number was resolved delegate called");
    #endif
    
    if (!self.phoneNumberCache) {
        #ifdef  kLoggingIsOn
            NSLog(@"Allocate dict cache");
        #endif
        self.phoneNumberCache = [[NSMutableDictionary alloc] init];
    }
    
    if ([self.phoneNumberCache objectForKey: [NSNumber numberWithInt: rowEntry]]) {
        #ifdef  kLoggingIsOn
            NSLog(@"Set phonenumber %@, for row: %d", phoneNumber, rowEntry);
        #endif
        [self.phoneNumberCache setObject: phoneNumber forKey: [NSNumber numberWithInt: rowEntry]];
    } else {
        #ifdef  kLoggingIsOn
            NSLog(@"Set phonenumber %@, for row: %d", phoneNumber, rowEntry);
        #endif
        [self.phoneNumberCache setObject: phoneNumber forKey: [NSNumber numberWithInt: rowEntry]];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    #ifdef  kLoggingIsOn
        NSLog(@"Keyboard will show");
    #endif
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    #ifdef  kLoggingIsOn
        NSLog(@"Keyboard will hide");
    #endif
    
    //[self.captchaTextField becomeFirstResponder];
}

- (IBAction)keyPadKeyPressed:(id)sender {
    if ([sender tag] <= 9) {
        
        if ([self.numberLabel.text length] <= 6) {
            self.numberLabel.text = [NSString stringWithFormat: @"%@%d", self.numberLabel.text, [sender tag]];
        }
        
    } else if ([sender tag] == 11) {
        self.numberLabel.text = @"";
    } else {
        if ([self.numberLabel.text length] > 0)
            self.numberLabel.text = [self.numberLabel.text substringToIndex:[self.numberLabel.text length] - 1];
    }
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    if (self.explanationViewOnScreen) {
        [self moveExplanationViewOffScreen];
    }
    
    [self.navigationController popViewControllerAfterAnimationAnimated: self 
                                                              animated: YES 
                                                        animationBlock:^{
                                                            self.searchView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
                                                        }];
}

- (IBAction)waitWithAddinsCancelButtonPressed:(id)sender {
    
    #ifdef  kLoggingIsOn
        NSLog(@"Wait with addins view cancel button pressed");
    #endif
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (currentGetRequest) [currentGetRequest clearDelegatesAndCancel];
    if (currentPostRequest) [currentPostRequest clearDelegatesAndCancel];
    
    currentGetRequest = nil;
    currentPostRequest = nil;
    
    self.waitWithAddinsViewOnScreen = NO;
        
    [self moveWaitWithAddinsViewOffScreen];
    
    
    if (self.searchViewWasOnScreen) {
        #ifdef  kLoggingIsOn
            NSLog(@"Search view was on screen");
        #endif
        
        [self performSelector:@selector(moveSearchViewOnScreen) withObject:nil afterDelay:0.3];
        //[self moveSearchViewOnScreen];
    }
    if (self.captchaViewWasOnScreen) {
        #ifdef  kLoggingIsOn
            NSLog(@"Captcha view was on screen");
        #endif
        
        [self performSelector:@selector(moveCaptchaViewOnScreen) withObject:nil afterDelay:0.3];
        //[self moveCaptchaViewOnScreen];
    }
    
    self.searchViewWasOnScreen = NO;
    self.captchaViewWasOnScreen = NO;
}

- (IBAction)explanationViewCancelButtonPressed:(id)sender {
    [self moveExplanationViewOffScreen];
}

- (id)initWithOptions:(int)webServiceCodeOption cantonCode:(NSString *)cantonCodeString flagName:(NSString *)flagNameString cantonRowOption:(int)cantonRowOption
{
    if ((self = [super initWithNibName: (([UIDevice currentResolution] == UIDevice_iPhoneTallerHiRes)?@"WebSearchViewController-568h":@"WebSearchViewController") bundle:nil]))
	{
		webServiceCode = webServiceCodeOption;
        cantonRow = cantonRowOption;
        self.cantonCode = cantonCodeString;
        self.flagName = flagNameString;
	}
	self.hidesBottomBarWhenPushed = YES;
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) pushNonWebServiceController {
    [self moveExplanationViewOnScreen];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (captchaViewOnScreen) {
        return YES;
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (explanationViewOnScreen) {
        [self moveExplanationViewOffScreen];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(captchaViewOnScreen) {
        [self captchaViewLoginAndSearch: nil];
        return  NO;
    }
    return YES; 
}

- (void) pushBack
{    
    if (self.explanationViewOnScreen) {
        [self moveExplanationViewOffScreen];
    }
    
    [self.navigationController popViewControllerAfterAnimationAnimated: self 
                                                              animated: YES 
                                                        animationBlock:^{
                                                           self.searchView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
                                                        }];
     
}

- (void)dealloc
{
    [controlCell release];
    [tableCell release];
    [controlRowIndexPath release];
    [tappedIndexPath release];
    [phoneNumberCache release];
    [ownersList release];
    [resultTableView release];
    [viacarCanton release];
    [viacarSessionID release];
    [viacarAuthID release];
    [viacarIndID release];
    [viacarViewState release];
    [viacarEventValidation release];
    [viacarCarNumber release];
    [viacarJpegID release];
    [viacarInputFieldName release];
    [cariCanton release];
    [cariCarNumber release];
    [cariCarType release];
    [carOwners release];
    [cantonCode release];
    [flagName release];
    [cantonLabel release];
    [cantonImage release];
    [captchaView release];
    [captchaImage release];
    [captchaTextField release];
    [explanationView release];
    [explanationLabel release];
    [explanationButton release];
    [vehicleSelectionScrollView release];
    [vehicleSelectionImagesView release];
    [bigSearchButton release];
    [normalBackgroundView release];
    [numberLabel release];
    [searchView release];
    [waitWithAddinsView release];
    [waitWithAddinsLabel release];
    [maskBackgroundView release];
    [enterCaptchaCodeLabel release];
    [numberTextField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) moveResultsViewOnScreen {
    
    #ifdef  kLoggingIsOn
        NSLog(@"Move reslts view on screen");
    #endif
    
    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.customTabBarViewController unblockTabBarUI];
    
    whichScrollViewIsActiveFlag = 2;
    
    //[self.vehicleSelectionScrollView setDelegate: nil];
    [self.resultTableView setDelegate: self];
    [self.resultTableView setDataSource: self];
    
    [resultTableView reloadData];
    
    CGFloat resultsviewHeight = self.waitWithAddinsView.frame.size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         self.waitWithAddinsView.transform = CGAffineTransformMakeTranslation(0, (resultsviewHeight + TOOLBARHEIGHT));
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [UIView commitAnimations];
    self.waitWithAddinsViewOnScreen = YES;
}

- (void) moveResultsViewOffScreen {
    
    #ifdef  kLoggingIsOn
        NSLog(@"Move results view off screen");
    #endif
    
    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.customTabBarViewController unblockTabBarUI];
    
    [self.resultTableView setDelegate: nil];
    [self.resultTableView setDataSource: nil];
    
    whichScrollViewIsActiveFlag = 1;
    //[self.vehicleSelectionScrollView setDelegate: self];
    
    CGFloat resultsviewHeight = self.waitWithAddinsView.frame.size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         self.waitWithAddinsView.transform = CGAffineTransformMakeTranslation(0, -(resultsviewHeight + TOOLBARHEIGHT));
                     }
                     completion:^(BOOL finished){
                         [self moveSearchViewOnScreen];
                         
                     }];
    [UIView commitAnimations];
    self.waitWithAddinsViewOnScreen = NO;
    
    //Clear phone number cache
    if (phoneNumberCache) {
        [self setPhoneNumberCache:nil];
        [phoneNumberCache release];
    }
}

- (void) moveWaitWithAddinsViewOnScreen {
    
    #ifdef  kLoggingIsOn
        NSLog(@"Move wait with addins view on screen");
    #endif
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         self.waitWithAddinsView.transform = CGAffineTransformMakeTranslation(0, (WAITVIEWHEIGHT + TOOLBARHEIGHT));
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [UIView commitAnimations];
    self.waitWithAddinsViewOnScreen = YES;
    
    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.customTabBarViewController blockTabBarUI];
}

- (void) moveWaitWithAddinsViewOffScreen {
   
    #ifdef  kLoggingIsOn
        NSLog(@"Move wait with addins view off screen");
    #endif
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         self.waitWithAddinsView.transform = CGAffineTransformMakeTranslation(0, -(WAITVIEWHEIGHT + TOOLBARHEIGHT)*2);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [UIView commitAnimations];
    self.waitWithAddinsViewOnScreen = NO;
    
    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.customTabBarViewController unblockTabBarUI];
}


- (void) moveSearchViewOnScreen {
    
    #ifdef  kLoggingIsOn
        NSLog(@"Move search view on screen");
    #endif
    
    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.customTabBarViewController unblockTabBarUI];
    
    //NSLog(@"Move search view on screen");
    
    whichScrollViewIsActiveFlag = 1;
    //[self.vehicleSelectionScrollView setDelegate: self];
    
    self.searchViewWasOnScreen = YES;
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         self.searchView.transform = CGAffineTransformMakeTranslation(0, -(self.view.frame.size.height - TOOLBARHEIGHT));
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [UIView commitAnimations];
    self.searchViewOnScreen = YES;
    
    [self.numberTextField becomeFirstResponder];
}

- (void) moveSearchViewOffScreen {
    
    #ifdef  kLoggingIsOn
        NSLog(@"Move search view off screen");
    #endif
    
    [self.numberTextField resignFirstResponder];
    
    //[self.vehicleSelectionScrollView setDelegate: nil];
    vehicleSelectionScrollView = 0;
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         self.searchView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [UIView commitAnimations];
    self.searchViewOnScreen = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{    
    //NSLog(@"Scroll view will enter: %d", whichScrollViewIsActiveFlag);
    
    if (whichScrollViewIsActiveFlag != 1) return;
    
    int newOffset = 0;
    if (scrollView.contentOffset.x <= 25) { newOffset = 0; self.cariCarType = @"L";} 
    else if (scrollView.contentOffset.x > 25 && scrollView.contentOffset.x <= 75) { newOffset = 50; self.cariCarType = @"K";} 
    else if (scrollView.contentOffset.x > 75 && scrollView.contentOffset.x <= 125) { newOffset = 100; self.cariCarType = @"M";} 
    else if (scrollView.contentOffset.x > 125 && scrollView.contentOffset.x <= 175) { newOffset = 150; self.cariCarType = @"LV";}
    else if (scrollView.contentOffset.x > 175) { newOffset = 200; self.cariCarType = @"Schiff";}

    [scrollView scrollRectToVisible:CGRectMake(newOffset,0,scrollView.frame.size.width,scrollView.frame.size.height) animated:YES];
}
        
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{    
    //NSLog(@"Scroll view did enter: %d", whichScrollViewIsActiveFlag);
    
    if (whichScrollViewIsActiveFlag != 1) return;
    
    int newOffset = 0;
    if (scrollView.contentOffset.x <= 25) { newOffset = 0; self.cariCarType = @"L";} 
    else if (scrollView.contentOffset.x > 25 && scrollView.contentOffset.x <= 75) { newOffset = 50; self.cariCarType = @"K";} 
    else if (scrollView.contentOffset.x > 75 && scrollView.contentOffset.x <= 125) { newOffset = 100; self.cariCarType = @"M";} 
    else if (scrollView.contentOffset.x > 125 && scrollView.contentOffset.x <= 175) { newOffset = 150; self.cariCarType = @"LV";}
    else if (scrollView.contentOffset.x > 175) { newOffset = 200; self.cariCarType = @"Schiff";}
    
    [scrollView scrollRectToVisible:CGRectMake(newOffset,0,scrollView.frame.size.width,scrollView.frame.size.height) animated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.vehicleSelectionScrollView.contentSize = CGSizeMake(350, 46); 
    [self.vehicleSelectionScrollView setDelegate: self];
        
    self.searchViewOnScreen = NO;
    self.waitWithAddinsViewOnScreen = NO;
    self.captchaViewOnScreen = NO;
    self.searchViewWasOnScreen = NO;
    self.captchaViewWasOnScreen = NO;
        
    //[self.cantonLabel setFont:[UIFont fontWithName:@"Numberplate-Switzerland" size:35]];
    //[self.numberLabel setFont:[UIFont fontWithName:@"Numberplate-Switzerland" size:32]];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self moveSearchViewOnScreen];
}

- (void)viewWillAppear:(BOOL)animated 
{		
    #ifdef kLoggingIsOn
        NSLog(@"Web search view controller: View will appear");
        NSLog(@"Current viewcontroller: %@", self.nibName);
    #endif
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    CGFloat frameHeight = self.view.frame.size.height;
    

    if (self.resultTableView.frame.size.height != (frameHeight - TOOLBARHEIGHT)) {
        CGRect tableFrame = self.resultTableView.frame;
        tableFrame.size.height = (frameHeight - TOOLBARHEIGHT);
        self.resultTableView.frame = tableFrame;
    }

	[self.navigationController setNavigationBarHidden: YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    
    [cantonLabel setText: self.cantonCode];
    [cantonImage setImage: [UIImage imageNamed: self.flagName]];
    
    [captchaTextField setAutocapitalizationType: UITextAutocapitalizationTypeNone];
    
    if (webServiceCode == 2 || webServiceCode == 4 || webServiceCode == 5 || webServiceCode == 8) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CantonConfig" ofType:@"plist"];      
        NSArray *cantonsList = [[NSDictionary dictionaryWithContentsOfFile: filePath] objectForKey: @"Cantons"];
        
        NSString *preflanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSString *languageIdentifier;
        
        if ([preflanguage isEqualToString:@"en"] || [preflanguage isEqualToString:@"de"] || [preflanguage isEqualToString:@"fr"] || [preflanguage isEqualToString:@"it"]) {
            languageIdentifier = [preflanguage uppercaseString];
        } else languageIdentifier = @"EN";
            
        NSString *viewTextString = nil;
        
        switch (webServiceCode) {
            case 2: 
                
                viewTextString= [NSString stringWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat:@"Text%@", languageIdentifier]]];
                
                [explanationLabel setText: [viewTextString stringByReplacingOccurrencesOfString: @"COST_KEY" withString:  [[cantonsList objectAtIndex: cantonRow] objectForKey: @"Cost"]]];
                [explanationButton setBackgroundImage: [UIImage imageNamed: @"SMSActionButton.png"] forState: UIControlStateNormal];
                [explanationButton setTitle: NSLocalizedString(@"Send SMS", @"SMS send button title") forState: UIControlStateNormal];
                break;
            case 4: 
                [explanationLabel setText: [[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat:@"Text%@", languageIdentifier]]];
                [explanationButton setBackgroundImage: [UIImage imageNamed: @"MailActionButton.png"] forState: UIControlStateNormal];
                [explanationButton setTitle: NSLocalizedString(@"Send Email", @"Email send button title") forState: UIControlStateNormal];
                break;
            case 5: 
                [explanationLabel setText: [[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat:@"Text%@", languageIdentifier]]];
                [explanationButton setBackgroundImage: [UIImage imageNamed: @"PhoneActionButton.png"] forState: UIControlStateNormal];
                [explanationButton setTitle: NSLocalizedString(@"Call", @"Call button title") forState: UIControlStateNormal];
                break;
            case 8:
                viewTextString= [NSString stringWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat:@"Text%@", languageIdentifier]]];
                [explanationLabel setText: [viewTextString stringByReplacingOccurrencesOfString: @"COST_KEY" withString:  [[cantonsList objectAtIndex: cantonRow] objectForKey: @"Cost"]]];
                [explanationButton setBackgroundImage: [UIImage imageNamed: @"SafariActionButton.png"] forState: UIControlStateNormal];
                [explanationButton setTitle: NSLocalizedString(@"Open Safari", @"Open Safari button title") forState: UIControlStateNormal];
                break;
            default:
                break;
        }
    }
    if (webServiceCode == 1) {
        [captchaTextField setAutocapitalizationType: UITextAutocapitalizationTypeAllCharacters];
    }
    if ((webServiceCode == 3) || (webServiceCode == 7)) {
        self.normalBackgroundView.hidden = NO;
        self.maskBackgroundView.hidden = YES;
        CGRect tempButtonFrame = self.bigSearchButton.frame;
        tempButtonFrame.origin.x = 127;
        self.bigSearchButton.frame = tempButtonFrame;
        //self.bigSearchButton.hidden = YES;
    } else {
        self.normalBackgroundView.hidden = YES;
        self.maskBackgroundView.hidden = NO;
        //self.bigSearchButton.hidden = NO;
    }
    
    self.resultTableView.backgroundColor = [UIColor clearColor];
	self.resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.resultTableView.showsVerticalScrollIndicator = NO;
    
#ifndef tUseCustomPushPop
    
    if (!searchViewOnScreen) {
        if (self.viewAppearsFromCustomTabbarPush) {
            
            #ifdef  kLoggingIsOn
                NSLog(@"WSVC; viewWillAppear: move search view on screen");
            #endif
            
            self.viewAppearsFromCustomTabbarPush = NO;
            [self performSelector:@selector(moveSearchViewOnScreen) withObject:nil afterDelay:0.3];
        } 
    }
    
#endif
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{        
    [self setControlCell: nil];
    [self setTableCell: nil];
    [self setControlRowIndexPath: nil];
    [self setTappedIndexPath: nil];
    [self setPhoneNumberCache:nil];
    [self getCookieWaitingAlertView];
    [self setViacarCanton:nil];
    [self setViacarSessionID:nil];
    [self setViacarAuthID:nil];
    [self setViacarIndID:nil];
    [self setViacarViewState: nil];
    [self setViacarEventValidation:nil];
    [self setViacarCarNumber:nil];
    [self setViacarJpegID:nil];
    [self setViacarInputFieldName:nil];
    [self setCariCanton:nil];
    [self setCariCarNumber:nil];
    [self setCariCarType:nil];
    [self setCarOwners:nil];
    [self setCantonCode:nil];
    [self setFlagName:nil];
    [self setCantonLabel:nil];
    [self setCantonImage:nil];
    [self setCaptchaView:nil];
    [self setCaptchaImage:nil];
    [self setCaptchaTextField:nil];
    [self setExplanationView:nil];
    [self setExplanationLabel:nil];
    [self setExplanationButton:nil];
    [self setVehicleSelectionScrollView:nil];
    [self setVehicleSelectionImagesView:nil];
    [self setBigSearchButton:nil];
    [self setNormalBackgroundView:nil];
    [self setNumberLabel:nil];
    [self setSearchView:nil];
    [self setWaitWithAddinsView:nil];
    [self setWaitWithAddinsLabel:nil];
    [self setMaskBackgroundView:nil];
    [self setEnterCaptchaCodeLabel:nil];
    [self setNumberTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) mailComposeController:(MFMailComposeViewController*) mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//NSLog(@"Mail return");

#ifndef kUseCustomTabbarControllerForPushAndPop
	[self dismissModalViewControllerAnimated:YES];
#else
    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate.customTabBarViewController dismissModalViewControllerAnimated:YES];
    [appDelegate.customTabBarViewController dismissViewControllerAnimated:YES completion:nil];
#endif
    
    [self becomeFirstResponder];
    //[self.numberTextField becomeFirstResponder];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    //NSLog(@"SMS return");
    
#ifndef kUseCustomTabbarControllerForPushAndPop
	[self dismissModalViewControllerAnimated:YES];
#else
    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate.customTabBarViewController dismissModalViewControllerAnimated:YES];
    [appDelegate.customTabBarViewController dismissViewControllerAnimated:YES completion:nil];
#endif
    
    [self becomeFirstResponder];
    
    //[self.numberTextField becomeFirstResponder];
}

- (IBAction)explanationAction:(id)sender {
    if ((!self.numberLabel.text) || ([self.numberLabel.text length] == 0)) 
	{
		WBInfoNoticeView *notice = [WBInfoNoticeView infoNoticeInWindow:NSLocalizedString(@"No car number entered", @"No car number entered alert view") message:NSLocalizedString(@"You must enter a car number to proceed", @"No car number entered alert view")];
        [notice show];
        
        //[self.numberTextField becomeFirstResponder];
        
		return;
	}
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CantonConfig" ofType:@"plist"];      
    NSArray *cantonsList = [[NSDictionary dictionaryWithContentsOfFile: filePath] objectForKey: @"Cantons"];

    NSString *preflanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *languageIdentifier;
    
    if ([preflanguage isEqualToString:@"en"] || [preflanguage isEqualToString:@"de"] || [preflanguage isEqualToString:@"fr"] || [preflanguage isEqualToString:@"it"]) {
        languageIdentifier = [preflanguage uppercaseString];
    } else languageIdentifier = @"EN";
    
    NSString *messageBodyText2 = nil;
    
    
    switch (webServiceCode) {
        case 2:  // SMS
            if([MFMessageComposeViewController canSendText])
            {
                MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
                controller.body = [NSString stringWithFormat: @"%@ %@", self.cantonCode, self.numberLabel.text];
                controller.recipients = [NSArray arrayWithObjects:[[cantonsList objectAtIndex: cantonRow] objectForKey: @"SMS"], nil];
                controller.messageComposeDelegate = self;
                
                #ifndef kUseCustomTabbarControllerForPushAndPop
                    [self presentModalViewController:controller animated:YES];
                #else
                    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
                    //[appDelegate.customTabBarViewController presentModalViewController:controller animated: YES];
                    [appDelegate.customTabBarViewController presentViewController:controller animated:YES completion:nil];
                #endif
                
            }
            break;
        case 4: // Email
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailController=  [[[MFMailComposeViewController alloc] init] autorelease];
                mailController.mailComposeDelegate = self;
                [mailController setSubject: [[[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat: @"MailSub%@", languageIdentifier]] stringByReplacingOccurrencesOfString:@"CARNUMBER" withString: [NSString stringWithFormat:@"%@%@", self.cantonCode, self.numberLabel.text]]];
                messageBodyText2 = [[[cantonsList objectAtIndex: cantonRow] objectForKey: @"MailText2"] stringByReplacingOccurrencesOfString:@"CARNUMBER" withString: [NSString stringWithFormat:@"%@%@", self.cantonCode, self.numberLabel.text]];
                [mailController setMessageBody: [NSString stringWithFormat: @"%@\r\n%@\r\n%@\r\n%@", [[cantonsList objectAtIndex: cantonRow] objectForKey: @"MailText1"], messageBodyText2, [[cantonsList objectAtIndex: cantonRow] objectForKey: @"MailText3"], [[cantonsList objectAtIndex: cantonRow] objectForKey: @"MailText4"]] isHTML:NO];
                [mailController setToRecipients:  [NSArray arrayWithObject: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"Email"]]];
                
                 #ifndef kUseCustomTabbarControllerForPushAndPop
                    [self presentModalViewController:mailController animated:YES];
                #else
                    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
                    //[appDelegate.customTabBarViewController presentModalViewController:mailController animated: YES];
                    [appDelegate.customTabBarViewController presentViewController:mailController animated:YES completion:nil];
                #endif
                
            }
            break;
        case 5: // Phone
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"tel://%@", [[cantonsList objectAtIndex: cantonRow] objectForKey: @"Phone"]]]]; 
            break;
        case 8: // Safari
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"HTTP"]]];
            break;
        default:
            break;
    }
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
    
    return (@"Unknown");
}

- (NSString *) systemVersion
{
    return ([[UIDevice currentDevice] systemVersion]);
}

- (void) contactSupportDueToError:(NSString *)subject message:(NSString *)message response:(NSString *) response {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailController=  [[[MFMailComposeViewController alloc] init] autorelease];
        mailController.mailComposeDelegate = self;
        [mailController setSubject: subject];
        
        NSString *messageId;
        messageId = [[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        /*
		[mailController setMessageBody: [NSString stringWithFormat: @"%@\n\n%@\n\n\n\n\n\n\n\nMessage id: %@\niPhone: %@\niOS Version: %@\n", NSLocalizedString(@"Dear Support, ", @"Swiss Plates settings support email draft text"), message, messageId, [self iPhoneDevice], [self systemVersion]] isHTML:NO];
        */
        
        #ifdef AddDecodingErrorResponseToEmail
        [mailController setMessageBody: [NSString stringWithFormat: @"%@\n\n%@\n\n\n\n\n\n\n\n\nMessage id: %@\niPhone: %@\niOS Version: %@\nApp version: %@\nLanguage: %@\nWeb response: \n\n%@",NSLocalizedString(@"Dear Support, ", @"Swiss Plates settings support email draft text"), message, messageId, [self iPhoneDevice], [self systemVersion], kUTControllerAppName, [[NSLocale currentLocale] localeIdentifier], response] isHTML:NO];
        #else
        [mailController setMessageBody: [NSString stringWithFormat: @"%@\n\n%@\n\n\n\n\n\n\n\n\nMessage id: %@\niPhone: %@\niOS Version: %@\nApp version: %@\nLanguage: %@",NSLocalizedString(@"Dear Support, ", @"Swiss Plates settings support email draft text"), message, messageId, [self iPhoneDevice], [self systemVersion], kUTControllerAppName, [[NSLocale currentLocale] localeIdentifier]] isHTML:NO];
        #endif
        
		[mailController setToRecipients:  [NSArray arrayWithObject: kSupportEmail]];
        
        #ifndef kUseCustomTabbarControllerForPushAndPop
        [self presentModalViewController:mailController animated:YES];
        #else
        Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[appDelegate.customTabBarViewController presentModalViewController:mailController animated: YES];
        [appDelegate.customTabBarViewController presentViewController:mailController animated:YES completion:nil];
        #endif
    }
}

- (IBAction)pushBackController:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startSearch:(id)sender {
    
#ifndef NONETWORK
    
    #ifdef  kLoggingIsOn
        NSLog(@"Check if network available");
    #endif
    
    if ((webServiceCode == 1) || (webServiceCode == 3) || (webServiceCode == 6) || (webServiceCode == 7))
    {
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
    }
#endif
        
    if (webServiceCode == 1) [self viacarGetCookie];
    if (webServiceCode == 2) [self pushNonWebServiceController];
    if (webServiceCode == 3) [self cariGetCookie];
    if (webServiceCode == 4) [self pushNonWebServiceController];
    if (webServiceCode == 5) [self pushNonWebServiceController];
    if (webServiceCode == 6) [self nwLoginAndSearch];
    if (webServiceCode == 7) [self tiGetCookie];
    if (webServiceCode == 8) [self pushNonWebServiceController];
}

- (IBAction)captchaViewCancel:(id)sender {
    [self moveCaptchaViewOffScreen];
    [self performSelector:@selector(moveSearchViewOnScreen) withObject:nil afterDelay: 0.3];
    //[self moveSearchViewOnScreen];
}

- (IBAction)captchaViewLoginAndSearch:(id)sender {
    
#ifndef NONETWORK
    
    if (!([UIDevice networkAvailable])) 
    {
        //NSLog(@"No network available");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No network", @"No network available alert view title") message:NSLocalizedString(@"There is no WiFi or cellular network available. Please check or try again later.", @"No network available alert view message")];
        [notice show];

        return;
    } 
#endif    
    if (webServiceCode == 1) [self viacarLoginAndSearch];
    if (webServiceCode == 3) [self cariLoginAndSearch];
    if (webServiceCode == 7) [self tiLoginAndSearch];
}

- (void) moveCaptchaViewOffScreen
{

    #ifdef  kLoggingIsOn
        NSLog(@"Move captcha view off screen");
    #endif
    
    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.customTabBarViewController unblockTabBarUI];
    
    [self.captchaTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         self.captchaView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [UIView commitAnimations];
     
     
    self.captchaViewOnScreen = NO;
}

- (void) moveExplanationViewOffScreen
{
    #ifdef  kLoggingIsOn
        NSLog(@"Move explanation view off screen");
    #endif
    
    self.explanationViewOnScreen = NO;
    
    CGFloat retina4Adjustment = (([UIDevice currentResolution] == UIDevice_iPhoneTallerHiRes)?EXPVIEWR4ADJ:0);
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         self.explanationView.transform = CGAffineTransformMakeTranslation(0, (EXPVIEWHEIGHT + retina4Adjustment));
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [UIView commitAnimations];
}

- (void) makeCaptchaTextFieldFirstResponder {
    [self.captchaTextField becomeFirstResponder];
}

- (void) moveCaptchaViewOnScreen
{	
	#ifdef  kLoggingIsOn
        NSLog(@"Move captcha view on screen");
    #endif
    
    Swiss_PlatesAppDelegate *appDelegate = (Swiss_PlatesAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.customTabBarViewController blockTabBarUI];
    
    self.enterCaptchaCodeLabel.text = NSLocalizedString(@"Please enter the text in the picture", @"Enter code in captcha image label");
    self.captchaTextField.placeholder = NSLocalizedString(@"Please enter the text in the picture", @"Enter code in captcha image label");
    
    self.captchaViewWasOnScreen = YES;
    
    CGFloat frameHeight = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         self.captchaView.transform = CGAffineTransformMakeTranslation(0, -(frameHeight - TOOLBARHEIGHT));
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [UIView commitAnimations];

    self.captchaViewOnScreen = YES;
    
    #ifdef  kLoggingIsOn
        NSLog(@"Captcha text field become first responder");
    #endif
    
    [self performSelector:@selector(makeCaptchaTextFieldFirstResponder) withObject:nil afterDelay:0];
}

- (void) moveExplanationViewOnScreen
{	
    #ifdef  kLoggingIsOn
        NSLog(@"Move explanation view on screen");
    #endif
    
    self.explanationViewOnScreen = YES;
    explanationView.backgroundColor = [UIColor clearColor];
    
    CGFloat retina4Adjustment = (([UIDevice currentResolution] == UIDevice_iPhoneTallerHiRes)?EXPVIEWR4ADJ:0);
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         self.explanationView.transform = CGAffineTransformMakeTranslation(0, -(EXPVIEWHEIGHT + retina4Adjustment));
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [UIView commitAnimations];
}

-(void) showBaseAlertView
{
    #ifdef  kLoggingIsOn
        NSLog(@"Show base alert");
    #endif
    
    if (self.waitWithAddinsViewOnScreen) return;
    
    if (self.searchViewOnScreen) {
        
        #ifdef  kLoggingIsOn
            NSLog(@"Show base alert, move search view off screen");
        #endif
        
        [self moveSearchViewOffScreen];
    }
    if (self.captchaViewWasOnScreen) {
        
        #ifdef  kLoggingIsOn
            NSLog(@"Show base alert, move captcha view off screen");
        #endif
        
        [self moveCaptchaViewOffScreen];
    };
        
    self.waitWithAddinsViewOnScreen = YES;
    
    self.waitWithAddinsLabel.text = NSLocalizedString(@"Please wait. The process can take up to 60 seconds", @"Get cookie waiting alert view message");
    
    [self performSelector:@selector(moveWaitWithAddinsViewOnScreen) withObject:nil afterDelay:0.3];
}


-(void) removeBaseAlertView
{
	if (!self.waitWithAddinsViewOnScreen) return;
    
    self.waitWithAddinsViewOnScreen = NO;
        
    [self moveWaitWithAddinsViewOffScreen];
    
    if (self.searchViewWasOnScreen) {
        
        #ifdef  kLoggingIsOn
            NSLog(@"Search view was on screen");
        #endif
        
        [self performSelector:@selector(moveSearchViewOnScreen) withObject:nil afterDelay:0.3];
        //[self moveSearchViewOnScreen];
    }
    if (self.captchaViewWasOnScreen) {
        
        #ifdef  kLoggingIsOn
            NSLog(@"Captcha view was on screen");
        #endif
        
        [self performSelector:@selector(moveCaptchaViewOnScreen) withObject:nil afterDelay:0.3];
        //[self moveCaptchaViewOnScreen];
    }
    
    self.searchViewWasOnScreen = NO;
    self.captchaViewWasOnScreen = NO;
}

#pragma mark - NW Processing

- (NSString *) md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}


- (NSString*) sha1:(NSString*)input
{
	NSData *data = [input dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(data.bytes, data.length, digest);
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	
	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];
	
	return output;
}


- (NSString *) generateKey:(NSString*)input
{
	NSString *saltedString = [NSString stringWithFormat: @"%@%@", input, @"H3R31AM"];
    
    NSString *sha1Result = [NSString stringWithString: [self sha1: saltedString]];
	NSString *result = [NSString stringWithString: [[[self md5: sha1Result] lowercaseString] substringToIndex: 4]];
	return ([sha1Result stringByAppendingString: result]);
}

- (void) nwLoginAndSearch {
    
    //self.carOwners = nil;
    //[self pwTestCode];
    //return;
    
    [ASIHTTPRequest clearSession];
    [ASIHTTPRequest setSessionCookies:nil];
    [ASIHTTPRequest setDefaultTimeOutSeconds: 180];
    
    if ((!self.numberLabel.text) || ([self.numberLabel.text length] == 0))
	{
		WBInfoNoticeView *notice = [WBInfoNoticeView infoNoticeInWindow:NSLocalizedString(@"No car number entered", @"No car number entered alert view") message:NSLocalizedString(@"You must enter a car number to proceed", @"No car number entered alert view")];
        [notice show];
        
		return;
	}
    
    //Voucher unlock code create flag file generation
    if ([self.numberLabel.text isEqualToString: @"620687"]) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *voucherFile = [documentsDirectory stringByAppendingPathComponent: kUnlockVoucherFieldFile];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath: voucherFile])
        {
            [@"UVC" writeToFile: voucherFile atomically: YES encoding: NSUTF8StringEncoding error: NULL];
        }
    }
    
    [self setCariCarNumber: self.numberLabel.text];
    [self setCariCanton: self.cantonCode];
    
    if (!cariCarNumber) return; if (!cariCanton) return;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CantonConfig" ofType:@"plist"];
    //NSArray *cantonsList = [[NSDictionary dictionaryWithContentsOfFile: filePath] objectForKey: @"Cantons"];
    
    //NSURL *url = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"LoginURL"]];
    
    NSString *stURL = [NSString stringWithFormat: @"%@?carNumber=%@&key=%@", @"http://www.zonezeroapps.com/servers/autoindexnw/getCarNumber.php", self.numberLabel.text, [self generateKey: self.numberLabel.text]];
    NSURL *url = [NSURL URLWithString: stURL];
    
    __block ASIHTTPRequest *loginRequest = [[ASIHTTPRequest requestWithURL:url] retain];
    [loginRequest setDelegate:self]; [loginRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
    //[cookieRequest setUseCookiePersistence:NO];
    [loginRequest setRequestMethod:@"GET"];
    [loginRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
    
    //NSLog(@"%@", [cookieRequest requestHeaders]);

    [loginRequest setCompletionBlock:^{
        NSString *responseString = [loginRequest responseString];
        //NSLog(@"Response: %@", responseString);
        //NSLog(@"%@", [loginRequest responseHeaders]);
        //[self removeBaseAlertView];
        
        if ([responseString isEqualToString: @"No result"]) {
            //NSLog(@"No result");
            
            [self removeBaseAlertView];
            self.currentPostRequest = nil;
            
            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No result", @"Search failed alert view") message:NSLocalizedString(@"The search did not return any result. There may be no owner with this plate number", @"Search failed alert view")];
            [notice show];
            
            return;
        }
        
        NSArray *ownersArray = [responseString componentsSeparatedByString: @"|"];
        
        //NSLog(@"Ownersarray: %@", ownersArray);
        
        if ([ownersArray count] != 3) {
            //NSLog(@"Owners decoding error");
            
            [self removeBaseAlertView];
            self.currentPostRequest = nil;
            
            if ([MFMailComposeViewController canSendMail]) {
                
                BlockAlertView *alert = [BlockAlertView alertWithTitle: NSLocalizedString(@"Decoding error", @"Decoding error alert view") message: NSLocalizedString(@"The search result could not be decoded. Please report this error immeditately to the app support", @"Decoding error alert view")];
                
                [alert setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Share action sheet, share via sheet cancel button") block:nil];
                [alert addButtonWithTitle:NSLocalizedString(@"Report to support", @"Report to support button title") block:^{
                    [self contactSupportDueToError: @"Decoding error" message: [NSString stringWithFormat: @"The search result for the plate number %@-%@ could not be decoded.", self.cantonCode, self.numberLabel.text] response: responseString];
                }];
                [alert show];
                
            } else {
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Decoding error", @"Decoding error alert view") message:NSLocalizedString(@"The search result could not be decoded. Please report this error immeditately to the app support", @"Decoding error alert view")];
                [notice show];
            }

            return;
        }
        
        self.carOwners = nil;
        
        NSMutableArray *tempCarOwners = [NSMutableArray arrayWithCapacity:1];
        
        NSString *carOwner = [NSString stringWithFormat: @"%@|%@|%@|%@|%@|%@|L", self.cariCanton, self.cariCarNumber, self.flagName,  [ownersArray objectAtIndex: 0],
                              [ownersArray objectAtIndex: 1], [ownersArray objectAtIndex: 2]];
        [tempCarOwners addObject: carOwner];
        
        self.carOwners = tempCarOwners;
        
        //NSLog(@"Ownersarray: %@", self.carOwners);
        //NSLog(@"NW success, show results");
        
        self.searchViewWasOnScreen = NO;
        self.captchaViewWasOnScreen = NO;
        
        self.currentPostRequest = nil;
        
        self.ownersList = self.carOwners;
        [self moveResultsViewOnScreen];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];

    }];
    [loginRequest setFailedBlock:^{
        //NSError *error = [loginRequest error];
        //NSLog(@"2nd failed %@",[error description]);
        
        [self removeBaseAlertView];
        self.currentGetRequest = nil;
        
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Login failed", @"Login failed alert view") message:NSLocalizedString(@"The app was unable to login into the web service", @"Login failed alert view")];
        [notice show];

    }];
    
    [self showBaseAlertView];
    
    self.currentGetRequest = loginRequest;
    self.currentPostRequest = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(1);
        [loginRequest startAsynchronous];
        [loginRequest release];
    });
}


#pragma mark - TI Processing

- (void) tiLoginAndSearch {
    if ((!self.captchaTextField.text) || ([self.captchaTextField.text length] == 0)) 
	{
		WBInfoNoticeView *notice = [WBInfoNoticeView infoNoticeInWindow:NSLocalizedString(@"No captcha code entered", @"No captcha code entered alert view") message:NSLocalizedString(@"You must enter the captcha code as shown in the image", @"No captcha code entered alert view")];
        [notice show];
                
        [self.captchaTextField becomeFirstResponder];
        
		return;
	}
    
    [self moveCaptchaViewOffScreen];
    
    //if (!self.cariCanton) NSLog(@"Miss canton");
    //if (!self.cariCarNumber) NSLog(@"Miss car number");
    
    if (!self.cariCanton || !self.cariCarNumber) return; 
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CantonConfig" ofType:@"plist"];      
    NSArray *cantonsList = [[NSDictionary dictionaryWithContentsOfFile: filePath] objectForKey: @"Cantons"];
    
    //NSURL *url = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"LoginURL"]];
    
    NSURL *url;
    if (self.cariCarType) {
        url = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat: @"LoginURL%@", self.cariCarType]]];
    } else {
        url = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"LoginURLL"]];
    }
    
    __block ASIFormDataRequest *loginRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    
    [loginRequest setDelegate:self]; [loginRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy]; 
    //[loginRequest setUseCookiePersistence:NO];
    [loginRequest setRequestMethod:@"POST"];
    [loginRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
    
    [loginRequest addPostValue: self.cariCarNumber forKey: @"notarga"];
    
    NSString *codice;
    if (self.cariCarType) {
        codice = [[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat: @"Codice%@", cariCarType]];
        //NSLog(@"TI codice: %@",codice);
    }  else {
        codice = @"11";
    }
    
    [loginRequest addPostValue: codice forKey:@"codice"];
    [loginRequest addPostValue: self.captchaTextField.text forKey:@"code"];
    [loginRequest addPostValue: @"Trova" forKey:@"bTrova"];
    
    [loginRequest setCompletionBlock:^{
        NSString *responseString = [loginRequest responseString];
        //NSLog(@"Response: %@", responseString);
        //NSLog(@"%@", [loginRequest responseHeaders]);
        
        NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
        NSString *cleanedStringResponse = [NSString stringWithString: [[responseString componentsSeparatedByCharactersInSet: cs] componentsJoinedByString: @""]];
        
        NSRegularExpression *noresultRegex = CreateRegex(@"La ricerca non ha fornito alcun");
        
        if (!CheckRegexMatch(noresultRegex, cleanedStringResponse)) {
            //NSLog(@"No result");
        
            self.searchViewWasOnScreen = YES;
            self.captchaViewWasOnScreen = NO;
            [self removeBaseAlertView];
            self.currentPostRequest = nil;
            
            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No result", @"Search failed alert view") message:NSLocalizedString(@"The search did not return any result. There may be no owner with this plate number", @"Search failed alert view")];
            [notice show];
            
            return;
        }
        
        NSRegularExpression *textBoxRegex = CreateRegex(@"Codice di validazione non valido");
        
        //NSLog(@"Matches: %d",[textBoxRegex numberOfMatchesInString:cleanedStringResponse options:0 range:NSMakeRange(0, [cleanedStringResponse length])]);
        
        if (!CheckRegexMatch(textBoxRegex, cleanedStringResponse)) {
            //NSLog(@"Login error");
            
            self.searchViewWasOnScreen = YES;
            self.captchaViewWasOnScreen = NO;
            [self removeBaseAlertView];
            self.currentPostRequest = nil;
            
            NSString *wrongCaptchaMessage = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"The captcha code you entered is not valid. Please try again", @"Wrong captcha code alert view"), NSLocalizedString(@"(Note the upper and lower case letters!)", @"Wrong captcha important lower and upper case letters")]; 
     
            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Wrong captcha code", @"Wrong captcha code alert view") message: wrongCaptchaMessage];
            [notice setDelay: 5];
            [notice show];
            
            return;
        } else {
            NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
            NSString *cleanedString = [NSString stringWithString: [[responseString componentsSeparatedByCharactersInSet: cs] componentsJoinedByString: @""]];
            
            NSString *tempName = nil;
            NSString *tempAdress = nil;
            NSString *tempplzplace = nil;
            
            //NSLog(@"Cleaned string: %@", cleanedString);
            
            NSTextCheckingResult *ownerMatch = RegexMatch(CreateRegex(@"<p class=\"targheRisultato\"><b>(.+?)</p>"), cleanedString);
            if (ownerMatch) { NSString *catch1 = GetMatchString(ownerMatch, cleanedString);                
                
                //NSLog(@"Step1");
                
                if (catch1) {
                    NSArray *splitCatch1 = [catch1 componentsSeparatedByString: @"</b>"];
                    
                    //NSLog(@"Step2");
                    
                    if (splitCatch1 && ([splitCatch1 count] >= 2)) {
                        tempName = [[splitCatch1 objectAtIndex: 0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        //NSLog(@"A1: %@", tempName);
                        
                        NSArray *splitCatch2 = [[splitCatch1 objectAtIndex: 1] componentsSeparatedByString: @"<br />"];
                        if (splitCatch2 && ([splitCatch2 count] >= 3)) {
                            tempAdress = [[splitCatch2 objectAtIndex: 1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            tempplzplace = [[splitCatch2 objectAtIndex: 2] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            
                            //NSLog(@"A2: %@", tempAdress);
                            //NSLog(@"A3: %@", tempplzplace);
                        }

                    }
                }
            }
            
            if (!tempName || !tempAdress || !tempplzplace) {
                //NSLog(@"Owners decoding error");
                
                self.searchViewWasOnScreen = YES;
                self.captchaViewWasOnScreen = NO;
                [self removeBaseAlertView];
                self.currentPostRequest = nil;
                
                if ([MFMailComposeViewController canSendMail]) {
                    BlockAlertView *alert = [BlockAlertView alertWithTitle: NSLocalizedString(@"Decoding error", @"Decoding error alert view") message: NSLocalizedString(@"The search result could not be decoded. Please report this error immeditately to the app support", @"Decoding error alert view")];
                    
                    [alert setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Share action sheet, share via sheet cancel button") block:nil];
                    [alert addButtonWithTitle:NSLocalizedString(@"Report to support", @"Report to support button title") block:^{
                        [self contactSupportDueToError: @"Decoding error" message: [NSString stringWithFormat: @"The search result for the plate number %@-%@ could not be decoded.", self.cantonCode, self.numberLabel.text] response: responseString];
                    }];
                    [alert show];
                } else {
                    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Decoding error", @"Decoding error alert view") message:NSLocalizedString(@"The search result could not be decoded. Please report this error immeditately to the app support", @"Decoding error alert view")];
                    [notice show];
                }
     
                return;
            }
            
            self.carOwners = nil;
            
            NSMutableArray *tempCarOwners = [NSMutableArray arrayWithCapacity:1];
            
            //NSString *carOwner = [NSString stringWithFormat: @"%@|%@|%@|%@|%@|%@|L", self.cariCanton, self.cariCarNumber, self.flagName,  tempName, tempAdress, tempplzplace];
            //[tempCarOwners addObject: carOwner];
            
            if (self.cariCarType) {
                NSString *carOwner = [NSString stringWithFormat: @"%@|%@|%@|%@|%@|%@|%@", self.cariCanton, self.cariCarNumber, self.flagName,  tempName, tempAdress, tempplzplace, self.cariCarType];
                [tempCarOwners addObject: carOwner];
                    
                //NSLog(@"current: %@", carOwner);
            } else {
                NSString *carOwner = [NSString stringWithFormat: @"%@|%@|%@|%@|%@|%@|L", self.cariCanton, self.cariCarNumber, self.flagName,  tempName, tempAdress, tempplzplace];
                [tempCarOwners addObject: carOwner];
                    
                //NSLog(@"current: %@", carOwner);
            }
            
            self.carOwners = tempCarOwners;
                        
            //NSLog(@"Ownersarray: %@", self.carOwners);
            
            
            self.searchViewWasOnScreen = NO;
            self.captchaViewWasOnScreen = NO;
            
            [self removeBaseAlertView];
            self.currentPostRequest = nil;
            
            self.ownersList = self.carOwners;
            [self moveResultsViewOnScreen];

        }
        
    }];
    
    [loginRequest setFailedBlock:^{
        //NSError *error = [loginRequest error];
        //NSLog(@"1nd failed %@",[error description]);
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        
        self.searchViewWasOnScreen = YES;
        self.captchaViewWasOnScreen = NO;
        [self removeBaseAlertView];
        self.currentPostRequest = nil;
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Login failed", @"Login failed alert view") message:NSLocalizedString(@"The app was unable to login into the web service", @"Login failed alert view")];
        [notice show];
 
    }];
    
    [self showBaseAlertView];
    self.currentGetRequest = nil;
    self.currentPostRequest = loginRequest;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(1);
        [loginRequest startAsynchronous];
        [loginRequest release];
    });
}

- (void) tiGetCookie {
    [ASIHTTPRequest clearSession];
    [ASIHTTPRequest setSessionCookies:nil];
    [ASIHTTPRequest setDefaultTimeOutSeconds: 180];
        
    if ((!self.numberLabel.text) || ([self.numberLabel.text length] == 0)) 
	{
		WBInfoNoticeView *notice = [WBInfoNoticeView infoNoticeInWindow:NSLocalizedString(@"No car number entered", @"No car number entered alert view") message:NSLocalizedString(@"You must enter a car number to proceed", @"No car number entered alert view")];
        [notice show];
                
		return;
	}
    
    [self setCariCarNumber: self.numberLabel.text];
    [self setCariCanton: self.cantonCode];
    
    if (!cariCarNumber) return; if (!cariCanton) return;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CantonConfig" ofType:@"plist"];      
    NSArray *cantonsList = [[NSDictionary dictionaryWithContentsOfFile: filePath] objectForKey: @"Cantons"];
    
    //NSLog(@"path: %@", filePath);
    //NSLog(@"Cantons: %@", cantonsList);
    
    NSURL *url;
    if (self.cariCarType) {
        url = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat: @"QueryURL%@", self.cariCarType]]];
        //NSLog(@"URL: 1");
    } else {
        url = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"QueryURLL"]];
        //NSLog(@"URL: 2");
    }
    
    //NSLog(@"URL: %@", url);
    //NSLog(@"CantonRow: %@", [cantonsList objectAtIndex: cantonRow]);
    
    __block ASIHTTPRequest *cookieRequest = [[ASIHTTPRequest requestWithURL:url] retain];
    [cookieRequest setDelegate:self]; [cookieRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
    //[cookieRequest setUseCookiePersistence:NO];
    [cookieRequest setRequestMethod:@"GET"];
    [cookieRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
    
    //NSLog(@"%@", [cookieRequest requestHeaders]);
    
    [cookieRequest setCompletionBlock:^{
        //NSString *responseString = [cookieRequest responseString];
        //NSLog(@"Response: %@", responseString);
        //NSLog(@"%@", [cookieRequest responseHeaders]);
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CantonConfig" ofType:@"plist"];      
        NSArray *cantonsList = [[NSDictionary dictionaryWithContentsOfFile: filePath] objectForKey: @"Cantons"];
        
        //NSURL *jpegUrl = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"CaptchaURL"]];
        
        NSURL *jpegUrl;
        if (self.cariCarType) {
            jpegUrl = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat: @"CaptchaURL%@", self.cariCarType]]];
        } else {
            jpegUrl = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"CaptchaURLL"]];
        }
        
        __block ASIHTTPRequest *captchaRequest = [ASIHTTPRequest requestWithURL: jpegUrl];
        [captchaRequest setDelegate:self]; [captchaRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
        //[captchaRequest setUseCookiePersistence:NO];
        [captchaRequest setRequestMethod:@"GET"];
        [captchaRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
        
        [captchaRequest setCompletionBlock:^{
            
            //NSLog(@"Picture received and set");
            
            //NEW
            //NSLog(@"Disable searchViewWasOnScreen");
            
            self.searchViewWasOnScreen = NO;            
            
            [self removeBaseAlertView];
            self.currentGetRequest = nil;
            
            NSData *responseData = [captchaRequest responseData];
            UIImage *tempCaptchaImage = [UIImage imageWithData:responseData];
            [captchaImage setImage: tempCaptchaImage];  
            [self moveCaptchaViewOnScreen];
            
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        }];
        [captchaRequest setFailedBlock:^{
            //NSError *error = [captchaRequest error];
            //NSLog(@"2nd failed %@",[error description]);
            
            [self removeBaseAlertView];
            self.currentGetRequest = nil;
            
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
            
            //[self moveSearchViewOnScreen];
            
            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Get captcha failed", @"Get captcha failed alert view") message:NSLocalizedString(@"The app was unable to get the captcha from the web service", @"Get captcha failed alert view")];
            [notice show];

        }];
        
        self.currentGetRequest = captchaRequest;
        self.currentPostRequest = nil;
        
        [captchaRequest startAsynchronous];
    }];
    [cookieRequest setFailedBlock:^{
        //NSError *error = [cookieRequest error];
        //NSLog(@"1st failed %@",[error description]);
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        
        [self removeBaseAlertView];
        self.currentGetRequest = nil;
        
        //[self moveSearchViewOnScreen];
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Get cookie failed", @"Get cookie step failed alert view")
 message:NSLocalizedString(@"The app was unable to get the cookie from the web service", @"Get cookie step failed alert view")];
        [notice show];

    }];
        
    // TEST CODE WO NETWORK
    
    [self showBaseAlertView];
    self.currentGetRequest = cookieRequest;
    self.currentPostRequest = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(1);
        [cookieRequest startAsynchronous];
        [cookieRequest release];
     }); 
     
    /*
    [self showBaseAlertView];
    [self testCodeExecuteGetCookieResultSuccess];
     */
}

#pragma mark - Cari RechDet Processing

- (void) cariLoginAndSearch {
    if ((!self.captchaTextField.text) || ([self.captchaTextField.text length] == 0)) 
	{
		WBInfoNoticeView *notice = [WBInfoNoticeView infoNoticeInWindow:NSLocalizedString(@"No captcha code entered", @"No captcha code entered alert view") message:NSLocalizedString(@"You must enter the captcha code as shown in the image", @"No captcha code entered alert view")];
        [notice show];
            
        [self.captchaTextField becomeFirstResponder];
        
		return;
	}
    
    [self moveCaptchaViewOffScreen];
    
    //if (!self.cariCanton) NSLog(@"Miss canton");
    //if (!self.cariCarNumber) NSLog(@"Miss car number");
    
    if (!self.cariCanton || !self.cariCarNumber) return; 
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CantonConfig" ofType:@"plist"];      
    NSArray *cantonsList = [[NSDictionary dictionaryWithContentsOfFile: filePath] objectForKey: @"Cantons"];
    
    NSURL *url = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"LoginURL"]];
    
    __block ASIFormDataRequest *loginRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    
    [loginRequest setDelegate:self]; [loginRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy]; 
    //[loginRequest setUseCookiePersistence:NO];
    [loginRequest setRequestMethod:@"POST"];
    [loginRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
         
    [loginRequest addPostValue: @"login" forKey:@"pageContext"];
    [loginRequest addPostValue: @"query" forKey:@"action"];
    [loginRequest addPostValue: self.cariCarNumber forKey: @"no"];
    
    NSString *cat; NSString *sousCat;
    
    if (self.cariCarType) {
        cat = [[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat: @"cat%@", cariCarType]];
        sousCat = [[cantonsList objectAtIndex: cantonRow] objectForKey: [NSString stringWithFormat: @"sousCat%@", cariCarType]];
        //NSLog(@"Cari cat: %@, sousCat: %@", cat, sousCat);
    }  else {
        cat = @"1"; sousCat = @"1";
    }
    
    [loginRequest addPostValue: cat forKey:@"cat"];
    [loginRequest addPostValue: sousCat forKey:@"sousCat"];
    [loginRequest addPostValue: self.captchaTextField.text forKey:@"captchaVal"];
    [loginRequest addPostValue: @"Fortsetzen" forKey:@"valider"];
    
    [loginRequest setCompletionBlock:^{
        NSString *responseString = [loginRequest responseString];
        //NSLog(@"Response: %@", responseString);
        //NSLog(@"%@", [loginRequest responseHeaders]);
        
        NSRegularExpression *textBoxRegex = CreateRegex(@"Resultat der Suche");
        if (CheckRegexMatch(textBoxRegex, responseString)) {
            //NSLog(@"Login error");
            
        
            //[self removeBaseAlertView];
            //self.currentPostRequest = nil;
            
            // Kein Halter gefunden - Check with FR2563
            // BL - mfk_kontrollschild-gesperrt - Kein Halter
            NSRegularExpression *wrongCodeRegexFR = CreateRegex(@"Bitte nochmal versuchen");
            NSRegularExpression *wrongCodeRegexBL = CreateRegex(@"Falscher Code");
            NSRegularExpression *noOwnerRegexFR = CreateRegex(@"Kein Halter gefunden");
            NSRegularExpression *noOwnerRegexBL = CreateRegex(@"mfk_kontrollschild-gesperrt");
            NSRegularExpression *noOwnerRegexBL2 = CreateRegex(@"Kontrollschild nicht in Verkehr");
            NSRegularExpression *noOwnerRegexBL3 = CreateRegex(@"Kontrollschild nicht verfügbar");
            NSRegularExpression *noOwnerRegexVS = CreateRegex(@"Kontrollschild erhältlich");
            NSRegularExpression *noOwnerRegexVS2 = CreateRegex(@"Diese Kontrollschild-Nr. ist ausser Tabelle");
            
            if (!CheckRegexMatch(wrongCodeRegexFR, responseString) || !CheckRegexMatch(wrongCodeRegexBL, responseString)) {
                
                self.searchViewWasOnScreen = YES;
                self.captchaViewWasOnScreen = NO;
                [self removeBaseAlertView];
                self.currentPostRequest = nil;
                
                NSString *wrongCaptchaMessage = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"The captcha code you entered is not valid. Please try again", @"Wrong captcha code alert view"), NSLocalizedString(@"(Note the upper and lower case letters!)", @"Wrong captcha important lower and upper case letters")]; 
                
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Wrong captcha code", @"Wrong captcha code alert view") message: wrongCaptchaMessage];
                [notice setDelay: 5];
                [notice show];
 
                return;
                
            } else if (!CheckRegexMatch(noOwnerRegexFR, responseString) || !CheckRegexMatch(noOwnerRegexBL, responseString) || !CheckRegexMatch(noOwnerRegexBL2, responseString) || !CheckRegexMatch(noOwnerRegexBL3, responseString) || !CheckRegexMatch(noOwnerRegexVS, responseString) || !CheckRegexMatch(noOwnerRegexVS2, responseString)) {
                
                self.searchViewWasOnScreen = YES;
                self.captchaViewWasOnScreen = NO;
                [self removeBaseAlertView];
                self.currentPostRequest = nil;
                
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No result", @"Search failed alert view") message:NSLocalizedString(@"The search did not return any result. There may be no owner with this plate number", @"Search failed alert view")];
                [notice show];
     
            } else {
                
                self.searchViewWasOnScreen = YES;
                self.captchaViewWasOnScreen = NO;
                [self removeBaseAlertView];
                self.currentPostRequest = nil;
                
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Login failed", @"Login failed alert view") message:NSLocalizedString(@"The app was unable to login into the web service", @"Login failed alert view")];
                [notice show];
  
            }
            
            return;
        } else {
             
            NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"\n\r\t"];
            NSString *tempCleanedString = [NSString stringWithString: [[responseString componentsSeparatedByCharactersInSet: cs] componentsJoinedByString: @""]];
            
            NSError *error = nil;
            NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"\\s{2,}" options:NSRegularExpressionCaseInsensitive error:&error];
            
            NSString *cleanedString = [regex stringByReplacingMatchesInString:tempCleanedString
                                                                      options:0
                                                                        range:NSMakeRange(0, [tempCleanedString length])
                                                                 withTemplate:@""];
            
            NSRegularExpression *ownersTablesRegex = CreateRegex(@"<td class='libelle'>(.+?)</td></tr>");
            
            NSMutableArray *ownersArray = [NSMutableArray arrayWithCapacity: 4];
            
            [ownersTablesRegex enumerateMatchesInString:cleanedString options:0 range:NSMakeRange(0, [cleanedString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                NSString *trimmedString = [GetMatchString(match, cleanedString) stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [ownersArray addObject: trimmedString];
            }];
            
            //NSLog(@"Ownersarray: %@", ownersArray);
            
            NSArray *nameArray = [[ownersArray objectAtIndex:3] componentsSeparatedByString: @"</td><td>"];
            NSArray *addressArray = [[ownersArray objectAtIndex:4] componentsSeparatedByString: @"</td><td>"];
            NSArray *placeArray = [[ownersArray objectAtIndex:6] componentsSeparatedByString: @"</td><td>"];
            
            //if (([ownersArray count] == 0) || ([ownersArray count] % 3 != 0)) {
            if (([ownersArray count] == 0) || ([ownersArray count] != 7) || ([nameArray count] != 2) || ([addressArray count] != 2) || ([placeArray count] != 2)) {
                //NSLog(@"Owners decoding error");

                self.searchViewWasOnScreen = YES;
                self.captchaViewWasOnScreen = NO;
                [self removeBaseAlertView];
                self.currentPostRequest = nil;
                
                if ([MFMailComposeViewController canSendMail]) {
                    BlockAlertView *alert = [BlockAlertView alertWithTitle: NSLocalizedString(@"Decoding error", @"Decoding error alert view") message: NSLocalizedString(@"The search result could not be decoded. Please report this error immeditately to the app support", @"Decoding error alert view")];
                    
                    [alert setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Share action sheet, share via sheet cancel button") block:nil];
                    [alert addButtonWithTitle:NSLocalizedString(@"Report to support", @"Report to support button title") block:^{
                        [self contactSupportDueToError: @"Decoding error" message: [NSString stringWithFormat: @"The search result for the plate number %@-%@ could not be decoded.", self.cantonCode, self.numberLabel.text] response: responseString];
                    }];
                    [alert show];
                } else {
                    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Decoding error", @"Decoding error alert view") message:NSLocalizedString(@"The search result could not be decoded. Please report this error immeditately to the app support", @"Decoding error alert view")];
                    [notice show];
                }
       
                return;
            }
            
            self.carOwners = nil;
            NSMutableArray *tempCarOwners = [NSMutableArray arrayWithCapacity: 2];
            
            if (self.cariCarType) {
                for (int i = 1; i <= 1; i++) {
                    NSString *carOwner = [NSString stringWithFormat: @"%@|%@|%@|%@|%@|%@|%@", self.cariCanton, self.cariCarNumber, self.flagName,  [nameArray objectAtIndex:1], 
                                          [addressArray objectAtIndex:1], [placeArray objectAtIndex:1], self.cariCarType];
                    [tempCarOwners addObject: carOwner];
                    
                    //NSLog(@"current: %@", carOwner);
                }
            } else {
                for (int i = 1; i <= 1; i++) {
                    NSString *carOwner = [NSString stringWithFormat: @"%@|%@|%@|%@|%@|%@|L", self.cariCanton, self.cariCarNumber, self.flagName,  [nameArray objectAtIndex:1], 
                                          [addressArray objectAtIndex:1], [placeArray objectAtIndex:1]];
                    [tempCarOwners addObject: carOwner];
                    
                    //NSLog(@"current: %@", carOwner);
                }
            }
            
            self.carOwners = tempCarOwners;
            
            //NSLog(@"Ownersarray: %@", self.carOwners);
            
            self.searchViewWasOnScreen = NO;
            self.captchaViewWasOnScreen = NO;
            
            [self removeBaseAlertView];
            self.currentPostRequest = nil;
            
            self.ownersList = self.carOwners;
            [self moveResultsViewOnScreen];

        }
        
    }];
    
    [loginRequest setFailedBlock:^{
        //NSError *error = [loginRequest error];
        //NSLog(@"1nd failed %@",[error description]);
       
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        
        /*
        //pwTestCode no network - Begin
        //NSLog(@"Disable searchViewWasOnScreen");
        
        self.searchViewWasOnScreen = NO; 
        self.captchaViewWasOnScreen = NO;
        [self removeBaseAlertView];
        self.currentGetRequest = nil;
        self.currentPostRequest = nil;
        //[self moveCaptchaViewOnScreen];
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        [self pwTestCode];
        return ;
        //pwTestCode wo network - End
         */
        
        self.searchViewWasOnScreen = YES;
        self.captchaViewWasOnScreen = NO;
        [self removeBaseAlertView];
        self.currentPostRequest = nil;        
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Login failed", @"Login failed alert view") message:NSLocalizedString(@"The app was unable to login into the web service", @"Login failed alert view")];
        [notice show];

    }];
    
    [self showBaseAlertView];
    self.currentGetRequest = nil;
    self.currentPostRequest = loginRequest;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(1);
        [loginRequest startAsynchronous];
        [loginRequest release];
    });
}

- (void) cariGetCookie {
    
    //NSLog(@"Cari get cookie");
    
    [ASIHTTPRequest clearSession];
    [ASIHTTPRequest setSessionCookies:nil];
    [ASIHTTPRequest setDefaultTimeOutSeconds: 180];
        
    if ((!self.numberLabel.text) || ([self.numberLabel.text length] == 0)) 
	{
        WBInfoNoticeView *notice = [WBInfoNoticeView infoNoticeInWindow:NSLocalizedString(@"No car number entered", @"No car number entered alert view") message:NSLocalizedString(@"You must enter a car number to proceed", @"No car number entered alert view")];
        [notice show];
        
		return;
	}
    
    [self setCariCarNumber: self.numberLabel.text];
    [self setCariCanton: self.cantonCode];
    
    if (!cariCarNumber) return; if (!cariCanton) return;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CantonConfig" ofType:@"plist"];      
    NSArray *cantonsList = [[NSDictionary dictionaryWithContentsOfFile: filePath] objectForKey: @"Cantons"];

    NSURL *url = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"QueryURL"]];
    
    //NSLog(@"URL: %@", [[cantonsList objectAtIndex: cantonRow] objectForKey: @"QueryURL"]);
    
    __block ASIHTTPRequest *cookieRequest = [[ASIHTTPRequest requestWithURL:url] retain];
    [cookieRequest setDelegate:self]; [cookieRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
    //[cookieRequest setUseCookiePersistence:NO];
    [cookieRequest setRequestMethod:@"GET"];
    [cookieRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
    
    //NSLog(@"%@", [cookieRequest requestHeaders]);
    
    [cookieRequest setCompletionBlock:^{
        //NSString *responseString = [cookieRequest responseString];
        //NSLog(@"Response: %@", responseString);
        //NSLog(@"%@", [cookieRequest responseHeaders]);
        
        //NSLog(@"Cari get cookie request completed");
                
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CantonConfig" ofType:@"plist"];      
        NSArray *cantonsList = [[NSDictionary dictionaryWithContentsOfFile: filePath] objectForKey: @"Cantons"];
        
        NSURL *jpegUrl = [NSURL URLWithString: [[cantonsList objectAtIndex: cantonRow] objectForKey: @"CaptchaURL"]];
                
        __block ASIHTTPRequest *captchaRequest = [ASIHTTPRequest requestWithURL: jpegUrl];
        [captchaRequest setDelegate:self]; [captchaRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
        //[captchaRequest setUseCookiePersistence:NO];
        [captchaRequest setRequestMethod:@"GET"];
        [captchaRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];

        [captchaRequest setCompletionBlock:^{
            //NSLog(@"Picture received and set");
            
            //NSLog(@"Cari get captcha request completed");
            //NEW
            //NSLog(@"Disable searchViewWasOnScreen");
            
            self.searchViewWasOnScreen = NO; 
            
            [self removeBaseAlertView];
            self.currentGetRequest = nil;
            
            NSData *responseData = [captchaRequest responseData];
            UIImage *tempCaptchaImage = [UIImage imageWithData:responseData];
            [captchaImage setImage: tempCaptchaImage];  
            
            [self moveCaptchaViewOnScreen];
            
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        }];
        [captchaRequest setFailedBlock:^{
            //NSError *error = [captchaRequest error];
            //NSLog(@"2nd failed %@",[error description]);
        /*    
        #ifdef NONETWORK
            //pwTestCode wo network - Begin
            NSLog(@"Disable searchViewWasOnScreen");
            self.searchViewWasOnScreen = NO; 
            [self removeBaseAlertView];
            self.currentGetRequest = nil;
            self.currentPostRequest = nil;
            [self moveCaptchaViewOnScreen];
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
            return ;
            //pwTestCode wo network - End
        #endif
         */
            
            [self removeBaseAlertView];
            self.currentGetRequest = nil;
            
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
            
            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Get captcha failed", @"Get captcha failed alert view") message:NSLocalizedString(@"The app was unable to get the captcha from the web service", @"Get captcha failed alert view")];
            [notice show];
 
        }];
        
        self.currentGetRequest = captchaRequest;
        self.currentPostRequest = nil;
        
        [captchaRequest startAsynchronous];
    }];
    [cookieRequest setFailedBlock:^{
        //NSLog(@"Cari get cookie request failed");
        //NSError *error = [cookieRequest error];
        //NSLog(@"1st failed %@",[error description]);
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    
    /*    
    #ifdef NONETWORK
        //pwTestCode wo network - Begin
        NSLog(@"Disable searchViewWasOnScreen");
        self.searchViewWasOnScreen = NO; 
        [self removeBaseAlertView];
        self.currentGetRequest = nil;
        self.currentPostRequest = nil;
        [self moveCaptchaViewOnScreen];
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        return ;
        //pwTestCode wo network - End
    #endif
     */
        
        //NSLog(@"Cari get cookie request failed, remove wait view");
        
        [self removeBaseAlertView];
        self.currentGetRequest = nil;
        
        //NSLog(@"Cari get cookie request failed, show notice view");
        
        // TEST CODE WO NETWORK
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Get cookie failed", @"Get cookie step failed alert view") message: NSLocalizedString(@"The app was unable to get the cookie from the web service", @"Get cookie step failed alert view")];
        [notice show];
        
        //NSLog(@"Cari get cookie request failed, send UT info");

    }];
    
    //NSLog(@"Cari get cookie request execute");
    
    [self showBaseAlertView];
    self.currentGetRequest = cookieRequest;
    self.currentPostRequest = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(1);
        [cookieRequest startAsynchronous];
        [cookieRequest release];
    });
}

#pragma mark - Viarcar Processing

- (void) viacarLoginAndSearch {
    if ((!self.captchaTextField.text) || ([self.captchaTextField.text length] == 0)) 
	{
		WBInfoNoticeView *notice = [WBInfoNoticeView infoNoticeInWindow:NSLocalizedString(@"No captcha code entered", @"No captcha code entered alert view") message:NSLocalizedString(@"You must enter the captcha code as shown in the image", @"No captcha code entered alert view")];
        [notice show];
        
        [self.captchaTextField becomeFirstResponder];
        
		return;
	}
    
    [self moveCaptchaViewOffScreen];
        
    if (!self.viacarCanton || !self.viacarCarNumber || !self.viacarInputFieldName || !self.viacarViewState || !self.viacarEventValidation || !self.viacarSessionID) return; 
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"https://www.viacar.ch/eindex/login.aspx?kanton=%@", viacarCanton]];
    __block ASIFormDataRequest *loginRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    
    
    /*
    [loginRequest setDelegate:self]; [loginRequest setUseCookiePersistence:NO]; [loginRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy]; 
    [loginRequest setRequestMethod:@"POST"];
    [loginRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
    */

    [loginRequest setDelegate:self];
    [loginRequest setUseCookiePersistence:NO];
    [loginRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
    [loginRequest setRequestMethod:@"POST"];
    [loginRequest addRequestHeader:@"Host" value:@"www.viacar.ch"];
    //[loginRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
    [loginRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14"];
    [loginRequest addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [loginRequest addRequestHeader:@"Origin" value:@"https://www.viacar.ch"];
    [loginRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [loginRequest addRequestHeader:@"Referer" value:[NSString stringWithFormat: @"https://www.viacar.ch/eindex/login.aspx?kanton=%@", self.viacarCanton]];
    [loginRequest addRequestHeader:@"Accept-Language" value:@"de-de"];
    [loginRequest addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    [loginRequest addRequestHeader:@"Connection" value:@"keep-alive"];
    
    /*
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    NSString *requestCookie = [[NSString stringWithFormat: @"ASP.NET_SessionId=%@", self.viacarSessionID] stringByAppendingString: 
                               [NSString stringWithFormat: @"; ViaInd%@=Anzahl=0&Date=%@&de-CH=de-CH", self.viacarCanton, currentDate]];
    */
    
    NSString *requestCookie = [[NSString stringWithFormat: @"ASP.NET_SessionId=%@", self.viacarSessionID] stringByAppendingString: [NSString stringWithFormat: @"; %@", self.viacarIndID]];
    
    //NSLog(@"Request cookie: %@", requestCookie);
    [loginRequest addRequestHeader:@"Cookie" value:requestCookie];
    
    //NSLog(@"%@", [loginRequest requestHeaders]);
    /*
    [loginRequest addPostValue: self.viacarViewState forKey:@"__VIEWSTATE"];
    [loginRequest addPostValue: self.captchaTextField.text forKey: self.viacarInputFieldName];
    [loginRequest addPostValue: @"Login" forKey:@"BtLogin"];
    [loginRequest addPostValue: self.viacarEventValidation forKey:@"__EVENTVALIDATION"];
    */
    
    [loginRequest addPostValue: self.viacarViewState forKey:@"__VIEWSTATE"];
    [loginRequest addPostValue: self.viacarEventValidation forKey:@"__EVENTVALIDATION"];
    [loginRequest addPostValue: self.captchaTextField.text forKey: self.viacarInputFieldName];
    [loginRequest addPostValue: @"Login" forKey:@"BtLogin"];
    
    
    [loginRequest setCompletionBlock:^{
        NSString *responseString = [loginRequest responseString];
        //NSLog(@"Response: %@", responseString);
        //NSLog(@"%@", [loginRequest responseHeaders]);

        NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
        NSString *cleanedStringResponse = [NSString stringWithString: [[responseString componentsSeparatedByCharactersInSet: cs] componentsJoinedByString: @""]];
        
        NSRegularExpression *wrongCaptchaRegex = CreateRegex(@"Falsche Eingabe");
        
        if (!CheckRegexMatch(wrongCaptchaRegex, cleanedStringResponse)) {
            //NSLog(@"No result");
            
            //[self removeBaseAlertView];
            //self.currentPostRequest = nil;
            
            self.searchViewWasOnScreen = YES;
            self.captchaViewWasOnScreen = NO;
            [self removeBaseAlertView];
            self.currentPostRequest = nil;
            
            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Wrong captcha code", @"Wrong captcha code alert view") message: NSLocalizedString(@"The captcha code you entered is not valid. Please try again", @"Wrong captcha code alert view")];
            [notice show];
  
            return;
        }

        NSRegularExpression *limitReachedRegex = CreateRegex(@"heute erreicht");
        
        if (!CheckRegexMatch(limitReachedRegex, cleanedStringResponse)) {
            //NSLog(@"Limit reached");
            
            //[self removeBaseAlertView];
            //self.currentPostRequest = nil;
            
            self.searchViewWasOnScreen = YES;
            self.captchaViewWasOnScreen = NO;
            [self removeBaseAlertView];
            self.currentPostRequest = nil;
            
            if ([UIDevice activeWWAN]) {
                                
                BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"Limit reached", @"Limit reached 3G alert view") message:NSLocalizedString(@"You reached the daily query limit set by the canton of 5 searches per day for today. Please try again tomorrow. Tip: if you have not done any searches yet and you are on the 3G cellular network, you can try to connect to a Wifi network and search again. The canton limits the number of search requests to 5 per IP address per day. If you are on a 3G cellular network you share the same IP with other people near you who may already have used the 5 credits available per day.", @"Limit reached 3G alert view")];
                [alert setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Share action sheet, share via sheet cancel button") block:nil];
                [alert show];
                
            } else {

                BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"Limit reached", @"Limit reached normal alert view") message:NSLocalizedString(@"You reached the daily query limit set by the canton of 5 searches per day for today. Please try again tomorrow.", @"Limit reached normal alert view")];
                [alert setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Share action sheet, share via sheet cancel button") block:nil];
                [alert show];
                
            }
     
            return;
        }
    
        NSString *cookieString = [[loginRequest responseHeaders] objectForKey:@"Set-Cookie"];
        
        //NSLog(@"Set-Cookie: %@", cookieString);
        
        NSTextCheckingResult *sessionIDMatch = RegexMatch(CreateRegex(@"ASP.NET_SessionId=(.+?); "), cookieString);
        
        if (sessionIDMatch) { self.viacarSessionID = GetMatchString(sessionIDMatch, cookieString);
            //NSLog(@"Session ID: %@", self.viacarSessionID);
        }
        
        NSTextCheckingResult *authIDMatch = RegexMatch(CreateRegex(@" .AUTOINDEXAUTH=(.+?); "), cookieString);
        if (authIDMatch) { self.viacarAuthID = GetMatchString(authIDMatch, cookieString);
            //NSLog(@"Auth ID: %@", self.viacarAuthID);
        }
        
        NSRegularExpression *textBoxRegex = CreateRegex(@"name=\"TextBoxKontrollschild\"");
        if (CheckRegexMatch(textBoxRegex, responseString)) {
            //NSLog(@"Login error");
            
            //******************* CHECK FOR CAPTCHA ERROR OR LIMIT REACHED ******************************
            
            //[self removeBaseAlertView];
            //self.currentPostRequest = nil;
            
            self.searchViewWasOnScreen = YES;
            self.captchaViewWasOnScreen = NO;
            [self removeBaseAlertView];
            self.currentPostRequest = nil;
            
            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Login failed", @"Login failed alert view") message:NSLocalizedString(@"The app was unable to login into the web service", @"Login failed alert view")];
            [notice show];
     
            return;
        } else {
            NSTextCheckingResult *viewStateMatch = RegexMatch(CreateRegex(@"name=\"__VIEWSTATE\" .* value=\"(.*)\""), responseString);
            if (viewStateMatch) { self.viacarViewState = GetMatchString(viewStateMatch, responseString);
                //NSLog(@"Auth ID: %@", self.viacarViewState);
            }
            
            NSTextCheckingResult *evenValidationMatch = RegexMatch(CreateRegex(@"name=\"__EVENTVALIDATION\" .* value=\"(.*)\""), responseString);
            if (evenValidationMatch) { self.viacarEventValidation = GetMatchString(evenValidationMatch, responseString);
                //NSLog(@"Auth ID: %@", self.viacarEventValidation);
            }
            
            //NSURL *searchUrl = [NSURL URLWithString:[NSString stringWithFormat: @"https://www.viacar.ch/eindex/Search.aspx?Kanton=%@", viacarCanton]];
            
            NSURL *searchUrl = [NSURL URLWithString:[NSString stringWithFormat: @"https://www.viacar.ch/eindex/Search.aspx?kanton=%@", viacarCanton]];
            
            __block ASIFormDataRequest *searchRequest = [ASIFormDataRequest requestWithURL:searchUrl];
            
            [searchRequest setDelegate:self]; [searchRequest setUseCookiePersistence:NO]; [searchRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
            [searchRequest setRequestMethod:@"POST"];
            //[searchRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
            [searchRequest addRequestHeader:@"Host" value:@"www.viacar.ch"];
            //[searchRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
            [searchRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14"];
            [searchRequest addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
            [searchRequest addRequestHeader:@"Origin" value:@"https://www.viacar.ch"];
            [searchRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            [searchRequest addRequestHeader:@"Referer" value:[NSString stringWithFormat: @"https://www.viacar.ch/eindex/login.aspx?kanton=%@", self.viacarCanton]];
            [searchRequest addRequestHeader:@"Accept-Language" value:@"de-de"];
            [searchRequest addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate"];
            
            /*
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd.MM.yyyy"];
            NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
            [dateFormatter release];
            
            NSString *requestCookie = [[[NSString stringWithFormat: @"ASP.NET_SessionId=%@", self.viacarSessionID] stringByAppendingString: 
                                        [NSString stringWithFormat: @"; ViaInd%@=Anzahl=0&Date=%@&de-CH=de-CH", self.viacarCanton, currentDate]] stringByAppendingString: 
                                       [NSString stringWithFormat: @"; .AUTOINDEXAUTH=%@", self.viacarAuthID]];
            */
            
            NSString *requestCookie = [[[NSString stringWithFormat: @".AUTOINDEXAUTH=%@; ", self.viacarAuthID] stringByAppendingString: [NSString stringWithFormat: @"ASP.NET_SessionId=%@; ", self.viacarSessionID]] stringByAppendingString: self.viacarIndID];
            
            //NSLog(@"Request cookie: %@", requestCookie);
            
            [searchRequest addRequestHeader:@"Cookie" value:requestCookie];
            
            //NSLog(@"%@", [searchRequest requestHeaders]);
            /*
            [searchRequest addPostValue: self.viacarViewState forKey:@"__VIEWSTATE"];
            [searchRequest addPostValue: self.viacarCarNumber forKey: @"TextBoxKontrollschild"];
            [searchRequest addPostValue: @"Suchen" forKey:@"ButtonSuchen"];
            [searchRequest addPostValue: self.viacarEventValidation forKey:@"__EVENTVALIDATION"];
            */
            
            [searchRequest addPostValue: self.viacarViewState forKey:@"__VIEWSTATE"];
            [searchRequest addPostValue: self.viacarEventValidation forKey:@"__EVENTVALIDATION"];
            [searchRequest addPostValue: self.viacarCarNumber forKey: @"TextBoxKontrollschild"];
            [searchRequest addPostValue: @"Suchen" forKey:@"ButtonSuchen"];
           
            
            [searchRequest setCompletionBlock:^{
                NSString *responseString = [searchRequest responseString];
                //NSLog(@"Response: %@", responseString);
                //NSLog(@"%@", [searchRequest responseHeaders]);
                
                //NSString *cookieString = [[searchRequest responseHeaders] objectForKey:@"Set-Cookie"];
                //NSLog(@"Set-Cookie: %@", cookieString);
                
                NSRegularExpression *searchRunRegex = CreateRegex(@"Ihre Anfrage wird verarbeitet ....");
                if (CheckRegexMatch(searchRunRegex, responseString)) {
                    //NSLog(@"Search request failed");
                    
                    //[self removeBaseAlertView];
                    //self.currentPostRequest = nil;
                    
                    self.searchViewWasOnScreen = YES;
                    self.captchaViewWasOnScreen = NO;
                    [self removeBaseAlertView];
                    self.currentPostRequest = nil;
                    
                    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Plate search failed", @"Plate search failed alert view") message:NSLocalizedString(@"An server error occurred during the search. Please try again later", @"Plate search failed alert view")];
                    [notice show];
           
                    return;
                } else {
                    NSURL *resultUrl = [NSURL URLWithString:@"https://www.viacar.ch/eindex/Result.aspx"];
                    __block ASIHTTPRequest *resultRequest = [ASIHTTPRequest requestWithURL:resultUrl];
                    [resultRequest setDelegate:self]; [resultRequest setUseCookiePersistence:NO]; [resultRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
                    [resultRequest setRequestMethod:@"GET"];
                    //[resultRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
                    [resultRequest addRequestHeader:@"Host" value:@"www.viacar.ch"];
                    [resultRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
                    //[cookieRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14"];
                    [resultRequest addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
                    [resultRequest addRequestHeader:@"Referer" value:[NSString stringWithFormat: @"https://www.viacar.ch/eindex/Search.aspx?kanton=%@", self.viacarCanton]];
                    [resultRequest addRequestHeader:@"Accept-Language" value:@"de-de"];
                    [resultRequest addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate"];
                    
                    /*
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
                    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
                    [dateFormatter release];
                     
                    
                    NSString *requestCookie = [[[NSString stringWithFormat: @"ASP.NET_SessionId=%@", self.viacarSessionID] stringByAppendingString: 
                                                [NSString stringWithFormat: @"; ViaInd%@=Anzahl=0&Date=%@&de-CH=de-CH", self.viacarCanton, currentDate]] stringByAppendingString: 
                                               [NSString stringWithFormat: @"; .AUTOINDEXAUTH=%@", self.viacarAuthID]];
                    */
                    
                    
                    NSString *requestCookie = [[[NSString stringWithFormat: @".AUTOINDEXAUTH=%@; ", self.viacarAuthID] stringByAppendingString: [NSString stringWithFormat: @"ASP.NET_SessionId=%@; ", self.viacarSessionID]] stringByAppendingString: self.viacarIndID];
                    
                    //NSLog(@"Request cookie: %@", requestCookie);
                    
                    [resultRequest addRequestHeader:@"Cookie" value:requestCookie];
                    
                    //NSLog(@"%@", [resultRequest requestHeaders]);
                    
                    [resultRequest setCompletionBlock:^{
                        NSString *responseString = [resultRequest responseString];
                        
                        //NSLog(@"Response: %@", responseString);
                        
                        NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
                        NSString *cleanedStringResponse = [NSString stringWithString: [[responseString componentsSeparatedByCharactersInSet: cs] componentsJoinedByString: @""]];
                        
                        NSRegularExpression *wrongCaptchaRegex = CreateRegex(@"Das Suchergebnis ist negativ ausgefallen");
                        
                        if (!CheckRegexMatch(wrongCaptchaRegex, cleanedStringResponse)) {
                            //NSLog(@"No result");
                            
                            //[self removeBaseAlertView];
                            //self.currentPostRequest = nil;
                            
                            self.searchViewWasOnScreen = YES;
                            self.captchaViewWasOnScreen = NO;
                            [self removeBaseAlertView];
                            self.currentPostRequest = nil;
                            
                            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No result", @"Search failed alert view") message:NSLocalizedString(@"The search did not return any result. There may be no owner with this plate number", @"Search failed alert view")];
                            [notice show];
             
                            return;
                        }
                        
                        NSRegularExpression *cantonNotAvailableRegex = CreateRegex(@"Der gewünschte Kanton ist nicht verfügbar");
                        
                        if (!CheckRegexMatch(cantonNotAvailableRegex, cleanedStringResponse)) {
                            //NSLog(@"No result");
                            
                            //[self removeBaseAlertView];
                            //self.currentPostRequest = nil;
                            
                            self.searchViewWasOnScreen = YES;
                            self.captchaViewWasOnScreen = NO;
                            [self removeBaseAlertView];
                            self.currentPostRequest = nil;
                            
                            /*
                            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Canton not available", @"Canton not available alert view") message:NSLocalizedString(@"The server of the canton you are searching for is currently not available. This is normally only a temporary problem (server too busy, maintenance). Please try again later", @"Canton not available alert view")];
                            [notice show];
                            */
                            
                            BlockAlertView *alert = [BlockAlertView alertWithTitle: NSLocalizedString(@"Canton not available", @"Canton not available alert view") message: NSLocalizedString(@"The server of the canton you are searching for is currently not available. This is normally only a temporary problem (server too busy, maintenance). Please try again later", @"Canton not available alert view")];
                            
                            [alert setCancelButtonWithTitle:NSLocalizedString(@"Ok", @"Canton not available sheet cancel button") block:nil];
                            [alert show];
    
                            return;
                        }
                        
                        
                        NSString *clStrongString = [cleanedStringResponse stringByReplacingOccurrencesOfString: @"</STRONG>" withString: @""];
                        NSRegularExpression *ownersTablesRegex = CreateRegex(@"style=\"font-family:Arial;font-size:15px;\">(.{0,60})</span></FONT>");
                        NSRegularExpression *typeTablesRegex = CreateRegex(@"LabelKT(.+?)\"");
                        
                        //NSRegularExpression *ownersTablesRegex = CreateRegex(@"style=\"font-family:Arial;font-size:15px;\">(.+?)</span>");
                        
                        NSMutableArray *ownersArray = [NSMutableArray arrayWithCapacity: 6];
                        NSMutableArray *typeArray = [NSMutableArray arrayWithCapacity: 6];
                        
                        //[ownersTablesRegex enumerateMatchesInString:responseString options:0 range:NSMakeRange(0, [responseString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                        //    [ownersArray addObject: GetMatchString(match, responseString)];
                        //}];
                        
                        [ownersTablesRegex enumerateMatchesInString:clStrongString options:0 range:NSMakeRange(0, [clStrongString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                            [ownersArray addObject: GetMatchString(match, clStrongString)];
                        }];
                        
                        [typeTablesRegex enumerateMatchesInString:clStrongString options:0 range:NSMakeRange(0, [clStrongString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                            [typeArray addObject: GetMatchString(match, clStrongString)];
                        }];
                        
                        //NSLog(@"Ownersarray regex catch: %@", ownersArray);
                        //NSLog(@"Ownersarray count: %d, %d", [ownersArray count], [ownersArray count] / 6);
                        //NSLog(@"Typearray regex catch: %@", typeArray);
                        //NSLog(@"Typearray count: %d", [typeArray count]);
                        
                        if (([ownersArray count] == 0) || ([ownersArray count] % 6 != 0) || (([ownersArray count] / 6) != [typeArray count])) {
                            
                            //NSLog(@"Owners decoding error");
                            
                            //[self removeBaseAlertView];
                            //self.currentPostRequest = nil;
                            
                            self.searchViewWasOnScreen = YES;
                            self.captchaViewWasOnScreen = NO;
                            [self removeBaseAlertView];
                            self.currentPostRequest = nil;
                            
                            if ([MFMailComposeViewController canSendMail]) {
                                
         
                                BlockAlertView *alert = [BlockAlertView alertWithTitle: NSLocalizedString(@"Decoding error", @"Decoding error alert view") message: NSLocalizedString(@"The search result could not be decoded. Please report this error immeditately to the app support", @"Decoding error alert view")];
                                                                
                                [alert setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Share action sheet, share via sheet cancel button") block:nil];
                                [alert addButtonWithTitle:NSLocalizedString(@"Report to support", @"Report to support button title") block:^{
                                    
                                    [self contactSupportDueToError: @"Decoding error" message: [NSString stringWithFormat: @"The search result for the plate number %@-%@ could not be decoded.", self.cantonCode, self.numberLabel.text] response: responseString];
                                    
                                }];
                                [alert show];
                            } else {
                                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Decoding error", @"Decoding error alert view") message:NSLocalizedString(@"The search result could not be decoded. Please report this error immeditately to the app support", @"Decoding error alert view")];
                                [notice show];
                            }
       
                            return;
                        }
                        
                        self.carOwners = nil;
                        NSMutableArray *tempCarOwners = [NSMutableArray arrayWithCapacity: 2];
                        
                        for (int i = 1; i <= ([ownersArray count] / 6); i++) {
                            NSString *carOwner = [NSString stringWithFormat: @"%@|%@|%@|%@|%@|%@|%@", self.viacarCanton, self.viacarCarNumber, self.flagName,  [ownersArray objectAtIndex: ((i - 1) * 6) + 1], 
                                                  [ownersArray objectAtIndex: ((i - 1) * 6) + 3], [ownersArray objectAtIndex: ((i - 1) * 6) + 5], 
                                                  [typeArray objectAtIndex: i - 1]];
                            [tempCarOwners addObject: carOwner];
                        }
                        self.carOwners = tempCarOwners;
                        
                        //NSLog(@"Ownersarray: %@", self.carOwners);
                        
                        self.searchViewWasOnScreen = NO;
                        self.captchaViewWasOnScreen = NO;
                        
                        [self removeBaseAlertView];
                        self.currentPostRequest = nil;
                        
                        self.ownersList = self.carOwners;
                        [self moveResultsViewOnScreen];
               
                    }];
                    
                    [resultRequest setFailedBlock:^{
                        //NSError *error = [resultRequest error];
                        //NSLog(@"3nd failed %@",[error description]);
                        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
                        
                        //[self removeBaseAlertView];
                        //self.currentGetRequest = nil;
                        
                        self.searchViewWasOnScreen = YES;
                        self.captchaViewWasOnScreen = NO;
                        [self removeBaseAlertView];
                        self.currentPostRequest = nil;
                        
                        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Get result failed", @"Get result failed alert view") message:NSLocalizedString(@"The app was unable to get the search result", @"Get result failed alert view")];
                        [notice show];
           
                    }];
                    
                    self.currentGetRequest = resultRequest;
                    self.currentPostRequest = nil;
                    
                    [resultRequest startAsynchronous];
                }
                
            }];
            
            [searchRequest setFailedBlock:^{
                //NSError *error = [searchRequest error];
                //NSLog(@"2nd failed %@",[error description]);
                [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
                
                //[self removeBaseAlertView];
                //self.currentPostRequest = nil;
                
                self.searchViewWasOnScreen = YES;
                self.captchaViewWasOnScreen = NO;
                [self removeBaseAlertView];
                self.currentPostRequest = nil;
                
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Search failed", @"Search failed alert view") message:NSLocalizedString(@"The app was unable to search for the plate number", @"Search failed alert view")];
                [notice show];

            }];
            
            self.currentGetRequest = nil;
            self.currentPostRequest = searchRequest;
            
            [searchRequest startAsynchronous];
        }
        
    }];
    
    [loginRequest setFailedBlock:^{
        //NSError *error = [loginRequest error];
        //NSLog(@"1nd failed %@",[error description]);
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        
        //[self removeBaseAlertView];
        //self.currentPostRequest = nil;
        
        self.searchViewWasOnScreen = YES;
        self.captchaViewWasOnScreen = NO;
        [self removeBaseAlertView];
        self.currentPostRequest = nil;
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Login failed", @"Login failed alert view") message:NSLocalizedString(@"The app was unable to login into the web service", @"Login failed alert view")];
        [notice show];

    }];
    
    [self showBaseAlertView];
    self.currentGetRequest = nil;
    self.currentPostRequest = loginRequest;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(1);
        [loginRequest startAsynchronous];
        [loginRequest release];
    });
}

- (void) viacarGetCookie {
    [ASIHTTPRequest clearSession];
    [ASIHTTPRequest setSessionCookies:nil];
    [ASIHTTPRequest setDefaultTimeOutSeconds: 180];
        
    if ((!self.numberLabel.text) || ([self.numberLabel.text length] == 0)) 
	{
		//TEST CODE WO NETWORK
        
        WBInfoNoticeView *notice = [WBInfoNoticeView infoNoticeInWindow:NSLocalizedString(@"No car number entered", @"No car number entered alert view") message:NSLocalizedString(@"You must enter a car number to proceed", @"No car number entered alert view")];
        [notice show];
        
		return;
	}
    
    [self setViacarCarNumber: self.numberLabel.text];
    [self setViacarCanton: self.cantonCode];
    
    if (!viacarCarNumber) return; if (!viacarCanton) return;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"https://www.viacar.ch/eindex/login.aspx?kanton=%@", viacarCanton]];
    __block ASIHTTPRequest *cookieRequest = [[ASIHTTPRequest requestWithURL:url] retain];
    [cookieRequest setDelegate:self];
    [cookieRequest setUseCookiePersistence:NO];
    [cookieRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
    [cookieRequest setRequestMethod:@"GET"];
    //[cookieRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
    [cookieRequest addRequestHeader:@"Host" value:@"www.viacar.ch"];
    [cookieRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14"];
    [cookieRequest addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [cookieRequest addRequestHeader:@"Accept-Language" value:@"de-de"];
    [cookieRequest addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    [cookieRequest addRequestHeader:@"Connection" value:@"keep-alive"];
    
    //NSLog(@"%@", [cookieRequest requestHeaders]);
    
    [cookieRequest setCompletionBlock:^{
        NSString *responseString = [cookieRequest responseString];
        //NSLog(@"Response: %@", responseString);
        //NSLog(@"%@", [cookieRequest responseHeaders]);
        
        NSString *cookieString = [[cookieRequest responseHeaders] objectForKey:@"Set-Cookie"];
        //NSLog(@"Set-Cookie: %@", cookieString);
        
        NSTextCheckingResult *sessionIDMatch = RegexMatch(CreateRegex(@"ASP.NET_SessionId=(.+?); "), cookieString);
        if (sessionIDMatch) { self.viacarSessionID = GetMatchString(sessionIDMatch, cookieString);
            //NSLog(@"Session ID: %@", self.viacarSessionID);
        }
        
        NSTextCheckingResult *indIDMatch = RegexMatch(CreateRegex(@"ViaInd(.+?); "), cookieString);
        if (indIDMatch) {
            NSString *tempString = GetMatchString(indIDMatch, cookieString);
            self.viacarIndID = [NSString stringWithFormat: @"%@%@", @"ViaInd", tempString];
            //NSLog(@"Ind ID: %@", self.viacarIndID);
        }
        
        NSTextCheckingResult *inputFieldMatch = RegexMatch(CreateRegex(@"input name=\"(.*)\" type=\"text\""), responseString);
        if (inputFieldMatch) { self.viacarInputFieldName = GetMatchString(inputFieldMatch, responseString);
            //NSLog(@"Input: %@", self.viacarInputFieldName);
        }
        
        NSTextCheckingResult *jpegIDMatch = RegexMatch(CreateRegex(@"\"JpegGenerate.aspx.ID=(.+?)\""), responseString);
        if (jpegIDMatch) { self.viacarJpegID = GetMatchString(jpegIDMatch, responseString);
            //NSLog(@"Jpeg id: %@", self.viacarJpegID);
        }
        
        NSTextCheckingResult *viewStateMatch = RegexMatch(CreateRegex(@"name=\"__VIEWSTATE\" .* value=\"(.*)\""), responseString);
        if (viewStateMatch) { self.viacarViewState = GetMatchString(viewStateMatch, responseString);
            //NSLog(@"viewstate: %@", self.viacarViewState);
        }
        
        NSTextCheckingResult *evenValidationMatch = RegexMatch(CreateRegex(@"name=\"__EVENTVALIDATION\" .* value=\"(.*)\""), responseString);
        if (evenValidationMatch) { self.viacarEventValidation = GetMatchString(evenValidationMatch, responseString);
            //NSLog(@"eventvalidation: %@", self.viacarEventValidation);
        }
        
        NSURL *jpegUrl = [NSURL URLWithString: [NSString stringWithFormat: @"https://www.viacar.ch/eindex/JpegGenerate.aspx?ID=%@", self.viacarJpegID]];
        
        __block ASIHTTPRequest *captchaRequest = [ASIHTTPRequest requestWithURL: jpegUrl];
        [captchaRequest setDelegate:self]; [captchaRequest setUseCookiePersistence:NO]; [captchaRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
        [captchaRequest setRequestMethod:@"GET"];
        //[captchaRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
        [captchaRequest addRequestHeader:@"Host" value:@"www.viacar.ch"];
        //[captchaRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
        [captchaRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14"];
        [captchaRequest addRequestHeader:@"Accept" value:@"*/*"];
        [captchaRequest addRequestHeader:@"Referer" value:[NSString stringWithFormat: @"https://www.viacar.ch/eindex/login.aspx?kanton=%@", self.viacarCanton]];
        [captchaRequest addRequestHeader:@"Accept-Language" value:@"de-de"];
        [captchaRequest addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate"];
        [captchaRequest addRequestHeader:@"Connection" value:@"keep-alive"];
        /*
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
        NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter release];
        */
        //NSString *requestCookie = [[NSString stringWithFormat: @"ASP.NET_SessionId=%@", self.viacarSessionID] stringByAppendingString: [NSString stringWithFormat: @"; ViaInd%@=Anzahl=0&Date=%@&de-CH=de-CH", self.viacarCanton, currentDate]];
        
        NSString *requestCookie = [[NSString stringWithFormat: @"ASP.NET_SessionId=%@; ", self.viacarSessionID]stringByAppendingString: self.viacarIndID];
        
        [captchaRequest addRequestHeader:@"Cookie" value:requestCookie];
        
        //NSLog(@"Request cookie: %@", requestCookie);
        //NSLog(@"%@", [captchaRequest requestHeaders]);
        
        [captchaRequest setCompletionBlock:^{
            
            //NSLog(@"Picture received and set");
            
            //NEW
            //NSLog(@"Disable searchViewWasOnScreen");
            
            self.searchViewWasOnScreen = NO; 
            
            [self removeBaseAlertView];
            self.currentGetRequest = nil;
            
            NSData *responseData = [captchaRequest responseData];
            UIImage *tempCaptchaImage = [UIImage imageWithData:responseData];
            [captchaImage setImage: tempCaptchaImage]; 
            
            //self.captchaViewWasOnScreen = YES;
            //self.searchViewWasOnScreen = NO;
            
            [self moveCaptchaViewOnScreen];
            
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        }];
        [captchaRequest setFailedBlock:^{
            //NSError *error = [captchaRequest error];
            //NSLog(@"2nd failed %@",[error description]);
            
            [self removeBaseAlertView];
            self.currentGetRequest = nil;
            
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
            
            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Get captcha failed", @"Get captcha failed alert view") message:NSLocalizedString(@"The app was unable to get the captcha from the web service", @"Get captcha failed alert view")];
            [notice show];

        }];
        
        self.currentGetRequest = captchaRequest;
        self.currentPostRequest = nil;
        
        [captchaRequest startAsynchronous];
    }];
    [cookieRequest setFailedBlock:^{
        //NSError *error = [cookieRequest error];
        //NSLog(@"1st failed %@",[error description]);
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        
        [self removeBaseAlertView];
        self.currentGetRequest = nil;
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Get cookie failed", @"Get cookie step failed alert view")
                                                                 message:NSLocalizedString(@"The app was unable to get the cookie from the web service", @"Get cookie step failed alert view")];
        [notice show];

    }];
    
    [self showBaseAlertView];
    self.currentGetRequest = cookieRequest;
    self.currentPostRequest = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(1);
        [cookieRequest startAsynchronous];
        [cookieRequest release];
    });
}


#pragma mark - Results table view functions

- (BOOL)checkVisibilityOfCell:(NSIndexPath *)indexPath {
    
    CGRect cellRect = [resultTableView rectForRowAtIndexPath:indexPath];
    cellRect = [resultTableView convertRect:cellRect toView:resultTableView.superview];
    BOOL completelyVisible = CGRectContainsRect(resultTableView.frame, cellRect);
    return completelyVisible;
}

-(BOOL)isRowZeroVisible:(NSIndexPath *)indexPath {
    NSArray *indexes = [resultTableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if ([index isEqual: indexPath]) {
            return YES;
        }
    }
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    int scrollDirection;
    if (lastContentOffset > scrollView.contentOffset.y)
        scrollDirection = DOWN;
    else if (lastContentOffset < scrollView.contentOffset.y) 
        scrollDirection = UP;
    lastContentOffset = scrollView.contentOffset.y;
    
    //NSLog(@"Scroll direction: %@", (scrollDirection == UP)?@"UP":@"DOWN");
    
    if (self.controlRowIndexPath) {
        if (scrollDirection == UP) {
            NSIndexPath *dataRowIndexPath = [NSIndexPath indexPathForRow: [self modelRowforRow: self.controlRowIndexPath.row] inSection: self.controlRowIndexPath.section];    
            
            PersonSearchResultCell *personCell = (PersonSearchResultCell *)[resultTableView cellForRowAtIndexPath: dataRowIndexPath];
            
            if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
                
                //NSLog(@"Scrolling up: delete control box, personCell not there anymore");
                
                NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:self.controlRowIndexPath.row inSection:self.controlRowIndexPath.section];
                
                self.tappedIndexPath = nil;
                self.controlRowIndexPath = nil;
                
                if(indexPathToDelete.row != 0){
                    [resultTableView beginUpdates];
                    [resultTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
                    [resultTableView endUpdates];
                }
            }
            
            if (![self checkVisibilityOfCell: dataRowIndexPath]) {
                
                //NSLog(@"Scrolling up: delete control box, personCell not visible anymore");
                
                NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:self.controlRowIndexPath.row inSection:self.controlRowIndexPath.section];
                
                self.tappedIndexPath = nil;
                self.controlRowIndexPath = nil;
                
                if(indexPathToDelete.row != 0){
                    [resultTableView beginUpdates];
                    [resultTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
                    [resultTableView endUpdates];
                }
            }
        }
        
        if (scrollDirection == DOWN) {
            if (![self checkVisibilityOfCell: self.controlRowIndexPath]) {
                //NSLog(@"Scrolling down: controlBox is not visible");
                
                NSIndexPath *dataRowIndexPath = [NSIndexPath indexPathForRow: [self modelRowforRow: self.controlRowIndexPath.row] inSection: self.controlRowIndexPath.section];    
                
                PersonSearchResultCell *personCell = (PersonSearchResultCell *)[resultTableView cellForRowAtIndexPath: dataRowIndexPath];
                if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
                    NSLog(@"Abnormal result: scroll view did scroll: scrolling down: check personcell if runBounceNoAnimation exists");
                    return;
                }
                
                //NSLog(@"Persons name: %@", personCell.nameLabel.text);
                
                if (![self checkVisibilityOfCell: dataRowIndexPath]) {
                    //NSLog(@"Person cell before control box is not visible");
                    //NSLog(@"Scroll down: delete control box");
                    
                    NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:self.controlRowIndexPath.row inSection:self.controlRowIndexPath.section];
                    
                    self.tappedIndexPath = nil;
                    self.controlRowIndexPath = nil;
                    
                    if(indexPathToDelete.row != 0){
                        [resultTableView beginUpdates];
                        [resultTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
                        [resultTableView endUpdates];
                    }
                    
                } else {
                    //NSLog(@"Person cell before control box is visible");
                }
            } else {
                //NSLog(@"Scrolling down: controlBox is visible");
            }
        }
    }
}

- (NSIndexPath *)modelIndexPathforIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"ModelIndexPathForIndexPath enter: %d", indexPath.row);
    
    int whereIsTheControlRow = self.controlRowIndexPath.row;
    if(self.controlRowIndexPath != nil && indexPath.row > whereIsTheControlRow)
        return [NSIndexPath indexPathForRow:indexPath.row - 1 inSection: [indexPath section]]; 
    return indexPath;
}

- (int)modelRowforRow:(int)row
{    
    int whereIsTheControlRow = self.controlRowIndexPath.row;
    if(self.controlRowIndexPath != nil && row >= whereIsTheControlRow)
        return row - 1; 
    return row;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{

    #ifdef kLoggingIsOn
        //NSLog(@"Ownerstable: numberOfRowsInSection: enter");
    #endif
	        
    if(self.controlRowIndexPath) {
        
        #ifdef kLoggingIsOn
            NSLog(@"Ownerstable: numberOfRowsInSection with controlbox: %d", [ownersList count] + 1);
        #endif
        
        return [ownersList count] + 1;
    }
    
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: numberOfRowsInSection: %d", [ownersList count]);
    #endif
    
    return [ownersList count];
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIImageView *headerImageView = [[[UIImageView alloc] initWithImage: [UIImage imageNamed: @"OwnerRowTopMarker.png"]] autorelease];
    CGRect tempFrame = headerImageView.frame;
    tempFrame.size.height = tempFrame.size.height - 2;
    
    UIView *headerView = [[[UIView alloc] initWithFrame: tempFrame] autorelease];
    [headerView addSubview: headerImageView];
    
    UIButton *cancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    //UIImage *buttonBackgroundImage = [UIImage imageNamed:@"OwnerRowTopMarkerButton.png"];
    UIImage *buttonBackgroundImage = [UIImage imageNamed:@"OwnerRowTopMarkerCancelButton.png"];
    
    [cancelButton setFrame: CGRectMake(7, 7, buttonBackgroundImage.size.width, buttonBackgroundImage.size.height)];
    [cancelButton setBackgroundImage: buttonBackgroundImage forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(moveResultsViewOffScreen) forControlEvents:UIControlEventTouchUpInside];
 
    [headerView addSubview: cancelButton];
    
    //CGRect headerViewFrame = CGRectMake(0.0, 0.0, self.resultTableView.bounds.size.width, headerView.bounds.size.height);
    //CGRect headerViewFrame = CGRectMake(0.0, 0.0, 320.0, 33.0);    
    //headerView.frame = headerViewFrame;
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: cellForRowAtIndexPath: enter: row: %d", indexPath.row);
    #endif
    
    if (self.controlRowIndexPath) {
        
        if ([indexPath isEqual:self.controlRowIndexPath]) {
            
            #ifdef kLoggingIsOn
                NSLog(@"Ownerstable: cellForRowAtIndexPath: returning control cell: %d", self.controlRowIndexPath.row);
            #endif
            
            static NSString *CellIdentifierControl = @"ControlCell";
            
            PersonSearchResultControlCell *cellControl = (PersonSearchResultControlCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierControl];
            if (cellControl == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"PersonSearchResultControlCell" owner:self options:nil];
                cellControl = controlCell;
                self.controlCell = nil;
            }
            /*
            NSIndexPath *offIndexPath = [self modelIndexPathforIndexPath: indexPath];
            
            NSCharacterSet *csDecResult = [NSCharacterSet characterSetWithCharactersInString:@"|"];
            NSArray *splitOwnersRow = [[ownersList objectAtIndex: [offIndexPath row]] componentsSeparatedByCharactersInSet: csDecResult];
            if ([self checkIfEntryExistsinDB: [splitOwnersRow objectAtIndex: 3]])
            {
                [cellControl setupAlreadySaveState: YES];
            } else {
                [cellControl setupAlreadySaveState: NO];
            }
            */
            //[cellControl rearrangeButtons];
            [cellControl setupAsSearchResultsControlBox];
            
            cellControl.rowNumber = self.controlRowIndexPath.row;
            cellControl.controlCellDelegate = self;
            
            #ifdef kLoggingIsOn
                NSLog(@"Ownerstable: cellForRowAtIndexPath: control cell return");
            #endif
            
            return cellControl;
        }
    }
    
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: cellForRowAtIndexPath: returning normal cell: %d", indexPath.row);
    #endif
    
    static NSString *CellIdentifierOwner = @"OwnerCell";
    
    PersonSearchResultCell *cell = (PersonSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierOwner];
    if (cell == nil) {
        
        #ifdef kLoggingIsOn
            NSLog(@"Ownercell is nil, alloc from scratch");
        #endif
        
        [[NSBundle mainBundle] loadNibNamed:@"PersonSearchResultCell" owner:self options:nil];
        cell = tableCell;
        self.tableCell = nil;
    }
    
    NSIndexPath *offsetIndexPath = [self modelIndexPathforIndexPath: indexPath];
    NSCharacterSet *csDecResult = [NSCharacterSet characterSetWithCharactersInString:@"|"];
	NSArray *splitOwnersRow = [[ownersList objectAtIndex: [offsetIndexPath row]] componentsSeparatedByCharactersInSet: csDecResult];
	
    //NSLog(@"results rows: %d", [ownersList count]);
    
	if (([splitOwnersRow count] != 6) && ([splitOwnersRow count] != 7)) 
	{
		NSLog(@"Error in owners list decoding");
		return cell;
	}
    
    //NSLog(@"split rows: %d", [splitOwnersRow count]);
    
    cell.cantonLabel.text = [splitOwnersRow objectAtIndex: 0];
    cell.numberLabel.text = [splitOwnersRow objectAtIndex: 1];
    
    //cell.numberLabel.text = [NSString stringWithFormat: @"%@ - %@", [splitOwnersRow objectAtIndex: 0], [splitOwnersRow objectAtIndex: 1]];
    cell.nameLabel.text = [splitOwnersRow objectAtIndex: 3];
    cell.addressLabel.text = [splitOwnersRow objectAtIndex: 4];
    cell.plzplaceLabel.text = [splitOwnersRow objectAtIndex: 5];
    //cell.phoneLabel.text = @"DUMMY NUMBER";
    cell.cantonImage.image = [UIImage imageNamed: [splitOwnersRow objectAtIndex: 2]];
    cell.latitude = [NSNumber numberWithInt: 0];
    cell.longitude = [NSNumber numberWithInt: 0];
    cell.cantonCode = [splitOwnersRow objectAtIndex: 0];
    cell.flagName = [splitOwnersRow objectAtIndex: 2];
    cell.carNumber = [splitOwnersRow objectAtIndex: 1];
    
    if ([splitOwnersRow count] == 7) {
        if ([[splitOwnersRow objectAtIndex: 6] isEqualToString: @"K"]) {
            cell.catType = @"CatBike.png";
            cell.typeImage.image = [UIImage imageNamed: @"CatBike.png"];
        } else if ([[splitOwnersRow objectAtIndex: 6] isEqualToString: @"LV"]) {
            cell.catType = @"CatTractor.png";
            cell.typeImage.image = [UIImage imageNamed: @"CatTractor.png"];
        } else if ([[splitOwnersRow objectAtIndex: 6] isEqualToString: @"Schiff"]) {
            cell.catType = @"CatShip.png";
            cell.typeImage.image = [UIImage imageNamed: @"CatShip.png"];
        } else if ([[splitOwnersRow objectAtIndex: 6] isEqualToString: @"L"]) {
            cell.catType = @"CatCar.png";
            cell.typeImage.image = [UIImage imageNamed: @"CatCar.png"];
        } else if ([[splitOwnersRow objectAtIndex: 6] isEqualToString: @"H"]) {
            cell.catType = @"CatCar.png";
            cell.typeImage.image = [UIImage imageNamed: @"CatCar.png"];
        } else if ([[splitOwnersRow objectAtIndex: 6] isEqualToString: @"M"]) {
            cell.catType = @"CatMoped.png";
            cell.typeImage.image = [UIImage imageNamed: @"CatMoped.png"];
        } else {
            cell.catType = @"CatQuestionMark.png";
            cell.typeImage.image = [UIImage imageNamed: @"CatQuestionMark.png"];
        }
    } else {
        cell.catType = @"CatQuestionMark.png";
        cell.typeImage.image = [UIImage imageNamed: @"CatQuestionMark.png"];
    }
    
    cell.currentNavigationController = self.navigationController;
    
    //cell.locateOwnerOnMapDelegate = self;
    cell.phoneNumberResolvingResultDelegate = self;
    cell.rowNumber = indexPath.row;    
    
    //[cell setPhoneNumberTestCode];
    
    if (self.phoneNumberCache) {
        
        #ifdef kLoggingIsOn
            NSLog(@"Cell setttings: phone number cache is there");
        #endif
        
        if ([self.phoneNumberCache objectForKey: [NSNumber numberWithInt: indexPath.row]]) {
            
            #ifdef kLoggingIsOn
                NSLog(@"Set number %@ from cache for row %d", [self.phoneNumberCache objectForKey: [NSNumber numberWithInt: indexPath.row]], indexPath.row);
            #endif
            
            [cell setPhoneNumberAndArrageButtons: [self.phoneNumberCache objectForKey: [NSNumber numberWithInt: indexPath.row]]];
            [cell hidePhoneSearchActivityIndicators];
        } else {
            
            #ifdef kLoggingIsOn
                NSLog(@"Resolve phone number");
            #endif
            
            [cell startPhoneNumberResolving];
        }
    } else {
        
        #ifdef kLoggingIsOn
            NSLog(@"Resolve phone number");
        #endif
        
        [cell startPhoneNumberResolving];
    }

    if ([self checkIfEntryExistsinDB: cell.nameLabel.text]) 
    {
        [cell rearrangeDBRibbonAndShadow: YES];
    } else {
        [cell rearrangeDBRibbonAndShadow: NO];
    }
    
    #ifdef kLoggingIsOn
        //NSLog(@"Ownerstable: cellForRowAtIndexPath: return");
    #endif
    
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: didSelectRowAtIndexPath: enter: %d", indexPath.row);
    #endif    
    
    if (self.controlRowIndexPath) {
        if ([indexPath isEqual:self.controlRowIndexPath]) {
            //NSLog(@"Did select cell: is control cell. return");
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            return;
        }
    }
    
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if([indexPath isEqual:self.tappedIndexPath]){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
        
    //update the indexpath if needed... I explain this below 
    indexPath = [self modelIndexPathforIndexPath:indexPath];
    
    NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:self.controlRowIndexPath.row inSection:self.controlRowIndexPath.section];
    
    
    //if in fact I tapped the same row twice lets clear our tapping trackers 
    if([indexPath isEqual:self.tappedIndexPath]){
        
        #ifdef  kLoggingIsOn
            NSLog(@"User tapped same row. Clean up: %d", indexPath.row);
        #endif
        
        self.tappedIndexPath = nil;
        self.controlRowIndexPath = nil;
        
        /*
         NSInteger sectionsAmount = [tableView numberOfSections];
         NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
         if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
         // This is the last cell in the table
         NSLog(@"This is the last row in the table without box set");
         } 
         */ 
    }
    //otherwise let's update them appropriately 
    else {
        
        //self.tappedIndexPath = indexPath; //the row the user just tapped. 
        //Now I set the location of where I need to add the dummy cell 
        self.controlRowIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1   inSection:indexPath.section];

        /*
         NSInteger sectionsAmount = [tableView numberOfSections];
         NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
         if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
         // This is the last cell in the table
         NSLog(@"This is the last row in the table with box set");
         }
         */
        
        self.tappedIndexPath = indexPath; //the row the user just tapped.
    }
    
    //all logic is done, lets start updating the table
    [tableView beginUpdates];
    
    #ifdef  kLoggingIsOn
        NSLog(@"Ownerstable: didSelectRowAtIndexPath: beginUpdates");
    #endif
    
    if(indexPathToDelete.row != 0){
        
        #ifdef  kLoggingIsOn
            NSLog(@"Ownerstable: didSelectRowAtIndexPath: delete controlbox: %d", indexPathToDelete.row);
        #endif
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    //lets add the new control cell in the right place 
    if(self.controlRowIndexPath){
        
        #ifdef kLoggingIsOn
            //NSLog(@"Ownerstable: didSelectRowAtIndexPath: control box is set");
            NSLog(@"Ownerstable: didSelectRowAtIndexPath: add controlbox: %d", self.controlRowIndexPath.row);
        #endif 
        
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.controlRowIndexPath] 
                         withRowAnimation:UITableViewRowAnimationNone];
    }
    
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: didSelectRowAtIndexPath: endUpdates");
    #endif
    
    [tableView endUpdates];
    
    if (self.controlRowIndexPath) {
        
        //[tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: self.controlRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        NSInteger sectionsAmount = [tableView numberOfSections];
        NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
        if ([self.controlRowIndexPath section] == sectionsAmount - 1 && [self.controlRowIndexPath row] == rowsAmount - 1) {
            // This is the last cell in the table
            // NSLog(@"This is the last row in the table with box set");
            [resultTableView scrollToRowAtIndexPath: self.controlRowIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  
    // Note: Some operations like calling [tableView cellForRowAtIndexPath:indexPath]  
    // will call heightForRow and thus create a stack overflow  
    
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: heightForRowAtIndexPath: enter: %d", indexPath.row);
    #endif
    
    if([indexPath isEqual:self.controlRowIndexPath]){
        return 49; //height for control cell
    }
    
    return  83;
} 


- (void) callOwnerAction:(int)rowEntry {
    //NSLog(@"callOwnerAction: %d", rowEntry);
    
    int offsetRow = [self modelRowforRow: rowEntry];    
    NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow: offsetRow inSection: 0];
    
    NSString *deviceType = [NSString stringWithString: [self machineName]];
    
    #ifdef  kLoggingIsOn
        NSLog(@"Devicetype: %@", [deviceType substringToIndex: 6]);
    #endif
    
    #ifdef kCheckForiPodServiceRestrictions
    if (![[deviceType substringToIndex: 6] isEqualToString: @"iPhone"]) {
        PersonSearchResultCell *personCell = (PersonSearchResultCell *)[resultTableView cellForRowAtIndexPath: offsetIndexPath];
        if ([personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
            [personCell runBounceNoAnimation];
        } else {
            NSLog(@"Abnormal result: callOwnerAction: runBounceAnimtation on cell");
        }
    }
    #endif
    
    #ifdef kSimulateiPodTouchPresence
    PersonSearchResultCell *personTestCell = (PersonSearchResultCell *)[resultTableView cellForRowAtIndexPath: offsetIndexPath];
    if ([personTestCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        [personTestCell runBounceNoAnimation];
    } else {
        NSLog(@"Abnormal result: callOwnerAction: runBounceAnimtation on cell");
    }
    #endif
    
    PersonSearchResultCell *personCell = (PersonSearchResultCell *)[resultTableView cellForRowAtIndexPath: offsetIndexPath];
    if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        NSLog(@"Abnormal result: callOwnerAction: check personcell if runBounceNoAnimation exists");
        return;
    }
    
    if (personCell.phoneNumberSet) {
        if ([personCell.phoneLabel.text length] != 0) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"tel://%@", personCell.phoneLabel.text]]]; 
        } else {
            [personCell runBounceNoAnimation];[personCell runBounceNoAnimation];
        }
    } else {
        [personCell runBounceNoAnimation];
    }
}

- (BOOL) checkIfEntryExistsinDB: (NSString *) ownersName {
    NSManagedObjectContext *context = [[CoreDataController sharedCoreDataController] managedObjectContext];
    
    CarOwners *ownersInfo = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"CarOwners" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", ownersName];
    
    NSError *error = nil;
    ownersInfo = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !ownersInfo) 
    {
        return NO;
    } else {
        return  YES;
    }
}

- (void) saveCarOwnerAction:(int)rowEntry {
    //NSLog(@"saveCarOwnerAction: %d", rowEntry);
    
    int offsetRow = [self modelRowforRow: rowEntry];    
    NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow: offsetRow inSection: 0];
    
    PersonSearchResultCell *personCell = (PersonSearchResultCell *)[resultTableView cellForRowAtIndexPath: offsetIndexPath];
    if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        NSLog(@"Abnormal result: deleteAction: check personcell if runBounceNoAnimation exists");
        return;
    }   

     NSManagedObjectContext *context = [[CoreDataController sharedCoreDataController] managedObjectContext];
     
     //if (!context) NSLog(@"No context");
     
     if (![self checkIfEntryExistsinDB: personCell.nameLabel.text]) 
     {
         CarOwners *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"CarOwners" inManagedObjectContext:context];
     
         if (!newEntry) NSLog(@"No new entry");
     
         [newEntry setName: personCell.nameLabel.text];
         //[newEntry setCarnumber: personCell.carNumber];
         [newEntry setCarnumber: [NSString stringWithFormat: @"%@;%@", personCell.carNumber, personCell.catType]];
         [newEntry setCantoncode: personCell.cantonCode];
         [newEntry setFlagname: personCell.flagName];
         [newEntry setLatitude: personCell.latitude];
         [newEntry setLongitude: personCell.longitude];
         [newEntry setPlzplace: personCell.plzplaceLabel.text];
         [newEntry setAddress: personCell.addressLabel.text];
     
         //[newEntry setPhonenumber: [phoneLabel text]];
     
     
         if (personCell.phoneNumberSet) {
             [newEntry setPhonenumber: personCell.phoneLabel.text];
         }
         else {
             [newEntry setPhonenumber: @"NONE"];
         }
     
     
         NSError *error;
         if (![context save:&error]) 
         {
             NSLog(@"Error saving new station: %@",[error localizedDescription]);
             return;
         }
     
         WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInWindow: NSLocalizedString(@"Entry saved", @"Entry saved alert view")];
         [notice show];
     
        [personCell rearrangeDBRibbonAndShadow: YES];
     
         //[personCell reloadInputViews];
     
    } else {
     
        if ([personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
            [personCell runBounceNoAnimation];
        } else {
            NSLog(@"Abnormal result: saveCarOwnerAction: runBounceAnimtation on cell");
        }        
    }

}

- (void) locateOwnerOnMapAction:(int)rowEntry {
    //NSLog(@"locateOwnerOnMapAction: %d", rowEntry);
    
    if (!([UIDevice networkAvailable])) 
    {
        //NSLog(@"No network available");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No network", @"No network available alert view title") message:NSLocalizedString(@"There is no WiFi or cellular network available. Please check or try again later.", @"No network available alert view message")];
        [notice show];
        
        return;
    }
    
    int offsetRow = [self modelRowforRow: rowEntry]; 
    //NSLog(@"Model row: %d", offsetRow);
    
    NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow: offsetRow inSection: 0];
    
    PersonSearchResultCell *personCell = (PersonSearchResultCell *)[resultTableView cellForRowAtIndexPath: offsetIndexPath];
    if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        NSLog(@"Abnormal result: locateOwnerOnMap: check personcell if runBounceNoAnimation exists");
    }
    
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName: @"MapViewController" bundle: nil];
    mapViewController.currentPerson = personCell;
    [self presentSemiViewController: mapViewController];
    [mapViewController resolveAddress];
}

- (void) shareOwnerInfoAction:(int)rowEntry {
    //NSLog(@"shareOwnerInfoAction: %d", rowEntry);
    
    int offsetRow = [self modelRowforRow: rowEntry];    
    NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow: offsetRow inSection: 0];
    
    PersonSearchResultCell *personCell = (PersonSearchResultCell *)[resultTableView cellForRowAtIndexPath: offsetIndexPath];
    if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        NSLog(@"Abnormal result: shareOwnerInfoAction: check personcell if runBounceNoAnimation exists");
    }
    
    BCDShareableItem *item = [[BCDShareableItem alloc] initWithTitle:NSLocalizedString(@"Car owner found", @"Found Owner Share Item Title")];
    
    NSString *part1 = NSLocalizedString(@"I found the owner of the license plate ", @"Found Owner Share Item Description Part 1");
    NSString *part2 = NSLocalizedString(@" with Swiss Plates: ", @"Found Owner Share Item Description Part 2");
    NSString *descriptionText = [NSString stringWithFormat: @"%@%@-%@%@%@, %@, %@, %@", part1, personCell.cantonLabel.text, personCell.numberLabel.text, part2, personCell.nameLabel.text, personCell.addressLabel.text, personCell.plzplaceLabel.text, personCell.phoneLabel.text];
    
    NSString *partShort1 = @"";
    NSString *shortDecpriptionText = [NSString stringWithFormat:@"%@%@-%@: %@, %@, %@, %@ %@", partShort1, personCell.cantonLabel.text, personCell.numberLabel.text, personCell.nameLabel.text, personCell.addressLabel.text, personCell.plzplaceLabel.text, personCell.phoneLabel.text, @"(by Swiss Plates)"];
    
    [item setDescription:descriptionText];
    [item setShortDescription:shortDecpriptionText];
    
    [item setItemURLString: AppStoreURLShort];
    
    [item setImageNameFromBundle: kBundleIconImage];
    
    UIActionSheet *sheet = [[BCDShareSheet sharedSharer] sheetForSharing:item iTellAFriend:NO completion:^(BCDResult result) {
        if (result==BCDResultSuccess) {
            
            #ifdef kLoggingIsOn
                NSLog(@"Yay!");
            #endif
        }
    }];
    UIWindow *appWindow = [[UIApplication sharedApplication].windows objectAtIndex: 0];
    [[BCDShareSheet sharedSharer] setRootViewController: appWindow.rootViewController];
    [[BCDShareSheet sharedSharer] setFacebookAppID:kFacebookAppID];
    [[BCDShareSheet sharedSharer] setAppName:kAppName];
    [sheet showInView: self.view];
    [item release];
}

- (void) ownerExistsAlreadyInAddressbook:(NSString *)lastname firstname:(NSString *)firstname successblock:(void (^)(BOOL entryfound))successblock failureblock:(void (^)(NSError *error))failureblock {
    
    if (!lastname || ! firstname) {
        if (failureblock) {
            failureblock(nil);
        }
    }
    
    if (ABAddressBookRequestAccessWithCompletion) {
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    if (failureblock) {
                        failureblock((NSError *)error);
                    }
                } else {
                    BOOL entryfound = NO;
                    
                    if (addressBook != nil)
                    {
                        CFArrayRef arrayOfEntries = ABAddressBookCopyArrayOfAllPeople(addressBook);
                        if (CFArrayGetCount(arrayOfEntries) > 0)
                        {
                            CFIndex countOfEntries = CFArrayGetCount(arrayOfEntries);
                            //NSLog(@"Address book entries: %ld", countOfEntries);
                            
                            for (int x = 0; x < countOfEntries ; x++)
                            {
                                ABRecordRef activeRecord = CFArrayGetValueAtIndex(arrayOfEntries, x);
                                NSString *firstnameEntry = (NSString *) CFBridgingRelease(ABRecordCopyValue(activeRecord, kABPersonFirstNameProperty));
                                //NSLog(@"First name: %@", firstnameEntry);
                                NSString *lastnameEntry = (NSString *) CFBridgingRelease(ABRecordCopyValue(activeRecord, kABPersonLastNameProperty));
                                //NSLog(@"Last name: %@", lastnameEntry);
                                
                                if ([firstnameEntry isEqualToString: firstname] && [lastnameEntry isEqualToString:lastname]) {
                                    entryfound = YES;
                                }
                            }
                        }
                        
                        CFRelease(arrayOfEntries);
                        CFRelease(addressBook);
                    }
                    if (successblock) {
                        successblock(entryfound);
                    }
                }
            });
        });
    }
}

- (void) addOwnerToAdressbookAction:(int)rowEntry {
    //NSLog(@"addOwnerToAdressbookAction: %d", rowEntry);
    
    int offsetRow = [self modelRowforRow: rowEntry];
    NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow: offsetRow inSection: 0];
    
    PersonSearchResultCell *personCell = (PersonSearchResultCell *)[resultTableView cellForRowAtIndexPath: offsetIndexPath];
    if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        NSLog(@"Abnormal result: shareOwnerInfoAction: check personcell if runBounceNoAnimation exists");
    }
    
    NSString *firstname; NSString *lastname;
    NSString *plz; NSString *city;
    
    
    NSArray *nameArray = [personCell.nameLabel.text componentsSeparatedByString: @" "];
    if ([nameArray count] > 1) {
        firstname = [nameArray objectAtIndex: 0];
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity: 1];
        for (int i = 1; i < [nameArray count]; i++) {
            [tempArray addObject: [nameArray objectAtIndex: i]];
        }
        lastname = [tempArray componentsJoinedByString: @" "];
    } else {
        NSLog(@"Abnormal result: Add owner to address book, name could not be split");
        return;
    }
    NSArray *plzplaceArray = [personCell.plzplaceLabel.text componentsSeparatedByString: @" "];
    if ([plzplaceArray count] == 2) {
        plz = [plzplaceArray objectAtIndex: 0];
        city = [plzplaceArray objectAtIndex: 1];
    } else {
        NSLog(@"Abnormal result: Add owner to address book, PLZ and Place could not be split");
        return;
    }
    
    __block BOOL accessGranted = NO;
    CFErrorRef err;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    if (!accessGranted) {
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Address book access denied", @"Addressbook access denied alert view title") message:NSLocalizedString(@"Swiss Plates cannot access the address book. You may allow Swiss Plates to access the address book in the privacy settings in order to save the contact information.", @"Addressbook access denied alert view message")];
        [notice show];
        
        CFRelease(addressBook);
        return;
    }
    
    [self ownerExistsAlreadyInAddressbook:lastname firstname:firstname successblock:^(BOOL entryfound) {
        if (entryfound) {
            if ([personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
                [personCell runBounceNoAnimation];
            } else {
                NSLog(@"Abnormal result: saveCarOwnerAction: runBounceAnimtation on cell");
            }
            
            CFRelease(addressBook);
        } else {
            CFErrorRef error = NULL;
            
            ABRecordRef newPerson = ABPersonCreate();
            ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (firstname), &error);
            ABRecordSetValue(newPerson, kABPersonLastNameProperty, (lastname), &error);
            
            if (personCell.phoneNumberSet) {
                ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                ABMultiValueAddValueAndLabel(multiPhone, (personCell.phoneLabel.text), kABPersonPhoneMainLabel, NULL);
                ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
                CFRelease(multiPhone);
            }
            
            ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
            
            NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
            
            [addressDictionary setObject: personCell.addressLabel.text forKey:(NSString *) kABPersonAddressStreetKey];
            [addressDictionary setObject: city forKey:(NSString *)kABPersonAddressCityKey];
            //[addressDictionary setObject:@"IL" forKey:(NSString *)kABPersonAddressStateKey];
            [addressDictionary setObject: plz forKey:(NSString *)kABPersonAddressZIPKey];
            [addressDictionary setObject:@"ch" forKey:(NSString *)kABPersonAddressCountryCodeKey];
            
            ABMultiValueAddValueAndLabel(multiAddress, (addressDictionary), kABHomeLabel, NULL);
            ABRecordSetValue(newPerson, kABPersonAddressProperty, multiAddress,&error);
            CFRelease(multiAddress);
            
            NSString *carNumberFull = [NSString stringWithFormat: @"%@-%@", personCell.cantonLabel.text, personCell.numberLabel.text];
            
            ABRecordSetValue(newPerson, kABPersonNoteProperty, carNumberFull, &error);
            
            
            ABAddressBookAddRecord(addressBook, newPerson, &error);
            ABAddressBookSave(addressBook, &error);
            
            if (error != NULL) {
                NSLog(@"Error: Entry could not be saved in addressbook!");
                
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Addressbook saving error", @"Addressbook saving error alert view title") message:NSLocalizedString(@"The owner details could not be saved in the addressbook", @"Addressbook saving error alert view message")];
                [notice show];
                
            } else {
                WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInWindow:NSLocalizedString(@"Entry saved in addressbook", @"Entry saved in addressbook alert view")];
                [notice show];
            }
            
            CFRelease(newPerson);
            CFRelease(addressBook);
        }
    } failureblock:^(NSError *error) {
        if ([personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
            [personCell runBounceNoAnimation];
        } else {
            NSLog(@"Abnormal result: saveCarOwnerAction: runBounceAnimtation on cell");
        }
        
        CFRelease(addressBook);
    }];
}


@end
