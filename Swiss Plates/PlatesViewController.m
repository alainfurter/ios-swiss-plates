//
//  PlatesViewController.m
//  Swiss Plates
//
//  Created by Alain Furter on 04.04.11.
//  Copyright 2011 Corporate Finance Manager. All rights reserved.
//

#import "PlatesViewController.h"

@implementation PlatesViewController

@synthesize editButton;
@synthesize fetchedResultsController, ownersTable, tableCell, controlCell;
@synthesize controlRowIndexPath, tappedIndexPath;

@synthesize emptyImageView;
@synthesize emptyLabel;

//NSInteger selectedCellRow;
//NSInteger previousCellRow;

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
    tableView.rowHeight = 83;
    tableView.sectionHeaderHeight = 35.0;
    tableView.sectionFooterHeight = 5.0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    
    self.ownersTable = tableView;
    
    [self.view addSubview: self.ownersTable];
    
    self.emptyImageView = [[UIImageView alloc] initWithFrame: CGRectMake(54, 57+EMPTYADJ, 213, 230)];
    [self.emptyImageView setImage: [UIImage imageNamed: @"OwnerDBEmptyHint.png"]];
    self.emptyImageView.hidden = YES;
    self.emptyLabel = [[UILabel alloc] initWithFrame: CGRectMake(82, 185+EMPTYADJ, 153, 81)];
    self.emptyLabel.font = [UIFont systemFontOfSize: 17.0];
    self.emptyLabel.textColor = [UIColor colorWithWhite: 0.8 alpha:1.0];
    self.emptyLabel.backgroundColor = [UIColor clearColor];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.emptyLabel.numberOfLines = 4;
    self.emptyLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    //self.emptyLabel.minimumFontSize = 10.0;
    self.emptyLabel.minimumScaleFactor = 1.0;
    self.emptyLabel.transform = CGAffineTransformMakeRotation(-0.05);
    self.emptyLabel.text = NSLocalizedString(@"Tap on the search button in order to start a search", @"DB is empty box text");
    [self.view addSubview: self.emptyImageView];
    [self.view addSubview: self.emptyLabel];
    
}

-(UIView*)parentTarget {
    // To make it work with UINav & UITabbar as well
    UIViewController * target = self;
    while (target.parentViewController != nil) {
        target = target.parentViewController;
    }
    return target.view;
}

-(CAAnimationGroup*)animationGroupForward:(BOOL)_forward {
    // Create animation keys, forwards and backwards
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, 15.0f*M_PI/180.0f, 1, 0, 0);
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = t1.m34;
    t2 = CATransform3DTranslate(t2, 0, [self parentTarget].frame.size.height*-0.08, 0);
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:t1];
    animation.duration = kSemiModalAnimationDuration/2;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.toValue = [NSValue valueWithCATransform3D:(_forward?t2:CATransform3DIdentity)];
    animation2.beginTime = animation.duration;
    animation2.duration = animation.duration;
    animation2.fillMode = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:animation.duration*2];
    [group setAnimations:[NSArray arrayWithObjects:animation,animation2, nil]];
    return group;
}

-(void)presentSemiViewController:(UIViewController*)vc {
    [self presentSemiView:vc.view];
}

-(void)presentSemiView:(UIView*)vc {
    // Determine target
    UIView * target = [self parentTarget];
    
    if (![target.subviews containsObject:vc]) {
        // Calulate all frames
        CGRect sf = vc.frame;
        CGRect vf = target.frame;
        CGRect f  = CGRectMake(0, vf.size.height-sf.size.height, vf.size.width, sf.size.height);
        CGRect of = CGRectMake(0, 0, vf.size.width, vf.size.height-sf.size.height);
        
        // Add semi overlay
        UIView * overlay = [[UIView alloc] initWithFrame:target.bounds];
        overlay.backgroundColor = [UIColor blackColor];
        
        // Take screenshot and scale
        UIGraphicsBeginImageContext(target.bounds.size);
        [target.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIImageView * ss = [[UIImageView alloc] initWithImage:image];
        [overlay addSubview:ss];
        [target addSubview:overlay];
        
        // Dismiss button
        // Don't use UITapGestureRecognizer to avoid complex handling
        UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissButton addTarget:self action:@selector(dismissSemiModalView) forControlEvents:UIControlEventTouchUpInside];
        dismissButton.backgroundColor = [UIColor clearColor];
        dismissButton.frame = of;
        [overlay addSubview:dismissButton];
        
        // Begin overlay animation
        [ss.layer addAnimation:[self animationGroupForward:YES] forKey:@"pushedBackAnimation"];
        [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
            ss.alpha = 0.5;
        }];
        
        // Present view animated
        vc.frame = CGRectMake(0, vf.size.height, vf.size.width, sf.size.height);
        [target addSubview:vc];
        vc.layer.shadowColor = [[UIColor blackColor] CGColor];
        vc.layer.shadowOffset = CGSizeMake(0, -2);
        vc.layer.shadowRadius = 5.0;
        vc.layer.shadowOpacity = 0.8;
        [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
            vc.frame = f;
        }];
    }
}

