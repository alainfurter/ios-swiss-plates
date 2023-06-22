//
//  WBRedGradientView.m
//  GradientView
//
//  Created by Tito Ciuro on 6/3/12.
//  Copyright (c) 2012 Webbo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WBYellowGradientView.h"

@implementation WBYellowGradientView

- (void)drawRect:(CGRect)rect
{
    
    UIColor *redTop = [UIColor colorWithRed:255/255.0f green:228/255.0f blue:138/255.0f alpha:1.0];
    UIColor *redBot = [UIColor colorWithRed:242/255.0f green:203/255.0f blue:71/255.0f alpha:1.0];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)redTop.CGColor,
                       (id)redBot.CGColor,
                       nil];
    gradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0f],
                          [NSNumber numberWithFloat:0.7],
                          nil];
    
    [self.layer insertSublayer:gradient atIndex:0];
    
    UIView *firstTopPinkLine = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, 1.0)];
    firstTopPinkLine.backgroundColor = [UIColor colorWithRed:251/255.0f green:219/255.0f blue:108/255.0f alpha:1.0];
    [self addSubview:firstTopPinkLine];
    
    UIView *secondTopRedLine = [[UIView alloc]initWithFrame:CGRectMake(0.0, 1.0, self.bounds.size.width, 1.0)];
    secondTopRedLine.backgroundColor = [UIColor colorWithRed:197/255.0f green:157/255.0f blue:19/255.0f alpha:1.0];
    [self addSubview:secondTopRedLine];
    
    UIView *firstBotRedLine = [[UIView alloc]initWithFrame:CGRectMake(0.0, self.bounds.size.height - 1, self.frame.size.width, 1.0)];
    firstBotRedLine.backgroundColor = [UIColor colorWithRed:167/255.0f green:133/255.0f blue:16/255.0f alpha:1.0];
    [self addSubview:firstBotRedLine];
    
    UIView *secondBotDarkLine = [[UIView alloc]initWithFrame:CGRectMake(0.0, self.bounds.size.height, self.frame.size.width, 1.0)];
    secondBotDarkLine.backgroundColor = [UIColor colorWithRed:97/255.0f green:78/255.0f blue:13/255.0f alpha:1.0];
    [self addSubview:secondBotDarkLine];
}

@end
