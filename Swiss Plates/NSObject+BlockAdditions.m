//
//  NSObject+BlockAdditions.m
//  Swiss Plates
//
//  Created by Alain Furter on 07.06.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import "NSObject+BlockAdditions.h"

@implementation NSObject (BlockAdditions)

- (void)my_callBlock
{
    void (^block)(void) = (id)self;
    block();
}

@end
