//
//  WBNoticeView.m
//  NoticeView
//
//  Created by Tito Ciuro on 5/16/12.
//  Copyright (c) 2012 Tito Ciuro. All rights reserved.
//

#import "WBNoticeView.h"
#import "WBNoticeView_Private.h"
#import "WBRedGradientView.h"
#import "WBBlueGradientView.h"
#import "WBYellowGradientView.h"
#import "UILabel+WBExtensions.h"

#import <QuartzCore/QuartzCore.h>

@interface WBNoticeView ()

@property(nonatomic, strong) UIView *noticeView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *messageLabel;

- (void)cleanup;

@end

@implementation WBNoticeView

@synthesize noticeView, titleLabel, messageLabel;

+ (WBNoticeView *)defaultManager
{
    static WBNoticeView *__sWBNoticeView = nil;
    
    if (nil ==  __sWBNoticeView) {
        __sWBNoticeView = [WBNoticeView new];
    }
    
    return __sWBNoticeView;
}

#pragma mark - Error Notice Methods

- (void)showErrorNoticeInView:(UIView *)view
                        title:(NSString *)title
                      message:(NSString *)message
{
    [self _showNoticeOfType:WBNoticeViewTypeError
                       view:view
                      title:title
                    message:message
                   duration:0.0
                      delay:0.0
                      alpha:0.8
                    yOrigin:0.0];
}

- (void)showErrorNoticeInView:(UIView *)view
                        title:(NSString *)title
                      message:(NSString *)message
                     duration:(float)duration
                        delay:(float)delay
                        alpha:(float)alpha
{
    [self _showNoticeOfType:WBNoticeViewTypeError
                       view:view
                      title:title
                    message:message
                   duration:duration
                      delay:delay
                      alpha:alpha
                    yOrigin:0.0];
}

- (void)showErrorNoticeInView:(UIView *)view
                        title:(NSString *)title
                      message:(NSString *)message
                     duration:(float)duration
                        delay:(float)delay
                        alpha:(float)alpha
                      yOrigin:(CGFloat)origin
{
    [self _showNoticeOfType:WBNoticeViewTypeError
                       view:view
                      title:title
                    message:message
                   duration:duration
                      delay:delay
                      alpha:alpha
                    yOrigin:origin];
}

- (void)showInfoNoticeInView:(UIView *)view
                        title:(NSString *)title
                      message:(NSString *)message
{
    [self _showNoticeOfType:WBNoticeViewTypeInfo
                       view:view
                      title:title
                    message:message
                   duration:0.0
                      delay:0.0
                      alpha:0.8
                    yOrigin:0.0];
}

- (void)showInfoNoticeInView:(UIView *)view
                        title:(NSString *)title
                      message:(NSString *)message
                     duration:(float)duration
                        delay:(float)delay
                        alpha:(float)alpha
{
    [self _showNoticeOfType:WBNoticeViewTypeInfo
                       view:view
                      title:title
                    message:message
                   duration:duration
                      delay:delay
                      alpha:alpha
                    yOrigin:0.0];
}

- (void)showInfoNoticeInView:(UIView *)view
                        title:(NSString *)title
                      message:(NSString *)message
                     duration:(float)duration
                        delay:(float)delay
                        alpha:(float)alpha
                      yOrigin:(CGFloat)origin
{
    [self _showNoticeOfType:WBNoticeViewTypeInfo
                       view:view
                      title:title
                    message:message
                   duration:duration
                      delay:delay
                      alpha:alpha
                    yOrigin:origin];
}

- (void)showSuccessNoticeInView:(UIView *)view
                        message:(NSString *)message
{
    [self _showNoticeOfType:WBNoticeViewTypeSuccess
                       view:view
                      title:message
                    message:nil
                   duration:0.0
                      delay:0.0
                      alpha:0.8
                    yOrigin:0.0];
}

- (void)showSuccessNoticeInView:(UIView *)view
                        message:(NSString *)message
                       duration:(float)duration
                          delay:(float)delay
                          alpha:(float)alpha
{
    [self _showNoticeOfType:WBNoticeViewTypeSuccess
                       view:view
                      title:message
                    message:nil
                   duration:duration
                      delay:delay
                      alpha:alpha
                    yOrigin:0.0];
}

