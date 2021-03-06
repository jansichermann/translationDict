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
    NSString *filePath = [self filePathForLanguage:[self phoneLanguage]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        self.localizedStrings = dict;
    }
    else {
        NSData *localizedData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"localized" ofType:@"json"]];
        self.localizedStrings = [NSJSONSerialization JSONObjectWithData:localizedData options:NSJSONReadingMutableLeaves error:nil];
    }
}

- (void)didReceiveMemoryWarning {
    self.localizedStrings = nil;
}

// MARK: BASE FUNCTION

- (NSString *)localizedString:(NSString *)string formatters:(NSArray *)formatters {
    @try {
        NSArray *placeholders = nil;
        [self replacePlainFormatters:&placeholders withNumberedinString:&string];
        
        // string analytics and request
        if ([self.requestedStrings objectForKey:string]) {
            NSNumber *oldCount = [self.requestedStrings objectForKey:string];
            int newCount = oldCount.integerValue + 1;
            [self.requestedStrings setValue:[NSNumber numberWithInt:newCount] forKey:string];
        }
        else {
            [self.requestedStrings setValue:[NSNumber numberWithInt:1] forKey:string];
        }
        
        
        string = [self localizedStringForKey:string withPlaceholders:placeholders andFormatters:formatters];
        
        string = [self replacePlaceholders:placeholders inString:string withFormatters:formatters];
    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@", exception);
    }
    @finally {
        return string;
    }
}




// MARK: helpers

- (NSString *)localizedStringForKey:(NSString *)string withPlaceholders:(NSArray *)placeholders andFormatters:(NSArray *)formatters {
    
    if (self.localizedStrings == nil) [self loadData];
    
    id stringData = [self.localizedStrings objectForKey:string];

    if (stringData != nil) {
        if ([stringData isKindOfClass:[NSString class]]) return stringData;
        if ([stringData isKindOfClass:[NSDictionary class]]) return [self stringInDict:stringData withPlaceholders:placeholders andFormatters:formatters];
    }
    return string;
}


- (NSString *)stringInDict:(id)stringObj withPlaceholders:(NSArray *)placeholders andFormatters:(NSArray *)formatters {
    int d = 0;
    while (true) {
        if ([stringObj isKindOfClass:[NSString class]]) break;
        // check that formatters has object index
        
        int formatterKey = [self formatterKeyForFormatters:formatters andPlaceholders:placeholders atIndex:d];
                
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


- (int)formatterKeyForFormatters:(NSArray *)formatters andPlaceholders:(NSArray *)placeholders atIndex:(int)d {
    int formatterKey = 0;
    if (d < formatters.count && d < placeholders.count) {
        id formatter = [formatters objectAtIndex:d];
        NSString *formatterKeyString = [placeholders objectAtIndex:d];
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
    // ENGLISH
    switch ([number intValue]) {
        case 1:     return 1;
        default:    return 0;
    }
}


- (NSString *)replacePlaceholders:(NSArray *)placeholders inString:(NSString *)string withFormatters:(NSArray *)formatters {
    int d = 0;
    for (NSString *stringFormatter in placeholders) {
        NSString *formatter = [formatters objectAtIndex:d];
        NSString *searchString = [self searchString:d forKey:stringFormatter];
        NSRange stringRange;
        
        stringRange.location = 0;
        stringRange.length = string.length;
        string = [string stringByReplacingOccurrencesOfString:searchString withString:formatter.description options:NSLiteralSearch range:stringRange];

        d++;
    }
    
    // replace literals
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{[!][A-z=]*\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    
    while (TRUE) {
        NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
        if (match == nil) break;
        else {
            NSRange substringRange = match.range;
            substringRange.location += 2;
            substringRange.length -= 3;
            NSString *substring = [string substringWithRange:substringRange];

            NSRange translationRange = [substring rangeOfString:@"="];
            if (translationRange.location != NSNotFound) {
                substring = [substring substringFromIndex:++translationRange.location];
            }

            string = [string stringByReplacingCharactersInRange:match.range withString:substring];
        }
    }
    return string;
}


- (NSString *)searchString:(int)position forKey:(NSString *)key {
    NSString *searchString = [NSString stringWithFormat:@"{%@%d}", key, position+1];
    return searchString;
}


- (void)replacePlainFormatters:(NSArray **)placeholders withNumberedinString:(NSString **)string {
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{[\\^#]\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    
    __block int d = 0;
    __block NSString *returnString = *string;

    __block NSMutableArray *mutableStringFormatters = [NSMutableArray array];
    
    [regex enumerateMatchesInString:*string options:0 range:NSMakeRange(0,[(NSString *)*string length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {

        NSString *formatter = [*string substringWithRange:NSMakeRange(match.range.location+1, 1)];
        [mutableStringFormatters addObject:formatter];
        
        NSString *searchString = [self searchString:d forKey:formatter];

        NSRange matchRange;
        matchRange.location = match.range.location + d;
        matchRange.length = 3;
        
        returnString = [returnString stringByReplacingCharactersInRange:matchRange withString:searchString];
        d++;
    }];
    *placeholders = [NSArray arrayWithArray:mutableStringFormatters];
    
    *string = returnString;
}

- (void)uploadRequests {
    if (self.requestedStrings.count > 0) {
        NSLog(@"requests: %@", self.requestedStrings);
        NSString *lang = [self phoneLanguage];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://108.171.174.170/v1/strings/%@/%@/addRequests", projectId, lang]];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.requestedStrings options:0 error:nil];
        NSString *uploadString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
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
                                                     if ([c.parseResult isKindOfClass:[NSDictionary class]]) {
                                                         [weak_self saveTranslationDict:(NSDictionary *)c.parseResult forLang:lang];
                                                     }
                                                     weak_self.requestedStrings = nil;
                                                 }
                                                   progressBlock:nil];
        uploadConnection.shouldRunInBackground = YES;
        [uploadConnection start];
    }
}

- (void)saveTranslationDict:(NSDictionary *)dict forLang:(NSString *)lang{
    NSDictionary *langDict = [[dict objectForKey:@"objects"] objectForKey:lang];
    if (langDict != nil) {
        NSString *filePath = [self filePathForLanguage:lang];
        [langDict writeToFile:filePath atomically:YES];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        [self addSkipBackupAttributeToItemAtURL:url];
    }
}

- (NSString *)filePathForLanguage:(NSString *)lang {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", lang]];
}

- (NSString *)phoneLanguage {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    if (URL) {
        assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
        
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    return FALSE;
}
@end
