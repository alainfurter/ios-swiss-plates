//
//  MapViewController.m
//  Swiss Plates
//
//  Created by Alain Furter on 09.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import "MapViewController.h"

#define CreateRegex(regexString)  [NSRegularExpression regularExpressionWithPattern: regexString options:NSRegularExpressionCaseInsensitive error:NULL]
#define RegexMatch(regexExpression, stringToSearch) [regexExpression firstMatchInString: stringToSearch options:0 range:NSMakeRange(0, [stringToSearch length])]
#define GetMatchString(regexMatch, stringToSearch) [stringToSearch substringWithRange: [regexMatch rangeAtIndex:1]]

@implementation MapViewController
@synthesize ownerLocation;
@synthesize downloadActivityIndicator;
@synthesize downloadActivityLabel;
@synthesize currentPerson;
@synthesize currentRequest, isDownloading;
@synthesize ownerAnnotation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentRequest = nil;
        isDownloading = NO;
    }
    return self;
}

- (void)dealloc
{
    if (isDownloading && currentRequest) {
        [currentRequest clearDelegatesAndCancel];
    }
    [self.ownerLocation removeAnnotations: [self.ownerLocation annotations]];
    [ownerAnnotation release];
    [ownerLocation release];
    [downloadActivityIndicator release];
    [downloadActivityLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated 
{		
    [super viewWillAppear:animated];
    
    //NSLog(@"Current viewcontroller: %@", self.nibName);
} 

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.downloadActivityIndicator startAnimating];
    self.downloadActivityLabel.text =  NSLocalizedString(@"Resolving address...", @"Resolving address mapview label");
}

