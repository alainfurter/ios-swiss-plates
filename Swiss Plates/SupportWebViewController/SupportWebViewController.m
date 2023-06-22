//
//  SupportWebViewController.m
//  Tweet Clock
//
//  Created by Alain Furter on 21.02.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import "SupportWebViewController.h"


@implementation SupportWebViewController
@synthesize loadingLabel;
@synthesize backButton;

@synthesize webView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    self.hidesBottomBarWhenPushed = YES;
    return self;
}


- (IBAction)pushBackController:(id)sender {
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void) pushback
{
	//AudioServicesPlaySystemSound (waveSoundID);
    
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
	
	//[self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//NSLog(@"Web page fully loaded");
	
	[UIView beginAnimations:@"AlarmViewFade" context:NULL];
	[UIView setAnimationDuration:0.35];
	
	self.webView.alpha = 1.0;
	
	[UIView commitAnimations];
}

- (void) loadWebURL:(NSString *)urlString
{
	if(!urlString) return;
	
	NSString *urlAddress = [NSString stringWithString: urlString];
	
	//NSLog(@"Url address: %@", urlAddress);
	
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:requestObj];
	
}

-(void) viewWillAppear:(BOOL)animated 
{
	[self.navigationController setNavigationBarHidden: YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [loadingLabel setText:NSLocalizedString(@"Loading...", @"Loading web support view title label")];
    [backButton setTitle: NSLocalizedString(@"Back", @"Back web support view button") forState:UIControlStateNormal];
    
	
	/*
	NSString *waveFileName = [[NSBundle mainBundle] pathForResource:@"Pushwave" ofType:@"wav"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:waveFileName], &waveSoundID);
	*/
	/*
	UIBarButtonItem *leftBarButtomItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Back", @"Back Bar Buttom Item Text") 
																		  style: UIBarButtonItemStyleBordered 
																		 target: self 
																		 action: @selector(pushback)];
	self.navigationItem.leftBarButtonItem = leftBarButtomItem;
	[leftBarButtomItem release];
	*/
	/*
	NSString *urlAddress = [NSString stringWithString: @"http://apps.fmlcreations.com"];
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:requestObj];
	 */
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setLoadingLabel:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.webView = nil;
}


- (void)dealloc {
	[webView release];
    [loadingLabel release];
    [backButton release];
    [super dealloc];
}


@end
