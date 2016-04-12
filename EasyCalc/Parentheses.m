//
//  Parentheses.m
//  EasyCalc
//
//  Created by LiBoli on 16/2/25.
//  Copyright © 2016年 LiBoli. All rights reserved.
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

@implementation Parentheses
@synthesize parent;
@synthesize guid;
@synthesize c_idx;
@synthesize roll;
@synthesize is_base_expo;
@synthesize ancestor;
@synthesize l_or_r;

-(id) init :(CGPoint)inputPos :(Equation *)E :(int)l_r :(ViewController *)vc {
    self = [super init];
    if (self) {
        CalcBoard *calcB = E.par;
        
        self.ancestor = E;
        self.delegate = vc;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = E.guid_cnt++;
        self.name = @"parentheses";
        self.hidden = NO;
        self.roll = calcB.curRoll;
        self.l_or_r = l_r;
        self.is_base_expo = calcB.base_or_expo;
        
        self.frame = CGRectMake(inputPos.x, inputPos.y, calcB.curFontH / PARENTH_HW_R, calcB.curFontH);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.guid = [coder decodeIntForKey:@"guid"];
        self.roll = [coder decodeIntForKey:@"roll"];
        self.is_base_expo = [coder decodeIntForKey:@"is_base_expo"];
        self.l_or_r = [coder decodeIntForKey:@"l_or_r"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.guid forKey:@"guid"];
    [coder encodeInt:self.roll forKey:@"roll"];
    [coder encodeInt:self.is_base_expo forKey:@"is_base_expo"];
    [coder encodeInt:self.l_or_r forKey:@"l_or_r"];
}

- (id)copyWithZone:(NSZone *)zone {
    Parentheses *copy = [[[self class] allocWithZone :zone] init];
    copy.c_idx = self.c_idx;
    copy.roll = self.roll;
    copy.is_base_expo = self.is_base_expo;
    copy.l_or_r = self.l_or_r;
    
    copy.frame = self.frame;
    copy.delegate = self.delegate;
    copy.contentsScale = [UIScreen mainScreen].scale;
    copy.name = [self.name copy];
    copy.hidden = NO;
    return copy;
}

- (void)updateCopyBlock:(Equation *)e {
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
