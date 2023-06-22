//
//  MapViewController.h
//  Swiss Plates
//
//  Created by Alain Furter on 09.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ASIHTTPRequest.h"
#import "PersonSearchResultCell.h"
#import "OwnerAnnotation.h"

@class PersonSearchResultCell;
@class OwnerAnnotation;

@interface MapViewController : UIViewController <MKMapViewDelegate> {
    
    MKMapView *ownerLocation;
    UIActivityIndicatorView *downloadActivityIndicator;
    UILabel *downloadActivityLabel;
    
    PersonSearchResultCell *currentPerson;
    
    ASIHTTPRequest *currentRequest;
    BOOL isDownloading;
    
    OwnerAnnotation *ownerAnnotation;
}
@property (nonatomic, retain) IBOutlet MKMapView *ownerLocation;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *downloadActivityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *downloadActivityLabel;

@property (nonatomic, retain) OwnerAnnotation *ownerAnnotation;

@property (assign) PersonSearchResultCell *currentPerson;
@property (assign) ASIHTTPRequest *currentRequest;
@property (assign) BOOL isDownloading;

- (IBAction)pushBackController:(id)sender;
- (void) resolveAddress;

@end
