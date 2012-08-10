//
//  Localization.m
//  translationDictionary
//
//  Created by Jan on 8/3/12.
//  Copyright (c) 2012 foursquare. All rights reserved.
//

#import "Localization.h"
#import "FSNConnection.h"

@interface Localization ()
@property (nonatomic) NSDictionary *localizedStrings;
@property (nonatomic) NSArray *stringFormatters;
@property (nonatomic) NSMutableDictionary *requestedStrings;
@end

@implementation Localization

const NSString* const projectId = @"5021c36c08f020242cc01293";

+ (id)sharedLocalization {
    static dispatch_once_t pred;
    static Localization *localization = nil;
    
    dispatch_once(&pred, ^{
        localization = [[self alloc] init];
        [localization loadData];
        localization.requestedStrings = [NSMutableDictionary dictionary];
    });
    return localization;
}


- (void)loadData {
    NSData *localizedData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"localized" ofType:@"json"]];
    self.localizedStrings = [NSJSONSerialization JSONObjectWithData:localizedData options:NSJSONReadingMutableLeaves error:nil];
}


- (NSString *)localizedString:(NSString *)string formatters:(NSArray *)formatters {
    @try {
        string = [self replacePlainFormattersWithNumbered:string];
        
        if ([self.requestedStrings objectForKey:string]) {
            NSNumber *oldCount = [self.requestedStrings objectForKey:string];
            int newCount = oldCount.integerValue + 1;
            [self.requestedStrings setValue:[NSNumber numberWithInt:newCount] forKey:string];
        }
        else {
            [self.requestedStrings setValue:[NSNumber numberWithInt:1] forKey:string];
        }
        
        string = [self localizedStringForKey:string withFormatters:formatters];
        
        string = [self replace:string withFormatters:formatters];
    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@", exception);
    }
    @finally {
        return string;
    }
}


- (NSString *)localizedStringForKey:(NSString *)string withFormatters:(NSArray *)formatters {
    id stringData = [self.localizedStrings objectForKey:string];
    
    if (stringData != nil) {
        if ([stringData isKindOfClass:[NSString class]]) return stringData;
        if ([stringData isKindOfClass:[NSDictionary class]]) return [self stringInDict:stringData withFormatters:formatters];
    }
    return string;
}


- (NSString *)stringInDict:(id)stringObj withFormatters:(NSArray *)formatters {
    int d = 0;
    while (true) {
        if ([stringObj isKindOfClass:[NSString class]]) break;
        // check that formatters has object index
        
        int formatterKey = [self formatterKeyForFormatters:formatters atIndex:d];
                
        NSString *genderKey = [NSString stringWithFormat:@"%d", formatterKey];
        
        // we try to use the key, if it doesn't exist, we grab the fallback = 0
        id nestedStringObj = [stringObj objectForKey:genderKey] ? [stringObj objectForKey:genderKey] : [stringObj objectForKey:0];

        if (nestedStringObj == nil) {
            // if even the fallback fails, we just grab whatever is there
            nestedStringObj = [stringObj objectForKey:[[stringObj allKeys] lastObject]];
        }
        stringObj = nestedStringObj;
        
        d++;
    }
    return stringObj;
}


- (int)formatterKeyForFormatters:(NSArray *)formatters atIndex:(int)d {
    int formatterKey = 0;
    if (d < formatters.count && d < self.stringFormatters.count) {
        id formatter = [formatters objectAtIndex:d];
        NSString *formatterKeyString = [self.stringFormatters objectAtIndex:d];
        if ([formatterKeyString isEqualToString:@"#"] && [formatter isKindOfClass:[NSNumber class]]) {
            formatterKey = [self formatterKeyForNumber:formatter];
        }
        else if ([formatterKeyString isEqualToString:@"^"] && [formatter conformsToProtocol:@protocol(GenderProtocol)]) {
            formatterKey = [(id<GenderProtocol>) formatter gender];
        }
    }
    return formatterKey;
}


- (int)formatterKeyForNumber:(NSNumber *)number {
    switch ([number intValue]) {
        case 1:     return 0;
        default:    return 1;
    }
}


- (NSString *)replace:(NSString *)string withFormatters:(NSArray *)formatters {
    int d = 0;
    for (NSString *stringFormatter in self.stringFormatters) {
        NSString *formatter = [formatters objectAtIndex:d];
        NSString *searchString = [self searchString:d forKey:stringFormatter];
        NSRange stringRange;
        
        stringRange.location = 0;
        stringRange.length = string.length;
        string = [string stringByReplacingOccurrencesOfString:searchString withString:formatter.description options:NSLiteralSearch range:stringRange];

        d++;
    }
    return string;
}


- (NSString *)searchString:(int)position forKey:(NSString *)key {
    NSString *searchString = [NSString stringWithFormat:@"{%@%d}", key, position+1];
    return searchString;
}


- (NSString *)replacePlainFormattersWithNumbered:(NSString *)string {
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{[\\^#]\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    
    __block int d = 0;
    __block NSString *returnString = string;

    __block NSMutableArray *mutableStringFormatters = [NSMutableArray array];
    
    [regex enumerateMatchesInString:string options:0 range:NSMakeRange(0,string.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {

        NSString *formatter = [string substringWithRange:NSMakeRange(match.range.location+1, 1)];
        [mutableStringFormatters addObject:formatter];
        
        NSString *searchString = [self searchString:d forKey:formatter];

        NSRange matchRange;
        matchRange.location = match.range.location + d;
        matchRange.length = 3;
        
        returnString = [returnString stringByReplacingCharactersInRange:matchRange withString:searchString];
        d++;
    }];
    self.stringFormatters = [NSArray arrayWithArray:mutableStringFormatters];
    
    return returnString;
}

- (void)uploadRequests {
    if (self.requestedStrings.count > 0) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://108.171.174.170/v1/string/%@/%@", projectId, [[NSLocale preferredLanguages] objectAtIndex:0]]];
        
        NSString *uploadString = [NSString stringWithFormat:@"%@",self.requestedStrings ];
        NSDictionary *parameters = @{ @"requests" : uploadString };
        __weak Localization *weak_self = self;
        FSNConnection *uploadConnection = [FSNConnection withUrl:url
                                                          method:FSNRequestMethodPOST
                                                         headers:nil
                                                      parameters:parameters
                                                      parseBlock:^id(FSNConnection *c, NSError **e) {
                                                         return [c.responseData dictionaryFromJSONWithError:e];
                                                    }
                                                 completionBlock: ^(FSNConnection *c) {
                                                     NSLog(@"%@", c.parseResult);
                                                     weak_self.requestedStrings = nil;
                                                 }
                                                   progressBlock:nil];
        [uploadConnection start];
    }
}
@end
