    //
//  ViewController.m
//  aplayer
//
//  Created by alex on 3/30/16.
//  Copyright © 2016 SDWR. All rights reserved.
//

#import "ViewController.h"

/*-------View Controllers-------*/

/*-------Frameworks-------*/
#import <QuartzCore/QuartzCore.h>
#import "TheAmazingAudioEngine.h"

/*-------Views-------*/
#import "SliderTableViewCell.h"
#import "SDWFilterHeaderView.h"

/*-------Helpers & Managers-------*/

#import "NSObject+Properties.h"

/*-------Models-------*/
#import "AEPlaythroughChannel.h"
#import "AEExpanderFilter.h"
#import "AELimiterFilter.h"
#import "AERecorder.h"
#import "AEReverbFilter.h"
#import "AEDelayFilter.h"
#import "AEBandpassFilter.h"
#import "AELowPassFilter.h"
#import "SDWFilterWrap.h"

#define SDWNonnull(x) (id __nonnull)x


@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) AEAudioController *audioController;
@property (nonatomic, strong) AEPlaythroughChannel *playthrough;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UISwitch *playSwitch;

@property (nonatomic, strong) AEBandpassFilter *bandpass;
@property (nonatomic, strong) AELowPassFilter *lowpass;

@property (nonatomic, strong) AEReverbFilter *reverb;
@property (nonatomic, strong) AEDelayFilter *delay1;
@property (nonatomic, strong) AEDelayFilter *delay2;


@property (nonatomic, strong) AEBlockFilter *blockFilter;

@property NSArray *filters;
@property NSDictionary *filtersSettings;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.audioController = [[AEAudioController alloc] initWithAudioDescription:AEAudioStreamBasicDescriptionNonInterleavedFloatStereo inputEnabled:YES];
    _audioController.preferredBufferDuration = 0.005;
    _audioController.useMeasurementMode = YES;
    [_audioController start:NULL];



    self.playthrough = [[AEPlaythroughChannel alloc] init];
    self.playthrough.volume = 0;//50;
    [_audioController addInputReceiver:_playthrough];
    [_audioController addChannels:@[_playthrough]];



    self.bandpass = [AEBandpassFilter new];
    self.bandpass.centerFrequency = 525;
    self.bandpass.bandwidth = 1000;
    
    [_audioController addFilter:self.bandpass toChannel:self.playthrough];


    self.delay1 = [[AEDelayFilter alloc] init];
    self.delay1.wetDryMix = 0;
    self.delay1.delayTime = 0.25;
    self.delay1.feedback = 85;

    [_audioController addFilter:self.delay1 toChannel:self.playthrough];



    self.delay2 = [[AEDelayFilter alloc] init];
    self.delay2.wetDryMix = 65;
    self.delay2.feedback = 70;
    self.delay2.delayTime = 0.7;


    [_audioController addFilter:self.delay2 toChannel:self.playthrough];


    self.lowpass = [AELowPassFilter new];
    self.lowpass.cutoffFrequency = 4500;
    self.lowpass.resonance = 5;
    [_audioController addFilter:self.lowpass toChannel:self.playthrough];


    self.reverb = [[AEReverbFilter alloc] init];
    self.reverb.dryWetMix = 35;
    self.reverb.decayTimeAtNyquist = 12;
     [_audioController addFilter:self.reverb toChannel:self.playthrough];




    SDWFilterWrap *filter1 = [SDWFilterWrap new];
    filter1.filter = self.bandpass;
    filter1.name = @"Bandpass";

    SDWFilterWrap *filter2 = [SDWFilterWrap new];
    filter2.filter = self.delay1;
    filter2.name = @"Delay";


    SDWFilterWrap *filter3 = [SDWFilterWrap new];
    filter3.filter = self.delay2;
    filter3.name = @"Delay";


    SDWFilterWrap *filter4 = [SDWFilterWrap new];
    filter4.filter = self.lowpass;
    filter4.name = @"Lowpass";


    SDWFilterWrap *filter5 = [SDWFilterWrap new];
    filter5.filter = self.reverb;
    filter5.name = @"Reverb";

    self.filters = @[filter1,filter2,filter3,filter4,filter5];


    NSMutableDictionary *propertiesToFilters = [NSMutableDictionary dictionary];

    for (SDWFilterWrap *filter in self.filters) {


        //SDWFilterWrap *f = [SDWFilterWrap new];
        //filter.filter = filter;
        filter.key = @([self.filters indexOfObject:filter]);

      //  NSString *key =  f.key;
        [propertiesToFilters setObject:[filter.filter dictionaryRepresentation] forKey:filter.key];

    }


    self.filtersSettings = [propertiesToFilters copy];


    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SDWFilterHeaderView class]) bundle:nil] forHeaderFooterViewReuseIdentifier:NSStringFromClass([SDWFilterHeaderView class])];


    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SliderTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SliderTableViewCell class])];


    //[self.tableView registerClass:[SliderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([SliderTableViewCell class])];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 100;

}


