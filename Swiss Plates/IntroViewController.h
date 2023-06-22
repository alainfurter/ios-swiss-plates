//
//  IntroViewController.h
//  Swiss Plates
//
//  Created by Alain Furter on 01.07.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDevice+Resolutions.h"
#import "ConfigFile.h"

@protocol IntroHasFinishedDelegate
@optional
- (void) introHasFinished;
@end

@interface IntroViewController : UIViewController <UIScrollViewDelegate> {
    id <IntroHasFinishedDelegate> introHasFinishedDelegate;
}

@property(nonatomic,assign) id <IntroHasFinishedDelegate> introHasFinishedDelegate;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIButton *endButton;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;
@property (retain, nonatomic) IBOutlet UIImageView *introBackgroundImageView;
- (IBAction)endButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;


@end
