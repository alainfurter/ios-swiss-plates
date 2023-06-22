//
//  OwnerAnnotation.h
//  Swiss Plates
//
//  Created by Alain Furter on 09.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface OwnerAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)location title:(NSString *)title subtitle:(NSString *)subTitle;

@end

