//
//  NSObject+Properties.h
//  aplayer
//
//  Created by alex on 3/31/16.
//  Copyright © 2016 SDWR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Properties)
/**
 Returns an NSDictionary containing the properties of an object that are not nil.
 */

- (NSDictionary *)dictionaryRepresentation;

@end
