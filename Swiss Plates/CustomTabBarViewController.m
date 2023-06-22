//
//  CustomTabBarViewController.m
//  Swiss Plates
//
//  Created by Alain Furter on 04.06.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import "CustomTabBarViewController.h"

//#import "SearchViewController.h"
#import "CantonsSearchViewController.h"
#import "PlatesViewController.h"
#import "WebSearchViewController.h"

#import "UINavigationController+PushPopAfterAnimation.h"

@implementation CustomTabBarViewController

@synthesize tabBarView;
@synthesize searchNaviController=_searchNaviController;
@synthesize platesNaviController=_platesNaviController;
@synthesize settingsButton;
@synthesize searchButton;
@synthesize dbButton;
@synthesize cartButton;
@synthesize backButton;
@synthesize arrowImageView;
@synthesize badgeImageView;
@synthesize badgeCreditsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated 
{
    #ifdef kLoggingIsOn
        NSLog(@"CTB: %.1f, %.1f, %.1f, %.1f", self.searchNaviController.view.frame.origin.x, self.searchNaviController.view.frame.origin.y,self.searchNaviController.view.frame.size.width, self.searchNaviController.view.frame.size.height);
        NSLog(@"CTB: %.1f, %.1f, %.1f, %.1f", self.view.frame.origin.x, self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height);
    #endif

    [self.cartButton setHidden: YES];
    [self.badgeImageView setHidden: YES];
    [self.badgeCreditsLabel setHidden: YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden: YES];
    
    CantonsSearchViewController *searchViewController = [[[CantonsSearchViewController alloc] init] autorelease];
    
    searchViewController.title = NSLocalizedString(@"Search", @"Search tab bar title"); 
    //searchViewController.s
    
    self.searchNaviController = [[[UINavigationController alloc] init] autorelease];
    self.searchNaviController = [[[UINavigationController alloc] initWithRootViewController: searchViewController] autorelease];
    
    self.searchNaviController.view.frame = CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height);
    
    [self.searchNaviController setNavigationBarHidden: YES];
    [self.searchNaviController setDelegate: self];
    
    PlatesViewController *platesViewController = [[[PlatesViewController alloc] init] autorelease];
    
    platesViewController.title = NSLocalizedString(@"Plates DB", @"Plates tab bar title"); 
    
    self.platesNaviController = [[[UINavigationController alloc] initWithRootViewController:platesViewController] autorelease];
    
    [self.platesNaviController setNavigationBarHidden: YES];
    [self.platesNaviController setDelegate: self];
    
    self.searchNaviController.view.frame = CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height);
    
    
    self.searchNaviController.view.tag = SELECTED_VIEW_CONTROLLER_TAG;

    [self.view insertSubview:self.searchNaviController.view atIndex: 0];
    
    visibleViewControllerTag = 1;
    
    supportViewVisible = NO;
    dbViewAvailable = NO;
    
    [searchButton setSelected: YES];
    [searchButton setUserInteractionEnabled: NO];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setTabBarView:nil];
    [self setSearchNaviController: nil];
    [self setPlatesNaviController: nil];
    [self setSettingsButton:nil];
    [self setSearchButton:nil];
    [self setDbButton:nil];
    [self setCartButton:nil];
    [self setArrowImageView:nil];
    [self setBackButton:nil];
    [self setBadgeImageView:nil];
    [self setBadgeCreditsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [tabBarView release];
    [_searchNaviController release];
    [_platesNaviController release];
    [settingsButton release];
    [searchButton release];
    [dbButton release];
    [cartButton release];
    [arrowImageView release];
    [backButton release];
    [badgeImageView release];
    [badgeCreditsLabel release];
    [super dealloc];
}

- (void) blockTabBarUI {
    self.settingsButton.userInteractionEnabled = NO;
    self.cartButton.userInteractionEnabled = NO;
    self.searchButton.userInteractionEnabled = NO;
    self.dbButton.userInteractionEnabled = NO;
    
    self.searchButton.alpha = 0;
    [searchButton setEnabled: NO];
    self.dbButton.alpha = 0;
    [dbButton setEnabled: NO];
    self.cartButton.alpha = 0;
    [cartButton setEnabled: NO];
    self.badgeCreditsLabel.alpha = 0;
    self.badgeImageView.alpha = 0;
    self.settingsButton.alpha = 0;
    [self.settingsButton setEnabled: NO];
    
    self.arrowImageView.alpha = 0;

}

