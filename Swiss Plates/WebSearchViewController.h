//
//  WebSearchViewController.h
//  Swiss Plates
//
//  Created by Alain Furter on 05.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <QuartzCore/Quartzcore.h>
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>

#import "CoreDataController.h"
#import "CarOwners.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "UIViewController+KNSemiModal.h"

#import "PersonSearchResultCell.h"
#import "PersonSearchResultControlCell.h"
#import "EndMarkerCell.h"
#import "MapViewController.h"

#import "ConfigFile.h"
#import "Swiss_PlatesAppDelegate.h"

#import "BCDShareSheet.h"
#import "BCDShareableItem.h"

#import "WBSuccessNoticeView.h"
#import "WBInfoNoticeView.h"
#import "WBErrorNoticeView.h"

#import "BlockAlertView.h"

#import "UIDevice-Reachability.h"
#import "UINavigationController+PushPopAfterAnimation.h"

#import "UIDevice+IdentifierAddition.h"
#import "UIDevice+Resolutions.h"
#import <sys/utsname.h>

#import <CommonCrypto/CommonDigest.h>

@class ShowSearchResultViewController;
@class OtherSearchViewController;
@class PersonSearchResultCell;
@class PersonSearchResultControlCell;
@class EndMarkerCell;

@interface WebSearchViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, PhoneNumberResolvingResultDelegate, ControlCellDelegate> {
    
    UILabel *cantonLabel;
    UIImageView *cantonImage;
    
    UIView *captchaView;
    UIImageView *captchaImage;
    UITextField *captchaTextField;
    
    int webServiceCode;
    int cantonRow;
    
    NSString *cantonCode;
    NSString *flagName;
    
    NSString *viacarCanton;
    NSString *viacarSessionID;
    NSString *viacarAuthID;
    NSString *viacarIndID;
    NSString *viacarViewState;
    NSString *viacarEventValidation;
    NSString *viacarCarNumber;
    NSString *viacarJpegID;
    NSString *viacarInputFieldName;
    
    NSString *cariCanton;
    NSString *cariCarNumber;
    NSString *cariCarType;
    
    NSArray *carOwners;
    
    ASIHTTPRequest *currentGetRequest;
    ASIFormDataRequest *currentPostRequest;
    
    UIAlertView *getCookieWaitingAlertView;
    BOOL getCookieWaitingAlertViewOnScreen;
    UIView *explanationView;
    UILabel *explanationLabel;
    UIButton *explanationButton;
    BOOL explanationViewOnScreen;
    UIScrollView *vehicleSelectionScrollView;
    UIView *vehicleSelectionImagesView;
    UIButton *bigSearchButton;
    UIImageView *normalBackgroundView;
    
    BOOL searchViewOnScreen;
    BOOL waitWithAddinsViewOnScreen;
    BOOL captchaViewOnScreen;
    BOOL searchViewWasOnScreen;
    BOOL captchaViewWasOnScreen;
    
    BOOL viewAppearsFromCustomTabbarPush;
    
    UITableView *resultTableView;
    NSArray *ownersList;
    PersonSearchResultCell *tableCell;
    PersonSearchResultControlCell *controlCell;
    NSMutableDictionary *phoneNumberCache;
    
    NSIndexPath *controlRowIndexPath;
    NSIndexPath *tappedIndexPath;
    
    int lastContentOffset;
    
    int whichScrollViewIsActiveFlag;
}
@property (nonatomic, retain) IBOutlet UILabel *cantonLabel;
@property (nonatomic, retain) IBOutlet UIImageView *cantonImage;

@property (nonatomic, retain) IBOutlet UIView *captchaView;
@property (nonatomic, retain) IBOutlet UIImageView *captchaImage;
@property (nonatomic, retain) IBOutlet UITextField *captchaTextField;

@property (nonatomic, retain) NSString *cantonCode;
@property (nonatomic, retain) NSString *flagName;

@property (nonatomic, retain) NSString *viacarCanton;
@property (nonatomic, retain) NSString *viacarSessionID;
@property (nonatomic, retain) NSString *viacarAuthID;
@property (nonatomic, retain) NSString *viacarIndID;
@property (nonatomic, retain) NSString *viacarViewState;
@property (nonatomic, retain) NSString *viacarEventValidation;
@property (nonatomic, retain) NSString *viacarCarNumber;
@property (nonatomic, retain) NSString *viacarJpegID;
@property (nonatomic, retain) NSString *viacarInputFieldName;

