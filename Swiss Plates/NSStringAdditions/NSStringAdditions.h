//
//  NSStringAdditions.h
//  URLCall
//
//  Created by Alain Furter on 11.04.10.
//  Copyright 2010 Corporate Finance Manager. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSStringAdditions)

+ (NSString *) base64StringFromData: (NSData *)data length: (NSInteger)length;

- (NSString*) stringByPercentEscapingCharacters:(NSString*)characters;
- (NSString*) stringByEscapingURL;

- (NSString*) stringByReplacingPercentEscapingCharacters;
- (NSString*) stringByRemovingEscapes;

- (NSString *)stringByDecodingXMLEntities;

@end
