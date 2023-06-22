//
//  CantonsSearchViewController.m
//  Swiss Plates
//
//  Created by Alain Furter on 05.06.12.
//  Copyright (c) 2012 Corporate Finance Manager. All rights reserved.
//

#import "CantonsSearchViewController.h"
#import "CantonsTableCell.h"
#import "WebSearchViewController.h"
#import "SupportViewController.h"

#import "UINavigationController+PushPopAfterAnimation.h"

#define kProductIDAdfreePurchase    @"201205180101"

@implementation CantonsSearchViewController

@synthesize CustomNavigationBar;
@synthesize customNavigationLabel;

@synthesize cantonsTable, list, tableCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [view setBackgroundColor:[UIColor colorWithPatternImage: [UIImage imageNamed:  @"BackgroundPatternDotted.png"]]];
    self.view = view;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TOOLBARHEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOOLBARHEIGHT)];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewStylePlain;
    tableView.rowHeight = 40;
    tableView.sectionHeaderHeight = 22.0;
    tableView.sectionFooterHeight = 22.0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    
    self.cantonsTable = tableView;
    
    [self.view addSubview: self.cantonsTable];
}

- (NSString *) machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
	
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
        
    CGFloat frameHeight = self.view.frame.size.height;

    if (self.cantonsTable.frame.size.height != (frameHeight - TOOLBARHEIGHT)) {
            
        #ifdef kLoggingIsOn
            NSLog(@"Cantons view: ads free, correct: %@", self.nibName);
            NSLog(@"Cantons view: ads free, correct: %.1f", self.cantonsTable.frame.size.height);
        #endif
            
        CGRect tableFrame = self.cantonsTable.frame;
        tableFrame.size.height = (frameHeight - TOOLBARHEIGHT);
        self.cantonsTable.frame = tableFrame;
    }

	self.cantonsTable.backgroundColor = [UIColor clearColor];
	self.cantonsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.cantonsTable.showsVerticalScrollIndicator = NO;
    
	[self.navigationController setNavigationBarHidden: YES];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CantonConfig" ofType:@"plist"];
    
    NSArray *cantonsList = [[NSDictionary dictionaryWithContentsOfFile: filePath] objectForKey: @"Cantons"];
    
    NSArray *filteredCantons;
    NSString *deviceType = [NSString stringWithString: [self machineName]];
    
    #ifdef  kLoggingIsOn
        NSLog(@"Devicetype: %@", [deviceType substringToIndex: 6]);
    #endif
    
#ifdef kCheckForiPodServiceRestrictions
    if ([[deviceType substringToIndex: 6] isEqualToString: @"iPhone"]) {
        
        #ifdef kSimulateiPodTouchPresence
            NSPredicate *iPodFilter = [NSPredicate predicateWithFormat: @"(Type != 2) AND (Type != 5)"];
            filteredCantons = [cantonsList filteredArrayUsingPredicate: iPodFilter];
        #else
            filteredCantons = cantonsList;
        #endif
        
    } else {
        NSPredicate *iPodFilter = [NSPredicate predicateWithFormat: @"(Type != 2) AND (Type != 5)"];
        filteredCantons = [cantonsList filteredArrayUsingPredicate: iPodFilter];
    }
    
    self.list = filteredCantons;
#else
    self.list = cantonsList;
    
