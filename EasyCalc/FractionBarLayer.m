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
#import "WrapedEqTxtLyr.h"
#import "Parentheses.h"
#import "CalcBoard.h"

@implementation FractionBarLayer

@synthesize guid;
@synthesize c_idx;
@synthesize parent;
@synthesize ancestor;
@synthesize is_base_expo;

-(id) init :(Equation *)e :(ViewController *)vc {
    self = [super init];
    if (self) {
        CalcBoard *calcB = e.par;
        
        self.ancestor = e;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = e.guid_cnt++;
        self.delegate = vc;
        is_base_expo = calcB.base_or_expo;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.guid = [coder decodeIntForKey:@"guid"];
        self.is_base_expo = [coder decodeIntForKey:@"is_base_expo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.guid forKey:@"guid"];
    [coder encodeInt:self.is_base_expo forKey:@"is_base_expo"];
}

- (id)copyWithZone:(NSZone *)zone {
    FractionBarLayer *copy = [[[self class] allocWithZone :zone] init];
    copy.c_idx = self.c_idx;
    copy.is_base_expo = self.is_base_expo;
    copy.frame = self.frame;
    copy.delegate = self.delegate;
    copy.contentsScale = [UIScreen mainScreen].scale;
    copy.name = [self.name copy];
    copy.hidden = NO;
    return copy;
}

- (void)updateCopyBlock:(Equation *)e {
    NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
    ancestor = e;
    guid = e.guid_cnt++;
    
    CalcBoard *calcB = e.par;
    [calcB.view.layer addSublayer:self];
    [self setNeedsDisplay];
}

-(void) destroy {
    [self removeFromSuperlayer];
}
@end