-(void)dismissSemiModalView {
    UIView * target = [self parentTarget];
    UIView * modal = [target.subviews objectAtIndex:target.subviews.count-1];
    UIView * overlay = [target.subviews objectAtIndex:target.subviews.count-2];
    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
        modal.frame = CGRectMake(0, target.frame.size.height, modal.frame.size.width, modal.frame.size.height);
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        [modal removeFromSuperview];
    }];
    
    // Begin overlay animation
    UIImageView * ss = (UIImageView*)[overlay.subviews objectAtIndex:0];
    [ss.layer addAnimation:[self animationGroupForward:NO] forKey:@"bringForwardAnimation"];
    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
        ss.alpha = 1;
    }];
}

#pragma mark -- Table view methods

- (BOOL)checkVisibilityOfCell:(NSIndexPath *)indexPath {
    
    CGRect cellRect = [ownersTable rectForRowAtIndexPath:indexPath];
    cellRect = [ownersTable convertRect:cellRect toView:ownersTable.superview];
    BOOL completelyVisible = CGRectContainsRect(ownersTable.frame, cellRect);
    return completelyVisible;
}

-(BOOL)isRowZeroVisible:(NSIndexPath *)indexPath {
    NSArray *indexes = [ownersTable indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if ([index isEqual: indexPath]) {
            return YES;
        }
    }
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    int scrollDirection;
    if (lastContentOffset > scrollView.contentOffset.y)
        scrollDirection = DOWN;
    else if (lastContentOffset < scrollView.contentOffset.y) 
        scrollDirection = UP;
    lastContentOffset = scrollView.contentOffset.y;
    
    //NSLog(@"Scroll direction: %@", (scrollDirection == UP)?@"UP":@"DOWN");
    
    if (self.controlRowIndexPath) {
        if (scrollDirection == UP) {
            NSIndexPath *dataRowIndexPath = [NSIndexPath indexPathForRow: [self modelRowforRow: self.controlRowIndexPath.row] inSection: self.controlRowIndexPath.section];    
            
            PersonSearchResultCell *personCell = (PersonSearchResultCell *)[ownersTable cellForRowAtIndexPath: dataRowIndexPath];
            
            if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
                
                #ifdef kLoggingIsOn
                    NSLog(@"Scrolling up: delete control box, personCell not there anymore");
                #endif
                
                NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:self.controlRowIndexPath.row inSection:self.controlRowIndexPath.section];
                
                self.tappedIndexPath = nil;
                self.controlRowIndexPath = nil;
                
                if(indexPathToDelete.row != 0){
                    [ownersTable beginUpdates];
                    [ownersTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
                    [ownersTable endUpdates];
                }
            }
            
            if (![self checkVisibilityOfCell: dataRowIndexPath]) {
                
                #ifdef kLoggingIsOn
                    NSLog(@"Scrolling up: delete control box, personCell not visible anymore");
                #endif
                
                NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:self.controlRowIndexPath.row inSection:self.controlRowIndexPath.section];
                
                self.tappedIndexPath = nil;
                self.controlRowIndexPath = nil;
                
                if(indexPathToDelete.row != 0){
                    [ownersTable beginUpdates];
                    [ownersTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
                    [ownersTable endUpdates];
                }
            }
        }
        
        if (scrollDirection == DOWN) {
            if (![self checkVisibilityOfCell: self.controlRowIndexPath]) {
                //NSLog(@"Scrolling down: controlBox is not visible");
                
                NSIndexPath *dataRowIndexPath = [NSIndexPath indexPathForRow: [self modelRowforRow: self.controlRowIndexPath.row] inSection: self.controlRowIndexPath.section];    
                
                PersonSearchResultCell *personCell = (PersonSearchResultCell *)[ownersTable cellForRowAtIndexPath: dataRowIndexPath];
                if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
                    NSLog(@"Abnormal result: scroll view did scroll: scrolling down: check personcell if runBounceNoAnimation exists");
                    return;
                }
                
                //NSLog(@"Persons name: %@", personCell.nameLabel.text);
                
                if (![self checkVisibilityOfCell: dataRowIndexPath]) {
                    //NSLog(@"Person cell before control box is not visible");
                    
                    #ifdef kLoggingIsOn
                        NSLog(@"Scroll down: delete control box");
                    #endif
                    
                    NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:self.controlRowIndexPath.row inSection:self.controlRowIndexPath.section];
                    
                    self.tappedIndexPath = nil;
                    self.controlRowIndexPath = nil;
                    
                    if(indexPathToDelete.row != 0){
                        [ownersTable beginUpdates];
                        [ownersTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
                        [ownersTable endUpdates];
                    }

                } else {
                    //NSLog(@"Person cell before control box is visible");
                }
            } else {
                //NSLog(@"Scrolling down: controlBox is visible");
            }
        }
    }
}


- (NSIndexPath *)modelIndexPathforIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"ModelIndexPathForIndexPath enter: %d", indexPath.row);
    
    int whereIsTheControlRow = self.controlRowIndexPath.row;
    if(self.controlRowIndexPath != nil && indexPath.row > whereIsTheControlRow)
        return [NSIndexPath indexPathForRow:indexPath.row - 1 inSection: [indexPath section]]; 
    return indexPath;
}

