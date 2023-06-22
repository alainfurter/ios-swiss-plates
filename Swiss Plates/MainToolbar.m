//
//  MainToolbar.m
//  Swiss Plates
//
//  Created by Alain on 25.09.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import "MainToolbar.h"

@implementation MainToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, 320, 44);
        UIImageView *toolbarImageView = [[UIImageView alloc] initWithFrame: self.frame];
        [toolbarImageView setImage: [UIImage imageNamed: @"TbBackground.png"]];
        [self addSubview: toolbarImageView];
        
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
