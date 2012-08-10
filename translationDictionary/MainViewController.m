//
//  MainViewController.m
//  translationDictionary
//
//  Created by Jan on 8/3/12.
//  Copyright (c) 2012 foursquare. All rights reserved.
//

#import "MainViewController.h"
#import "Localization.h"
#import "Actor.h"

@interface MainViewController ()
@property (nonatomic) UILabel *label;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.label = [[UILabel alloc]  initWithFrame:self.view.bounds];
    [self.view addSubview:self.label];
    self.label.numberOfLines = 20;
    
    Actor *actorI = [Actor new];
    actorI.name = @"Tom";
    actorI.gender = genderMale;

    Actor *actorII = [Actor new];
    actorII.name = @"Jane";
    actorII.gender = genderFemale;
    
    self.label.text = [[Localization sharedLocalization] localizedString:@"{^} saved {^}'s {#} tips that he left yesterday to his list" formatters:[NSArray arrayWithObjects:actorI, actorII, [NSNumber numberWithInt:1], nil]];

}

@end
