//
//  EquationTextLayer.m
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
#import <ChameleonFramework/Chameleon.h>

@implementation EquationTextLayer
@synthesize parent;
@synthesize ancestor;
@synthesize guid;
@synthesize c_idx;
@synthesize roll;
@synthesize expo;
@synthesize mainFrame;
@synthesize type;
@synthesize strLenTbl;
@synthesize fontLvl;
@synthesize isCopy;
@synthesize timeStamp;
@synthesize pureStr;

-(id) init : (NSString *)str : (Equation *)e : (int)t {
    self = [super init];
    if (self) {
        CalcBoard *calcB = e.par;
        self.ancestor = e;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = e.guid_cnt++;
        self.roll = calcB.curRoll;
        self.type = t;
        self.name = str;
        self.strLenTbl = [NSMutableArray array];
        [self.strLenTbl addObject:@0.0];
        self.fontLvl = calcB.curFontLvl;
        self.isCopy = NO;
        self.timeStamp = [NSDate date];
        self.pureStr = [NSMutableString stringWithString:str];
        self.hasFraction = NO;
        
        NSMutableAttributedString *attStr;
        CGSize newStrSize = CGSizeMake(0.0, 0.0);
        if (t == TEXTLAYER_NUM) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            [attStr addAttribute:NSForegroundColorAttributeName value:gDspFontColor range:NSMakeRange(0,str.length)];
            CFRelease(ctFont);
            newStrSize = [attStr size];
            [self.strLenTbl addObject:@(newStrSize.width)];
            if ([str isEqual:@"."]) {
                self.hasFraction = YES;
            }
            
        } else if (t == TEXTLAYER_OP) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            [attStr addAttribute:NSForegroundColorAttributeName value:gDspFontColor range:NSMakeRange(0,str.length)];
            CFRelease(ctFont);
            newStrSize = [attStr size];
            [self.strLenTbl addObject:@(newStrSize.width)];
        } else if (t == TEXTLAYER_EMPTY) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            CFRelease(ctFont);
            [attStr addAttribute:NSForegroundColorAttributeName value:gDspFontColor range:NSMakeRange(0,str.length)];
            newStrSize = [attStr size];
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        self.frame = CGRectMake(0.0, 0.0, newStrSize.width, newStrSize.height);
        self.mainFrame = self.frame;
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.string = attStr;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.roll = [coder decodeIntForKey:@"roll"];
        self.guid = [coder decodeIntForKey:@"guid"];
        self.expo = [coder decodeObjectForKey:@"expo"];
        self.mainFrame = [coder decodeCGRectForKey:@"mainFrame"];
        self.type = [coder decodeIntForKey:@"type"];
        self.strLenTbl = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"strLenTbl"]];
        self.fontLvl = [coder decodeIntForKey:@"fontLvl"];
        self.isCopy = NO;
        self.timeStamp = [coder decodeObjectForKey:@"timeStamp"];
        self.pureStr = [coder decodeObjectForKey:@"pureStr"];
        self.hasFraction = [coder decodeBoolForKey:@"hasFraction"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInt:self.roll forKey:@"roll"];
    [coder encodeInt:self.guid forKey:@"guid"];
    if (self.expo != nil) {
        [coder encodeObject:self.expo forKey:@"expo"];
    }
    [coder encodeCGRect:self.mainFrame forKey:@"mainFrame"];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeObject:[NSArray arrayWithArray:self.strLenTbl] forKey:@"strLenTbl"];
    [coder encodeInt:self.fontLvl forKey:@"fontLvl"];
    [coder encodeObject:self.timeStamp forKey:@"timeStamp"];
    if (self.pureStr != nil) {
        [coder encodeObject:self.pureStr forKey:@"pureStr"];
    }
    [coder encodeBool:self.hasFraction forKey:@"hasFraction"];
}