#endif
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];   
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];  
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [self setCantonsTable:nil];
    [self setList:nil];
    [self setCustomNavigationBar:nil];
    [self setCustomNavigationLabel:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"CantonsCell";
    
    CantonsTableCell *cell = (CantonsTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"CantonsTableCell" owner:self options:nil];
        cell = tableCell;
        self.tableCell = nil;
    }
    
    NSString *preflanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *languageIdentifier;
    
    if ([preflanguage isEqualToString:@"en"] || [preflanguage isEqualToString:@"de"] || [preflanguage isEqualToString:@"fr"] || [preflanguage isEqualToString:@"it"]) {
        languageIdentifier = [preflanguage uppercaseString];
    } else languageIdentifier = @"EN";
    
    cell.cantonCode.text = [[list objectAtIndex: [indexPath row]] objectForKey: @"Code"];
    cell.cantonName.text = [[list objectAtIndex: [indexPath row]] objectForKey: [NSString stringWithFormat:@"Name%@", languageIdentifier]];
    cell.cantonImage.image = [UIImage imageNamed: [[list objectAtIndex: [indexPath row]] objectForKey: @"Flag"]];
    cell.typeImage.image = [UIImage imageNamed: [[list objectAtIndex: [indexPath row]] objectForKey: @"TypeImg"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //NSLog(@"Row selected: %d, %@", [indexPath row], [[list objectAtIndex: [indexPath row]] objectForKey: @"Code"]);
    
    //int currentTypeCode = [[[list objectAtIndex: [indexPath row]] objectForKey: @"Type"] intValue];
    
    //if (currentTypeCode == 1 || currentTypeCode == 3 || currentTypeCode == 6 || currentTypeCode == 7) {
    
    int rowTranslation;
    NSString *deviceType = [NSString stringWithString: [self machineName]];
    
    #ifdef  kLoggingIsOn
        NSLog(@"Devicetype: %@", [deviceType substringToIndex: 6]);
    #endif
    
#ifdef kCheckForiPodServiceRestrictions
    
    if ([[deviceType substringToIndex: 6] isEqualToString: @"iPhone"]) {
        
        #ifdef kSimulateiPodTouchPresence
            if ([indexPath row] == 0) rowTranslation = 0;
            if ([indexPath row] == 1) rowTranslation = 3;
            if ([indexPath row] == 2) rowTranslation = 4;
            if ([indexPath row] == 3) rowTranslation = 6;
            if ([indexPath row] == 4) rowTranslation = 11;
            if ([indexPath row] == 5) rowTranslation = 12;
            if ([indexPath row] == 6) rowTranslation = 13;
            if ([indexPath row] == 7) rowTranslation = 14;
            if ([indexPath row] == 8) rowTranslation = 16;
            if ([indexPath row] == 9) rowTranslation = 20;
            if ([indexPath row] == 10) rowTranslation = 21;
            if ([indexPath row] == 11) rowTranslation = 22;
            if ([indexPath row] == 12) rowTranslation = 23;
            if ([indexPath row] == 13) rowTranslation = 24;
            if ([indexPath row] == 14) rowTranslation = 25;
        #else
            rowTranslation = [indexPath row];
        #endif
        
    } else {;
        //NSLog(@"Indexpath: %d", [indexPath row]);
        if ([indexPath row] == 0) rowTranslation = 0;
        if ([indexPath row] == 1) rowTranslation = 3;
        if ([indexPath row] == 2) rowTranslation = 4;
        if ([indexPath row] == 3) rowTranslation = 6;
        if ([indexPath row] == 4) rowTranslation = 11;
        if ([indexPath row] == 5) rowTranslation = 12;
        if ([indexPath row] == 6) rowTranslation = 13;
        if ([indexPath row] == 7) rowTranslation = 14;
        if ([indexPath row] == 8) rowTranslation = 16;
        if ([indexPath row] == 9) rowTranslation = 20;
        if ([indexPath row] == 10) rowTranslation = 21;
        if ([indexPath row] == 11) rowTranslation = 22;
        if ([indexPath row] == 12) rowTranslation = 23;
        if ([indexPath row] == 13) rowTranslation = 24;
        if ([indexPath row] == 14) rowTranslation = 25;
        
         //NSLog(@"Indexpath: %d", rowTranslation);
    }
#else
   rowTranslation = [indexPath row];
    
#endif
    
    
    WebSearchViewController *webSearchViewController = [[[WebSearchViewController alloc] initWithOptions: [[[list objectAtIndex: [indexPath row]] objectForKey: @"Type"] intValue]
                                                                                              cantonCode:[[list objectAtIndex: [indexPath row]] objectForKey: @"Code"]
                                                                                                flagName:[[list objectAtIndex: [indexPath row]] objectForKey: @"Flag"]
                                                                                         cantonRowOption: rowTranslation] autorelease];
    
    //NSLog(@"Code: %@", [[list objectAtIndex: [indexPath row] objectForKey: @"Code"]);
    
    //NSLog(@"Row: %@", [list objectAtIndex: rowTranslation]);
    /*
    WebSearchViewController *webSearchViewController = [[[WebSearchViewController alloc] initWithOptions: [[[list objectAtIndex: [indexPath row]] objectForKey: @"Type"] intValue]
                                                                                              cantonCode:[[list objectAtIndex: [indexPath row]] objectForKey: @"Code"]
                                                                                                flagName:[[list objectAtIndex: [indexPath row]] objectForKey: @"Flag"]
                                                                                         cantonRowOption: [indexPath row]] autorelease];
    */
    /*
     UIButton* backButton = [UIButton buttonWithType: UIButtonTypeCustom]; // left-pointing shape!
     [backButton addTarget: webSearchViewController action:@selector(pushBack) forControlEvents:UIControlEventTouchUpInside];
     [backButton setTitle: NSLocalizedString(@"Back", @"NavigationBarBackButtonText") forState:UIControlStateNormal];
     [backButton setBackgroundImage: [UIImage imageNamed: @"BackButton.png"] forState: UIControlStateNormal];
     
     // create button item -- possible because UIButton subclasses UIView!
     UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
     
     self.navigationItem.backBarButtonItem = backItem;
     */
    
    /*
    UIView *currentView = (UIView *) webSearchViewController.view;
       
    [self.navigationController pushViewControllerAfterAnimation: webSearchViewController 
                                                       animated: YES 
                                                 animationBlock:^{
                                                     NSLog(@"Push animation bock"); 
                                                     
                                                     [UIView animateWithDuration:0.3
                                                                      animations:^{ 
                                                                          currentView.transform=CGAffineTransformMakeTranslation(0, -416);
                                                                          
                                                                      }
                                                                      completion:^(BOOL finished){
                                                        
                                                                      }];
                                                     
                                                     [UIView commitAnimations];  
                                                     
                                                     NSLog(@"SV: %.1f, %.1f, %.1f, %.1f", currentView.frame.origin.x, currentView.frame.origin.y,currentView.frame.size.width, currentView.frame.size.height);
                           
                                                       }]; */
    /*
    [self.navigationController pushViewControllerAfterAnimation: webSearchViewController 
                                                       animated: YES 
                                                 animationBlock:^{
                                                     NSLog(@"Push animation bock"); 
                                                     
                                                     NSLog(@"SV: %.1f, %.1f, %.1f, %.1f", currentView.frame.origin.x, currentView.frame.origin.y,currentView.frame.size.width, currentView.frame.size.height);
                                                     
                                                     CGAffineTransformMakeTranslation(0, -416);
                                                     
                                                     NSLog(@"SV: %.1f, %.1f, %.1f, %.1f", currentView.frame.origin.x, currentView.frame.origin.y,currentView.frame.size.width, currentView.frame.size.height);
                                                     
                                                     [currentView setNeedsDisplay];
                                                     
                                                 }]; */
    
#ifdef tUseCustomPushPop
    UIView *currentView = (UIView *) webSearchViewController.view;
    
    
    [webSearchViewController setViewAppearsFromCustomTabbarPush:YES];
    //NSLog(@"ViewAppearsFromCustomTabbar: %@", [webSearchViewController viewAppearsFromCustomTabbarPush]?@"Y":@"N");
    CGFloat height = self.view.frame.size.height;
    
    [self.navigationController pushViewControllerAfterAnimation: webSearchViewController 
                                                       animated: YES 
                                                 animationBlock:^{
                                                     
                                                     currentView.transform = CGAffineTransformMakeTranslation(0, height);
                                                }];
#else
    [webSearchViewController setViewAppearsFromCustomTabbarPush:YES];
    [self.navigationController pushViewController:webSearchViewController animated:YES];
#endif
    
    //}
}

- (void)dealloc
{
    [cantonsTable release];
    [list release];
    [CustomNavigationBar release];
    [customNavigationLabel release];
    [super dealloc];
}

@end
