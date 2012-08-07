//
//  PerformanceTest.h
//  translationDictionary
//
//  Created by Jan on 8/7/12.
//  Copyright (c) 2012 foursquare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PerformanceTest : NSObject

- (float)dictLookup;
- (float)arrayLookup;

-(void)loadJsonDict;
-(void)destroyJsonDict;

-(void)loadJsonArray;
-(void)destroyJsonArray;

- (NSString *)setRandomLookupWord;
@end