- (id)copyWithZone:(NSZone *)zone {
    EquationTextLayer *copy = [[[self class] allocWithZone :zone] init];
    copy.c_idx = self.c_idx;
    copy.roll = self.roll;
    if (self.expo != nil) {
        copy.expo = [self.expo copy];
    }
    copy.mainFrame = self.mainFrame;
    copy.type = self.type;
    copy.strLenTbl = [self.strLenTbl mutableCopy];
    copy.fontLvl = self.fontLvl;
    
    copy.contentsScale = [UIScreen mainScreen].scale;
    copy.frame = self.frame;
    copy.backgroundColor = [UIColor clearColor].CGColor;
    copy.name = [self.name copy];
    copy.string = [self.string copy];
    copy.isCopy = YES;
    copy.timeStamp = [NSDate date];
    if (self.pureStr != nil) {
        copy.pureStr = [self.pureStr copy];
    }
    copy.hasFraction = self.hasFraction;
    return copy;
}

-(NSMutableString *) addNumFormat {
    NSMutableString *ret = [NSMutableString stringWithString:self.pureStr];
    
    if (!gSettingThousandSeperator) {
        return ret;
    }
    
    int i = ret.length - 1;
    if (self.hasFraction) {
        while (i >= 0) {
            if ([ret characterAtIndex:i] == '.') {
                break;
            }
            i--;
        }
        
        i--;
    }
    
    int j = 1;
    while (i > 0) {
        if (j == 3) {
            j = 0;
            [ret insertString:@"," atIndex:i];
        }
        
        j++;
        i--;
    }
    
    return ret;
}

-(CGFloat) addNumStr:(NSString *)str {
    CalcBoard *calcB = self.ancestor.par;
    
    if ([str isEqual:@"."]) {
        if (self.hasFraction) {
            [self shake];
            return [self.strLenTbl.lastObject doubleValue];
        } else {
            self.hasFraction = YES;
        }
    }
    
    if (self.type == TEXTLAYER_NUM) {
        [self.pureStr appendString:str];
    } else if (self.type == TEXTLAYER_EMPTY) {
        self.type = TEXTLAYER_NUM;
        self.pureStr = [NSMutableString stringWithString:str];
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return 0.0;
    }
    
    NSString *formatedStr = [self addNumFormat];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: formatedStr];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, formatedStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:gDspFontColor range:NSMakeRange(0,formatedStr.length)];
    CFRelease(ctFont);
    
    CGSize strSize = [attStr size];
    CGRect f = self.frame;
    f.size.width = strSize.width;
    f.size.height = strSize.height;
    self.frame = f;
    
    self.string = attStr;
    [self updateFrameBaseOnBase];
    
    [self updateStrLenTbl];
    
    return [self.strLenTbl.lastObject doubleValue];
}

-(CGFloat) insertNumChar:(NSString *)str at:(int)idx {
    if (self.strLenTbl.count == 1) { // For empty
        return 0.0;
    }
    
    if ([str isEqual:@"."]) {
        if (self.hasFraction) {
            [self shake];
            return [[self.strLenTbl objectAtIndex:idx] doubleValue];
        } else {
            self.hasFraction = YES;
        }
    }
    
    CalcBoard *calcB = self.ancestor.par;
    
    [self.pureStr insertString:str atIndex:idx];
    
    NSString *formatedStr = [self addNumFormat];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: formatedStr];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, formatedStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:gDspFontColor range:NSMakeRange(0,formatedStr.length)];
    CFRelease(ctFont);
    
    CGSize strSize = [attStr size];
    CGRect f = self.frame;
    f.size.width = strSize.width;
    f.size.height = strSize.height;
    self.frame = f;
    
    self.string = attStr;
    [self updateFrameBaseOnBase];
    
    [self updateStrLenTbl];
    
    return [[self.strLenTbl objectAtIndex:idx + str.length] doubleValue];
}

