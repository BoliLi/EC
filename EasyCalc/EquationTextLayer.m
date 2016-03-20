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

//-(id) init : (Equation *)e {
//    self = [super init];
//    if (self) {
//        self.ancestor = e;
//        self.contentsScale = [UIScreen mainScreen].scale;
//        self.guid = ++e.guid_cnt;
//        self.roll = e.curRoll;
//        self.strLenTbl = [NSMutableArray array];
//        [self.strLenTbl addObject:@0.0];
//        
//        if (e.curFont == e.baseFont) {
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
        self.ancestor = e;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = e.guid_cnt++;
        self.roll = e.curRoll;
        self.type = t;
        self.name = str;
        self.strLenTbl = [NSMutableArray array];
        [self.strLenTbl addObject:@0.0];
        
        if (e.curFont == e.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
        
        NSMutableAttributedString *attStr;
        CGSize newStrSize = CGSizeMake(0.0, 0.0);
        if (t == TEXTLAYER_NUM) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)e.curFont.fontName, e.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            CFRelease(ctFont);
            newStrSize = [attStr size];
            [self.strLenTbl addObject:@(newStrSize.width)];
        } else if (t == TEXTLAYER_OP) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)e.curFont.fontName, e.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            CFRelease(ctFont);
            newStrSize = [attStr size];
            [self.strLenTbl addObject:@(newStrSize.width)];
        } else if (t == TEXTLAYER_EMPTY) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)e.curFont.fontName, e.curFont.pointSize, NULL);
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
}

//-(CGFloat) fillEmptyLayer:(NSString *)str oftype:(int)t {
//    Equation *E = self.ancestor;
//    
//    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: str];
//    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)E.curFont.fontName, E.curFont.pointSize, NULL);
//    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
//    CFRelease(ctFont);
//    CGSize strSize = [attStr size];
//    CGRect f = self.frame;
//    f.size.width = strSize.width;
//    f.size.height = strSize.height;
//    self.frame = f;
//    
//    self.string = attStr;
//    [self updateFrameBaseOnBase];
//    
//    [self.strLenTbl addObject:@(strSize.width)];
//    
//    self.type = t;
//    
//    return strSize.width;
//}

-(CGFloat) addNumChar:(NSString *)str {
    Equation *E = self.ancestor;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: str];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)E.curFont.fontName, E.curFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
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
    
    CGFloat preStrLen = [self.strLenTbl.lastObject doubleValue];
    CGFloat charW = getCharWidth(E.zoomInLvl, self.is_base_expo, str);
    [self.strLenTbl addObject:@(preStrLen + charW)];
    
    return [self.strLenTbl.lastObject doubleValue];
}

-(CGFloat) insertNumChar:(NSString *)str at:(int)idx {
    if (self.strLenTbl.count == 1) {
        return 0.0;
    }
    
    Equation *E = self.ancestor;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: str];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)E.curFont.fontName, E.curFont.pointSize, NULL);
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
    CGFloat charW = getCharWidth(E.zoomInLvl, self.is_base_expo, str);
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
    Equation *E = self.ancestor;
    NSString *str = [self.string string];
    CGFloat strLen = 0.0;
    
    for (int i = 1; i < self.strLenTbl.count; i++) {
        NSString *subStr = [str substringWithRange:NSMakeRange(i - 1, 1)];
        CGFloat charW = getCharWidth(E.zoomInLvl, self.is_base_expo, subStr);
        strLen += charW;
        NSNumber *len = @(strLen);
        [self.strLenTbl replaceObjectAtIndex:i withObject:len];
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
        frame.origin.y = (self.frame.origin.y + self.ancestor.baseCharHight * 0.45) - frame.size.height;
        frame.origin.x = self.frame.origin.x + self.frame.size.width;
        self.expo.mainFrame = frame;
        self.mainFrame = CGRectUnion(frame, self.frame);
    } else {
        self.mainFrame = self.frame;
    }
}

-(void) updateFrameBaseOnExpo {
    CGRect frame = self.expo.mainFrame;
    self.mainFrame = CGRectUnion(frame, self.frame);
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

-(void) destroy {
    if (self.expo != nil) {
        [self.expo destroy];
    }
    [self.strLenTbl removeAllObjects];
    self.strLenTbl = nil;
    [self removeFromSuperlayer];
}

@end
