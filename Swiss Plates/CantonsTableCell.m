//
//  CantonsTableCell.m
//  Swiss Plates
//
//  Created by Alain Furter on 04.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import "CantonsTableCell.h"


@implementation CantonsTableCell

@synthesize background, cantonCode, cantonName, cantonImage, typeImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
 
    [UIView beginAnimations:@"AlphaChange" context:NULL];
	[UIView setAnimationDuration:0.15];
		    
    if (selected == YES) 
        background.alpha = .5;
    else
        background.alpha = 1;
    
    [UIView commitAnimations];
        
    // Configure the view for the selected state
}

- (void)dealloc
{
    [background release];
    [cantonCode release];
    [cantonName release];
    [cantonImage release];
    [typeImage release];
    [super dealloc];
}

@end