-(CGFloat) delNumCharAt:(int)idx {
    if (self.strLenTbl.count - 1 <= 1) {
        return 0.0;
    }
    
    [self.pureStr deleteCharactersInRange:NSMakeRange(idx - 1, 1)];
    
    NSString *formatedStr = [self addNumFormat];
    
    CalcBoard *calcB = self.ancestor.par;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: formatedStr];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, formatedStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:gDspFontColor range:NSMakeRange(0,formatedStr.length)];
    CFRelease(ctFont);
    
    CGSize strSize = [attStr size];
    CGRect f = self.frame;
    f.size.width = strSize.width;
    f.size.height = strSize.height;
    self.frame = f;
    
    self.string = attStr;
    [self updateFrameBaseOnBase];

    [self updateStrLenTbl];
    
    return [[self.strLenTbl objectAtIndex:idx - 1] doubleValue];
}

-(void) updateStrLenTbl {
    if (self.type == TEXTLAYER_EMPTY) {
        return;
    }
    
    NSString *str = [self.string string];
    
    [self.strLenTbl removeAllObjects];
    self.strLenTbl = [NSMutableArray array];
    [self.strLenTbl addObject:@0.0];
    int j = 0;
    for (int i = 0; i < str.length; i++) {
        NSString *subStr = [str substringWithRange:NSMakeRange(i, 1)];
        if ([subStr isEqual:@","]) {
            continue;
        }
        
        CGFloat charW = getCharWidth(gSettingMainFontLevel, fontLvl, subStr);
        if (i + 1 < str.length) {
            subStr = [str substringWithRange:NSMakeRange(i + 1, 1)];
            if ([subStr isEqual:@","]) {
                charW += getCharWidth(gSettingMainFontLevel, fontLvl, subStr);
            }
        }
        
        NSNumber *len = [self.strLenTbl objectAtIndex:j++];
        CGFloat orgLen = [len doubleValue];
        len = @(orgLen + charW);
        [self.strLenTbl addObject:len];
    }
}

-(int) getTxtInsIdx: (CGPoint) p {
    NSMutableArray *arr = self.strLenTbl;
    
    CGFloat target = p.x - self.frame.origin.x;
    int mid, left = 0, right = (int)arr.count - 1;
    
    while(left <= right) {
        mid = (left + right) / 2;
        CGFloat v = [[arr objectAtIndex:mid] doubleValue];
        if(v == target)
            return mid;
        if(v > target)
            right = mid - 1;
        else
            left = mid + 1;
    }
    
    if (left == arr.count) {
        return right;
    } else if(right < 0) {
        return left;
    } else {
        CGFloat leftV = [[arr objectAtIndex:right] doubleValue];
        CGFloat rightV = [[arr objectAtIndex:left] doubleValue];
        if (fabs(leftV - target) < fabs(target - rightV)) {
            return right;
        } else {
            return left;
        }
    }
}

-(void) updateFrameBaseOnBase {
    if (self.expo != nil) {
        CGRect frame = self.expo.mainFrame;
        frame.origin.y = (self.frame.origin.y + self.frame.size.height * 0.45) - frame.size.height;
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
    f.origin.y = self.expo.mainFrame.origin.y + self.expo.mainFrame.size.height - f.size.height * 0.45;
    self.mainFrame = CGRectUnion(f, self.expo.mainFrame);
}

-(BOOL) isExpoEmpty {
    if (self.expo == nil) {
        return YES;
    }
    
    if ([self.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]] && self.expo.children.count == 1) {
        EquationTextLayer *l = self.expo.children.firstObject;
        if (l.type == TEXTLAYER_EMPTY) {
            return YES;
        }
    }
    
    return NO;
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
}

- (void)updateSize:(int)lvl {
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[self.string string]];
    UIFont *font = getFont(gSettingMainFontLevel, lvl);
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, attStr.length)];
    
    CFRelease(ctFont);
    
    if (self.type == TEXTLAYER_EMPTY) {
        [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor flatBlueColor] range:NSMakeRange(0, attStr.length)];
    } else {
        [attStr addAttribute:NSForegroundColorAttributeName value:gDspFontColor range:NSMakeRange(0, attStr.length)];
    }
    
    self.string = attStr;
    
    CGRect f = self.frame;
    f.size = [attStr size];
    self.frame = f;
    
    if (self.expo != nil) {
        [self.expo updateSize:lvl + 1];
        [self updateFrameBaseOnBase];
    } else {
        self.mainFrame = self.frame;
    }
    
    self.fontLvl = lvl;
    
    [self updateStrLenTbl];
}

