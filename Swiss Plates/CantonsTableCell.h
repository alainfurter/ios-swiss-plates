//
//  CantonsTableCell.h
//  Swiss Plates
//
//  Created by Alain Furter on 04.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CantonsTableCell : UITableViewCell {
    UIImageView *background;
    UILabel *cantonCode;
    UILabel *cantonName;
    UIImageView *cantonImage;
    UIImageView *typeImage;
}

@property (nonatomic, retain) IBOutlet UIImageView *background;
@property (nonatomic, retain) IBOutlet UILabel *cantonCode;
@property (nonatomic, retain) IBOutlet UILabel *cantonName;
@property (nonatomic, retain) IBOutlet UIImageView *cantonImage;
@property (nonatomic, retain) IBOutlet UIImageView *typeImage;

@end
