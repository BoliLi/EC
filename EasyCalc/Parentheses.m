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
        self.ancestor = E;
        self.delegate = vc;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = E.guid_cnt++;
        self.name = @"parentheses";
        self.hidden = NO;
        self.roll = E.curRoll;
        self.l_or_r = l_r;
        
        self.frame = CGRectMake(inputPos.x, inputPos.y, E.curFontH / PARENTH_HW_R, E.curFontH);
        
        if (E.curFont == E.baseFont) {
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

-(void) destroy {
    [self removeFromSuperlayer];
}
@end
