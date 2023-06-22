//
//  PersonSearchResultCell.m
//  Swiss Plates
//
//  Created by Alain Furter on 06.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import "PersonSearchResultCell.h"
#import "CoreDataController.h"
#import "CarOwners.h"
#import "MapViewController.h"
#import "UIDevice-Reachability.h"

#import "BCDShareSheet.h"
#import "BCDShareableItem.h"
#import "WBSuccessNoticeView.h"
#import "WBInfoNoticeView.h"
#import "WBErrorNoticeView.h"

#define APIKEY @"194ab8bb662ad9a72dcf34c27b9c1381"

#define CreateRegex(regexString)  [NSRegularExpression regularExpressionWithPattern: regexString options:NSRegularExpressionCaseInsensitive error:NULL]
#define RegexMatch(regexExpression, stringToSearch) [regexExpression firstMatchInString: stringToSearch options:0 range:NSMakeRange(0, [stringToSearch length])]
#define GetMatchString(regexMatch, stringToSearch) [stringToSearch substringWithRange: [regexMatch rangeAtIndex:1]]

@implementation PersonSearchResultCell

@synthesize downloadActivityLabel;
@synthesize downloadActivityIndicator;
@synthesize typeImage;
@synthesize cantonLabel;
@synthesize dbRibbonImageView;
@synthesize topRowShadowImageView;
@synthesize bottomRowEndMarker;
@synthesize topRowEndMarker;
@synthesize background, numberLabel, nameLabel, addressLabel, plzplaceLabel, phoneLabel, cantonImage;
@synthesize cantonCode, flagName, latitude, longitude, carNumber, catType;
@synthesize isDownloading, phoneNumberSet, phoneNumberFailed;
@synthesize currentRequest, currentNavigationController; // currentViewController;
@synthesize phoneNumberResolvingResultDelegate;
@synthesize rowNumber;
@synthesize savedInDB;

@synthesize hasControlBoxOpen;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    //NSLog(@"Init cell");
    
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        self.isDownloading = NO;
        self.phoneNumberSet = NO;
        self.phoneNumberFailed = NO;
        self.savedInDB = NO;
        self.hasControlBoxOpen = NO;
        self.currentRequest = nil;
    }
    return self;
}

- (void) rearrangeDBRibbonAndShadow: (BOOL) savedState {
    if (savedState) {
        self.dbRibbonImageView.hidden = NO;
        //self.topRowShadowImageView.hidden = NO;
    } else {
        self.dbRibbonImageView.hidden = YES;
        //self.topRowShadowImageView.hidden = YES;
    }
}

- (void) hidePhoneSearchActivityIndicators {
    [self.downloadActivityIndicator stopAnimating];
    [self.downloadActivityIndicator setHidden: YES];
    [self.downloadActivityLabel setHidden: YES];
}

- (void) hideDownloadActivityIndicatorAndLabel {
    [self.downloadActivityIndicator stopAnimating];
    [self.downloadActivityIndicator setHidden: YES];
    [self.downloadActivityLabel setHidden: YES];
}

- (void) setPhoneNumberAndArrageButtons:(NSString *)phoneNumberString {
    //NSLog(@"Set phone number");
    
    if (!phoneNumberString) return;
    [self.phoneLabel setText: phoneNumberString];
    self.phoneNumberSet = YES;
    
    /*
    [self.phoneButton setBackgroundImage: [UIImage imageNamed: @"OwnerRowPhoneYButton.png"] forState: UIControlStateNormal];
    phoneButton.userInteractionEnabled = YES;
     */
}

- (void) setPhoneNumberTestCode {
    
    NSMutableString *phoneString = [NSMutableString stringWithString: @"+4179"];
    
    for (int i = 1; i<=7; i++) {
        //RANDOM_SEED();
        //int randomNumber = RANDOM_INT(1, 9);
        int r = arc4random() % 9;
        [phoneString appendFormat: @"%d", r];
    }
    
    [self setPhoneNumberSet: YES];
    [self.phoneLabel setText: phoneString];
    [self.downloadActivityIndicator setHidden: YES];
    
    //if (self.controllCellPointer) {
    //    [controllCellPointer setPhoneButtonActive: YES];
    //}
}