- (int)modelRowforRow:(int)row
{    
    int whereIsTheControlRow = self.controlRowIndexPath.row;
    if(self.controlRowIndexPath != nil && row >= whereIsTheControlRow)
        return row - 1; 
    return row;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//NSLog(@"Number of sections ind table view: %d",[[fetchedResultsController sections] count]);
	
    #ifdef kLoggingIsOn
        //NSLog(@"Ownerstable: numberOfSectionsInTableview: enter: %d", [[fetchedResultsController sections] count]);
    #endif
    
	return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
    
    #ifdef kLoggingIsOn
        //NSLog(@"Ownerstable: numberOfRowsInSection: enter");
    #endif
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    
    if(self.controlRowIndexPath) {
        
        #ifdef kLoggingIsOn
            //NSLog(@"Ownerstable: numberOfRowsInSection with controlbox: %d", [sectionInfo numberOfObjects] + 1);
        #endif
        
        #ifdef NONETWORK
            return 9;
        #endif
        
        return [sectionInfo numberOfObjects] + 1;
    } else {
        
        #ifdef kLoggingIsOn
            //NSLog(@"Ownerstable: numberOfRowsInSection: %d", [sectionInfo numberOfObjects]);
        #endif
        
        #ifdef NONETWORK
            return 8;
        #endif
        
        return [sectionInfo numberOfObjects];
    }
}

