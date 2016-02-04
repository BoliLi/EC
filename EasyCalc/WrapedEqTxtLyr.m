//
//  WrapedEqTxtLyr.m
//  EasyCalc
//
//  Created by LiBoli on 16/2/3.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import "Global.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"
#import "WrapedEqTxtLyr.h"

@implementation WrapedEqTxtLyr
@synthesize guid;
@synthesize c_idx;
@synthesize parent;
@synthesize ancestor;
@synthesize is_base_expo;
@synthesize mainFrame;
@synthesize roll;
@synthesize prefix;
@synthesize content;
@synthesize suffix;

-(id) init : (NSString *)str : (CGPoint)inputPos : (Equation *)E {
    self = [super init];
    if (self) {
        self.ancestor = E;
        self.guid = E.guid_cnt++;
        self.roll = E.curRoll;
        
        if (E.curFont == E.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
    }
    return self;
}
@end
