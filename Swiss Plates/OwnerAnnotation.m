//
//  OwnerAnnotation.m
//  Swiss Plates
//
//  Created by Alain Furter on 09.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import "OwnerAnnotation.h"


@implementation OwnerAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)location title:_title subtitle:_subTitle {
    self = [super init];
    if (self != nil) {
        coordinate = location;
        title = _title;
        [title retain];
        subtitle = _subTitle;
        [subtitle retain];
    }
    return self;
}

- (void)dealloc {
    [title release];
    [subtitle release];
    [super dealloc];
}

@end
