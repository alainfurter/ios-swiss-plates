//
//  StationsController.h
//  Pendler Alarm CH
//
//  Created by Alain Furter on 13.07.10.
//  Copyright 2010 Corporate Finance Manager. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface CoreDataController : NSObject 
{
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;		
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataController *) sharedCoreDataController;

@end
