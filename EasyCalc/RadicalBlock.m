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
#import "UIView+Easing.h"

@implementation RadicalBlock
@synthesize content;
@synthesize parent;
@synthesize guid;
@synthesize c_idx;
@synthesize roll;
@synthesize ancestor;
@synthesize rootNum;
@synthesize fontLvl;
@synthesize isCopy;
@synthesize mainFrame;

//-(id) init :(Equation *)e :(ViewController *)vc {
//    self = [super init];
//    if (self) {
//        CalcBoard *calcB = e.par;
//        
//        self.ancestor = e;
//        self.delegate = vc;
//        self.contentsScale = [UIScreen mainScreen].scale;
//        self.content = [[EquationBlock alloc] init:e];
//        self.guid = e.guid_cnt++;
//        self.roll = calcB.curRoll;
//        self.fontLvl = calcB.curFontLvl;
//        self.isCopy = NO;
//    }
//    return self;
//}

-(id) init : (Equation *)e :(ViewController *)vc :(BOOL)hasRootNum {
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
        self.isCopy = NO;
        self.rootNum = nil;
        
        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :e :TEXTLAYER_EMPTY];
        
        self.content = [[EquationBlock alloc] init:e];
        layer.parent = self.content;
        self.content.parent = self;
        self.content.roll = ROLL_ROOT_ROOT;
        self.content.mainFrame = layer.frame;
        self.content.numerFrame = layer.frame;
        self.content.numerTopHalf = calcB.curFontH / 2.0;
        self.content.numerBtmHalf = calcB.curFontH / 2.0;
        
        CGRect frame = CGRectZero;
        frame.size.height = RADICAL_MARGINE_T + calcB.curFontH + RADICAL_MARGINE_B;
        CGFloat margineL = RADICAL_MARGINE_L_PERC * frame.size.height;
        frame.size.width = margineL + calcB.curFontW + RADICAL_MARGINE_R;
        self.frame = frame;
        self.mainFrame = frame;
        
        if (hasRootNum) {
            int orgFontLvl = calcB.curFontLvl;
            [calcB updateFontInfo:orgFontLvl + 1];
            self.rootNum = [[EquationTextLayer alloc] init:@"_" :e :TEXTLAYER_EMPTY];
            self.rootNum.ancestor = e;
            self.rootNum.parent = self;
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
    
    if (rootNum != nil) {
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
        self.rootNum = [coder decodeObjectForKey:@"rootNum"];
        self.fontLvl = [coder decodeIntForKey:@"fontLvl"];
        self.isCopy = NO;
        self.mainFrame = [coder decodeCGRectForKey:@"mainFrame"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeInt:self.guid forKey:@"guid"];
    [coder encodeInt:self.roll forKey:@"roll"];
    if (rootNum != nil) {
        [coder encodeObject:self.rootNum forKey:@"rootNum"];
    }
    [coder encodeInt:self.fontLvl forKey:@"fontLvl"];
    [coder encodeCGRect:self.mainFrame forKey:@"mainFrame"];
}

- (id)copyWithZone:(NSZone *)zone {
    RadicalBlock *copy = [[[self class] allocWithZone :zone] init];
    copy.content = [self.content copy];
    copy.c_idx = self.c_idx;
    copy.roll = self.roll;
    if (self.rootNum != nil) {
        copy.rootNum = [self.rootNum copy];
    }
    copy.fontLvl = self.fontLvl;
    copy.frame = self.frame;
    copy.delegate = self.delegate;
    copy.contentsScale = [UIScreen mainScreen].scale;
    copy.name = [self.name copy];
    copy.hidden = NO;
    copy.isCopy = YES;
    copy.mainFrame = self.mainFrame;
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
        CGRect f = self.rootNum.frame;
        self.rootNum.frame = CGRectMake(frame.origin.x + margineL / 2.0 - f.size.width, frame.origin.y, f.size.width, f.size.height);
        self.mainFrame = CGRectUnion(self.frame, self.rootNum.frame);
    } else {
        self.mainFrame = self.frame;
    }
    
}