/*
-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIImageView *headerImageView = [[[UIImageView alloc] initWithImage: [UIImage imageNamed: @"OwnerRowTopMarker.png"]] autorelease];
    CGRect tempFrame = headerImageView.frame;
    tempFrame.size.height = tempFrame.size.height - 2;
    
    UIView *headerView = [[[UIView alloc] initWithFrame: tempFrame] autorelease];
    [headerView addSubview: headerImageView];
    
    return headerView;
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#ifdef kLoggingIsOn
    NSLog(@"Ownerstable: cellForRowAtIndexPath: enter: row: %d", indexPath.row);
#endif
        
    if (self.controlRowIndexPath) {
        
        if ([indexPath isEqual:self.controlRowIndexPath]) {
            
            #ifdef kLoggingIsOn
                NSLog(@"Ownerstable: cellForRowAtIndexPath: returning control cell: %d", self.controlRowIndexPath.row);
            #endif
            
            static NSString *CellIdentifierControl = @"ControlCell";
            
            PersonSearchResultControlCell *cellControl = (PersonSearchResultControlCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierControl];
            //PersonSearchResultControlCell *cellControl;
            if (cellControl == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"PersonSearchResultControlCell" owner:self options:nil];
                cellControl = controlCell;
                self.controlCell = nil;
            }
            
            [cellControl setupAsPlatesViewControlBox];
            
            cellControl.rowNumber = self.controlRowIndexPath.row;
            cellControl.controlCellDelegate = self;
                        
            #ifdef kLoggingIsOn
                NSLog(@"Ownerstable: cellForRowAtIndexPath: control cell return");
            #endif
            
            return cellControl;
        }
    }
    
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: cellForRowAtIndexPath: returning normal cell: %d", indexPath.row);
    #endif
        
    static NSString *CellIdentifierOwner = @"OwnerCell";
    
    PersonSearchResultCell *cell = (PersonSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierOwner];
    //PersonSearchResultCell *cell;
    if (cell == nil) {
        //NSLog(@"Ownercell is nil, alloc from scratch");
        
        [[NSBundle mainBundle] loadNibNamed:@"PersonSearchResultCell" owner:self options:nil];

        cell = tableCell;
        self.tableCell = nil;
    }
    
    NSIndexPath *offsetIndexPath = [self modelIndexPathforIndexPath: indexPath];
    
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: cellForRowAtIndexPath: returning normal cell normalized: %d", indexPath.row);
    #endif
    
//NO NETWORK TEST CODE
#ifdef NONETWORK
    cell.cantonLabel.text =  @"ZH";
    cell.numberLabel.text = @"12345";
    cell.typeImage.image = [UIImage imageNamed: @"CatCar.png"];
    cell.addressLabel.text = @"Dummystrasse 1";
    cell.plzplaceLabel.text = @"1000 Dummy";
    cell.cantonImage.image = [UIImage imageNamed: @"ZH.png"];
    cell.nameLabel.text = @"Hans Müller";
    [cell hidePhoneSearchActivityIndicators];
    [cell setPhoneNumberAndArrageButtons: @"+419999999"];
    [cell setNeedsDisplay];
    return cell;
#endif
    
    CarOwners *carOwner = [fetchedResultsController objectAtIndexPath:offsetIndexPath];
    
    if (!carOwner) {
        NSLog(@"Abnormal error: carOwner not found");
    }
        
    NSCharacterSet *csDecResult = [NSCharacterSet characterSetWithCharactersInString:@";"];
    NSArray *splitOwnersRow = [[carOwner carnumber] componentsSeparatedByCharactersInSet: csDecResult];
    
    NSString *typeImageName = @"CatCar.png";
    
    if ([splitOwnersRow count] > 1) {
        if ((![[carOwner cantoncode] isEqualToString:@"AG"]) && (![[carOwner cantoncode] isEqualToString:@"LU"]) && (![[carOwner cantoncode] isEqualToString:@"SH"])&& (![[carOwner cantoncode] isEqualToString:@"ZG"]) && (![[carOwner cantoncode] isEqualToString:@"ZH"])) {
            if ([[splitOwnersRow objectAtIndex: 1] isEqualToString: @"CatQuestionMark.png"]) {
                typeImageName = @"CatCar.png";
            } else {
                typeImageName = [splitOwnersRow objectAtIndex: 1]; 
            }
        } else {
            typeImageName = [splitOwnersRow objectAtIndex: 1];
        }
        
        cell.cantonLabel.text = [carOwner cantoncode];
        cell.numberLabel.text = [splitOwnersRow objectAtIndex: 0];        
        cell.typeImage.image = [UIImage imageNamed: typeImageName];
    } else {
        cell.numberLabel.text = [NSString stringWithFormat: @"%@ - %@", [carOwner cantoncode] , [carOwner carnumber]];
    }
    
    cell.addressLabel.text = [carOwner address];
    cell.plzplaceLabel.text = [carOwner plzplace];
    cell.cantonImage.image = [UIImage imageNamed: [carOwner flagname]];
    cell.nameLabel.text = [NSString stringWithFormat: @"%@", [carOwner name]];
    
    //NSLog(@"Name: %@", cell.nameLabel.text);
    
    [cell hidePhoneSearchActivityIndicators];
    
    if (![[carOwner phonenumber] isEqualToString:@"NONE"]) {
        [cell setPhoneNumberAndArrageButtons: [carOwner phonenumber]];
    }
    
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: cellForRowAtIndexPath: normal return");
    #endif
    
    [cell setNeedsDisplay];
    
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: didSelectRowAtIndexPath: enter: %d", indexPath.row);
    #endif    
        
    if (self.controlRowIndexPath) {
        if ([indexPath isEqual:self.controlRowIndexPath]) {
            //NSLog(@"Did select cell: is control cell. return");
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            return;
        }
    }
    
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if([indexPath isEqual:self.tappedIndexPath]){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    //NSIndexPath  *tappedIndexBeforeUpdatePath = indexPath;
    
    //update the indexpath if needed... I explain this below 
    indexPath = [self modelIndexPathforIndexPath:indexPath];
        
    NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:self.controlRowIndexPath.row inSection:self.controlRowIndexPath.section];
    
    
    //if in fact I tapped the same row twice lets clear our tapping trackers 
    if([indexPath isEqual:self.tappedIndexPath]){
        
        #ifdef kLoggingIsOn
            NSLog(@"User tapped same row. Clean up: %d", indexPath.row);
        #endif
        
        self.tappedIndexPath = nil;
        self.controlRowIndexPath = nil;
        
        /*
        NSInteger sectionsAmount = [tableView numberOfSections];
        NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
        if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
            // This is the last cell in the table
            NSLog(@"This is the last row in the table without box set");
        } 
        */ 
    }
    //otherwise let's update them appropriately 
    else {
        
        //self.tappedIndexPath = indexPath; //the row the user just tapped. 
        //Now I set the location of where I need to add the dummy cell 
        self.controlRowIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1   inSection:indexPath.section];
        
        /*
        NSInteger sectionsAmount = [tableView numberOfSections];
        NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
        if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
            // This is the last cell in the table
            NSLog(@"This is the last row in the table with box set");
        }
        */
        
        self.tappedIndexPath = indexPath; //the row the user just tapped.
    }
    
    //all logic is done, lets start updating the table
    [tableView beginUpdates];
    
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: didSelectRowAtIndexPath: beginUpdates");
    #endif
    
    if(indexPathToDelete.row != 0){
        
        #ifdef kLoggingIsOn
            NSLog(@"Ownerstable: didSelectRowAtIndexPath: delete controlbox: %d", indexPathToDelete.row);
        #endif
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
    }
        
    //lets add the new control cell in the right place 
    if(self.controlRowIndexPath){
        
        #ifdef kLoggingIsOn
            //NSLog(@"Ownerstable: didSelectRowAtIndexPath: control box is set");
        NSLog(@"Ownerstable: didSelectRowAtIndexPath: add controlbox: %d", self.controlRowIndexPath.row);
        #endif 
                
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.controlRowIndexPath] 
                         withRowAnimation:UITableViewRowAnimationNone];
    }
    
    #ifdef kLoggingIsOn
        NSLog(@"Ownerstable: didSelectRowAtIndexPath: endUpdates");
    #endif
    
    [tableView endUpdates];
    
    if (self.controlRowIndexPath) {
        
        //[tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: self.controlRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        NSInteger sectionsAmount = [tableView numberOfSections];
        NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
        if ([self.controlRowIndexPath section] == sectionsAmount - 1 && [self.controlRowIndexPath row] == rowsAmount - 1) {
            // This is the last cell in the table
            //NSLog(@"This is the last row in the table with box set");
            [ownersTable scrollToRowAtIndexPath: self.controlRowIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }        
    }
    
    //[tableView reloadData];
    //[tableView reloadInputViews];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  
    // Note: Some operations like calling [tableView cellForRowAtIndexPath:indexPath]  
    // will call heightForRow and thus create a stack overflow  
        
    #ifdef kLoggingIsOn
       //NSLog(@"Ownerstable: heightForRowAtIndexPath: enter: %d", indexPath.row);
    #endif

    if([indexPath isEqual:self.controlRowIndexPath]){
        return 49; //height for control cell
    }
        
    return  83;
} 
 
