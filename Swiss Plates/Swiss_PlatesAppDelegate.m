//
//  Swiss_PlatesAppDelegate.m
//  Swiss Plates
//
//  Created by Alain Furter on 04.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import "Swiss_PlatesAppDelegate.h"

#import "SupportViewController.h"
#import "PlatesViewController.h"

#import "BCDShareSheet.h"
#import "iTellAFriend.h"

@implementation Swiss_PlatesAppDelegate


@synthesize window=_window;
//@synthesize naviController=_naviController;
@synthesize customTabBarViewController=_customTabBarViewController;
@synthesize supportViewController=_supportViewController;
@synthesize containerViewController=_containerViewController;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[url scheme] hasPrefix:@"fb"]) {
        return [[BCDShareSheet sharedSharer] openURL:url];
    } else {
        return NO; // handle any other URLs your app responds to here.
    }
}


-(void)handleUserInfo:(NSDictionary*)userInfo
{
    #ifdef  kLoggingIsOn
        NSLog(@"Handle remote notification: %@", userInfo);
    #endif
    
    NSString *alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Swiss Plates News", @"Swiss Plates News Remote Notification Title")
                                                    message: alertValue
                                                   delegate: nil
                                          cancelButtonTitle: NSLocalizedString(@"Ok", @"Swiss Plates News Remote Notification Button")
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];

}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{     
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];

    if (![[NSFileManager defaultManager] fileExistsAtPath: [documentsDirectory stringByAppendingPathComponent: DeviceAlreadyRegisteredForRemoteNotificationFlagfile]])
	{
        [ASIHTTPRequest clearSession];
        [ASIHTTPRequest setSessionCookies:nil];
        [ASIHTTPRequest setDefaultTimeOutSeconds: 180];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
        
        const char *data = [devToken bytes];
		NSMutableString* tokenString = [NSMutableString string];
		
		for (int i = 0; i < [devToken length]; i++) 
		{
			[tokenString appendFormat:@"%02.2hhX", data[i]];
		}
		
        #ifdef  kLoggingIsOn
            NSLog(@"Register with device token: %@",tokenString);
        #endif
        
        NSString *deviceID = [[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
    
        NSString *countryCode = [NSString stringWithString: [[[NSLocale currentLocale] localeIdentifier] stringByEscapingURL]];
        NSString *languageCode = [NSString stringWithString: [[NSLocale preferredLanguages] objectAtIndex:0]];
        
        #ifdef kLoggingIsOn
            NSLog(@"Country code: %@, language: %@", countryCode, languageCode);
        #endif
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://www.zonezeroapps.com/servers/pushnotificationserver/registerDevice.php?appId=%@&deviceToken=%@&deviceId=%@&countryCode=%@&languageCode=%@", AppID, tokenString, deviceID, countryCode, languageCode]];
        __block ASIHTTPRequest *registerDeviceRequest = [ASIHTTPRequest requestWithURL:url];
        [registerDeviceRequest setDelegate:self]; [registerDeviceRequest setUseCookiePersistence:NO]; [registerDeviceRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
        [registerDeviceRequest setRequestMethod:@"GET"];
        [registerDeviceRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"];
        
        [registerDeviceRequest setCompletionBlock:^{
            
            #ifdef  kLoggingIsOn
                NSString *responseString = [registerDeviceRequest responseString];
                NSLog(@"Registered for remote notification response: %@", responseString);
                NSLog(@"Register device token on server - first time");
            #endif
            
            [@"DAR" writeToFile:[documentsDirectory stringByAppendingPathComponent: DeviceAlreadyRegisteredForRemoteNotificationFlagfile] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        }];
        
        [registerDeviceRequest setFailedBlock:^{
            
            #ifdef  kLoggingIsOn
                NSError *error = [registerDeviceRequest error];
                NSLog(@"Registered for remote notification error: %@",[error description]);
            #endif
            
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        }];
        
        [registerDeviceRequest startAsynchronous];
	}
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    #ifdef  kLoggingIsOn
        NSLog(@"Error in registration. Error: %@", err);
    #endif
    
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
	[self handleUserInfo:userInfo];
}

- (void)navigationController:(UINavigationController *)navigationController  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    #ifdef  kLoggingIsOn
        NSLog(@"NaviController willShowViewController delegate: %@, %@", navigationController.title, viewController.nibName);
    #endif
    
    [viewController viewWillAppear:animated];
}

- (void) appLaunchRegisterForRemoteNotifications {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void) appLaunchDeRegisterForRemoteNotifications {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (void) runIntro {
    #ifdef  kLoggingIsOn
        NSLog(@"Show intro");
    #endif
        
    IntroViewController *introViewController = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
    [introViewController setIntroHasFinishedDelegate: self];
    [self.customTabBarViewController presentViewController:introViewController animated:YES completion:nil];
    [introViewController release];
}

- (void) introHasFinished {
    #ifdef kLoggingIsOn
        NSLog(@"IntroHasFinished delegate called");
    #endif
    
    [self appLaunchRegisterForRemoteNotifications];
    //[self appLaunchDeRegisterForRemoteNotifications];
    [Appirater appLaunched:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
                
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    
    #ifdef kLoggingIsOn
        NSString *countryCode = [NSString stringWithString: [[[NSLocale currentLocale] localeIdentifier] stringByEscapingURL]];
        NSString *languageCode = [NSString stringWithString: [[NSLocale preferredLanguages] objectAtIndex:0]];
        NSLog(@"Country code: %@, language: %@", countryCode, languageCode);
    #endif
        
	if(launchOptions)
	{
		NSDictionary *userInfo=[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
		if(userInfo)
			[self handleUserInfo:userInfo];
	};
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor blackColor];
    
    self.containerViewController = [[[UIViewController alloc] init] autorelease];
    self.containerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.containerViewController.view.frame = self.window.bounds;
    self.window.rootViewController = self.containerViewController;
    
    self.supportViewController = [[[SupportViewController alloc] init] autorelease];
    self.supportViewController.view.frame = self.window.bounds;
    [self.containerViewController.view addSubview: self.supportViewController.view];

    self.customTabBarViewController = [[[CustomTabBarViewController alloc] initWithNibName: @"CustomTabBarViewController" bundle: nil] autorelease];
    self.customTabBarViewController.view.frame = self.window.bounds;
    
    [self.containerViewController.view addSubview: self.customTabBarViewController.view];
    
    [self.window makeKeyAndVisible];
    
#ifdef kForceIntroRun
    [self runIntro];
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: [documentsDirectory stringByAppendingPathComponent: @"introrun.plist"]])
	{
        [self runIntro];
        [@"Intro already run" writeToFile:[documentsDirectory stringByAppendingPathComponent: @"introrun.plist"] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    } else {
        [self appLaunchRegisterForRemoteNotifications];
    }
#endif
            
    [iTellAFriend sharedInstance].appStoreID = AppStoreID;
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    //NSLog(@"App will enter foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    //NSLog(@"App did become active");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_window release];
    [_customTabBarViewController release];
    [_supportViewController release];
    [super dealloc];
}

@end