-(void) moveCopy:(CGPoint)dest {
    self.isCopy = NO;
    
    CGPoint radiDest = dest;
    radiDest.x = dest.x + self.mainFrame.size.width / 2.0 - self.frame.size.width / 2.0;
    
    CGPoint contDest;
    
    contDest.x = radiDest.x + self.frame.size.width / 2.0 - RADICAL_MARGINE_R - self.content.mainFrame.size.width / 2.0;
    contDest.y = radiDest.y - self.frame.size.height / 2.0 + RADICAL_MARGINE_T + self.content.mainFrame.size.height / 2.0;
    
    if (self.rootNum != nil) {
        CGPoint rootNumDest;
        CGFloat ML = RADICAL_MARGINE_L_PERC * self.frame.size.height;
        rootNumDest.x = radiDest.x - self.frame.size.width / 2.0 + ML / 2.0 - self.rootNum.frame.size.width / 2.0;
        rootNumDest.y = radiDest.y - self.frame.size.height / 2.0 + self.rootNum.frame.size.height / 2.0;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.5;
        animation.delegate = self;
        animation.fromValue = [NSValue valueWithCGPoint:self.rootNum.position];
        animation.toValue = [NSValue valueWithCGPoint:rootNumDest];
        [animation setTimingFunction:easeOutBack];
        [self.rootNum addAnimation:animation forKey:nil];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.rootNum.position = rootNumDest;
        [CATransaction commit];
    }
    
    NSLog(@"%s%i>~%@~%@~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGPoint(self.position), NSStringFromCGPoint(radiDest));
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.5;
    animation.delegate = self;
    animation.fromValue = [NSValue valueWithCGPoint:self.position];
    animation.toValue = [NSValue valueWithCGPoint:radiDest];
    [animation setTimingFunction:easeOutBack];
    [self addAnimation:animation forKey:nil];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.position = radiDest;
    [CATransaction commit];
    
    [self.content moveCopy:contDest];
}

-(void) reorganize :(Equation *)anc :(ViewController *)vc :(int)chld_idx :(id)par {
    CalcBoard *calcB = anc.par;
    self.isCopy = NO;
    self.c_idx = chld_idx;
    self.parent = par;
    self.ancestor = anc;
    self.delegate = vc;
    [calcB.view.layer addSublayer: self];
    [self setNeedsDisplay];
    
    if (self.rootNum != nil) {
        self.rootNum.parent = self;
        self.rootNum.ancestor = anc;
        [calcB.view.layer addSublayer: self.rootNum];
    }
    
    [self.content reorganize:anc :vc :0 :self];
}

-(void) updateFrameWidth : (CGFloat)incrWidth : (int)r {
    CGFloat orgW = self.mainFrame.size.width;
    [self updateFrame];
    [self setNeedsDisplay];
    if ((int)orgW != (int)self.mainFrame.size.width) {
        [self.parent updateFrameWidth:self.mainFrame.size.width - orgW :self.roll];
    }
}

-(void) updateCalcBoardInfo {
    Equation *eq = self.ancestor;
    CalcBoard *cb = eq.par;
    cb.insertCIdx = self.c_idx + 1;
    cb.curTxtLyr = nil;
    cb.curBlk = self;
    cb.txtInsIdx = 1;
    cb.curRoll = self.roll;
    cb.curParent = self.parent;
    [cb updateFontInfo:self.fontLvl];
    if (self.c_idx == ((EquationBlock *)self.parent).children.count - 1) {
        cb.curMode = MODE_INPUT;
    } else {
        cb.curMode = MODE_INSERT;
    }
    cb.view.cursor.frame = CGRectMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y, CURSOR_W, self.frame.size.height);
}

-(EquationTextLayer *) lookForEmptyTxtLyr {
    if (self.rootNum != nil && self.rootNum.type == TEXTLAYER_EMPTY) {
        return self.rootNum;
    }
    return [self.content lookForEmptyTxtLyr];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([self animationForKey:@"remove"] == anim) {
        [self removeFromSuperlayer];
    }
}

-(void) destroy {
    [self.content destroy];
    
    if (self.rootNum != nil) {
        [self.rootNum destroy];
        self.rootNum = nil;
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0.0];
    animation.duration = 0.4;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.delegate = self;
    [self addAnimation:animation forKey:@"remove"];
}
@end
