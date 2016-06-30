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
#import "Parentheses.h"
#import "CalcBoard.h"
#import "UIView+Easing.h"
#import "Utils.h"

@implementation WrapedEqTxtLyr
@synthesize guid;
@synthesize c_idx;
@synthesize parent;
@synthesize ancestor;
@synthesize mainFrame;
@synthesize roll;
@synthesize title;
@synthesize content;
@synthesize left_parenth;
@synthesize right_parenth;
@synthesize fontLvl;
@synthesize isCopy;
@synthesize timeStamp;

-(id) init :(NSString *)pfx :(Equation *)E :(ViewController *)vc {
    self = [super init];
    if (self) {
        CalcBoard *calcB = E.par;
        self.ancestor = E;
        self.guid = E.guid_cnt++;
        self.roll = calcB.curRoll;
        self.fontLvl = calcB.curFontLvl;
        self.isCopy = NO;
        self.timeStamp = [NSDate date];
        
        CGPoint org = CGPointZero;
        CGFloat w = 0.0;
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: pfx];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, pfx.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:gDspFontColor range:NSMakeRange(0, pfx.length)];
        CFRelease(ctFont);
        if ([[pfx substringToIndex:pfx.length > 3 ? 3 : pfx.length] isEqual:@"log"]) {
            UIFont *subFont = getFont(gSettingMainFontLevel, calcB.curFontLvl + 1);
            CTFontRef ctFont1 = CTFontCreateWithName((CFStringRef)subFont.fontName, subFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont1 range:NSMakeRange(3, pfx.length - 3)];
            CFRelease(ctFont1);
        }
        
        CGSize strSize = [attStr size];
        
        self.title = [[CATextLayer alloc] init];
        self.title.contentsScale = [UIScreen mainScreen].scale;
        self.title.backgroundColor = [UIColor clearColor].CGColor;
        self.title.frame = CGRectMake(org.x, org.y, strSize.width, strSize.height);
        self.title.string = attStr;
        [calcB.view.layer addSublayer:self.title];
        
        org.x += strSize.width;
        w += strSize.width;
        
        self.left_parenth = [[Parentheses alloc] init:E :LEFT_PARENTH :vc];
        self.left_parenth.parent = self;
        [calcB.view.layer addSublayer:self.left_parenth];
        [self.left_parenth setNeedsDisplay];
        
        org.x += self.left_parenth.frame.size.width;
        w += self.left_parenth.frame.size.width;
        
        self.content = [[EquationBlock alloc] init:E];
        self.content.roll = ROLL_WRAP_ROOT;
        self.content.parent = self;
        NSLog(@"%s%i>~%.1f~%.1f~~~~~~~~~", __FUNCTION__, __LINE__, org.x, org.y);
        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :E :TEXTLAYER_EMPTY];
        layer.roll = ROLL_NUMERATOR;
        layer.parent = self.content;
        self.content.numerFrame = layer.frame;
        self.content.mainFrame = layer.frame;
        
        layer.c_idx = 0;
        [self.content.children addObject:layer];
        [calcB.view.layer addSublayer:layer];
        calcB.curTxtLyr = layer;
        calcB.curBlk = layer;
        
        self.parent = calcB.curParent;
        
        org.x += layer.mainFrame.size.width;
        w += layer.mainFrame.size.width;
        
        self.right_parenth = [[Parentheses alloc] init:E :RIGHT_PARENTH :vc];
        self.right_parenth.parent = self;
        [calcB.view.layer addSublayer:self.right_parenth];
        [self.right_parenth setNeedsDisplay];
        
        w += self.right_parenth.frame.size.width;
        
        self.mainFrame = CGRectMake(0.0, 0.0, w, self.content.mainFrame.size.height);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.roll = [coder decodeIntForKey:@"roll"];
        self.guid = [coder decodeIntForKey:@"guid"];
        self.mainFrame = [coder decodeCGRectForKey:@"mainFrame"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.content = [coder decodeObjectForKey:@"content"];
        self.left_parenth = [coder decodeObjectForKey:@"left_parenth"];
        self.right_parenth = [coder decodeObjectForKey:@"right_parenth"];
        self.fontLvl = [coder decodeIntForKey:@"fontLvl"];
        self.isCopy = NO;
        self.timeStamp = [coder decodeObjectForKey:@"timeStamp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.roll forKey:@"roll"];
    [coder encodeInt:self.guid forKey:@"guid"];
    [coder encodeCGRect:self.mainFrame forKey:@"mainFrame"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeObject:self.left_parenth forKey:@"left_parenth"];
    [coder encodeObject:self.right_parenth forKey:@"right_parenth"];
    [coder encodeInt:self.fontLvl forKey:@"fontLvl"];
    [coder encodeObject:self.timeStamp forKey:@"timeStamp"];
}

- (id)copyWithZone:(NSZone *)zone {
    WrapedEqTxtLyr *copy = [[[self class] allocWithZone :zone] init];
    copy.c_idx = self.c_idx;
    copy.roll = self.roll;
    
    copy.title = [[CATextLayer alloc] init];
    copy.title.contentsScale = [UIScreen mainScreen].scale;
    copy.title.backgroundColor = [UIColor clearColor].CGColor;
    copy.title.frame = self.title.frame;
    copy.title.string = [self.title.string copy];
    
    copy.content = [self.content copy];
    copy.left_parenth = [self.left_parenth copy];
    copy.right_parenth = [self.right_parenth copy];
    copy.mainFrame = self.mainFrame;
    copy.fontLvl = self.fontLvl;
    copy.isCopy = YES;
    copy.timeStamp = [NSDate date];
    return copy;
}

-(void) updateFrame:(BOOL)updateParenth {
    if (updateParenth) {
        self.left_parenth.frame = CGRectMake(self.left_parenth.frame.origin.x, self.left_parenth.frame.origin.y, self.content.mainFrame.size.height / PARENTH_HW_R, self.content.mainFrame.size.height);
        [self.left_parenth setNeedsDisplay];
        self.right_parenth.frame = CGRectMake(self.right_parenth.frame.origin.x, self.right_parenth.frame.origin.y, self.content.mainFrame.size.height / PARENTH_HW_R, self.content.mainFrame.size.height);
        [self.right_parenth setNeedsDisplay];
    }
    
    CGFloat newW = self.title.frame.size.width + self.left_parenth.frame.size.width + self.content.mainFrame.size.width + self.right_parenth.frame.size.width;
    CGFloat newH = self.content.mainFrame.size.height;
    self.mainFrame = CGRectMake(self.mainFrame.origin.x, self.mainFrame.origin.y, newW, newH);
}

- (void)updateCopyBlock:(Equation *)e {
    ancestor = e;
    guid = e.guid_cnt++;
    content.parent = self;
    
    CalcBoard *calcB = e.par;
    [calcB.view.layer addSublayer:self.title];
    
    [content updateCopyBlock:e];
    left_parenth.parent = self;
    [left_parenth updateCopyBlock:e];
    right_parenth.parent = self;
    [right_parenth updateCopyBlock:e];
}

- (void)updateSize:(int)lvl {
    
    UIFont *font = getFont(gSettingMainFontLevel, lvl);
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[self.title.string string]];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:gDspFontColor range:NSMakeRange(0, attStr.length)];
    CFRelease(ctFont);
    
    CGRect f = self.title.frame;
    f.size = [attStr size];
    self.title.frame = f;
    
    self.title.string = attStr;
    
    [self.content updateSize:lvl];
    
    [self updateFrame:YES];
    
    self.fontLvl = lvl;
}