#pragma mark -- Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{    
    
    #ifdef kLoggingIsOn
        NSLog(@"NSFetchedResultscontroller: enter");
    #endif
    
    if (fetchedResultsController != nil)
	{
		return fetchedResultsController;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"CarOwners" inManagedObjectContext:
                                   [CoreDataController sharedCoreDataController].managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Apply a filter predicate
    // NONE
    
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:10];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"cantoncode" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	
	
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:[CoreDataController  sharedCoreDataController].managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName: @"OWN"];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
    
    
    #ifdef kLoggingIsOn
        NSLog(@"NSFetchedResultscontroller: fetched objects: %d", [fetchedResultsController.fetchedObjects count]);
    #endif
    
    //NSLog(@"Fetched objects: %d", [fetchedResultsController.fetchedObjects count]);
	
	return fetchedResultsController;
}	


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
    #ifdef kLoggingIsOn
        NSLog(@"NSFetchedResultscontroller func: controllerWillChangeContent: enter");
    #endif
    
    sectionInsertCount = 0;
    [self.ownersTable beginUpdates];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    #ifdef kLoggingIsOn
        NSLog(@"NSFetchedResultscontroller func: controllerDidChangeContent: enter");
    #endif
    
    [self.ownersTable endUpdates];
    
    if ([[fetchedResultsController fetchedObjects] count] != 0) {
        [self.emptyImageView setHidden: YES];
        [self.emptyLabel setHidden: YES];
    } else {
        [self.emptyImageView setHidden: NO];
        [self.emptyLabel setHidden: NO];
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    #ifdef kLoggingIsOn
        NSLog(@"NSFetchedResultscontroller func: didChangeObject: enter");
    #endif
    
    switch(type) {
		case NSFetchedResultsChangeInsert:
            [self.ownersTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[self.ownersTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
        case NSFetchedResultsChangeUpdate: {
            NSString *sectionKeyPath = [controller sectionNameKeyPath];
            if (sectionKeyPath == nil)
                break;
            NSManagedObject *changedObject = [controller objectAtIndexPath:indexPath];
            NSArray *keyParts = [sectionKeyPath componentsSeparatedByString:@"."];
            id currentKeyValue = [changedObject valueForKeyPath:sectionKeyPath];
            for (int i = 0; i < [keyParts count] - 1; i++) {
                NSString *onePart = [keyParts objectAtIndex:i];
                changedObject = [changedObject valueForKey:onePart];
            }
            sectionKeyPath = [keyParts lastObject];
            NSDictionary *committedValues = [changedObject committedValuesForKeys:nil];
            
            if ([[committedValues valueForKeyPath:sectionKeyPath] isEqual:currentKeyValue])
                break;
            
            NSUInteger tableSectionCount = [self.ownersTable numberOfSections];
            NSUInteger frcSectionCount = [[controller sections] count];
            if (tableSectionCount + sectionInsertCount != frcSectionCount) {
                // Need to insert a section
                NSArray *sections = controller.sections;
                NSInteger newSectionLocation = -1;
                for (id oneSection in sections) {
                    NSString *sectionName = [oneSection name];
                    if ([currentKeyValue isEqual:sectionName]) {
                        newSectionLocation = [sections indexOfObject:oneSection];
                        break;
                    }
                }
                if (newSectionLocation == -1)
                    return; // uh oh
                
                if (!((newSectionLocation == 0) && (tableSectionCount == 1) && ([self.ownersTable numberOfRowsInSection:0] == 0))) {
                    [self.ownersTable insertSections:[NSIndexSet indexSetWithIndex:newSectionLocation] withRowAnimation:UITableViewRowAnimationFade];
                    sectionInsertCount++;
                }
                
                NSUInteger indices[2] = {newSectionLocation, 0};
                newIndexPath = [[[NSIndexPath alloc] initWithIndexes:indices length:2] autorelease];
            }
        }
		case NSFetchedResultsChangeMove:
            if (newIndexPath != nil) {
                
                NSUInteger tableSectionCount = [self.ownersTable numberOfSections];
                NSUInteger frcSectionCount = [[controller sections] count];
                if (frcSectionCount != tableSectionCount + sectionInsertCount)  {
                    [self.ownersTable insertSections:[NSIndexSet indexSetWithIndex:[newIndexPath section]] withRowAnimation:UITableViewRowAnimationNone];
                    sectionInsertCount++;
                }
                
                
                [self.ownersTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.ownersTable insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation: UITableViewRowAnimationRight];
                
            }
            else {
                [self.ownersTable reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
            }
			break;
        default:
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
    #ifdef kLoggingIsOn
        NSLog(@"NSFetchedResultscontroller func: didChangeSection: enter");
    #endif
    
    switch(type) {
		case NSFetchedResultsChangeInsert:
            if (!((sectionIndex == 0) && ([self.ownersTable numberOfSections] == 1))) {
                [self.ownersTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                sectionInsertCount++;
            }
            
			break;
		case NSFetchedResultsChangeDelete:
            if (!((sectionIndex == 0) && ([self.ownersTable numberOfSections] == 1) )) {
                [self.ownersTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                sectionInsertCount--;
            }
            
			break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate: 
            break;
        default:
            break;
	}
}

- (void)dealloc
{
    [fetchedResultsController release];
    [controlRowIndexPath release];
    [tappedIndexPath release];
    [tableCell release];
    [controlCell release];
    [ownersTable release];
    [editButton release];
    [emptyImageView release];
    [emptyLabel release];
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
    #ifdef kLoggingIsOn
        NSLog(@"Plates view controller: View will appear");
        NSLog(@"Current viewcontroller: %@", self.nibName);
    #endif
    
    [super viewWillAppear:animated];
    
    CGFloat frameHeight = self.view.frame.size.height;
    
    if (self.ownersTable.frame.size.height != (frameHeight - TOOLBARHEIGHT)) {
        CGRect tableFrame = self.ownersTable.frame;
        tableFrame.size.height = (frameHeight - TOOLBARHEIGHT);
        self.ownersTable.frame = tableFrame;
    }

	self.ownersTable.backgroundColor = [UIColor clearColor];
	self.ownersTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.ownersTable.showsVerticalScrollIndicator = NO;
    
	[self.navigationController setNavigationBarHidden: YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    
    self.fetchedResultsController = nil;
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    #ifdef kLoggingIsOn
        NSLog(@"Will appear: %d objects fetched", [[fetchedResultsController fetchedObjects] count]);
    #endif
    
    [self.ownersTable reloadData];
    
    #ifdef kLoggingIsOn
        NSLog(@"Will appear: ownerstable reloaded");
    #endif
    
    //self.emptyLabel.transform = CGAffineTransformMakeRotation(-0.05);
    
    #ifndef NONETWORK
    if ([[fetchedResultsController fetchedObjects] count] != 0) {
        [self.emptyImageView setHidden: YES];
        [self.emptyLabel setHidden: YES];
    } else {
        [self.emptyImageView setHidden: NO];
        [self.emptyLabel setHidden: NO];
    }
    #endif
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.fetchedResultsController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [ownersTable reloadData];
}

- (void)viewDidUnload
{
    [self setControlRowIndexPath: nil];
    [self setTappedIndexPath: nil];
    [self setEditButton:nil];
    [super viewDidUnload];
    [self setOwnersTable: nil];
    [self setFetchedResultsController: nil];
    [self setControlCell: nil];
    [self setTableCell: nil];
    [self setEmptyImageView:nil];
    [self setEmptyLabel:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *) machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
	
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}


- (void) callOwnerAction:(int)rowEntry {
    //NSLog(@"callOwnerAction: %d", rowEntry);
    
    int offsetRow = [self modelRowforRow: rowEntry];
    NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow: offsetRow inSection: 0];
    
    NSString *deviceType = [NSString stringWithString: [self machineName]];
    
    #ifdef  kLoggingIsOn
        NSLog(@"Devicetype: %@", [deviceType substringToIndex: 6]);
    #endif
    
    #ifdef kCheckForiPodServiceRestrictions
    if (![[deviceType substringToIndex: 6] isEqualToString: @"iPhone"]) {
        PersonSearchResultCell *personCell = (PersonSearchResultCell *)[ownersTable cellForRowAtIndexPath: offsetIndexPath];
        if ([personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
            [personCell runBounceNoAnimation];
        } else {
            NSLog(@"Abnormal result: callOwnerAction: runBounceAnimtation on cell");
        }
    }
    #endif
    
    #ifdef kSimulateiPodTouchPresence
    PersonSearchResultCell *personCell = (PersonSearchResultCell *)[ownersTable cellForRowAtIndexPath: offsetIndexPath];
    if ([personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        [personCell runBounceNoAnimation];
    } else {
        NSLog(@"Abnormal result: callOwnerAction: runBounceAnimtation on cell");
    }
    #endif
    
    CarOwners *carOwner = [fetchedResultsController objectAtIndexPath:offsetIndexPath];
    
    //NSLog(@"Car owner: %@", carOwner);
    //NSLog(@"Phone numer: %@", [carOwner phonenumber]);
    
    if ([[carOwner phonenumber] isEqualToString:@"NONE"]) {
        PersonSearchResultCell *personCell = (PersonSearchResultCell *)[ownersTable cellForRowAtIndexPath: offsetIndexPath];
        if ([personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
            [personCell runBounceNoAnimation];
        } else {
            NSLog(@"Abnormal result: callOwnerAction: runBounceAnimtation on cell");
        }
    } else {
        if ([[carOwner phonenumber] length] !=0) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"tel://%@", [carOwner phonenumber]]]]; 
        } else {
            NSLog(@"Abnormal result: callOwnerAction: length of phonenumber");
        }
    }
    
}

- (BOOL) checkIfEntryExistsinDB: (NSString *) ownersName {
    NSManagedObjectContext *context = [[CoreDataController sharedCoreDataController] managedObjectContext];
    
    CarOwners *ownersInfo = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"CarOwners" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", ownersName];
    
    NSError *error = nil;
    ownersInfo = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !ownersInfo) 
    {
        return NO;
    } else {
        return  YES;
    }
}

- (void) saveCarOwnerAction:(int)rowEntry {
    //NSLog(@"saveCarOwnerAction: %d", rowEntry);
    
    int offsetRow = [self modelRowforRow: rowEntry];    
    NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow: offsetRow inSection: 0];
    
    PersonSearchResultCell *personCell = (PersonSearchResultCell *)[ownersTable cellForRowAtIndexPath: offsetIndexPath];
    if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        NSLog(@"Abnormal result: deleteAction: check personcell if runBounceNoAnimation exists");
    }   
    
    if (self.controlRowIndexPath) {
        NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:self.controlRowIndexPath.row inSection:self.controlRowIndexPath.section];
        
        self.tappedIndexPath = nil;
        self.controlRowIndexPath = nil;
        
        if(indexPathToDelete.row != 0){
            [ownersTable beginUpdates];
            [ownersTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
            [ownersTable endUpdates];
        }
        
    } else {
        NSLog(@"Abnormal situation: deleteAction expected controlBox set but is not");
    }
        
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [context deleteObject:[self.fetchedResultsController objectAtIndexPath:offsetIndexPath]];
        
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving after delete", @"Error saving after delete.") 
                                                        message:[NSString stringWithFormat: @"%@", [error localizedDescription]]
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Error saving after delete.")
                                              otherButtonTitles:nil];
        [alert show];
        exit(-1);
    }
}

