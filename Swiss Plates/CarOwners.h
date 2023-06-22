//
//  CarOwners.h
//  Swiss Plates
//
//  Created by Alain Furter on 06.04.11.
//  Copyright (c) 2011 Corporate Finance Manager. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CarOwners : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * plzplace;
@property (nonatomic, retain) NSString * phonenumber;
@property (nonatomic, retain) NSString * cantoncode;
@property (nonatomic, retain) NSString * flagname;
@property (nonatomic, retain) NSString * carnumber;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;



@end
