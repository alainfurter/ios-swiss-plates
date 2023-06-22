//
//  WBErrorNoticeView.m
//  NoticeView
//
//  Created by Tito Ciuro on 5/25/12.
//  Copyright (c) 2012 Tito Ciuro. All rights reserved.
//

#import "WBInfoNoticeView.h"
#import "WBNoticeView_Private.h"

@implementation WBInfoNoticeView

@synthesize message;

+ (WBInfoNoticeView *)infoNoticeInView:(UIView *)view title:(NSString *)title message:(NSString *)message
{
    WBInfoNoticeView *notice = [[WBInfoNoticeView alloc]initWithView:view title:title];
    
    notice.message = message;
    
    return notice;
}

+ (WBInfoNoticeView *)infoNoticeInWindow:(NSString *)title message:(NSString *)message {
    
    UIWindow *currentWindow = [[UIApplication sharedApplication].windows objectAtIndex: 0];
    
    WBInfoNoticeView *notice = [[WBInfoNoticeView alloc]initWithView:currentWindow title:title];
    
    notice.message = message;
    
    return notice;
}

- (void)show
{
    [self _showNoticeOfType:WBNoticeViewTypeInfo
                       view:self.view
                      title:self.title
                    message:self.message
                   duration:self.duration
                      delay:self.delay
                      alpha:self.alpha
                    yOrigin:64];
}

@end
