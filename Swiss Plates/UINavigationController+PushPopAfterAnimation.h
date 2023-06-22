//
//  UINavigationController+PushPopAfterAnimation.h
//  Swiss Plates
//
//  Created by Alain Furter on 06.06.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConfigFile.h"

//#define tUseCustomPushPop 1

@interface UINavigationController (PushPopAfterAnimation)

- (void)pushViewControllerAfterAnimation:(UIViewController *)viewController animated:(BOOL)animated animationBlock:(void(^)())animationBlock;
- (void)popViewControllerAfterAnimationAnimated:(UIViewController *)viewController animated:(BOOL)animated animationBlock:(void(^)())animationBlock;

@end
