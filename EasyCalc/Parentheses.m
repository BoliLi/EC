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
#import "UIView+Easing.h"

@implementation Parentheses
@synthesize parent;
@synthesize guid;
@synthesize c_idx;
@synthesize roll;
@synthesize ancestor;
@synthesize l_or_r;
@synthesize expo;
@synthesize mainFrame;
@synthesize fontLvl;

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
        self.expo = nil;
        
        self.frame = CGRectMake(inputPos.x, inputPos.y, calcB.curFontH / PARENTH_HW_R, calcB.curFontH);
        self.mainFrame = self.frame;
        self.fontLvl = calcB.curFontLvl;
        self.isCopy = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.guid = [coder decodeIntForKey:@"guid"];
        self.roll = [coder decodeIntForKey:@"roll"];
        self.l_or_r = [coder decodeIntForKey:@"l_or_r"];
        self.expo = [coder decodeObjectForKey:@"expo"];
        self.mainFrame = [coder decodeCGRectForKey:@"mainFrame"];
        self.fontLvl = [coder decodeIntForKey:@"fontLvl"];
        self.isCopy = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.guid forKey:@"guid"];
    [coder encodeInt:self.roll forKey:@"roll"];
    [coder encodeInt:self.l_or_r forKey:@"l_or_r"];
    if (self.expo != nil) {
        [coder encodeObject:self.expo forKey:@"expo"];
    }
    [coder encodeCGRect:self.mainFrame forKey:@"mainFrame"];
    [coder encodeInt:self.fontLvl forKey:@"fontLvl"];
}

- (id)copyWithZone:(NSZone *)zone {
    Parentheses *copy = [[[self class] allocWithZone :zone] init];
    copy.c_idx = self.c_idx;
    copy.roll = self.roll;
    copy.l_or_r = self.l_or_r;
    
    copy.frame = self.frame;
    copy.delegate = self.delegate;
    copy.contentsScale = [UIScreen mainScreen].scale;
    copy.name = [self.name copy];
    copy.hidden = NO;
    if (self.expo != nil) {
        copy.expo = [self.expo copy];
    }
    copy.mainFrame = self.mainFrame;
    copy.fontLvl = self.fontLvl;
    copy.isCopy = YES;
    return copy;
}

- (void)updateCopyBlock:(Equation *)e {
    ancestor = e;
    guid = e.guid_cnt++;
    
    if (expo != nil) {
        expo.parent = self;
        [expo updateCopyBlock:e];
    }
    
    CalcBoard *calcB = e.par;
    [calcB.view.layer addSublayer:self];
    [self setNeedsDisplay];
}

-(void) updateFrameBaseOnBase {
    if (self.expo != nil) {
        CGRect frame = self.expo.mainFrame;
        
        frame.origin.y = self.frame.origin.y + gCharHeightTbl[self.expo.fontLvl] / 2.0 - frame.size.height;
        frame.origin.x = self.frame.origin.x + self.frame.size.width;
        self.expo.mainFrame = frame;
        self.mainFrame = CGRectUnion(frame, self.frame);
    } else {
        self.mainFrame = self.frame;
    }
}

-(void) updateFrameBaseOnExpo {
    CGRect f = self.frame;
    f.origin.x = self.expo.mainFrame.origin.x - f.size.width;
    f.origin.y = self.expo.mainFrame.origin.y + self.expo.mainFrame.size.height - gCharHeightTbl[self.expo.fontLvl] / 2.0;
    self.mainFrame = CGRectUnion(f, self.expo.mainFrame);
}

-(void) moveCopy:(CGPoint)dest {
    NSLog(@"%s%i>~%@~%@~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGPoint(CGPointMake(self.mainFrame.origin.x + self.mainFrame.size.width / 2.0, self.mainFrame.origin.y + self.mainFrame.size.height / 2.0)), NSStringFromCGPoint(dest));
    
    self.isCopy = NO;
    self.mainFrame = CGRectMake(dest.x - self.frame.size.width / 2.0, dest.y + self.frame.size.height / 2.0 - self.mainFrame.size.height, self.mainFrame.size.width, self.mainFrame.size.height);
    
    if (self.expo == nil) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.5;
        animation.delegate = self;
        animation.fromValue = [NSValue valueWithCGPoint:self.position];
        animation.toValue = [NSValue valueWithCGPoint:dest];
        [animation setTimingFunction:easeOutBack];
        [self addAnimation:animation forKey:nil];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.position = dest;
        [CATransaction commit];
    } else {
        CGPoint expoPos;
        expoPos.x = self.mainFrame.origin.x + self.mainFrame.size.width - self.expo.mainFrame.size.width / 2.0;
        expoPos.y = self.mainFrame.origin.y + self.expo.mainFrame.size.height / 2.0;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.5;
        animation.delegate = self;
        animation.fromValue = [NSValue valueWithCGPoint:self.position];
        animation.toValue = [NSValue valueWithCGPoint:dest];
        [animation setTimingFunction:easeOutBack];
        [self addAnimation:animation forKey:nil];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.position = dest;
        [CATransaction commit];
        
        [self.expo moveCopy:expoPos];
    }
}

-(void) updateFrameWidth : (CGFloat)incrWidth : (int)r {
    CGFloat orgWidth1 = self.mainFrame.size.width;
    [self updateFrameBaseOnBase];
    if ((int)orgWidth1 != (int)self.mainFrame.size.width) {
        [self.parent updateFrameWidth:self.mainFrame.size.width - orgWidth1 :self.roll];
    }
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
    if (self.expo != nil) {
        [self.expo reorganize:anc :vc :0 :self];
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
    cb.view.cursor.frame = CGRectMake(self.mainFrame.origin.x + self.mainFrame.size.width, self.mainFrame.origin.y, CURSOR_W, self.mainFrame.size.height);
    cb.view.inpOrg = CGPointMake(self.mainFrame.origin.x + self.mainFrame.size.width, self.frame.origin.y + self.frame.size.height / 2.0 - cb.curFontH / 2.0);
}

-(EquationTextLayer *) lookForEmptyTxtLyr {
    if (self.expo == nil) {
        return nil;
    } else {
        return [self.expo lookForEmptyTxtLyr];
    }
}

-(void) destroy {
    if (self.expo != nil) {
        [self.expo destroy];
    }
    [self removeFromSuperlayer];
}
@end