-(void) moveFrom:(CGPoint)orgF :(CGPoint)desF {
    if (self.expo == nil) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.75;
        animation.delegate = self;
        animation.fromValue = [NSValue valueWithCGPoint:orgF];
        animation.toValue = [NSValue valueWithCGPoint:desF];
        [animation setTimingFunction:easeOutBack];
        [self addAnimation:animation forKey:nil];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.position = desF;
        [CATransaction commit];
        
        self.mainFrame = self.frame;
        NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGPoint(self.position));
    } else {
        CGPoint baseOrg, expoOrg, baseDes, expoDes;
        baseOrg.x = orgF.x - self.mainFrame.size.width / 2.0 + self.frame.size.width / 2.0;
        baseOrg.y = orgF.y + self.mainFrame.size.height / 2.0 - self.frame.size.height / 2.0;
        expoOrg.x = orgF.x + self.mainFrame.size.width / 2.0 - self.expo.mainFrame.size.width / 2.0;
        expoOrg.y = orgF.y - self.mainFrame.size.height / 2.0 + self.expo.mainFrame.size.height / 2.0;
        baseDes.x = desF.x - self.mainFrame.size.width / 2.0 + self.frame.size.width / 2.0;
        baseDes.y = desF.y + self.mainFrame.size.height / 2.0 - self.frame.size.height / 2.0;
        expoDes.x = desF.x + self.mainFrame.size.width / 2.0 - self.expo.mainFrame.size.width / 2.0;
        expoDes.y = desF.y - self.mainFrame.size.height / 2.0 + self.expo.mainFrame.size.height / 2.0;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.75;
        animation.delegate = self;
        animation.fromValue = [NSValue valueWithCGPoint:baseOrg];
        animation.toValue = [NSValue valueWithCGPoint:baseDes];
        [animation setTimingFunction:easeOutBack];
        [self addAnimation:animation forKey:nil];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.position = baseDes;
        [CATransaction commit];
        
        // TODO: [self.expo moveFrom:]
    }
    
}

