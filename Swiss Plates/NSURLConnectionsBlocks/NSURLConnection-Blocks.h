//
//  NSURLConnection-Blocks.h
//  Face Buttons
//
//  Created by Alain Furter on 21.11.11.
//  Copyright (c) 2011 Corporate Finance Manager. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (block) 

#pragma mark Class API Extensions  

+ (void)asyncRequest:(NSURLRequest *)request 
             success:(void(^)(NSData *,NSURLResponse *))
             successBlock_ failure:(void(^)(NSData *,NSError *))failureBlock_;  
@end  