#pragma mark - UITableViewDataSource,UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    SDWFilterHeaderView *headerView =
    [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([SDWFilterHeaderView class])];

    SDWFilterWrap *filter = self.filters[section];

    headerView.headerLabel.text = filter.name;

    return headerView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filters.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    SDWFilterWrap *filter = self.filters[section];
    NSDictionary *propertiesDict = [self.filtersSettings objectForKey:filter.key];

    return propertiesDict.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SDWFilterWrap *filter = self.filters[indexPath.section];
    NSDictionary *propertiesDict = [self.filtersSettings objectForKey:filter.key];


    NSString *propertyName =  [[propertiesDict allKeys] objectAtIndex:indexPath.row];
    NSNumber *value =  [propertiesDict objectForKey:propertyName];
 //   NSString *value = [filter valueForKey:key];

    NSNumber *minValue = [self minValueForFilterPropertyName:propertyName];
    NSNumber *maxValue = [self maxValueForFilterPropertyName:propertyName];


    SliderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SliderTableViewCell class])];
    [cell setupWithCurrentValue:value minValue:minValue maxValue:maxValue forPropertyName:propertyName didChangeBlock:^(NSNumber *changedValue) {


        [filter.filter setValue:changedValue forKey:propertyName];
    }];


    return cell;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (NSNumber *)minValueForFilterPropertyName:(NSString *)propertyName {


    if ([propertyName isEqualToString:@"lopassCutoff"]) {

        return @(10);
    }

    if ([propertyName isEqualToString:@"bandwidth"]) {

        return @(100);
    }

    if ([propertyName isEqualToString:@"centerFrequency"]) {

        return @(20);
    }

    if ([propertyName isEqualToString:@"delayTime"]) {

        return @(0.0);
    }

    if ([propertyName isEqualToString:@"feedback"]) {

        return @(-100.0);
    }

    if ([propertyName isEqualToString:@"lopassCutoff"]) {

        return @(10.0);
    }

    if ([propertyName isEqualToString:@"wetDryMix"]) {

        return @(0.0);
    }

    if ([propertyName isEqualToString:@"cutoffFrequency"]) {

        return @(10.0);
    }

    if ([propertyName isEqualToString:@"resonance"]) {

        return @(-20.0);
    }

    if ([propertyName isEqualToString:@"filterGain"]) {

        return @(-18.0);
    }


    if ([propertyName isEqualToString:@"decayTimeAtNyquist"]) {

        return @(0.001);
    }

    if ([propertyName isEqualToString:@"maxDelayTime"]) {

        return @(0.0001);
    }

    if ([propertyName isEqualToString:@"gain"]) {

        return @(-20);
    }

    if ([propertyName isEqualToString:@"randomizeReflections"]) {

        return @(1);
    }


    if ([propertyName isEqualToString:@"filterFrequency"]) {

        return @(10);
    }

    if ([propertyName isEqualToString:@"filterBandwidth"]) {

        return @(0.05);
    }

    if ([propertyName isEqualToString:@"decayTimeAt0Hz"]) {

        return @(0.001);
    }


    if ([propertyName isEqualToString:@"minDelayTime"]) {

        return @(0.001);
    }

    return @(0.0);
}

- (NSNumber *)maxValueForFilterPropertyName:(NSString *)propertyName {

    if ([propertyName isEqualToString:@"lopassCutoff"]) {

        return @(15000);
    }


    if ([propertyName isEqualToString:@"bandwidth"]) {

        return @(12000);
    }

    if ([propertyName isEqualToString:@"centerFrequency"]) {

        return @(20000);
    }

    if ([propertyName isEqualToString:@"delayTime"]) {

        return @(2.0);
    }

    if ([propertyName isEqualToString:@"feedback"]) {

        return @(100.0);
    }

    if ([propertyName isEqualToString:@"lopassCutoff"]) {

        return @(12000.0);
    }


    if ([propertyName isEqualToString:@"wetDryMix"]) {

        return @(100.0);
    }

    if ([propertyName isEqualToString:@"cutoffFrequency"]) {

        return @(12000.0);
    }

    if ([propertyName isEqualToString:@"resonance"]) {

        return @(40.0);
    }

    if ([propertyName isEqualToString:@"filterGain"]) {

        return @(18.0);
    }

    if ([propertyName isEqualToString:@"decayTimeAtNyquist"]) {

        return @(20.00);
    }

    if ([propertyName isEqualToString:@"maxDelayTime"]) {

        return @(1.000);
    }

    if ([propertyName isEqualToString:@"gain"]) {

        return @(20);
    }

    if ([propertyName isEqualToString:@"randomizeReflections"]) {

        return @(1000);
    }

    if ([propertyName isEqualToString:@"filterFrequency"]) {

        return @(20000);
    }

    if ([propertyName isEqualToString:@"filterBandwidth"]) {

        return @(4.00);
    }


    if ([propertyName isEqualToString:@"decayTimeAt0Hz"]) {

        return @(20.0);
    }

    if ([propertyName isEqualToString:@"minDelayTime"]) {

        return @(1.0);
    }

    return @(1.0);
}

- (IBAction)didSwitchPlay:(UISwitch *)sender {

    BOOL isOn = sender.isOn;
    if ( isOn ) {
//        self.playthrough = [[AEPlaythroughChannel alloc] init];
//        [_audioController addInputReceiver:_playthrough];
//        [_audioController addChannels:@[_playthrough]];
        self.playthrough.volume = 50;
    } else {
        self.playthrough.volume = 0;
//        [_audioController removeChannels:@[_playthrough]];
//        [_audioController removeInputReceiver:_playthrough];
//        self.playthrough = nil;
    }
}


@end