- (void)viewDidUnload
{
    [self setOwnerAnnotation: nil];
    [self setOwnerLocation:nil];
    [self setDownloadActivityIndicator:nil];
    [self setDownloadActivityLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pushBackController:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {   
    
    for (MKAnnotationView *aV in views) {
        
        // Don't pin drop if annotation is user location
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        
        // Check if current annotation is inside visible map rect, else go to next one
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(mapView.visibleMapRect, point)) {
            continue;
        }
        
        CGRect endFrame = aV.frame;
        
        // Move annotation out of view
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
        
        // Animate drop
        [UIView animateWithDuration:0.3 delay:0.03*[views indexOfObject:aV] options:UIViewAnimationCurveLinear animations:^{
            
            aV.frame = endFrame;
            
            // Animate squash
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
                    
                }completion:^(BOOL finished){
                    if (finished) {
                        [UIView animateWithDuration:0.5 animations:^{
                            aV.transform = CGAffineTransformIdentity;
                            [self performSelector:@selector(showOwnerLocation:) withObject: aV.annotation afterDelay: 0.5];
                        }];
                    }
                }];
            }
        }];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation: (id <MKAnnotation>)annotation {
    //MKPinAnnotationView *pinView = nil; 
    
    static NSString *AnnotationViewID = @"annotationViewID";
    MKAnnotationView *annotationView = (MKAnnotationView *)[mV dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
        annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
    
    annotationView.image = [UIImage imageNamed:@"CustomPin.png"];
    annotationView.annotation = annotation;
    annotationView.canShowCallout = YES;
    
    //[annotationView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:@"pinSelected"];
    //[annotationView setEnabled:YES];
    
    return annotationView;
}

- (void) showOwnerLocation:(OwnerAnnotation*)ownerAnnotation {
    [self.ownerLocation selectAnnotation: self.ownerAnnotation animated: YES];
}

- (void) resolveAddress {
    if (!currentPerson) return;
    if (([currentPerson.nameLabel.text length] == 0) || ([currentPerson.addressLabel.text length] == 0) || ([currentPerson.plzplaceLabel.text length] == 0))  return;
    if (isDownloading) return; if (currentRequest) return;
    if (([currentPerson.longitude floatValue] != 0.0f) && ([currentPerson.latitude floatValue] != 0.0f)) {
        [self.downloadActivityIndicator stopAnimating];
        [self.downloadActivityIndicator setHidden: YES];
        [self.downloadActivityLabel setHidden: YES];
        
        [self.ownerLocation removeAnnotations: [self.ownerLocation annotations]];
        
        CLLocationCoordinate2D ownerLocationCoordinate;
        ownerLocationCoordinate.latitude = [[currentPerson latitude] floatValue];
        ownerLocationCoordinate.longitude = [[currentPerson longitude] floatValue];
        self.ownerAnnotation = [[OwnerAnnotation alloc] initWithCoordinate:ownerLocationCoordinate title:currentPerson.nameLabel.text subtitle:[NSString stringWithFormat: @"%@ / %@", currentPerson.addressLabel.text, currentPerson.plzplaceLabel.text]];
    
        [self.ownerLocation addAnnotation: self.ownerAnnotation];
        [self.ownerLocation setRegion:MKCoordinateRegionMake(ownerLocationCoordinate, MKCoordinateSpanMake(0.00449964 , 0.00449964)) animated: YES];
        self.ownerLocation.hidden = NO;
        if (self.ownerAnnotation) [self.ownerLocation selectAnnotation: self.ownerAnnotation  animated: YES]; 
    }
    [ASIHTTPRequest setDefaultTimeOutSeconds: 20];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    NSString *googleBaseString = @"http://maps.google.com/maps/api/geocode/xml?address=";
	NSString *sensorAdd = @"&sensor=false";
	NSString *regionAdd = @"&region=ch";
    NSString *addressString = [NSString stringWithFormat: @"%@ %@", currentPerson.addressLabel.text, currentPerson.plzplaceLabel.text];
    
    NSString *urlString = [[[googleBaseString stringByAppendingString: [addressString stringByEscapingURL]] 
							stringByAppendingString: regionAdd] stringByAppendingString: sensorAdd];
    
    //NSLog(@"Search string: %@", urlString);
        
    NSURL *url = [NSURL URLWithString: urlString];
    
    __block ASIHTTPRequest *cookieRequest = [ASIHTTPRequest requestWithURL:url];
    [cookieRequest setDelegate:self]; [cookieRequest setCachePolicy: ASIDoNotReadFromCacheCachePolicy];
    [cookieRequest setRequestMethod:@"GET"];
    [cookieRequest addRequestHeader:@"User-Agent" value:@"Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0)"];

    [cookieRequest setCompletionBlock:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        NSString *responseString = [cookieRequest responseString];
        //NSLog(@"Response: %@", responseString);
        //NSLog(@"Response header: %@", [cookieRequest responseHeaders]);
        
        isDownloading = NO;
        [self.downloadActivityIndicator stopAnimating];
        [self.downloadActivityIndicator setHidden: YES];
        
        NSString *latString = nil;
        NSString *lngString = nil;
        
        if (responseString) {
            if ([responseString length] != 0) {
                NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
                NSString *cleanedStringResponse = [NSString stringWithString: [[responseString componentsSeparatedByCharactersInSet: cs] componentsJoinedByString: @""]];
                
                //NSLog(@"Cleaned response: %@", cleanedStringResponse);
                
                NSTextCheckingResult *locationMatch = RegexMatch(CreateRegex(@"<location>(.+?)</location>"), cleanedStringResponse);
                if (locationMatch) { 
                    NSString *locationString = GetMatchString(locationMatch, cleanedStringResponse);
                    
                    //NSLog(@"Match 1: %@", locationString);
                    
                    NSTextCheckingResult *latMatch = RegexMatch(CreateRegex(@"<lat>(.+?)</lat>"), locationString);
                    NSTextCheckingResult *lngMatch = RegexMatch(CreateRegex(@"<lng>(.+?)</lng>"), locationString);
                    if (latMatch) latString = GetMatchString(latMatch, locationString);
                    if (lngMatch) lngString = GetMatchString(lngMatch, locationString);
                    
                    //NSLog(@"Match 2: %@", latString);
                    //NSLog(@"Match 3: %@", lngString);
                } 
            }
        }
        
        if (!latString || ! lngString) {
            self.downloadActivityLabel.text =  NSLocalizedString(@"Could not resolve address", @"Address resolving answer message");
            return;
        }
        
        [self.downloadActivityLabel setHidden: YES];
        
        [self.ownerLocation removeAnnotations: [self.ownerLocation annotations]];
        
        CLLocationCoordinate2D ownerLocationCoordinate;
        ownerLocationCoordinate.latitude = [latString floatValue];
        ownerLocationCoordinate.longitude = [lngString floatValue];
    
        if (self.ownerAnnotation) {
            [self setOwnerAnnotation: nil];
            [ownerAnnotation release];
        }
        
        
        self.ownerAnnotation = [[OwnerAnnotation alloc] initWithCoordinate: ownerLocationCoordinate title:currentPerson.nameLabel.text subtitle:[NSString stringWithFormat: @"%@ / %@", currentPerson.addressLabel.text, currentPerson.plzplaceLabel.text]];
        [self.ownerLocation addAnnotation:self.ownerAnnotation];
        
        //[ownerAnnotation release];
        
        [self.ownerLocation setRegion:MKCoordinateRegionMake(ownerLocationCoordinate, MKCoordinateSpanMake(0.00449964 , 0.00449964)) animated: YES];
                
        self.ownerLocation.hidden = NO;
        currentPerson.latitude = [NSNumber numberWithFloat: [latString floatValue]];
        currentPerson.longitude = [NSNumber numberWithFloat: [lngString floatValue]];
    }];
    
    [cookieRequest setFailedBlock:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        //NSLog(@"Response header: %@", [cookieRequest responseHeaders]);
        //NSError *error = [cookieRequest error];
        //NSLog(@"Resolve address failed %@",[error description]);
        
        [self.downloadActivityLabel setText: NSLocalizedString(@"Could not resolve address", @"Address resolving answer message")];
        
        isDownloading = NO;
        [self.downloadActivityIndicator stopAnimating];
        [self.downloadActivityIndicator setHidden: YES];
        //[self.downloadActivityLabel setHidden: YES];
        
    }];
    
    isDownloading = YES;
    currentRequest = cookieRequest;
    [cookieRequest startAsynchronous];
}

@end
