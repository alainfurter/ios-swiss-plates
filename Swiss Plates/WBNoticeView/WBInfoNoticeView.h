//
//  WBErrorNoticeView.h
//  NoticeView
//
//  Created by Tito Ciuro on 5/25/12.
//  Copyright (c) 2012 Tito Ciuro. All rights reserved.
//

#import "WBBaseNoticeView.h"

@interface WBInfoNoticeView : WBBaseNoticeView

+ (WBInfoNoticeView *)infoNoticeInView:(UIView *)view title:(NSString *)title message:(NSString *)message;

+ (WBInfoNoticeView *)infoNoticeInWindow:(NSString *)title message:(NSString *)message;

@property (nonatomic, strong) NSString *message; // default: @"Information not provided."

@end