- (void) locateOwnerOnMapAction:(int)rowEntry {
    //NSLog(@"locateOwnerOnMapAction: %d", rowEntry);
    
    if (!([UIDevice networkAvailable])) 
    {
        //NSLog(@"No network available");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"No network", @"No network available alert view title") message:NSLocalizedString(@"There is no WiFi or cellular network available. Please check or try again later.", @"No network available alert view message")];
        [notice show];
        
        return;
    }
    
    int offsetRow = [self modelRowforRow: rowEntry]; 
    //NSLog(@"Model row: %d", offsetRow);
    
    NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow: offsetRow inSection: 0];
        
    PersonSearchResultCell *personCell = (PersonSearchResultCell *)[ownersTable cellForRowAtIndexPath: offsetIndexPath];
    if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        NSLog(@"Abnormal result: locateOwnerOnMap: check personcell if runBounceNoAnimation exists");
    }
    
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName: @"MapViewController" bundle: nil];
    mapViewController.currentPerson = personCell;
    [self presentSemiViewController: mapViewController];
    [mapViewController resolveAddress];
}

- (void) shareOwnerInfoAction:(int)rowEntry {
    //NSLog(@"shareOwnerInfoAction: %d", rowEntry);
    
    int offsetRow = [self modelRowforRow: rowEntry];    
    NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow: offsetRow inSection: 0];
    
    PersonSearchResultCell *personCell = (PersonSearchResultCell *)[ownersTable cellForRowAtIndexPath: offsetIndexPath];
    if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        NSLog(@"Abnormal result: shareOwnerInfoAction: check personcell if runBounceNoAnimation exists");
    }
    
    BCDShareableItem *item = [[BCDShareableItem alloc] initWithTitle:NSLocalizedString(@"Car owner found", @"Found Owner Share Item Title")];
    
    NSString *part1 = NSLocalizedString(@"I found the owner of the license plate ", @"Found Owner Share Item Description Part 1");
    NSString *part2 = NSLocalizedString(@" with Swiss Plates: ", @"Found Owner Share Item Description Part 2");
    NSString *descriptionText = [NSString stringWithFormat: @"%@%@-%@%@%@, %@, %@, %@", part1, personCell.cantonLabel.text, personCell.numberLabel.text, part2, personCell.nameLabel.text, personCell.addressLabel.text, personCell.plzplaceLabel.text, personCell.phoneLabel.text];
    
    NSString *partShort1 = @"";
    NSString *shortDecpriptionText = [NSString stringWithFormat:@"%@%@-%@: %@, %@, %@, %@ %@", partShort1, personCell.cantonLabel.text, personCell.numberLabel.text, personCell.nameLabel.text, personCell.addressLabel.text, personCell.plzplaceLabel.text, personCell.phoneLabel.text, @"(by Swiss Plates)"];
    
    [item setDescription:descriptionText];
    [item setShortDescription:shortDecpriptionText];
    
    [item setItemURLString: AppStoreURLShort];
    
    [item setImageNameFromBundle: kBundleIconImage];
    
    UIActionSheet *sheet = [[BCDShareSheet sharedSharer] sheetForSharing:item iTellAFriend:NO completion:^(BCDResult result) {
        if (result==BCDResultSuccess) {
            
            #ifdef kLoggingIsOn
                NSLog(@"Yay!");
            #endif
        }
    }];
    UIWindow *appWindow = [[UIApplication sharedApplication].windows objectAtIndex: 0];
    [[BCDShareSheet sharedSharer] setRootViewController: appWindow.rootViewController];
    [[BCDShareSheet sharedSharer] setFacebookAppID:kFacebookAppID];
    [[BCDShareSheet sharedSharer] setAppName:kAppName];
    [sheet showInView: self.view];
    [item release];
}