- (void)showSuccessNoticeInView:(UIView *)view
                        message:(NSString *)message
                       duration:(float)duration
                          delay:(float)delay
                          alpha:(float)alpha
                        yOrigin:(CGFloat)origin
{
    [self _showNoticeOfType:WBNoticeViewTypeSuccess
                       view:view
                      title:message
                    message:nil
                   duration:duration
                      delay:delay
                      alpha:alpha
                    yOrigin:origin];
}

#pragma mark - Private Section

- (void)_showNoticeOfType:(WBNoticeViewType)noticeType
                     view:(UIView *)view
                    title:(NSString *)title
                  message:(NSString *)message
                 duration:(float)duration
                    delay:(float)delay
                    alpha:(float)alpha
                  yOrigin:(CGFloat)origin
{
    if (nil == self.noticeView) {
        // Set default values if needed
        if (nil == title) title = @"Unknown Error";
        if (nil == message) message = @"Information not provided.";
        if (0.0 == duration) duration = 0.5;
        if (0.0 == delay) delay = 2.0;
        if (0.0 == alpha) alpha = 1.0;
        if (origin < 0.0) origin = 0.0;

        // Obtain the screen width
        CGFloat viewWidth = view.frame.size.width;
        
        // Locate the images
        NSString *path = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"NoticeView.bundle"];
        
        NSString *noticeIconImageName;
        if (noticeType == WBNoticeViewTypeError) {
            noticeIconImageName = [path stringByAppendingPathComponent: @"notice_error_icon.png"];
        } else if (noticeType == WBNoticeViewTypeSuccess) {
            noticeIconImageName = [path stringByAppendingPathComponent: @"notice_success_icon.png"];
        } else if (noticeType == WBNoticeViewTypeInfo) {
            noticeIconImageName = [path stringByAppendingPathComponent: @"notice_info_icon.png"];
        }
        
        NSInteger numberOfLines = 1;
        CGFloat messageLineHeight = 30.0;
        
        // Make and add the title label
        float titleYOrigin;
        if (noticeType == WBNoticeViewTypeError) {
            titleYOrigin = 10.0;
        } else if (noticeType == WBNoticeViewTypeSuccess) {
            titleYOrigin = 18.0;
        } else if (noticeType == WBNoticeViewTypeInfo) {
            titleYOrigin = 10.0;
        }

        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55.0, titleYOrigin, viewWidth - 70.0, 16.0)];
        //self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        
        if ((noticeType == WBNoticeViewTypeError) || (noticeType == WBNoticeViewTypeSuccess)) {
            self.titleLabel.textColor = [UIColor whiteColor];
            self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        } else {
            self.titleLabel.textColor = [UIColor colorWithWhite:0.225 alpha:1.0];
            //self.titleLabel.font = [UIFont boldSystemFontOfSize:19.0];
            self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        }
        
        //self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        self.titleLabel.shadowColor = [UIColor blackColor];
        self.titleLabel.text = title;
        
        if ((WBNoticeViewTypeError == noticeType) || (WBNoticeViewTypeInfo == noticeType)) {
            // Make the message label
            self.messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(55.0, 10.0 + 10.0, viewWidth - 70.0, messageLineHeight)];
            //self.messageLabel.font = [UIFont systemFontOfSize:13.0];
            
            if ((noticeType == WBNoticeViewTypeError) || (noticeType == WBNoticeViewTypeSuccess)) {
                self.messageLabel.textColor = [UIColor colorWithRed:239.0/255.0 green:167.0/255.0 blue:163.0/255.0 alpha:1.0];
                self.messageLabel.font = [UIFont systemFontOfSize:13.0];
            } else {
                self.messageLabel.textColor = [UIColor colorWithWhite:0.225 alpha:1.0];
                self.messageLabel.font = [UIFont systemFontOfSize: 13.0];
            }
            
            //self.messageLabel.textColor = [UIColor colorWithRed:239.0/255.0 green:167.0/255.0 blue:163.0/255.0 alpha:1.0];
            self.messageLabel.backgroundColor = [UIColor clearColor];
            self.messageLabel.text = message;
            
            // Calculate the number of lines it'll take to display the text
            numberOfLines = [[self.messageLabel lines]count];
            self.messageLabel.numberOfLines = numberOfLines;
            CGRect r = self.messageLabel.frame;
            r.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;//(1 == numberOfLines) ? self.titleLabel.frame.origin.y : self.titleLabel.frame.origin.y - 11.0;
            
            // This step is needed to avoid having the UILabel center the text in the middle
            [self.messageLabel sizeToFit];
            
            // Now we can determine the height of one line of text
            messageLineHeight = self.messageLabel.frame.size.height;
            r.size.height = self.messageLabel.frame.size.height * numberOfLines;
            r.size.width = viewWidth - 70.0;
            self.messageLabel.frame = r;
        }
        
        // Calculate the notice view height
        float noticeViewHeight;
        if (noticeType == WBNoticeViewTypeError) {
            noticeViewHeight = 50.0;
        } else if (noticeType == WBNoticeViewTypeSuccess) {
            noticeViewHeight = 40.0;
        } else if (noticeType == WBNoticeViewTypeInfo) {
            noticeViewHeight = 50.0;
        }

        float hiddenYOrigin = 0.0;
        if (numberOfLines > 1) {
            noticeViewHeight += (numberOfLines - 1) * messageLineHeight;
        }
        
        // Make sure we hide completely the view, including its shadow
        hiddenYOrigin = -noticeViewHeight - 20.0;
        
        // Make and add the notice view
        if (noticeType == WBNoticeViewTypeError) {
            self.noticeView = [[WBRedGradientView alloc]initWithFrame:CGRectMake(0.0, hiddenYOrigin, viewWidth, noticeViewHeight + 10.0)];
        } else if (noticeType == WBNoticeViewTypeSuccess) {
            self.noticeView = [[WBBlueGradientView alloc]initWithFrame:CGRectMake(0.0, hiddenYOrigin, viewWidth, noticeViewHeight + 10.0)];
        } else if (noticeType == WBNoticeViewTypeInfo) {
            self.noticeView = [[WBYellowGradientView alloc]initWithFrame:CGRectMake(0.0, hiddenYOrigin, viewWidth, noticeViewHeight + 10.0)];
        }
    
        [view addSubview:self.noticeView];
        
        // Make and add the icon view
        UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0, 10.0, 30.0, 30.0)];
        iconView.image = [UIImage imageWithContentsOfFile:noticeIconImageName];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.alpha = 0.8;
        [self.noticeView addSubview:iconView];
        
        // Add the title label
        [self.noticeView addSubview:self.titleLabel];
        
        // Add the message label if it's an error notice
        if ((WBNoticeViewTypeError == noticeType) || (WBNoticeViewTypeInfo == noticeType)) {
            [self.noticeView addSubview:self.messageLabel];
        }
        
        // Add the drop shadow to the notice view
        self.noticeView.layer.shadowColor = [[UIColor blackColor]CGColor];
        self.noticeView.layer.shadowOffset = CGSizeMake(0.0, 3);
        self.noticeView.layer.shadowOpacity = 0.50;
        self.noticeView.layer.masksToBounds = NO;
        self.noticeView.layer.shouldRasterize = YES;
        
        // Go ahead, display it and then hide it automatically
        [UIView animateWithDuration:duration animations:^ {
            CGRect newFrame = self.noticeView.frame;
            newFrame.origin.y = origin;
            self.noticeView.frame = newFrame;
            self.noticeView.alpha = alpha;
        } completion:^ (BOOL finished) {
            if (finished) {
                // Display for a while, then hide it again
                [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^ {
                    CGRect newFrame = self.noticeView.frame;
                    newFrame.origin.y = hiddenYOrigin;
                    self.noticeView.frame = newFrame;
                } completion:^ (BOOL finished) {
                    if (finished) {  
                        // Cleanup
                        [self cleanup];
                    }
                }];
            }
        }];
    }
}

- (void)cleanup
{
    [self.noticeView removeFromSuperview];
    self.noticeView = nil;
    self.titleLabel = nil;
    self.messageLabel = nil;
}

- (void)dealloc
{
    [self cleanup];
    [super dealloc];
}



@end
