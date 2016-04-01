//
//  NSObject+Properties.m
//  aplayer
//
//  Created by alex on 3/31/16.
//  Copyright © 2016 SDWR. All rights reserved.
//

#import "NSObject+Properties.h"
#import <objc/runtime.h>

@implementation NSObject (Properties)

- (NSDictionary *)dictionaryRepresentation {

    unsigned int count = 0;
    // Get a list of all properties in the class.
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:count];

    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        NSNumber *value = [self valueForKey:key];
        // Only add to the NSDictionary if it's not nil.
        if (value)
            //NSLog(@"%@ - %@",key,value);
            [dictionary setObject:value forKey:key];
    }

    free(properties);

    return dictionary;
}


@end