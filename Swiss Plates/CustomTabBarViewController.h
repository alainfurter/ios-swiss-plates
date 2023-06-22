//
//  CustomTabBarViewController.h
//  Swiss Plates
//
//  Created by Alain Furter on 04.06.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UIDevice-Reachability.h"

#import "ConfigFile.h"

#define SELECTED_VIEW_CONTROLLER_TAG 98456345

#define ANIMATION_DURATION 1.0f
#define FLIP_GAP 60.0f

@interface CustomTabBarViewController : UIViewController <UINavigationControllerDelegate> {
    int visibleViewControllerTag;
    BOOL supportViewVisible;
    BOOL dbViewAvailable;
}

@property (retain, nonatomic) IBOutlet UIView *tabBarView;

@property (strong, nonatomic) UINavigationController *searchNaviController;
@property (strong, nonatomic) UINavigationController *platesNaviController;
@property (retain, nonatomic) IBOutlet UIButton *settingsButton;
@property (retain, nonatomic) IBOutlet UIButton *searchButton;
@property (retain, nonatomic) IBOutlet UIButton *dbButton;
@property (retain, nonatomic) IBOutlet UIButton *cartButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (retain, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (retain, nonatomic) IBOutlet UILabel *badgeCreditsLabel;

- (IBAction)pushSearchViewController:(id)sender;
- (IBAction)pushPlatesViewController:(id)sender;
- (IBAction)pushDownViewController:(id)sender;
- (IBAction)pushBackViewController:(id)sender;

- (void) blockTabBarUI;
- (void) unblockTabBarUI;

@end