-(void) moveCopy:(CGPoint)dest {
    self.isCopy = NO;
    self.mainFrame = CGRectMake(dest.x - self.frame.size.width / 2.0, dest.y + self.frame.size.height / 2.0 - self.mainFrame.size.height, self.mainFrame.size.width, self.mainFrame.size.height);
    
    NSLog(@"%s%i>~%@~%@~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGPoint(self.position), NSStringFromCGPoint(dest));
    
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

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([self animationForKey:@"remove"] == anim) {
        [self removeFromSuperlayer];
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
    [calcB.view.layer addSublayer:self];
    if (self.expo != nil) {
        [self.expo reorganize:anc :vc :0 :self];
    }
}

-(void) updateCalcBoardInfo {
    CalcBoard *cb = self.ancestor.par;
    if (self.type == TEXTLAYER_EMPTY) {
        cb.insertCIdx = self.c_idx + 1;
        cb.curTxtLyr = self;
        cb.txtInsIdx = 0;
        cb.curBlk = self;
        cb.curRoll = self.roll;
        cb.curParent = self.parent;
        [cb updateFontInfo:self.fontLvl :gSettingMainFontLevel];
        
        if ([self.parent isMemberOfClass:[EquationBlock class]]) {
            if (self.c_idx == ((EquationBlock *)self.parent).children.count - 1) {
                cb.curMode = MODE_INPUT;
            } else {
                cb.curMode = MODE_INSERT;
            }
            if (self.expo != nil) {
                cb.allowInputBitMap = INPUT_NUM_BIT | INPUT_DOT_BIT;
            } else {
                cb.allowInputBitMap = INPUT_ALL_BIT;
            }
            
        } else if ([self.parent isMemberOfClass:[RadicalBlock class]]) {
            cb.curMode = MODE_INPUT;
            cb.allowInputBitMap = INPUT_NUM_BIT;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        cb.view.cursor.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CURSOR_W, cb.curFontH);
    } else {
        cb.insertCIdx = self.c_idx + 1;
        if (self.expo == nil) {
            cb.curTxtLyr = self;
            cb.txtInsIdx = (int)self.strLenTbl.count - 1; // num & empty
        } else {
            cb.curTxtLyr = nil;
            cb.txtInsIdx = 1;
        }
        cb.curBlk = self;
        cb.curRoll = self.roll;
        cb.curParent = self.parent;
        [cb updateFontInfo:self.fontLvl :gSettingMainFontLevel];
        
        if ([self.parent isMemberOfClass:[EquationBlock class]]) {
            if (self.c_idx == ((EquationBlock *)self.parent).children.count - 1) {
                cb.curMode = MODE_INPUT;
            } else {
                cb.curMode = MODE_INSERT;
            }
            cb.allowInputBitMap = INPUT_ALL_BIT;
        } else if ([self.parent isMemberOfClass:[RadicalBlock class]]) {
            cb.curMode = MODE_INPUT;
            cb.allowInputBitMap = INPUT_NUM_BIT;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        cb.view.cursor.frame = CGRectMake(self.mainFrame.origin.x + self.mainFrame.size.width, self.mainFrame.origin.y, CURSOR_W, self.mainFrame.size.height);
    }
    
}

-(EquationTextLayer *) lookForEmptyTxtLyr {
    if (self.type == TEXTLAYER_EMPTY) {
        return self;
    }
    
    if (self.expo != nil) {
        return [self.expo lookForEmptyTxtLyr];
    }
    
    return nil;
}

-(void) shake {
    if (self.expo != nil) {
        [self.expo shake];
    }
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    shakeAnimation.values = @[[NSValue valueWithCGPoint:self.position], [NSValue valueWithCGPoint:CGPointMake(self.position.x + 7.0, self.position.y)], [NSValue valueWithCGPoint:CGPointMake(self.position.x - 7.0, self.position.y)], [NSValue valueWithCGPoint:CGPointMake(self.position.x + 7.0, self.position.y)], [NSValue valueWithCGPoint:self.position]];
    [shakeAnimation setTimingFunction:easeOutSine];
    shakeAnimation.duration = 0.5;
    shakeAnimation.removedOnCompletion = YES;
    [self addAnimation:shakeAnimation forKey:nil];
}

-(CGFloat) replaceWithEmpty {
    CalcBoard *calcB = self.ancestor.par;
    CGFloat orgWidth = self.mainFrame.size.width;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: @"_"];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
    CFRelease(ctFont);
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor flatBlueColor] range:NSMakeRange(0, 1)];
    
    self.string = attStr;
    
    CGRect frame = self.frame;
    frame.size.width = [attStr size].width;
    self.frame = frame;
    
    [self updateFrameBaseOnBase];
    
    self.type = TEXTLAYER_EMPTY;
    [self.strLenTbl removeAllObjects];
    [self.strLenTbl addObject:@0.0];
    
    return self.mainFrame.size.width - orgWidth;
}

-(BOOL) isAllowed {
    if (self.expo != nil && !TEST_BIT(gCurCB.allowInputBitMap, INPUT_EXPO_BIT)) {
        return NO;
    }
    
    if (self.type == TEXTLAYER_NUM) {
        if (!TEST_BIT(gCurCB.allowInputBitMap, INPUT_NUM_BIT)) {
            return NO;
        }
    } else if (self.type == TEXTLAYER_OP) {
        if (!TEST_BIT(gCurCB.allowInputBitMap, INPUT_OP_BIT)) {
            return NO;
        }
    } else if (self.type == TEXTLAYER_EMPTY) {
        if (!TEST_BIT(gCurCB.allowInputBitMap, INPUT_EMPTY_BIT)) {
            return NO;
        }
    } else {
        return NO;
    }
    
    return YES;
}