- (void) startPhoneNumberResolving {
    //NSLog(@"Start resolving");
        
    if (!([UIDevice networkAvailable])) 
    {
        //NSLog(@"No network available");
        [self.phoneLabel setText: @""];
        self.phoneNumberFailed = YES;
        return;
    }
    
    
    //NSLog(@"Phone number failed: %@", phoneNumberFailed?@"YES":@"NO");
    
    if (self.isDownloading ) return; if (self.phoneNumberSet) return; if (self.phoneNumberFailed) return; if (self.currentRequest) return;
    if (([[nameLabel text] length] == 0) || ([[addressLabel text] length] == 0) || ([[plzplaceLabel text] length] == 0)) return;
    /*
    if (!self.phoneNumberSet || !self.phoneNumberFailed) {
        [self.downloadActivityIndicator startAnimating];
    }
    */
    [self.downloadActivityIndicator setHidden: NO];
    [self.downloadActivityIndicator startAnimating];
    [self.downloadActivityLabel setHidden: NO];
    
    [ASIHTTPRequest setDefaultTimeOutSeconds: 20];

    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
        
    NSString *urlString = [NSString stringWithFormat: @"http://tel.search.ch/api/?was=%@&wo=%@+%@&key=%@", [[nameLabel text] stringByEscapingURL],
                           [[addressLabel text] stringByEscapingURL], [[plzplaceLabel text] stringByEscapingURL], APIKEY];
    
    //NSLog(@"Tel search api call: %@", urlString);
        
    NSURL *url = [NSURL URLWithString: urlString];
        
    __block ASIHTTPRequest *cookieRequest = [ASIHTTPRequest requestWithURL:url];
    [cookieRequest setDelegate:self]; [cookieRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
    [cookieRequest setRequestMethod:@"GET"];
    [cookieRequest addRequestHeader:@"User-Agent" value:@"Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0)"];

    [cookieRequest setCompletionBlock:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        NSString *responseString = [cookieRequest responseString];
        //NSLog(@"Response: %@", responseString);
        //NSLog(@"Response header: %@", [cookieRequest responseHeaders]);
        
        self.isDownloading = NO;
        [self.downloadActivityIndicator stopAnimating];
        [self.downloadActivityIndicator setHidden: YES];
        [self.downloadActivityLabel setHidden: YES];
        
        self.currentRequest = nil;
                
        if (responseString) {
            if ([responseString length] != 0) {
                NSTextCheckingResult *phoneNumberMatch = RegexMatch(CreateRegex(@"<tel:phone>(.+?)</tel:phone>"), responseString);
                
                if (phoneNumberMatch) { 
                    //NSLog(@"Phone number matched");
                    //[self.phoneLabel setText: GetMatchString(phoneNumberMatch, responseString)];
                    [self setPhoneNumberAndArrageButtons:GetMatchString(phoneNumberMatch, responseString)];
                    if (phoneNumberResolvingResultDelegate) {
                        [phoneNumberResolvingResultDelegate phoneNumberWasResolved:GetMatchString(phoneNumberMatch, responseString) rowEntry: rowNumber];
                    }
                    
                    //if (self.controllCellPointer) {
                    //    [controllCellPointer setPhoneButtonActive: YES];
                    //}
                
                } else {
                    //NSLog(@"Failed: %@", nameLabel.text);
                    //[self.phoneLabel setText: NSLocalizedString(@"Phone number could not be found", @"Phone number resolving answer message")];
                    [self.phoneLabel setText: @""];
                    self.phoneNumberFailed = YES;
                } 
            } else {
                //NSLog(@"Failed: %@", nameLabel.text);
                //[self.phoneLabel setText: NSLocalizedString(@"Phone number could not be found", @"Phone number resolving answer message")];
                [self.phoneLabel setText: @""];
                self.phoneNumberFailed = YES;
            }
        } else {
            //NSLog(@"Failed: %@", nameLabel.text);
            //[self.phoneLabel setText: NSLocalizedString(@"Phone number could not be found", @"Phone number resolving answer message")];
            [self.phoneLabel setText: @""];
            self.phoneNumberFailed = YES;
        }
    }];
    
    [cookieRequest setFailedBlock:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        //NSLog(@"Response header: %@", [cookieRequest responseHeaders]);
        //NSError *error = [cookieRequest error];
        //NSLog(@"1st failed %@",[error description]);
        
        [self.phoneLabel setText: NSLocalizedString(@"Could not resolve phone number", @"Phone number resolving answer message")];
        
        if (phoneNumberResolvingResultDelegate) {
            [phoneNumberResolvingResultDelegate phoneNumberWasResolved:NSLocalizedString(@"Could not resolve phone number", @"Phone number resolving answer message") rowEntry: rowNumber];
        }
        
        self.isDownloading = NO;
        self.phoneNumberFailed = YES;
        [self.downloadActivityIndicator stopAnimating];
        [self.downloadActivityIndicator setHidden: YES];
        [self.downloadActivityLabel setHidden: YES];
        
        self.currentRequest = nil;
        
    }];
     
    self.isDownloading = YES;
    self.currentRequest = cookieRequest;
    [cookieRequest startAsynchronous];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

- (void)dealloc
{
    if (self.isDownloading && self.currentRequest) {
        [currentRequest clearDelegatesAndCancel];
    }
    
    [cantonCode release];
    [flagName release];
    [latitude release];
    [longitude release];
    [carNumber release];
    [catType release];
    [background release];
    [numberLabel release];
    [nameLabel release];
    [addressLabel release];
    [plzplaceLabel release];
    [phoneLabel release];
    [cantonImage release];
    [downloadActivityIndicator release];
    [downloadActivityLabel release];
    [typeImage release];
    [cantonLabel release];
    [dbRibbonImageView release];
    [topRowShadowImageView release];
    [bottomRowEndMarker release];
    [topRowEndMarker release];
    
    [super dealloc];
}

