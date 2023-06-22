//
//  PersonSearchResultControlCell.m
//  Swiss Plates
//
//  Created by Alain Furter on 28.06.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import "PersonSearchResultControlCell.h"

@implementation PersonSearchResultControlCell

@synthesize phoneButton, downloadButton, locateOwnerButton, shareButton, addContactButton;
@synthesize rowNumber, controlCellDelegate;
@synthesize userTappedTwiceOnDeleteButton ,isSearchResultViewControlBox;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.userTappedTwiceOnDeleteButton = NO;
        self.isSearchResultViewControlBox = YES;
    }
    return self;
}

- (IBAction)callCarOwner:(id)sender {
    if (self.controlCellDelegate) {
        [self.controlCellDelegate callOwnerAction: rowNumber];
    }
}

- (IBAction)saveCarOwner:(id)sender {
    if (!self.isSearchResultViewControlBox) {
        if (!self.userTappedTwiceOnDeleteButton) {
            self.userTappedTwiceOnDeleteButton = YES;
            [self.downloadButton setBackgroundImage: [UIImage imageNamed: @"OwnerRowDeleteButtonSecond.png"] forState: UIControlStateNormal];
            return;
        } else {
            if (self.controlCellDelegate) {
                [self.controlCellDelegate saveCarOwnerAction: rowNumber];
            }
        }
    } else {
        //[self.downloadButton setBackgroundImage: [UIImage imageNamed: @"OwnerRowDBButtonOn.png"] forState: UIControlStateNormal];
        if (self.controlCellDelegate) {
            [self.controlCellDelegate saveCarOwnerAction: rowNumber];
        }
    }
}

- (IBAction)locateCarOwner:(id)sender {
    if (self.controlCellDelegate) {
        [self.controlCellDelegate locateOwnerOnMapAction: rowNumber];
    }
}

- (IBAction)shareOwnerInfo:(id)sender {
    if (self.controlCellDelegate) {
        [self.controlCellDelegate shareOwnerInfoAction: rowNumber];
    }
}

- (IBAction)addOwnerToAddressbook:(id)sender {
    if (self.controlCellDelegate) {
        [self.controlCellDelegate addOwnerToAdressbookAction: rowNumber];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *) machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
	
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (void) rearrangeButtonsForiPodTouch {
    
    NSString *deviceType = [NSString stringWithString: [self machineName]];
    
    #ifdef  kLoggingIsOn
        NSLog(@"Devicetype: %@", [deviceType substringToIndex: 6]);
    #endif
    
    #ifdef kCheckForiPodServiceRestrictions
    if (![[deviceType substringToIndex: 6] isEqualToString: @"iPhone"]) {
        
        [self.phoneButton setHidden: YES];
        
        CGRect tempFrame = self.downloadButton.frame;
        tempFrame.origin.x = 31;
        self.downloadButton.frame = tempFrame;
        
        tempFrame = self.shareButton.frame;
        tempFrame.origin.x = 102;
        self.shareButton.frame = tempFrame;
        
        tempFrame = addContactButton.frame;
        tempFrame.origin.x = 173;
        self.addContactButton.frame = tempFrame;
        
        tempFrame = self.locateOwnerButton.frame;
        tempFrame.origin.x = 242;
        self.locateOwnerButton.frame = tempFrame;
        
        return;
    }
    #endif
    
    #ifdef kSimulateiPodTouchPresence
    [self.phoneButton setHidden: YES];
    
    CGRect tempFrame = self.downloadButton.frame;
    tempFrame.origin.x += 10;
    self.downloadButton.frame = tempFrame;
    
    tempFrame = self.shareButton.frame;
    tempFrame.origin.x += -35;
    self.shareButton.frame = tempFrame;
    
    tempFrame = addContactButton.frame;
    tempFrame.origin.x += -22;
    self.addContactButton.frame = tempFrame;
    
    tempFrame = self.locateOwnerButton.frame;
    tempFrame.origin.x += -10;
    self.locateOwnerButton.frame = tempFrame;
    
    return;
    #endif
}

- (void) setPhoneButtonActive:(BOOL)isActive {
    if (isActive) {
        [self.phoneButton setBackgroundImage: [UIImage imageNamed: @"OwnerRowPhoneYButton.png"] forState: UIControlStateNormal];
        
        //phoneButton.userInteractionEnabled = YES;
    } else {
        [self.phoneButton setBackgroundImage: [UIImage imageNamed: @"OwnerRowPhoneNButton.png"] forState: UIControlStateNormal];
        
        //phoneButton.userInteractionEnabled = NO;
    }
}

- (void) setupAlreadySaveState:(BOOL)isSaved  {
    if (isSaved) {
        [self.downloadButton setBackgroundImage: [UIImage imageNamed: @"OwnerRowDBButtonOn.png"] forState: UIControlStateNormal];
    } else {
        [self.downloadButton setBackgroundImage: [UIImage imageNamed: @"OwnerRowDBButtonOff.png"] forState: UIControlStateNormal];
    }
    
}

- (void) setupAsSearchResultsControlBox {
    self.isSearchResultViewControlBox = YES;
    [self.downloadButton setBackgroundImage: [UIImage imageNamed: @"OwnerRowDBButtonOff.png"] forState: UIControlStateNormal];
    
    [self rearrangeButtonsForiPodTouch];
}

- (void) setupAsPlatesViewControlBox {
    
    [self.downloadButton setBackgroundImage: [UIImage imageNamed: @"OwnerRowDeleteButtonFirst.png"] forState: UIControlStateNormal];
    self.userTappedTwiceOnDeleteButton = NO;
    self.isSearchResultViewControlBox = NO;
    
    [self rearrangeButtonsForiPodTouch];
}

- (void)dealloc
{
    [phoneButton release];
    [downloadButton release];
    [locateOwnerButton release];
    [shareButton release];
    [addContactButton release];
    [super dealloc];
}


@end
