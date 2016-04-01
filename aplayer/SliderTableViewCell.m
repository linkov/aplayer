//
//  SliderTableViewCell.m
//  aplayer
//
//  Created by alex on 3/31/16.
//  Copyright © 2016 SDWR. All rights reserved.
//

#import "SliderTableViewCell.h"

@interface SliderTableViewCell ()

@property (copy) SDWValueChangedBlock block;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UISlider *slider;

@end

@implementation SliderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupWithCurrentValue:(NSNumber *)value minValue:(NSNumber *)minValue maxValue:(NSNumber *)maxValue forPropertyName:(NSString *)propertyName didChangeBlock:(SDWValueChangedBlock)block {

    self.slider.minimumValue = [minValue floatValue];
    self.slider.maximumValue = [maxValue floatValue];
    self.slider.value = [value floatValue];
    self.nameLabel.text = propertyName;
    self.valueLabel.text = value.stringValue;
    self.block = block;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)sliderDidChange:(UISlider *)sender {

    self.valueLabel.text = [NSString stringWithFormat:@"%f",sender.value];

    if (self.block) {

        self.block( @(sender.value));
    }

}


@end