- (void) unblockTabBarUI {
    self.settingsButton.userInteractionEnabled = YES;
    self.cartButton.userInteractionEnabled = YES;
    self.searchButton.userInteractionEnabled = YES;
    self.dbButton.userInteractionEnabled = YES;
    
    self.searchButton.alpha = 1;
    [searchButton setEnabled: YES];
    self.dbButton.alpha = 1;
    [dbButton setEnabled: YES];
    self.cartButton.alpha = 1;
    [cartButton setEnabled: YES];
    self.badgeCreditsLabel.alpha = 1;
    self.badgeImageView.alpha = 1;
    self.settingsButton.alpha = 1;
    [self.settingsButton setEnabled: YES];
    
    self.arrowImageView.alpha = 1;
}

- (IBAction)pushSearchViewController:(id)sender {
    
    #ifdef kLoggingIsOn
        NSLog(@"Push search view controller");
    #endif
    
    if (visibleViewControllerTag == 1) return;
    
    UIView *currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];

    //self.searchNaviController.view.frame = CGRectMake(-320,0,self.view.bounds.size.width, self.view.bounds.size.height-(tabBarView.frame.size.height));
    
    self.searchNaviController.view.frame = CGRectMake(-320,0,self.view.bounds.size.width, self.view.bounds.size.height);
    
    
    //self.searchNaviController.view.frame = CGRectMake(-320,44,320, 460);
    
    self.searchNaviController.view.tag = SELECTED_VIEW_CONTROLLER_TAG;
    
    [self.view insertSubview:self.searchNaviController.view atIndex: 0];
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         currentView.transform=CGAffineTransformMakeTranslation(0, 0);
                         arrowImageView.transform =CGAffineTransformMakeTranslation(0, 0);
                         self.searchNaviController.view.transform=CGAffineTransformMakeTranslation(0, 0);
                     }
                     completion:^(BOOL finished){
                         [currentView removeFromSuperview];
                         
                     }];
    
    [UIView commitAnimations];
    
    visibleViewControllerTag = 1;
    [searchButton setSelected: YES];
    [dbButton setSelected: NO];
    
    [searchButton setUserInteractionEnabled: NO];
    [dbButton setUserInteractionEnabled: YES];
    
    [dbButton setEnabled: YES];
}

- (IBAction)pushPlatesViewController:(id)sender {
    
    #ifdef kLoggingIsOn
        NSLog(@"Push plates view controller");
    #endif
    
    if (visibleViewControllerTag == 2) return;
    
    UIView *currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];

    //self.platesNaviController.view.frame = CGRectMake(320,0,self.view.bounds.size.width, self.view.bounds.size.height-(tabBarView.frame.size.height));
    
    self.platesNaviController.view.frame = CGRectMake(320,0,self.view.bounds.size.width, self.view.bounds.size.height);
    
    self.platesNaviController.view.tag = SELECTED_VIEW_CONTROLLER_TAG;

    [self.view insertSubview:self.platesNaviController.view atIndex: 0];
  
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         currentView.transform=CGAffineTransformMakeTranslation(-320, 0);
                         arrowImageView.transform =CGAffineTransformMakeTranslation(45, 0);
                         self.platesNaviController.view.transform=CGAffineTransformMakeTranslation(-320, 0);
                     }
                     completion:^(BOOL finished){
                         [currentView removeFromSuperview];
                         
                     }];
    
    [UIView commitAnimations];
    
    visibleViewControllerTag = 2;
    [searchButton setSelected: NO];
    [dbButton setSelected: YES];
    
    [searchButton setUserInteractionEnabled: YES];
    [dbButton setUserInteractionEnabled: NO];
}