- (void) ownerExistsAlreadyInAddressbook:(NSString *)lastname firstname:(NSString *)firstname successblock:(void (^)(BOOL entryfound))successblock failureblock:(void (^)(NSError *error))failureblock {
    
    if (!lastname || ! firstname) {
        if (failureblock) {
            failureblock(nil);
        }
    }
    
    if (ABAddressBookRequestAccessWithCompletion) {
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    if (failureblock) {
                        failureblock((NSError *)error);
                    }
                } else {
                    BOOL entryfound = NO;
                    
                    if (addressBook != nil)
                    {
                        CFArrayRef arrayOfEntries = ABAddressBookCopyArrayOfAllPeople(addressBook);
                        if (CFArrayGetCount(arrayOfEntries) > 0)
                        {
                            CFIndex countOfEntries = CFArrayGetCount(arrayOfEntries);
                            //NSLog(@"Address book entries: %ld", countOfEntries);
                            
                            for (int x = 0; x < countOfEntries ; x++)
                            {
                                ABRecordRef activeRecord = CFArrayGetValueAtIndex(arrayOfEntries, x);
                                NSString *firstnameEntry = (NSString *) CFBridgingRelease(ABRecordCopyValue(activeRecord, kABPersonFirstNameProperty));
                                //NSLog(@"First name: %@", firstnameEntry);
                                NSString *lastnameEntry = (NSString *) CFBridgingRelease(ABRecordCopyValue(activeRecord, kABPersonLastNameProperty));
                                //NSLog(@"Last name: %@", lastnameEntry);
                                
                                if ([firstnameEntry isEqualToString: firstname] && [lastnameEntry isEqualToString:lastname]) {
                                    entryfound = YES;
                                }
                            }
                        }
                        
                        CFRelease(arrayOfEntries);
                        CFRelease(addressBook);
                    }
                    if (successblock) {
                        successblock(entryfound);
                    }
                }
            });
        });
    }
}

