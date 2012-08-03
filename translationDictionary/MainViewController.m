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

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    Actor *actorI = [Actor new];
    actorI.name = @"Tom";
    actorI.gender = genderMale;

    Actor *actorII = [Actor new];
    actorII.name = @"Jane";
    actorII.gender = genderFemale;
    
    NSLog(@"%@",
          [[Localization sharedLocalization] localizedString:@"%@ saved %@'s %@ tips that he left yesterday to his list" formatters:[NSArray arrayWithObjects:actorI, actorII, [NSNumber numberWithInt:14], nil]]
      );

    NSLog(@"%@",
          [[Localization sharedLocalization] localizedString:@"%@ saved %@'s %@ tips that he left yesterday to his list" formatters:[NSArray arrayWithObjects:actorI, actorI, [NSNumber numberWithInt:1], nil]]
          );
    
    NSLog(@"%@",
          [[Localization sharedLocalization] localizedString:@"%@ saved %@'s %@ tips that he left yesterday to his list" formatters:[NSArray arrayWithObjects:actorII, actorII, [NSNumber numberWithInt:14], nil]]
          );
	// Do any additional setup after loading the view.
}

@end
