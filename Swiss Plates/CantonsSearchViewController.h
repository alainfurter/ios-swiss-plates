//
//  CantonsSearchViewController.h
//  Swiss Plates
//
//  Created by Alain Furter on 05.06.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import <sys/utsname.h>

#import "ConfigFile.h"

//#define tUseCustomPushPop 1

@class CantonsTableCell;
@class WebSearchViewController;
//@class SupportViewController;

@interface CantonsSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UITableView *cantonsTable;
    NSArray *list;
    CantonsTableCell *tableCell;
    UIImageView *CustomNavigationBar;
    UILabel *customNavigationLabel;
}

@property (nonatomic, retain) IBOutlet UITableView *cantonsTable;
@property (nonatomic, retain) NSArray *list;
@property (nonatomic, assign) IBOutlet CantonsTableCell *tableCell;
@property (nonatomic, retain) IBOutlet UIImageView *CustomNavigationBar;
@property (nonatomic, retain) IBOutlet UILabel *customNavigationLabel;

@end
