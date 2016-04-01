//
//  SliderTableViewCell.h
//  aplayer
//
//  Created by alex on 3/31/16.
//  Copyright © 2016 SDWR. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SDWValueChangedBlock)(NSNumber *changedValue);



@interface SliderTableViewCell : UITableViewCell


- (void)setupWithCurrentValue:(NSNumber *)value minValue:(NSNumber *)minValue maxValue:(NSNumber *)maxValue forPropertyName:(NSString *)propertyName didChangeBlock:(SDWValueChangedBlock)block;

@end
