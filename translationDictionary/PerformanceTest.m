//
//  PerformanceTest.m
//  translationDictionary
//
//  Created by Jan on 8/7/12.
//  Copyright (c) 2012 foursquare. All rights reserved.
//


#import "PerformanceTest.h"


@interface PerformanceTest ()
@property (nonatomic) NSDictionary  *dictionaryJson;
@property (nonatomic) NSDictionary  *arrayJson;
@property (nonatomic) NSString      *lookupWord;
@property (nonatomic) NSDictionary  *nestedArrayJson;
@end


@implementation PerformanceTest


- (NSString *)randomLookupKey:(int)lookupIndex inDict:(NSDictionary *)dict {
    NSString *lookupKey = [dict.allKeys objectAtIndex:lookupIndex];
    return lookupKey;
}


- (NSString *)setRandomLookupWord {
    NSDictionary *lookupDict = self.dictionaryJson ? self.dictionaryJson : self.arrayJson;
    if (lookupDict) {
        int lookupIndex = arc4random() % lookupDict.count - 1;
        self.lookupWord = [self randomLookupKey:lookupIndex inDict:lookupDict];
    }
    return self.lookupWord;
}


-(void)loadJsonDict {
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"testDict" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    NSError *error = nil;
    self.dictionaryJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) NSLog(@"%@", [error localizedDescription]);
}


-(void)destroyJsonDict {
    self.dictionaryJson = nil;
}

- (NSString *)combinationString:(NSDictionary *)dict {
    id combination = [dict objectForKey:@"3"];
    if ([combination isKindOfClass:[NSString class]]) return combination;
    return [self combinationString:combination];
}


- (float)dictLookup {
    if (self.dictionaryJson != nil && self.lookupWord != nil) {
        NSDate *startDate = [NSDate date];
        NSLog(@"%@", [self combinationString:[self.dictionaryJson objectForKey:self.lookupWord]] );
        return [[NSDate date] timeIntervalSinceDate:startDate];
    }
    return 0;
}


- (float)arrayLookup {
    if (self.arrayJson != nil && self.lookupWord != nil) {        
        NSDate *startDate = [NSDate date];
        NSLog(@"%@", [[self.arrayJson objectForKey:self.lookupWord] objectAtIndex:3] );
        return [[NSDate date] timeIntervalSinceDate:startDate];
    }
    return 0;
}


-(void)loadJsonArray {
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"testArray" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    NSError *error = nil;
    self.arrayJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) NSLog(@"%@", [error localizedDescription]);
}


-(void)destroyJsonArray {
    self.arrayJson = nil;
}


- (void)loadNestedArray {
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"testNestedArray" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    NSError *error = nil;
    self.nestedArrayJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) NSLog(@"%@", [error localizedDescription]);\
}


- (void)destroyNestedArray {
    self.nestedArrayJson = nil;
}


@end
