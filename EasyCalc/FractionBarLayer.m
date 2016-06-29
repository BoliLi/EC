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
#import "UIView+Easing.h"

@implementation FractionBarLayer

@synthesize guid;
@synthesize c_idx;
@synthesize parent;
@synthesize ancestor;
@synthesize fontLvl;
@synthesize isCopy;
@synthesize timeStamp;

-(id) init :(Equation *)e :(ViewController *)vc {
    self = [super init];
    if (self) {
        CalcBoard *calcB = e.par;
        
        self.ancestor = e;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = e.guid_cnt++;
        self.delegate = vc;
        fontLvl = calcB.curFontLvl;
        self.isCopy = NO;
        self.timeStamp = [NSDate date];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.guid = [coder decodeIntForKey:@"guid"];
        self.fontLvl = [coder decodeIntForKey:@"fontLvl"];
        self.isCopy = NO;
        self.timeStamp = [coder decodeObjectForKey:@"timeStamp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.guid forKey:@"guid"];
    [coder encodeInt:self.fontLvl forKey:@"fontLvl"];
    [coder encodeObject:self.timeStamp forKey:@"timeStamp"];
}

- (id)copyWithZone:(NSZone *)zone {
    FractionBarLayer *copy = [[[self class] allocWithZone :zone] init];
    copy.c_idx = self.c_idx;
    copy.frame = self.frame;
    copy.delegate = self.delegate;
    copy.contentsScale = [UIScreen mainScreen].scale;
    copy.name = [self.name copy];
    copy.hidden = NO;
    copy.fontLvl = self.fontLvl;
    copy.isCopy = YES;
    copy.timeStamp = [NSDate date];
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

-(void) moveCopy:(CGPoint)dest {
    self.isCopy = NO;
    
    NSLog(@"%s%i>~%@~%@~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGPoint(self.position), NSStringFromCGPoint(dest));
    
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
}

-(EquationTextLayer *) lookForEmptyTxtLyr {
    return nil;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([self animationForKey:@"remove"] == anim) {
        [self removeFromSuperlayer];
    }
}

-(void) shake {
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    shakeAnimation.values = @[[NSValue valueWithCGPoint:self.position], [NSValue valueWithCGPoint:CGPointMake(self.position.x + 7.0, self.position.y)], [NSValue valueWithCGPoint:CGPointMake(self.position.x - 7.0, self.position.y)], [NSValue valueWithCGPoint:CGPointMake(self.position.x + 7.0, self.position.y)], [NSValue valueWithCGPoint:self.position]];
    [shakeAnimation setTimingFunction:easeOutSine];
    shakeAnimation.duration = 0.5;
    shakeAnimation.removedOnCompletion = YES;
    [self addAnimation:shakeAnimation forKey:nil];
}

-(BOOL) isAllowed {
    return NO;
}

-(void) destroyWithAnim {
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

-(void) destroy {
    [self removeFromSuperlayer];
}

@end
