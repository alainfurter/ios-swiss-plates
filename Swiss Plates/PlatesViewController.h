//
//  PlatesViewController.h
//  Swiss Plates
//
//  Created by Alain Furter on 04.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>

#import "CoreDataController.h"
#import "CarOwners.h"

#import "PersonSearchResultCell.h"
#import "PersonSearchResultControlCell.h"
#import "MapViewController.h"

#import "BCDShareSheet.h"
#import "BCDShareableItem.h"
#import "WBSuccessNoticeView.h"
#import "WBInfoNoticeView.h"
#import "WBErrorNoticeView.h"

#import "UIViewController+KNSemiModal.h"
#import "UIDevice-Reachability.h"

#import <sys/utsname.h>

#define kSemiModalAnimationDuration   0.5

@class PersonSearchResultCell;
@class PersonSearchResultControlCell;
@class PlatesDBShowDetailViewController;
@class MapViewController;

@interface PlatesViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, ControlCellDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    UITableView *ownersTable;
    PersonSearchResultCell *tableCell;
    PersonSearchResultControlCell *controlCell;
        
    UIButton *editButton;
    
    NSUInteger sectionInsertCount;
    
    NSIndexPath *controlRowIndexPath;
    NSIndexPath *tappedIndexPath;
    
    int lastContentOffset;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UITableView *ownersTable;
@property (nonatomic, assign) IBOutlet PersonSearchResultCell *tableCell;
@property (nonatomic, assign) IBOutlet PersonSearchResultControlCell *controlCell;
@property (nonatomic, retain) IBOutlet UIButton *editButton;

@property (nonatomic, retain) NSIndexPath *controlRowIndexPath;
@property (nonatomic, retain) NSIndexPath *tappedIndexPath;

@property (retain, nonatomic) UIImageView *emptyImageView;
@property (retain, nonatomic) UILabel *emptyLabel;

- (NSIndexPath *)modelIndexPathforIndexPath:(NSIndexPath *)indexPath;
- (int)modelRowforRow:(int)row;

@end
