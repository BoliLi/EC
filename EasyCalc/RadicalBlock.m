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
#import "WrapedEqTxtLyr.h"
#import "Parentheses.h"

@implementation RadicalBlock
@synthesize content;
@synthesize parent;
@synthesize guid;
@synthesize c_idx;
@synthesize roll;
@synthesize is_base_expo;
@synthesize ancestor;
@synthesize rootNum;

-(id) init :(Equation *)e :(ViewController *)vc {
    self = [super init];
    if (self) {
        self.ancestor = e;
        self.delegate = vc;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.content = [[EquationBlock alloc] init:e];
        self.guid = e.guid_cnt++;
        self.roll = e.curRoll;
        
        if (e.curFont == e.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
    }
    return self;
}

-(id) init : (CGPoint)inputPos : (Equation *)e : (int)rootCnt :(ViewController *)vc {
    self = [super init];
    if (self) {
        self.ancestor = e;
        self.delegate = vc;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = e.guid_cnt++;
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
        
        if (rootCnt == 3) {
            UIFont *orgFont = e.curFont;
            e.curFont = e.superscriptFont;
            self.rootNum = [[EquationTextLayer alloc] init:@"3" :CGPointMake(inputPos.x + margineL / 2.0 - 4.0, frame.origin.y) :e :TEXTLAYER_NUM];
            [e.view.layer addSublayer: self.rootNum];
            e.curFont = orgFont;
        }
        
        layer.roll = ROLL_NUMERATOR;
        layer.c_idx = 0;
        [self.content.children addObject:layer];
        [e.view.layer addSublayer: layer];
        e.curBlk = layer;
        e.curTxtLyr = layer;
        
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
        self.content = [coder decodeObjectForKey:@"content"];
        self.guid = [coder decodeIntForKey:@"guid"];
        self.roll = [coder decodeIntForKey:@"roll"];
        self.is_base_expo = [coder decodeIntForKey:@"is_base_expo"];
        self.rootNum = [coder decodeObjectForKey:@"rootNum"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeInt:self.guid forKey:@"guid"];
    [coder encodeInt:self.roll forKey:@"roll"];
    [coder encodeInt:self.is_base_expo forKey:@"is_base_expo"];
    if (self.rootNum != nil) {
        [coder encodeObject:self.rootNum forKey:@"rootNum"];
    }
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
    if (self.rootNum != nil) {
        [self.rootNum removeFromSuperlayer];
        self.rootNum = nil;
    }
    [self removeFromSuperlayer];
}
@end
