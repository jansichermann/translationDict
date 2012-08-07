//
//  PerfTestViewController.m
//  translationDictionary
//
//  Created by Jan on 8/7/12.
//  Copyright (c) 2012 foursquare. All rights reserved.
//

#import "PerfTestViewController.h"
#import "PerformanceTest.h"

@interface PerfTestViewController ()
@property (nonatomic) PerformanceTest *perfTest;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *lookupWord;
@end

@implementation PerfTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.perfTest = [[PerformanceTest alloc] init];
    
    
    UIButton *startLoading = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startLoading setTitle:@"loadJSON" forState:UIControlStateNormal];
    startLoading.frame = CGRectMake(10, 20, 300, 30);
    [startLoading addTarget:self action:@selector(startDictJson) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startLoading];
    
    UIButton *destroyJson = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [destroyJson setTitle:@"destroyJSON" forState:UIControlStateNormal];
    destroyJson.frame = CGRectMake(10, 60, 300, 30);
    [destroyJson addTarget:self action:@selector(destroyDictJson) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:destroyJson];
    
    UIButton *lookupDictButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [lookupDictButton setTitle:@"lookup in dict" forState:UIControlStateNormal];
    lookupDictButton.frame = CGRectMake(10, 100, 300, 30);
    [lookupDictButton addTarget:self action:@selector(dictLookup) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lookupDictButton];
    
    
    UIButton *startArrayLoading = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startArrayLoading setTitle:@"loadArrayJson" forState:UIControlStateNormal];
    startArrayLoading.frame = CGRectMake(10, 160, 300, 30);
    [startArrayLoading addTarget:self action:@selector(startArrayJson) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startArrayLoading];
    
    UIButton *destroyArrayJsonButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [destroyArrayJsonButton setTitle:@"destroyJSON" forState:UIControlStateNormal];
    destroyArrayJsonButton.frame = CGRectMake(10, 200, 300, 30);
    [destroyArrayJsonButton addTarget:self action:@selector(destroyArrayJson) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:destroyArrayJsonButton];
    
    UIButton *lookupArrayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [lookupArrayButton setTitle:@"lookup in array" forState:UIControlStateNormal];
    lookupArrayButton.frame = CGRectMake(10, 240, 300, 30);
    [lookupArrayButton addTarget:self action:@selector(arrayLookup) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lookupArrayButton];
    
    
    UIButton *startNestdArrayLoading = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startNestdArrayLoading setTitle:@"loadArrayJson" forState:UIControlStateNormal];
    startNestdArrayLoading.frame = CGRectMake(10, 300, 300, 30);
    [startNestdArrayLoading addTarget:self action:@selector(startNestedArrayLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startNestdArrayLoading];

    UIButton *destroyNestedArrayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [destroyNestedArrayButton setTitle:@"destroy nested array" forState:UIControlStateNormal];
    destroyNestedArrayButton.frame = CGRectMake(10, 340, 300, 30);
    [destroyNestedArrayButton addTarget:self action:@selector(destroyNestedArray) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:destroyNestedArrayButton];
    
    
    

    UIButton *lookupWordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [lookupWordButton setTitle:@"random lookupWord" forState:UIControlStateNormal];
    lookupWordButton.frame = CGRectMake(10, 380, 300, 30);
    [lookupWordButton addTarget:self action:@selector(randomLookupWord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lookupWordButton];
    
    self.lookupWord = [[UILabel alloc] init];
    self.lookupWord.frame = CGRectMake(10, 400, 300, 30);
    self.lookupWord.adjustsFontSizeToFitWidth = YES;
    self.lookupWord.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.lookupWord];
    
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.frame = CGRectMake(10, 420, 300, 30);
    self.dateLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.dateLabel];
}

- (void)startDictJson {
    self.startDate = [NSDate date];
    [self.perfTest loadJsonDict];
    [self updateDate];
}

- (void)destroyDictJson {
    self.startDate = [NSDate date];
    [self.perfTest destroyJsonDict];
    [self updateDate];
}

- (void)startArrayJson {
    self.startDate = [NSDate date];
    [self.perfTest loadJsonArray];
    [self updateDate];
}

- (void)destroyArrayJson {
    self.startDate = [NSDate date];
    [self.perfTest destroyJsonArray];
    [self updateDate];
}

- (void)updateDate {
    self.dateLabel.text = [NSString stringWithFormat:@"%f",
                           [[NSDate date] timeIntervalSinceDate:self.startDate] ];
}


- (void)dictLookup {
    self.dateLabel.text = [NSString stringWithFormat:@"%f", [self.perfTest dictLookup] ];
}

- (void)arrayLookup {
    self.dateLabel.text = [NSString stringWithFormat:@"%f", [self.perfTest arrayLookup] ];
}

- (void)randomLookupWord {
    self.lookupWord.text = [self.perfTest setRandomLookupWord];
}

- (void)startNestedArrayLoading {
    self.startDate = [NSDate date];
    [self.perfTest loadNestedArray];
    [self updateDate];
}

- (void)destroyNestedArray {
    self.startDate = [NSDate date];
    [self.perfTest destroyNestedArray];
    [self updateDate];
}

@end
