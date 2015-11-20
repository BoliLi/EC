//
//  RadicalBlock.m
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

@implementation RadicalBlock
@synthesize content;
@synthesize parent;
@synthesize guid;
@synthesize c_idx;
@synthesize roll;
@synthesize is_base_expo;
@synthesize ancestor;

-(id) init : (Equation *)e {
    self = [super init];
    if (self) {
        self.ancestor = e;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.content = [[EquationBlock alloc] init:e];
        self.guid = ++e.guid_cnt;
        self.roll = e.curRoll;
        
        if (e.curFont == e.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
    }
    return self;
}

-(id) init : (CGPoint)inputPos : (Equation *)e {
    self = [super init];
    if (self) {
        self.ancestor = e;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = ++e.guid_cnt;
        self.name = @"radical";
        self.hidden = NO;
        self.roll = e.curRoll;
        
        CGRect frame;
        frame.size.height = RADICAL_MARGINE_T + e.curFontH + RADICAL_MARGINE_B;
        CGFloat margineL = RADICAL_MARGINE_L_PERC * frame.size.height;
        frame.origin.x = inputPos.x + margineL;
        frame.origin.y = inputPos.y - RADICAL_MARGINE_B;
        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :frame.origin :e :TEXTLAYER_EMPTY];
        
        self.content = [[EquationBlock alloc] init:e];
        layer.parent = self.content;
        self.content.parent = self;
        self.content.roll = ROLL_ROOT_ROOT;
        self.content.mainFrame = layer.frame;
        self.content.numerFrame = layer.frame;
        self.content.numerTopHalf = e.curFontH / 2.0;
        self.content.numerBtmHalf = e.curFontH / 2.0;
        
        frame.origin.x = inputPos.x;
        frame.origin.y = inputPos.y - RADICAL_MARGINE_T - RADICAL_MARGINE_B;
        frame.size.width = margineL + e.curFontW + RADICAL_MARGINE_R;
        self.frame = frame;
        
        layer.roll = ROLL_NUMERATOR;
        layer.c_idx = 0;
        [self.content.children addObject:layer];
        [e.view.layer addSublayer: layer];
        e.curBlock = layer;
        e.curTextLayer = layer;
        e.curParent = self.content;
        e.needNewLayer = NO;
        
        if (e.curFont == e.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
    }
    return self;
}

-(void) updateFrame {
    EquationBlock *eBlock = self.content;
    CGRect frame;
    
    frame.size.height = eBlock.mainFrame.size.height + RADICAL_MARGINE_T + RADICAL_MARGINE_B;
    CGFloat margineL = RADICAL_MARGINE_L_PERC * frame.size.height;
    frame.origin.x = eBlock.mainFrame.origin.x - margineL;
    frame.origin.y = eBlock.mainFrame.origin.y - RADICAL_MARGINE_T;
    frame.size.width = eBlock.mainFrame.size.width + margineL + RADICAL_MARGINE_R;
    self.frame = frame;
}

-(void) destroy {
    [self.content destroy];
    [self removeFromSuperlayer];
}
@end
