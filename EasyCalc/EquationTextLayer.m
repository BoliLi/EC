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

@implementation EquationTextLayer
@synthesize parent;
@synthesize ancestor;
@synthesize guid;
@synthesize c_idx;
@synthesize roll;
@synthesize expo;
@synthesize mainFrame;
@synthesize is_base_expo;
@synthesize type;
@synthesize strLenTbl;
@synthesize fontLvl;
@synthesize isCopy;

//-(id) init : (Equation *)e {
//    self = [super init];
//    if (self) {
//        self.ancestor = e;
//        self.contentsScale = [UIScreen mainScreen].scale;
//        self.guid = ++e.guid_cnt;
//        self.roll = calcB.curRoll;
//        self.strLenTbl = [NSMutableArray array];
//        [self.strLenTbl addObject:@0.0];
//        
//        if (calcB.curFont == calcB.baseFont) {
//            is_base_expo = IS_BASE;
//        } else {
//            is_base_expo = IS_EXPO;
//        }
//    }
//    return self;
//}

-(id) init : (NSString *)str : (CGPoint)org : (Equation *)e : (int)t {
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
        self.is_base_expo = calcB.base_or_expo;
        self.isCopy = NO;
        
        NSMutableAttributedString *attStr;
        CGSize newStrSize = CGSizeMake(0.0, 0.0);
        if (t == TEXTLAYER_NUM) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            CFRelease(ctFont);
            newStrSize = [attStr size];
            [self.strLenTbl addObject:@(newStrSize.width)];
        } else if (t == TEXTLAYER_OP) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            CFRelease(ctFont);
            newStrSize = [attStr size];
            [self.strLenTbl addObject:@(newStrSize.width)];
        } else if (t == TEXTLAYER_EMPTY) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            CFRelease(ctFont);
            [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,str.length)];
            newStrSize = [attStr size];
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        self.frame = CGRectMake(org.x, org.y, newStrSize.width, newStrSize.height);
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
        self.is_base_expo = [coder decodeIntForKey:@"is_base_expo"];
        self.type = [coder decodeIntForKey:@"type"];
        self.strLenTbl = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"strLenTbl"]];
        self.fontLvl = [coder decodeIntForKey:@"fontLvl"];
        self.isCopy = NO;
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
    [coder encodeInt:self.is_base_expo forKey:@"is_base_expo"];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeObject:[NSArray arrayWithArray:self.strLenTbl] forKey:@"strLenTbl"];
    [coder encodeInt:self.fontLvl forKey:@"fontLvl"];
}

- (id)copyWithZone:(NSZone *)zone {
    EquationTextLayer *copy = [[[self class] allocWithZone :zone] init];
    copy.c_idx = self.c_idx;
    copy.roll = self.roll;
    if (self.expo != nil) {
        copy.expo = [self.expo copy];
    }
    copy.mainFrame = self.mainFrame;
    copy.is_base_expo = self.is_base_expo;
    copy.type = self.type;
    copy.strLenTbl = [self.strLenTbl mutableCopy];
    copy.fontLvl = self.fontLvl;
    
    copy.contentsScale = [UIScreen mainScreen].scale;
    copy.frame = self.frame;
    copy.backgroundColor = [UIColor clearColor].CGColor;
    copy.name = [self.name copy];
    copy.string = [self.string copy];
    copy.isCopy = YES;
    return copy;
}

//- (id) mutableCopyWithZone:(NSZone *)zone {
//    EquationTextLayer *copy = [[[self class] allocWithZone :zone] init];
//    copy.c_idx = self.c_idx;
//    copy.roll = self.roll;
//    if (self.expo != nil) {
//        copy.expo = [self.expo copy];
//    }
//    copy.mainFrame = self.mainFrame;
//    copy.is_base_expo = self.is_base_expo;
//    copy.type = self.type;
//    copy.strLenTbl = [self.strLenTbl mutableCopy];
//    
//    copy.contentsScale = [UIScreen mainScreen].scale;
//    copy.frame = self.frame;
//    copy.backgroundColor = [UIColor clearColor].CGColor;
//    copy.name = [self.name copy];
//    copy.string = [self.string copy];
//    return copy;
//}

