//
//  StationsController.m
//  Pendler Alarm CH
//
//  Created by Alain Furter on 13.07.10.
//  Copyright 2010 Corporate Finance Manager. All rights reserved.
//

#import "CoreDataController.h"
#import "SynthesizeSingleton.h"


@implementation CoreDataController


SYNTHESIZE_SINGLETON_FOR_CLASS(CoreDataController);


@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;


#pragma mark -
#pragma mark Core Data stack


- (NSManagedObjectContext *)managedObjectContext
{
	//NSLog(@"MOC Enter");
    
    if (managedObjectContext != nil)
	{
		//NSLog(@"MOC Return MOC");
        
        return managedObjectContext;
	}
	
    //NSLog(@"MOC init PSC");
    
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil)
	{
		 //NSLog(@"MOC PSC Set");
        
        managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
	}
	return managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel
{
	//NSLog(@"MOM Enter");
    
    if (managedObjectModel != nil)
	{
		//NSLog(@"MOM Return MOM");
        
        return managedObjectModel;
	}
	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];	
	return managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	//NSLog(@"PSC Enter");
    
    if (persistentStoreCoordinator != nil)
	{
		//NSLog(@"PSC Return PSC");
        
        return persistentStoreCoordinator;
	}
	
	//Standard DB copy to documents directory code
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *storePath = [documentsDirectory stringByAppendingPathComponent: @"SavedPlates.sqlite"];
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
    //NSLog(@"PSC Patch: %@", storePath);
    
    /*
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:storePath]) 
	{
		//NSLog(@"Copy DB from bundle");
		
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"SavedPlates" ofType:@"sqlite"];
		if (defaultStorePath) 
		{
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
		else 
		{
			NSLog(@"Unresolved error: standard DB in bundle not found!");
			abort();
			
		}
	}
	else 
	{
		//NSLog(@"Init DB from documents directory");
		
	}
	*/

	
	// Standard code to leave DB in Bundle
    /*
	NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"SavedPlates" ofType:@"sqlite"]; 
	if (!defaultStorePath) 
	{
		NSLog(@"Unresolved error: standard DB in bundle not found!");
		abort();
	} 

    NSURL *storeUrl = [NSURL fileURLWithPath: defaultStorePath];
     */
	
    //NSLog(@"PSC init PSC");
    
	NSError *error = nil;
	persistentStoreCoordinator =
	[[NSPersistentStoreCoordinator alloc]
	 initWithManagedObjectModel:[self managedObjectModel]];
	if (![persistentStoreCoordinator
		  addPersistentStoreWithType:NSSQLiteStoreType
		  configuration:nil
		  URL:storeUrl
		  options:nil
		  error:&error])
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
	
	return persistentStoreCoordinator;
}


@end
