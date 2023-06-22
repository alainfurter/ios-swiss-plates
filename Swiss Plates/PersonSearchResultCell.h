//
//  PersonSearchResultCell.h
//  Swiss Plates
//
//  Created by Alain Furter on 06.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ASIHTTPRequest.h"
#import "NSStringAdditions.h"

//#define RANDOM_SEED() srandom(time(NULL))
//#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))
 
@protocol PhoneNumberResolvingResultDelegate
@optional
- (void)phoneNumberWasResolved:(NSString *) phoneNumber rowEntry:(int)rowEntry;
@end

@interface PersonSearchResultCell : UITableViewCell {
    UIImageView *background;
    UILabel *numberLabel;
    UILabel *nameLabel;
    UILabel *addressLabel;
    UILabel *plzplaceLabel;
    UILabel *phoneLabel;
    UIImageView *cantonImage;
    UILabel *downloadActivityLabel;
    UIActivityIndicatorView *downloadActivityIndicator;
    UIImageView *typeImage;
    
    NSString *cantonCode;
    NSString *flagName;
    NSNumber *latitude;
    NSNumber *longitude;
    NSString *carNumber;
    NSString *catType;
    
    BOOL isDownloading;
    BOOL phoneNumberSet;
    BOOL phoneNumberFailed;
    BOOL savedInDB;
    
    ASIHTTPRequest *currentRequest;
    
    UINavigationController *currentNavigationController;
    
    id <PhoneNumberResolvingResultDelegate> phoneNumberResolvingResultDelegate;
    int rowNumber;
    
    BOOL hasControlBoxOpen;
}

@property (nonatomic, retain) IBOutlet UIImageView *background;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet UILabel *plzplaceLabel;
@property (nonatomic, retain) IBOutlet UILabel *phoneLabel;
@property (nonatomic, retain) IBOutlet UIImageView *cantonImage;
@property (nonatomic, retain) IBOutlet UILabel *downloadActivityLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *downloadActivityIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *typeImage;
@property (retain, nonatomic) IBOutlet UILabel *cantonLabel;
@property (retain, nonatomic) IBOutlet UIImageView *dbRibbonImageView;
@property (retain, nonatomic) IBOutlet UIImageView *topRowShadowImageView;
@property (retain, nonatomic) IBOutlet UIImageView *bottomRowEndMarker;
@property (retain, nonatomic) IBOutlet UIImageView *topRowEndMarker;

@property (nonatomic, retain) NSString *cantonCode;
@property (nonatomic, retain) NSString *flagName;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *carNumber;
@property (nonatomic, retain) NSString *catType;

@property (assign) BOOL isDownloading;
@property (assign) BOOL phoneNumberSet;
@property (assign) BOOL phoneNumberFailed;
@property (assign) BOOL savedInDB;

@property (assign) int rowNumber;

@property (assign) UINavigationController *currentNavigationController;
@property (assign) ASIHTTPRequest *currentRequest;

@property(nonatomic,assign) id <PhoneNumberResolvingResultDelegate> phoneNumberResolvingResultDelegate;

@property (assign) BOOL hasControlBoxOpen;

- (void) startPhoneNumberResolving;
- (void) hidePhoneSearchActivityIndicators;
- (void) setPhoneNumberAndArrageButtons:(NSString *)phoneNumberString;
- (void) hideDownloadActivityIndicatorAndLabel;
- (void) runBounceNoAnimation;
- (void) rearrangeDBRibbonAndShadow: (BOOL) savedState;
- (void) setPhoneNumberTestCode;

@end
