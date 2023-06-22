//
//  PersonSearchResultControlCell.h
//  Swiss Plates
//
//  Created by Alain Furter on 28.06.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <sys/utsname.h>

#import "ConfigFile.h"

@protocol ControlCellDelegate
@optional
- (void) callOwnerAction:(int)rowEntry;
- (void) saveCarOwnerAction:(int)rowEntry;
- (void) locateOwnerOnMapAction:(int)rowEntry;
- (void) shareOwnerInfoAction:(int)rowEntry;
- (void) addOwnerToAdressbookAction:(int)rowEntry;
@end

@interface PersonSearchResultControlCell : UITableViewCell {
    UIButton *phoneButton;
    UIButton *downloadButton;
    UIButton *locateOwnerButton;
    UIButton *shareButton;
    UIButton *addContactButton;    
   
    int rowNumber;
    id <ControlCellDelegate> controllCellDelegate;
    
    BOOL userTappedTwiceOnDeleteButton;
    BOOL isSearchResultViewControlBox;
}

@property (nonatomic, retain) IBOutlet UIButton *phoneButton;
@property (nonatomic, retain) IBOutlet UIButton *downloadButton;
@property (retain, nonatomic) IBOutlet UIButton *locateOwnerButton;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *addContactButton;

@property (assign) int rowNumber;
@property(nonatomic,assign) id <ControlCellDelegate> controlCellDelegate;
@property (assign) BOOL userTappedTwiceOnDeleteButton;
@property (assign) BOOL isSearchResultViewControlBox;

- (IBAction)callCarOwner:(id)sender;
- (IBAction)saveCarOwner:(id)sender;
- (IBAction)locateCarOwner:(id)sender;
- (IBAction)shareOwnerInfo:(id)sender;
- (IBAction)addOwnerToAddressbook:(id)sender;

- (void) setupAlreadySaveState:(BOOL)isSaved;
- (void) setupAsSearchResultsControlBox;
- (void) setupAsPlatesViewControlBox;
- (void) setPhoneButtonActive:(BOOL)isActive;

- (void) rearrangeButtonsForiPodTouch;

@end
