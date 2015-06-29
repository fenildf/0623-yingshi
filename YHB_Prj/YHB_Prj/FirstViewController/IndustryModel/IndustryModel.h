//
//  IndustryModel.h
//
//  Created by  C陈政旭 on 15/6/29
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface IndustryModel : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double success;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) double code;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