-(CGFloat) addNumStr:(NSString *)str {
    Equation *E = self.ancestor;
    CalcBoard *calcB = E.par;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: str];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
    CFRelease(ctFont);
    NSMutableAttributedString *orgStr;
    if (self.type == TEXTLAYER_NUM) {
        orgStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.string];
        [orgStr appendAttributedString:attStr];
    } else if (self.type == TEXTLAYER_EMPTY) {
        self.type = TEXTLAYER_NUM;
        orgStr = attStr;
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return 0.0;
    }
    
    CGSize strSize = [orgStr size];
    CGRect f = self.frame;
    f.size.width = strSize.width;
    f.size.height = strSize.height;
    self.frame = f;
    
    self.string = orgStr;
    [self updateFrameBaseOnBase];
    
    for (int i = 0; i < str.length; i++) {
        CGFloat preStrLen = [self.strLenTbl.lastObject doubleValue];
        CGFloat charW = getCharWidth(fontLvl, [str substringWithRange:NSMakeRange(i, 1)]);
        [self.strLenTbl addObject:@(preStrLen + charW)];
    }
    
    return [self.strLenTbl.lastObject doubleValue];
}

-(CGFloat) insertNumChar:(NSString *)str at:(int)idx {
    if (self.strLenTbl.count == 1) {
        return 0.0;
    }
    
    Equation *E = self.ancestor;
    CalcBoard *calcB = E.par;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: str];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
    CFRelease(ctFont);
    NSMutableAttributedString *orgStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.string];
    
    [orgStr insertAttributedString:attStr atIndex:idx];
    
    CGSize strSize = [orgStr size];
    CGRect f = self.frame;
    f.size.width = strSize.width;
    f.size.height = strSize.height;
    self.frame = f;
    
    self.string = orgStr;
    [self updateFrameBaseOnBase];
    
    CGFloat preStrLen = [[self.strLenTbl objectAtIndex:idx] doubleValue];
    CGFloat charW = getCharWidth(fontLvl, str);
    [self.strLenTbl insertObject:@(preStrLen + charW) atIndex:idx + 1];
    
    for (int i = idx + 2; i < self.strLenTbl.count; i++) {
        NSNumber *len = [self.strLenTbl objectAtIndex:i];
        CGFloat orgLen = [len doubleValue];
        len = @(orgLen + charW);
        [self.strLenTbl replaceObjectAtIndex:i withObject:len];
    }
    
    return [[self.strLenTbl objectAtIndex:idx + 1] doubleValue];
}

-(CGFloat) delNumCharAt:(int)idx {
    if (self.strLenTbl.count - 1 <= 1) {
        return 0.0;
    }
    
    NSMutableAttributedString *orgStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.string];
    CGSize strSize = [orgStr size];
    CGFloat orgW = strSize.width;
    
    [orgStr deleteCharactersInRange:NSMakeRange(idx - 1, 1)];
    
    strSize = [orgStr size];
    CGFloat charW = orgW - strSize.width;
    CGRect f = self.frame;
    f.size.width = strSize.width;
    f.size.height = strSize.height;
    self.frame = f;
    
    self.string = orgStr;
    [self updateFrameBaseOnBase];

    [self.strLenTbl removeObjectAtIndex:idx];
    
    for (int i = idx; i < self.strLenTbl.count; i++) {
        NSNumber *len = [self.strLenTbl objectAtIndex:i];
        CGFloat orgLen = [len doubleValue];
        len = @(orgLen - charW);
        [self.strLenTbl replaceObjectAtIndex:i withObject:len];
    }
    
    return [[self.strLenTbl objectAtIndex:idx - 1] doubleValue];
}

-(void) updateStrLenTbl {
    NSString *str = [self.string string];
    
    [self.strLenTbl removeAllObjects];
    self.strLenTbl = [NSMutableArray array];
    [self.strLenTbl addObject:@0.0];
    
    for (int i = 0; i < str.length; i++) {
        NSString *subStr = [str substringWithRange:NSMakeRange(i, 1)];
        CGFloat charW = getCharWidth(fontLvl, subStr);
        NSNumber *len = [self.strLenTbl objectAtIndex:i];
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
    
    return false;
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
    if (self.fontLvl == lvl) {
        return;
    }
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[self.string string]];
    UIFont *font = getFont(lvl);
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, attStr.length)];
    CFRelease(ctFont);
    
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
        animation.duration = 0.75;
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
    
    //self.opacity = 1.0;
    
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
