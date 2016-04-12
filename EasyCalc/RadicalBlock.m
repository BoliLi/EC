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
#import "CalcBoard.h"

@implementation RadicalBlock
@synthesize content;
@synthesize parent;
@synthesize guid;
@synthesize c_idx;
@synthesize roll;
@synthesize is_base_expo;
@synthesize ancestor;
@synthesize rootNum;
@synthesize fontLvl;

-(id) init :(Equation *)e :(ViewController *)vc {
    self = [super init];
    if (self) {
        CalcBoard *calcB = e.par;
        
        self.ancestor = e;
        self.delegate = vc;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.content = [[EquationBlock alloc] init:e];
        self.guid = e.guid_cnt++;
        self.roll = calcB.curRoll;
        self.fontLvl = calcB.curFontLvl;
        is_base_expo = calcB.base_or_expo;
    }
    return self;
}

-(id) init : (CGPoint)inputPos : (Equation *)e : (int)rootCnt :(ViewController *)vc {
    self = [super init];
    if (self) {
        CalcBoard *calcB = e.par;
        
        self.ancestor = e;
        self.delegate = vc;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = e.guid_cnt++;
        self.name = @"radical";
        self.hidden = NO;
        self.roll = calcB.curRoll;
        
        CGRect frame;
        frame.size.height = RADICAL_MARGINE_T + calcB.curFontH + RADICAL_MARGINE_B;
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
        self.content.numerTopHalf = calcB.curFontH / 2.0;
        self.content.numerBtmHalf = calcB.curFontH / 2.0;
        
        frame.origin.x = inputPos.x;
        frame.origin.y = inputPos.y - RADICAL_MARGINE_T - RADICAL_MARGINE_B;
        frame.size.width = margineL + calcB.curFontW + RADICAL_MARGINE_R;
        self.frame = frame;
        
        if (rootCnt == 3) {
            int orgFontLvl = calcB.curFontLvl;
            [calcB updateFontInfo:orgFontLvl + 1];
            self.rootNum = [[EquationTextLayer alloc] init:@"3" :CGPointMake(inputPos.x + margineL / 2.0 - 4.0, frame.origin.y) :e :TEXTLAYER_NUM];
            [calcB.view.layer addSublayer: self.rootNum];
            [calcB updateFontInfo:orgFontLvl];
        }
        
        layer.roll = ROLL_NUMERATOR;
        layer.c_idx = 0;
        [self.content.children addObject:layer];
        [calcB.view.layer addSublayer: layer];
        calcB.curBlk = layer;
        calcB.curTxtLyr = layer;
        self.fontLvl = calcB.curFontLvl;
        self.is_base_expo = calcB.base_or_expo;
    }
    return self;
}

- (void)updateCopyBlock:(Equation *)e {
    ancestor = e;
    guid = e.guid_cnt++;
    content.parent = self;
    [content updateCopyBlock:e];
    if (rootNum != nil) {
        rootNum.parent = self;
        [rootNum updateCopyBlock:e];
    }
    
    CalcBoard *calcB = e.par;
    [calcB.view.layer addSublayer:self];
    [self setNeedsDisplay];
}

- (void)updateSize:(int)lvl {
    if (self.fontLvl == lvl) {
        return;
    }
    
    [self.content updateSize:lvl];
    
    if (self.rootNum != nil) {
        [self.rootNum updateSize:lvl + 1];
    }
    
    [self updateFrame];
    
    self.fontLvl = lvl;
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
        self.fontLvl = [coder decodeIntForKey:@"fontLvl"];
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
    [coder encodeInt:self.fontLvl forKey:@"fontLvl"];
}

- (id)copyWithZone:(NSZone *)zone {
    RadicalBlock *copy = [[[self class] allocWithZone :zone] init];
    copy.content = [self.content copy];
    copy.c_idx = self.c_idx;
    copy.roll = self.roll;
    copy.is_base_expo = self.is_base_expo;
    if (self.rootNum != nil) {
        copy.rootNum = [self.rootNum copy];
    }
    copy.fontLvl = self.fontLvl;
    
    copy.frame = self.frame;
    copy.delegate = self.delegate;
    copy.contentsScale = [UIScreen mainScreen].scale;
    copy.name = [self.name copy];
    copy.hidden = NO;
    return copy;
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
    
    if (self.rootNum != nil) {
        CGFloat ML = RADICAL_MARGINE_L_PERC * self.frame.size.height;
        CGRect f = self.rootNum.frame;
        self.rootNum.frame = CGRectMake(frame.origin.x + ML / 2.0 - 4.0, frame.origin.y, f.size.width, f.size.height);
    }
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
