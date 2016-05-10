//
//  EquationTemplate.m
//  EasyCalc
//
//  Created by LiBoli on 16/5/6.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import "EquationTemplate.h"

@implementation EquationTemplate
@synthesize title;
@synthesize detailTitle;
@synthesize root;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.title = [coder decodeObjectForKey:@"title"];
        self.detailTitle = [coder decodeObjectForKey:@"detailTitle"];
        self.root = [coder decodeObjectForKey:@"root"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.detailTitle forKey:@"detailTitle"];
    [coder encodeObject:self.root forKey:@"root"];
}
@end
