//
//  main.m
//  Swiss Plates
//
//  Created by Alain Furter on 04.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Swiss_PlatesAppDelegate.h"

/*
int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
*/

int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([Swiss_PlatesAppDelegate class]));
    }
}