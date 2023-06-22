//
//  Swiss_PlatesAppDelegate.h
//  Swiss Plates
//
//  Created by Alain Furter on 04.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "NSString+MD5Addition.h"
#import "BlockAlertView.h"

#import "CustomTabBarViewController.h"
#import "IntroViewController.h"

#import "ConfigFile.h"

@class SplashViewController;
@class  CustomTabBarViewController;

@interface Swiss_PlatesAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, IntroHasFinishedDelegate> {
    CustomTabBarViewController *customTabBarViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) CustomTabBarViewController *customTabBarViewController;
@property (strong, nonatomic) UIViewController *supportViewController;
@property (strong, nonatomic) UIViewController *containerViewController;

-(void)handleUserInfo:(NSDictionary*)userInfo;

@end
