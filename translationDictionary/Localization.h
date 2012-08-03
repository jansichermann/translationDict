//
//  Localization.h
//  translationDictionary
//
//  Created by Jan on 8/3/12.
//  Copyright (c) 2012 foursquare. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    genderMale = 0,
    genderFemale,
    genderNeuter
} genderType;

@protocol GenderProtocol
- (genderType)gender;
- (NSString *)description;
@end

@interface Localization : NSObject
+ (id)sharedLocalization;
- (NSString *)localizedString:(NSString *)string formatters:(NSArray *)formatters;
@end