-(void) moveCopy:(CGPoint)dest {
    NSLog(@"%s%i>~%@~%@~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGPoint(CGPointMake(self.mainFrame.origin.x + self.mainFrame.size.width / 2.0, self.mainFrame.origin.y + self.mainFrame.size.height / 2.0)), NSStringFromCGPoint(dest));
    self.isCopy = NO;
    self.mainFrame = CGRectMake(dest.x - self.mainFrame.size.width / 2.0, dest.y - self.mainFrame.size.height / 2.0, self.mainFrame.size.width, self.mainFrame.size.height);
    
    CGFloat curX = dest.x - self.mainFrame.size.width / 2.0;
    
    CGPoint tDest = CGPointMake(curX + self.title.frame.size.width / 2.0, dest.y);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.5;
    animation.delegate = self;
    animation.fromValue = [NSValue valueWithCGPoint:self.title.position];
    animation.toValue = [NSValue valueWithCGPoint:tDest];
    [animation setTimingFunction:easeOutBack];
    [self.title addAnimation:animation forKey:nil];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.title.position = tDest;
    [CATransaction commit];
    curX += self.title.frame.size.width;
    
    CGPoint lpDest = CGPointMake(curX + self.left_parenth.frame.size.width / 2.0, dest.y);
    [self.left_parenth moveCopy:lpDest];
    curX += self.left_parenth.frame.size.width;
    
    CGPoint contDest = CGPointMake(curX + self.content.mainFrame.size.width / 2.0, dest.y);
    [self.content moveCopy:contDest];
    curX += self.content.mainFrame.size.width;
    
    CGPoint rpDest = CGPointMake(curX + self.left_parenth.frame.size.width / 2.0, dest.y);
    [self.right_parenth moveCopy:rpDest];
    curX += self.right_parenth.frame.size.width;
}

-(void) updateFrameWidth : (CGFloat)incrWidth : (int)r {
    CGFloat orgWidth1 = self.mainFrame.size.width;
    CGFloat newMW = self.title.frame.size.width + self.left_parenth.frame.size.width + self.content.mainFrame.size.width + self.right_parenth.frame.size.width;
    self.mainFrame = CGRectMake(self.mainFrame.origin.x, self.mainFrame.origin.y, newMW, self.mainFrame.size.height);
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
    [calcB.view.layer addSublayer: self.title];
    [calcB.view.layer addSublayer: self.left_parenth];
    self.left_parenth.delegate = vc;
    [self.left_parenth setNeedsDisplay];
    [calcB.view.layer addSublayer: self.right_parenth];
    self.right_parenth.delegate = vc;
    [self.right_parenth setNeedsDisplay];
    
    [self.content reorganize:anc :vc :0 :self];
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
    cb.allowInputBitMap = INPUT_ALL_BIT;
    [cb updateFontInfo:self.fontLvl :gSettingMainFontLevel];
    if (self.c_idx == ((EquationBlock *)self.parent).children.count - 1) {
        cb.curMode = MODE_INPUT;
    } else {
        cb.curMode = MODE_INSERT;
    }
    cb.view.cursor.frame = CGRectMake(self.mainFrame.origin.x + self.mainFrame.size.width, self.mainFrame.origin.y, CURSOR_W, self.mainFrame.size.height);
}

-(EquationTextLayer *) lookForEmptyTxtLyr {
    return [self.content lookForEmptyTxtLyr];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([self.title animationForKey:@"remove"] == anim) {
        [self.title removeFromSuperlayer];
    }
}

-(void) shake {
    CAKeyframeAnimation *titleAni = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    titleAni.values = @[[NSValue valueWithCGPoint:self.title.position], [NSValue valueWithCGPoint:CGPointMake(self.title.position.x + 7.0, self.title.position.y)], [NSValue valueWithCGPoint:CGPointMake(self.title.position.x - 7.0, self.title.position.y)], [NSValue valueWithCGPoint:CGPointMake(self.title.position.x + 7.0, self.title.position.y)], [NSValue valueWithCGPoint:self.title.position]];
    [titleAni setTimingFunction:easeOutSine];
    titleAni.duration = 0.5;
    titleAni.removedOnCompletion = YES;
    [self.title addAnimation:titleAni forKey:nil];
    
    CAKeyframeAnimation *leftPAni = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    leftPAni.values = @[[NSValue valueWithCGPoint:self.left_parenth.position], [NSValue valueWithCGPoint:CGPointMake(self.left_parenth.position.x + 7.0, self.left_parenth.position.y)], [NSValue valueWithCGPoint:CGPointMake(self.left_parenth.position.x - 7.0, self.left_parenth.position.y)], [NSValue valueWithCGPoint:CGPointMake(self.left_parenth.position.x + 7.0, self.left_parenth.position.y)], [NSValue valueWithCGPoint:self.left_parenth.position]];
    [leftPAni setTimingFunction:easeOutSine];
    leftPAni.duration = 0.5;
    leftPAni.removedOnCompletion = YES;
    [self.left_parenth addAnimation:leftPAni forKey:nil];
    
    CAKeyframeAnimation *rightPAni = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    rightPAni.values = @[[NSValue valueWithCGPoint:self.right_parenth.position], [NSValue valueWithCGPoint:CGPointMake(self.right_parenth.position.x + 7.0, self.right_parenth.position.y)], [NSValue valueWithCGPoint:CGPointMake(self.right_parenth.position.x - 7.0, self.right_parenth.position.y)], [NSValue valueWithCGPoint:CGPointMake(self.right_parenth.position.x + 7.0, self.right_parenth.position.y)], [NSValue valueWithCGPoint:self.right_parenth.position]];
    [rightPAni setTimingFunction:easeOutSine];
    rightPAni.duration = 0.5;
    rightPAni.removedOnCompletion = YES;
    [self.right_parenth addAnimation:rightPAni forKey:nil];
    
    [self.content shake];
}

-(BOOL) isAllowed {
    if (!TEST_BIT(gCurCB.allowInputBitMap, INPUT_WETL_BIT)) {
        return NO;
    }
    
    return YES;
}

-(void) handleDelete {
    Equation *equation = self.ancestor;
    CalcBoard *calcBoard = equation.par;

    if (calcBoard.insertCIdx == self.c_idx) {
        id pre = getPrevBlk(self);
        if (pre == nil) {
            return;
        }

        EquationBlock *par = self.parent; // Parent can only be EB

        if (self.c_idx == 0) { // Consider the cases that from expo switch to base
            if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *l = pre;
                if (l.fontLvl == self.fontLvl) { // pre is with the same parent
                    (void)locaLastLyr(equation, l);
                } else { //Switch from expo to base in a same text layer
                    cfgEqnBySlctBlk(equation, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                }
            } else if ([pre isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = pre;
                if (p.fontLvl == self.fontLvl) { // pre is with the same parent
                    (void)locaLastLyr(equation, p);
                } else { //Switch from expo to base in a same text layer
                    cfgEqnBySlctBlk(equation, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                }
            } else {
                (void)locaLastLyr(equation, pre);
            }
            return;
        } else if ([[par.children objectAtIndex:self.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) { // Locate last text layer in previous block, no need to delete
            (void)locaLastLyr(equation, pre);
            return;
        } else { // If previous block is text layer or parenth may need to delete character. Otherwise just locate last text layer in previous block.
            if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *l = pre;
                calcBoard.insertCIdx = l.c_idx + 1;
                [l handleDelete];
            } else if ([pre isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = pre;
                calcBoard.insertCIdx = p.c_idx + 1;
                [p handleDelete];
            } else {
                (void)locaLastLyr(equation, pre);
            }
        }
    } else if (calcBoard.insertCIdx == self.c_idx + 1) {
        (void)locaLastLyr(equation, self);
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    }
}

-(void) destroyWithAnim {
    [self.content destroyWithAnim];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0.0];
    animation.duration = 0.4;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.delegate = self;
    [self.title addAnimation:animation forKey:@"remove"];
    
    [self.left_parenth destroyWithAnim];
    [self.right_parenth destroyWithAnim];
}

-(void) destroy {
    [self.content destroy];
    
    [self.title removeFromSuperlayer];
    
    [self.left_parenth destroy];
    [self.right_parenth destroy];
}
@end