- (void) addOwnerToAdressbookAction:(int)rowEntry {
    //NSLog(@"addOwnerToAdressbookAction: %d", rowEntry);
    
    int offsetRow = [self modelRowforRow: rowEntry];    
    NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow: offsetRow inSection: 0];
    
    PersonSearchResultCell *personCell = (PersonSearchResultCell *)[ownersTable cellForRowAtIndexPath: offsetIndexPath];
    if (![personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
        NSLog(@"Abnormal result: shareOwnerInfoAction: check personcell if runBounceNoAnimation exists");
    }
    
    NSString *firstname; NSString *lastname;
    NSString *plz; NSString *city;
    
    
    NSArray *nameArray = [personCell.nameLabel.text componentsSeparatedByString: @" "];
    if ([nameArray count] > 1) {
        firstname = [nameArray objectAtIndex: 0];
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity: 1];
        for (int i = 1; i < [nameArray count]; i++) {
            [tempArray addObject: [nameArray objectAtIndex: i]];
        }
        lastname = [tempArray componentsJoinedByString: @" "];
    } else {
        NSLog(@"Abnormal result: Add owner to address book, name could not be split");
        return;
    }
    NSArray *plzplaceArray = [personCell.plzplaceLabel.text componentsSeparatedByString: @" "];
    if ([plzplaceArray count] == 2) {
        plz = [plzplaceArray objectAtIndex: 0];
        city = [plzplaceArray objectAtIndex: 1];
    } else {
        NSLog(@"Abnormal result: Add owner to address book, PLZ and Place could not be split");
        return;
    }
    
    __block BOOL accessGranted = NO;
    CFErrorRef err;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    if (!accessGranted) {
        
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Address book access denied", @"Addressbook access denied alert view title") message:NSLocalizedString(@"Swiss Plates cannot access the address book. You may allow Swiss Plates to access the address book in the privacy settings in order to save the contact information.", @"Addressbook access denied alert view message")];
        [notice show];
        
        CFRelease(addressBook);
        return;
    }
    
    [self ownerExistsAlreadyInAddressbook:lastname firstname:firstname successblock:^(BOOL entryfound) {
        if (entryfound) {
            if ([personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
                [personCell runBounceNoAnimation];
            } else {
                NSLog(@"Abnormal result: saveCarOwnerAction: runBounceAnimtation on cell");
            }
            
            CFRelease(addressBook);
        } else {
            CFErrorRef error = NULL;
            
            ABRecordRef newPerson = ABPersonCreate();
            ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (firstname), &error);
            ABRecordSetValue(newPerson, kABPersonLastNameProperty, (lastname), &error);
            
            if (personCell.phoneNumberSet) {
                ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                ABMultiValueAddValueAndLabel(multiPhone, (personCell.phoneLabel.text), kABPersonPhoneMainLabel, NULL);
                ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
                CFRelease(multiPhone);
            }
            
            ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
            
            NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
            
            [addressDictionary setObject: personCell.addressLabel.text forKey:(NSString *) kABPersonAddressStreetKey];
            [addressDictionary setObject: city forKey:(NSString *)kABPersonAddressCityKey];
            //[addressDictionary setObject:@"IL" forKey:(NSString *)kABPersonAddressStateKey];
            [addressDictionary setObject: plz forKey:(NSString *)kABPersonAddressZIPKey];
            [addressDictionary setObject:@"ch" forKey:(NSString *)kABPersonAddressCountryCodeKey];
            
            ABMultiValueAddValueAndLabel(multiAddress, (addressDictionary), kABHomeLabel, NULL);
            ABRecordSetValue(newPerson, kABPersonAddressProperty, multiAddress,&error);
            CFRelease(multiAddress);
            
            NSString *carNumberFull = [NSString stringWithFormat: @"%@-%@", personCell.cantonLabel.text, personCell.numberLabel.text];
            
            ABRecordSetValue(newPerson, kABPersonNoteProperty, carNumberFull, &error);
            
            
            ABAddressBookAddRecord(addressBook, newPerson, &error);
            ABAddressBookSave(addressBook, &error);
            
            if (error != NULL) {
                NSLog(@"Error: Entry could not be saved in addressbook!");
                
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInWindow:NSLocalizedString(@"Addressbook saving error", @"Addressbook saving error alert view title") message:NSLocalizedString(@"The owner details could not be saved in the addressbook", @"Addressbook saving error alert view message")];
                [notice show];
                
            } else {
                WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInWindow:NSLocalizedString(@"Entry saved in addressbook", @"Entry saved in addressbook alert view")];
                [notice show];
            }
            
            CFRelease(newPerson);
            CFRelease(addressBook);
        }
    } failureblock:^(NSError *error) {
        if ([personCell respondsToSelector: @selector(runBounceNoAnimation)]) {
            [personCell runBounceNoAnimation];
        } else {
            NSLog(@"Abnormal result: saveCarOwnerAction: runBounceAnimtation on cell");
        }
        
        CFRelease(addressBook);
    }];
}

@end
