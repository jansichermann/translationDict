//
//  Localization.m
//  translationDictionary
//
//  Created by Jan on 8/3/12.
//  Copyright (c) 2012 foursquare. All rights reserved.
//

#import "Localization.h"

@interface Localization ()
@property (nonatomic) NSDictionary *localizedStrings;
@end

@implementation Localization

+ (id)sharedLocalization {
    static dispatch_once_t pred;
    static Localization *localization = nil;
    
    dispatch_once(&pred, ^{
        localization = [[self alloc] init];
        [localization loadData];
    });
    return localization;
}

- (void)loadData {
    NSData *localizedData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"localized" ofType:@"json"]];
    self.localizedStrings = [NSJSONSerialization JSONObjectWithData:localizedData options:NSJSONReadingMutableLeaves error:nil];
}

- (NSString *)localizedString:(NSString *)string formatters:(NSArray *)formatters {
    string = [self replacePlainFormattersWithNumbered:string];
    
    string = [self localizedStringForKey:string withFormatters:formatters];
    
    string = [self replace:string withFormatters:formatters];
    
    return string;
}

- (NSString *)localizedStringForKey:(NSString *)string withFormatters:(NSArray *)formatters {
    NSDictionary *stringData = [self.localizedStrings objectForKey:string];
    NSString *returnString = string;
    
    if (stringData != nil) {
        returnString = [self stringInDict:stringData withFormatters:formatters];
             
    }
    return returnString;
}

- (NSString *)stringInDict:(id)stringObj withFormatters:(NSArray *)formatters {
    int d = 0;
    while (true) {
        if ([stringObj isKindOfClass:[NSString class]]) break;
        // check that formatters has object index
        
        int formatterKey = 0;
        if (d < formatters.count) {
            id formatter = [formatters objectAtIndex:d];
            
            if ([formatter isKindOfClass:[NSNumber class]]) {
                formatterKey = [self formatterKeyForNumber:formatter];
            }
            else if ([formatter conformsToProtocol:@protocol(GenderProtocol)]) {
                formatterKey = [(id<GenderProtocol>) formatter gender];
            }
        }
        
        NSString *genderKey = [NSString stringWithFormat:@"%d", formatterKey];
        stringObj = [stringObj objectForKey:genderKey];
        
        d++;
    }
    return stringObj;
}

- (int)formatterKeyForNumber:(NSNumber *)number {
    switch ([number intValue]) {
        case 1:     return 0;
        default:    return 1;
    }
}

- (NSString *)replace:(NSString *)string withFormatters:(NSArray *)formatters {
    for (int i = 0; i < formatters.count; i++) {
        NSString *formatter = [formatters objectAtIndex:i];
        NSString *searchString = [self searchString:i];
        
        NSRange stringRange;
        
        stringRange.location = 0;
        stringRange.length = string.length;
        string = [string stringByReplacingOccurrencesOfString:searchString withString:formatter.description options:NSLiteralSearch range:stringRange];
    }
    return string;
}

- (NSString *)searchString:(int)position {
    NSString *searchString = @"%";
    searchString = [searchString stringByAppendingFormat:@"%d", position+1];
    searchString = [searchString stringByAppendingString:@"$@"];
    return searchString;
}

- (NSString *)replacePlainFormattersWithNumbered:(NSString *)string {
    int d = 0;
    NSRange formatterRange;
    while (true) {
        formatterRange = [string rangeOfString:@"%@" options:NSLiteralSearch];
        
        if (formatterRange.location == NSNotFound) break;
        
        NSString *searchString = [self searchString:d];
        string = [string stringByReplacingCharactersInRange:formatterRange withString:searchString];
        d++;
    }
    return string;
}

@end