@property (nonatomic, retain) NSString *cariCanton;
@property (nonatomic, retain) NSString *cariCarNumber;
@property (nonatomic, retain) NSString *cariCarType;

@property (nonatomic, retain) NSArray *carOwners;

@property (nonatomic, retain) NSIndexPath *controlRowIndexPath;
@property (nonatomic, retain) NSIndexPath *tappedIndexPath;

@property (assign) ASIHTTPRequest *currentGetRequest;
@property (assign) ASIFormDataRequest *currentPostRequest;

@property (nonatomic, retain) UIAlertView *getCookieWaitingAlertView;
@property (assign) BOOL getCookieWaitingAlertViewOnScreen;
@property (assign) BOOL searchViewOnScreen;
@property (assign) BOOL waitWithAddinsViewOnScreen;
@property (assign) BOOL captchaViewOnScreen;
@property (assign) BOOL searchViewWasOnScreen;
@property (assign) BOOL captchaViewWasOnScreen;

@property (assign) BOOL viewAppearsFromCustomTabbarPush;

@property (nonatomic, retain) IBOutlet UIView *explanationView;
@property (nonatomic, retain) IBOutlet UILabel *explanationLabel;
@property (nonatomic, retain) IBOutlet UIButton *explanationButton;
@property (assign) BOOL explanationViewOnScreen;

@property (nonatomic, retain) IBOutlet UIScrollView *vehicleSelectionScrollView;
@property (nonatomic, retain) IBOutlet UIView *vehicleSelectionImagesView;
@property (nonatomic, retain) IBOutlet UIButton *bigSearchButton;
@property (nonatomic, retain) IBOutlet UIImageView *normalBackgroundView;
@property (retain, nonatomic) IBOutlet UIImageView *maskBackgroundView;

@property (retain, nonatomic) IBOutlet UITextField *numberTextField;
@property (retain, nonatomic) IBOutlet UILabel *numberLabel;
@property (retain, nonatomic) IBOutlet UIView *searchView;
@property (retain, nonatomic) IBOutlet UIView *waitWithAddinsView;
@property (retain, nonatomic) IBOutlet UILabel *waitWithAddinsLabel;
@property (retain, nonatomic) IBOutlet UILabel *enterCaptchaCodeLabel;

@property (nonatomic, retain) IBOutlet UITableView *resultTableView;
@property (nonatomic, retain) NSArray *ownersList;
@property (nonatomic, assign) IBOutlet PersonSearchResultCell *tableCell;
@property (nonatomic, assign) IBOutlet PersonSearchResultControlCell *controlCell;

@property (nonatomic, retain) NSMutableDictionary *phoneNumberCache;

- (IBAction)explanationAction:(id)sender;

- (IBAction)pushBackController:(id)sender;

- (IBAction)startSearch:(id)sender;
- (IBAction)captchaViewCancel:(id)sender;
- (IBAction)captchaViewLoginAndSearch:(id)sender;
- (IBAction)keyPadKeyPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)waitWithAddinsCancelButtonPressed:(id)sender;
- (IBAction)explanationViewCancelButtonPressed:(id)sender;

- (id)initWithOptions:(int)webServiceCodeOption cantonCode:(NSString *)cantonCodeString flagName:(NSString *)flagNameString cantonRowOption:(int) cantonRowOption;
- (void) pushBack;

- (void) viacarLoginAndSearch;
- (void) viacarGetCookie;

- (void) cariLoginAndSearch;
- (void) cariGetCookie;

- (void) tiLoginAndSearch;
- (void) tiGetCookie;

- (void) nwLoginAndSearch;

- (void) moveCaptchaViewOnScreen;
- (void) moveCaptchaViewOffScreen;

- (void) moveExplanationViewOnScreen;
- (void) moveExplanationViewOffScreen;

- (void) moveSearchViewOnScreen;
- (void) moveSearchViewOffScreen;

- (NSIndexPath *)modelIndexPathforIndexPath:(NSIndexPath *)indexPath;
- (int)modelRowforRow:(int)row;

@end
