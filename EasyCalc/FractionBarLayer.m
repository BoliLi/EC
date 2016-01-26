//
//  FractionBarLayer.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import "Global.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"

@implementation FractionBarLayer

@synthesize guid;
@synthesize c_idx;
@synthesize parent;
@synthesize ancestor;
@synthesize is_base_expo;

-(id) init : (Equation *)e {
    self = [super init];
    if (self) {
        self.ancestor = e;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = ++e.guid_cnt;
        
        if (e.curFont == e.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.is_base_expo = [coder decodeIntForKey:@"is_base_expo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.is_base_expo forKey:@"is_base_expo"];
}

-(void) destroy {
    [self removeFromSuperlayer];
}
@end