-(void) handlDelete {
    Equation *equation = self.ancestor;
    CalcBoard *calcBoard = equation.par;

    if (calcBoard.insertCIdx == self.c_idx) {
        if (self.type == TEXTLAYER_EMPTY) { // If expo != empty, then get previous block, otherwise remove self
            if ([self isExpoEmpty]) {
                [equation removeElement:self];
            } else {
                id pre = getPrevBlk(self);
                if (pre == nil) {
                    return;
                }
                (void)locaLastLyr(equation, pre);
            }
            return;
        }

        if (self.roll == ROLL_ROOT_NUM) { // Root number, get parent's(Radical block) previous block
            id pre = getPrevBlk(self.parent);
            if (pre == nil) {
                return;
            }
            
            (void)locaLastLyr(equation, pre);
            return;
        }

        id pre = getPrevBlk(self);
        if (pre == nil) {
            return;
        }

        EquationBlock *par = self.parent; // Parent can only be EB as self is not ROLL_ROOT_NUM

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
                return;
            } else if ([pre isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = pre;
                calcBoard.insertCIdx = p.c_idx + 1;
                [p handleDelete];
                return;
            } else {
                (void)locaLastLyr(equation, pre);
                return;
            }
        }
    } else if (calcBoard.insertCIdx == self.c_idx + 1) {
        if (self.expo != nil && calcBoard.curTxtLyr == nil) { // Expo != nil, Not at base
            (void)locaLastLyr(equation, self);
            return;
        } else if (self.expo != nil && calcBoard.curTxtLyr != nil) { // Expo != nil, At base
            if (self.strLenTbl.count == 2 && calcBoard.txtInsIdx == 1) { // Number 1 char, replace base and keep expo
                CGFloat incrWidth = [self replaceWithEmpty];
                [par updateFrameWidth:incrWidth :self.roll];
                [equation.root adjustElementPosition];
                calcBoard.view.cursor.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CURSOR_W, calcBoard.curFontH);
                calcBoard.txtInsIdx = 0;
                return;
            } else { // Number > 1 char
                CGFloat orgW = self.mainFrame.size.width;
                CGFloat offset = [self delNumCharAt:calcBoard.txtInsIdx--];
                CGFloat incrWidth = self.mainFrame.size.width - orgW;
                [(EquationBlock *)calcBoard.curParent updateFrameWidth:incrWidth :calcBoard.curRoll];
                [calcBoard.curEq.root adjustElementPosition];
                calcBoard.view.cursor.frame = CGRectMake(self.frame.origin.x + offset, self.frame.origin.y, CURSOR_W, calcBoard.curFontH);
                if (calcBoard.txtInsIdx == 0) {
                    calcBoard.insertCIdx = self.c_idx;
                }
                return;
            }
        } else { // Expo == nil
            if (self.strLenTbl.count == 2 || self.strLenTbl.count == 1) { // 1 char num/op, normally count should not == 1
                [equation removeElement:self];
                return;
            } else { // Number > 1 char
                CGFloat orgW = self.mainFrame.size.width;
                CGFloat offset = [self delNumCharAt:calcBoard.txtInsIdx--];
                CGFloat incrWidth = self.mainFrame.size.width - orgW;
                [self.parent updateFrameWidth:incrWidth :self.roll];
                [equation.root adjustElementPosition];
                calcBoard.view.cursor.frame = CGRectMake(self.frame.origin.x + offset, self.frame.origin.y, CURSOR_W, calcBoard.curFontH);
                if (calcBoard.txtInsIdx == 0) {
                    calcBoard.insertCIdx = self.c_idx;
                }
                return;
            }
        }
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    }
}

-(void) destroyWithAnim {
    if (self.expo != nil) {
        [self.expo destroyWithAnim];
    }
    [self.strLenTbl removeAllObjects];
    self.strLenTbl = nil;
    
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
    if (self.expo != nil) {
        [self.expo destroy];
    }
    [self.strLenTbl removeAllObjects];
    self.strLenTbl = nil;
    
    [self removeFromSuperlayer];
}
@end
