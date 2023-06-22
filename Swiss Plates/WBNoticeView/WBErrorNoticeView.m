//
//  WBErrorNoticeView.m
//  NoticeView
//
//  Created by Tito Ciuro on 5/25/12.
//  Copyright (c) 2012 Tito Ciuro. All rights reserved.
//

#import "WBErrorNoticeView.h"
#import "WBNoticeView_Private.h"

@implementation WBErrorNoticeView

@synthesize message;

+ (WBErrorNoticeView *)errorNoticeInView:(UIView *)view title:(NSString *)title message:(NSString *)message
{
    WBErrorNoticeView *notice = [[WBErrorNoticeView alloc]initWithView:view title:title];
    
    notice.message = message;
    
    return notice;
}

+ (WBErrorNoticeView *)errorNoticeInWindow:(NSString *)title message:(NSString *)message {
    
    UIWindow *currentWindow = [[UIApplication sharedApplication].windows objectAtIndex: 0];

    WBErrorNoticeView *notice = [[WBErrorNoticeView alloc]initWithView:currentWindow title:title];
    
    notice.message = message;
    
    return notice;
}


- (void)show
{
    [self _showNoticeOfType:WBNoticeViewTypeError
                       view:self.view
                      title:self.title
                    message:self.message
                   duration:self.duration
                      delay:self.delay
                      alpha:self.alpha
                    yOrigin:64];
}

@end
