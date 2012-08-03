//
//  Actor.h
//  translationDictionary
//
//  Created by Jan on 8/3/12.
//  Copyright (c) 2012 foursquare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Localization.h"
@interface Actor : NSObject <GenderProtocol>
@property (nonatomic) genderType gender;
@property (nonatomic) NSString *name;
@end
