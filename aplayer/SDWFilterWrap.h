//
//  SDWFilterWrap.h
//  aplayer
//
//  Created by alex on 3/31/16.
//  Copyright © 2016 SDWR. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AEAudioUnitFilter;

@interface SDWFilterWrap : NSObject

@property id filter;
@property NSNumber *key;
@property NSString *name;

@end