// ANIMATION 1 BEGIN

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	
	//NSLog(@"Bounce animation finished");
    
     if (anim == [self.layer animationForKey:@"bounce"]){
         [self.layer removeAnimationForKey:@"bounce"];
         [self.layer removeAllAnimations];

         [self.layer setAnchorPoint:CGPointMake(0, 0.5)];
         [self.layer setPosition:CGPointMake(0, self.layer.position.y)];
     }     
}


- (CAAnimationGroup *)bounceAnimationWithHideDuration:(CGFloat)hideDuration initialXOrigin:(CGFloat)originalX {
	
	CABasicAnimation * animation0 = [CABasicAnimation animationWithKeyPath:@"position.x"];
	[animation0 setFromValue:[NSNumber numberWithFloat:originalX]];
	[animation0 setToValue:[NSNumber numberWithFloat:0]];
	[animation0 setDuration:hideDuration];
	[animation0 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[animation0 setBeginTime:0];
	
	CAAnimationGroup * hideAnimations = [CAAnimationGroup animation];
	[hideAnimations setAnimations:[NSArray arrayWithObject:animation0]];
	
	CGFloat fullDuration = hideDuration;
	
	if (YES){
		
		CGFloat bounceDuration = 0.04;
		
		CABasicAnimation * animation1 = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation1 setFromValue:[NSNumber numberWithFloat:0]];
		[animation1 setToValue:[NSNumber numberWithFloat:-25]];
		[animation1 setDuration:bounceDuration];
		[animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[animation1 setBeginTime:hideDuration];
		
		CABasicAnimation * animation2 = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation2 setFromValue:[NSNumber numberWithFloat:-25]];
		[animation2 setToValue:[NSNumber numberWithFloat:20]];
		[animation2 setDuration:bounceDuration];
		[animation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[animation2 setBeginTime:(hideDuration + bounceDuration)];
		
		CABasicAnimation * animation3 = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation3 setFromValue:[NSNumber numberWithFloat:20]];
		[animation3 setToValue:[NSNumber numberWithFloat:0]];
		[animation3 setDuration:bounceDuration];
		[animation3 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[animation3 setBeginTime:(hideDuration + (bounceDuration * 2))];
		
		[hideAnimations setAnimations:[NSArray arrayWithObjects:animation0, animation1, animation2, animation3, nil]];
		
		fullDuration = hideDuration + (bounceDuration * 3);
	}
	
	[hideAnimations setDuration:fullDuration];
	[hideAnimations setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[hideAnimations setDelegate:self];
	[hideAnimations setRemovedOnCompletion:NO];
	
	return hideAnimations;
}


// ANIMATION 1 END

// ANIMATION 2 BEGIN
/*
- (void) displayNoCommentWithAnimation{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 2;
    
    int steps = 120;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double value = 0;
    float e = 2.71;
    for (int t = 0; t < steps; t++) {
        value = 210 - abs(105 * pow(e, -0.025*t) * cos(0.12*t));
        [values addObject:[NSNumber numberWithFloat:value]];
    }
    animation.values = values;
    
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [self.layer addAnimation:animation forKey:nil];
}


- (void) animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    CAKeyframeAnimation *keyframeAnimation = (CAKeyframeAnimation*)animation;
    [self.layer setValue:[NSNumber numberWithInt:210] forKeyPath:keyframeAnimation.keyPath];
    [self.layer removeAllAnimations];
}
*/
// ANIMATION 2 END

- (void) runBounceNoAnimation {
    
    // ANIMATION 1 BEGIN
    
    CGFloat hideDuration = 0.09;
    CGFloat originalX = self.layer.position.x;
    [self.layer setAnchorPoint:CGPointMake(0, 0.5)];
    [self.layer setPosition:CGPointMake(0, self.layer.position.y)];
    [self.layer addAnimation:[self bounceAnimationWithHideDuration:hideDuration initialXOrigin:originalX] forKey:@"bounce"];
    
    // ANIMATION 1 END
    
    // ANIMATION 2 BEGIN
    /*
    [self displayNoCommentWithAnimation];
    */
    //ANIMATION 2 END
    
    // ANIMATION 3 BEGIN
    /*
    var activeCell = ((Element)sender).GetActiveCell();
    
    var animation = (CAKeyFrameAnimation)CAKeyFrameAnimation.FromKeyPath ("transform.translation.x");
    animation.Duration = 0.3;
    
    animation.TimingFunction = // small details matter :)
    CAMediaTimingFunction.FromName(CAMediaTimingFunction.EaseOut.ToString()); 
    
    animation.Values = new NSObject[]{
        NSObject.FromObject (20), 
        NSObject.FromObject (-20),
        NSObject.FromObject (10),
        NSObject.FromObject (-10),
        NSObject.FromObject (15),
        NSObject.FromObject (-15),
    };
    
    activeCell.Layer.AddAnimation (animation,"bounce");
     */
    // ANIMATION 3 END
}

@end