- (IBAction)pushDownViewController:(id)sender {
    
    #ifdef kLoggingIsOn
        NSLog(@"Push down view controller");
    #endif
    
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         if (!supportViewVisible) {
                             
                             #ifdef kLoggingIsOn
                                NSLog(@"Down");
                             #endif
                             
                             supportViewVisible = YES;
                             self.view.transform=CGAffineTransformMakeTranslation(0, self.view.frame.size.height - TOOLBARHEIGHT);
                             
                             self.searchButton.alpha = 0;
                             [searchButton setEnabled: NO];
                             self.dbButton.alpha = 0;
                             [dbButton setEnabled: NO];
                             self.cartButton.alpha = 0;
                             [cartButton setEnabled: NO];
                             self.badgeCreditsLabel.alpha = 0;
                             self.badgeImageView.alpha = 0;
                             
                             self.arrowImageView.alpha = 0;
                             
                         } else {
                             
                             #ifdef kLoggingIsOn
                                NSLog(@"Up");
                             #endif
                             
                             supportViewVisible = NO;
                             self.view.transform=CGAffineTransformMakeTranslation(0, 0);
                             
                             self.searchButton.alpha = 1;
                             [searchButton setEnabled: YES];
                             self.dbButton.alpha = 1;
                             [dbButton setEnabled: YES];
                             self.cartButton.alpha = 1;
                             [cartButton setEnabled: YES];
                             self.badgeCreditsLabel.alpha = 1;
                             self.badgeImageView.alpha = 1;
                             
                             self.arrowImageView.alpha = 1;
                         }
                     }
                     completion:^(BOOL finished){
                         if (supportViewVisible) {
                            
                             [settingsButton setBackgroundImage: [UIImage imageNamed: @"TbSettingsBackOn.png"] forState: UIControlStateNormal];
                             [settingsButton setBackgroundImage: [UIImage imageNamed: @"TbSettingsBackHighlighted.png"] forState: UIControlStateHighlighted];
                             
                         } else {
                             
                             [settingsButton setBackgroundImage: [UIImage imageNamed: @"TbSettingsOff.png"] forState: UIControlStateNormal];
                             [settingsButton setBackgroundImage: [UIImage imageNamed: @"TbSettingsHighlighted.png"] forState: UIControlStateHighlighted];
                             
                         }
                     }];
    [UIView commitAnimations];
}

- (IBAction)pushBackViewController:(id)sender {
    if (visibleViewControllerTag == 1) {
        if ([self.searchNaviController.visibleViewController isKindOfClass: [WebSearchViewController class]]) {
            WebSearchViewController *currentViewController = (WebSearchViewController *) self.searchNaviController.visibleViewController;
            
            //UIView *currentView = currentViewController.searchView;
            
            [self.searchNaviController popViewControllerAfterAnimationAnimated: currentViewController
                                                                      animated: YES 
                                                                animationBlock:^{
                                                                    
                                                                     //NSLog(@"SV: %.1f, %.1f, %.1f, %.1f", currentView.frame.origin.x, currentView.frame.origin.y,currentView.frame.size.width, currentView.frame.size.height);
                                                                    
                                                                    currentViewController.searchView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
                                                                    
                                                                    //NSLog(@"SV: %.1f, %.1f, %.1f, %.1f", currentView.frame.origin.x, currentView.frame.origin.y,currentView.frame.size.width, currentView.frame.size.height);
                                                                }];
        } else {
             [self.searchNaviController popViewControllerAnimated: YES];
        }
    } else {
        [self.platesNaviController popViewControllerAnimated: YES];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{    
    #ifdef kLoggingIsOn
        NSLog(@"NavigationController did show view: %@, %@", navigationController.title, viewController.nibName);
    #endif
    
    if ([viewController isKindOfClass: [CantonsSearchViewController class]] || [viewController isKindOfClass: [PlatesViewController class]]) {
        
        #ifdef kLoggingIsOn
            NSLog(@"Is Cantons or Plates View Controller");
        #endif
        
    } else {
        
        #ifdef kLoggingIsOn
            NSLog(@"Is NOT Cantons or Plates View Controller");
        #endif
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

@end
