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
@synthesize charCnt;
@synthesize strLenTbl;

-(id) init : (Equation *)e {
    self = [super init];
    if (self) {
        self.ancestor = e;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = ++e.guid_cnt;
        self.roll = e.curRoll;
        self.charCnt = 0;
        self.strLenTbl = [NSMutableArray array];
        [self.strLenTbl addObject:@0.0];
        if (e.curFont == e.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
    }
    return self;
}

-(id) init : (NSString *)str : (CGPoint)org : (Equation *)e : (int)t {
    self = [super init];
    if (self) {
        self.ancestor = e;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = ++e.guid_cnt;
        self.roll = e.curRoll;
        self.type = t;
        self.name = str;
        self.charCnt = 0;
        self.strLenTbl = [NSMutableArray array];
        [self.strLenTbl addObject:@0.0];
        
        if (e.curFont == e.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
        
        NSMutableAttributedString *attStr;
        
        if (t == TEXTLAYER_NUM) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)e.curFont.fontName, e.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            
            [self.strLenTbl addObject:@(getCharWidth(is_base_expo, str))];
            self.charCnt++;
        } else if (t == TEXTLAYER_OP) {
//            NSString *s = @" ";
//            s = [s stringByAppendingString:str];
//            s = [s stringByAppendingString:@" "];
            
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)e.curFont.fontName, e.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            
//            ctFont = CTFontCreateWithName((CFStringRef)e.curFont.fontName, e.curFont.pointSize / 4.0, NULL);
//            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
//            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(2, 1)];
        } else if (t == TEXTLAYER_EMPTY) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)e.curFont.fontName, e.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
            [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,str.length)];
        } else if (t == TEXTLAYER_PARENTH) {
            attStr = [[NSMutableAttributedString alloc] initWithString: str];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)e.curFont.fontName, e.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
        } else {
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        CGSize newStrSize = [attStr size];
        self.frame = CGRectMake(org.x, org.y, newStrSize.width, newStrSize.height);
        self.mainFrame = self.frame;
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.string = attStr;
    }
    return self;
}

-(CGFloat) fillEmptyLayer:(NSString *)str oftype:(int)t {
    Equation *E = self.ancestor;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: str];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)E.curFont.fontName, E.curFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
    
    CGSize strSize = [attStr size];
    CGRect f = self.frame;
    f.size.width = strSize.width;
    f.size.height = strSize.height;
    self.frame = f;
    
    self.string = attStr;
    [self updateFrameBaseOnBase];
    
    [self.strLenTbl addObject:@(strSize.width)];
    
    self.charCnt++;
    
    self.type = t;
    
    return strSize.width;
}

-(CGFloat) addNumChar:(NSString *)str {
    Equation *E = self.ancestor;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: str];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)E.curFont.fontName, E.curFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
    
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
    CGFloat charW = getCharWidth(self.is_base_expo, str);
    [self.strLenTbl addObject:@(preStrLen + charW)];
    
    self.charCnt++;
    
    return [self.strLenTbl.lastObject doubleValue];
}

-(CGFloat) insertNumChar:(NSString *)str at:(int)idx {
    if (self.charCnt == 0) {
        return 0.0;
    }
    
    Equation *E = self.ancestor;
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: str];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)E.curFont.fontName, E.curFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
    
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
    CGFloat charW = getCharWidth(self.is_base_expo, str);
    [self.strLenTbl insertObject:@(preStrLen + charW) atIndex:idx + 1];
    self.charCnt++;
    
    for (int i = idx + 2; i < self.strLenTbl.count; i++) {
        NSNumber *len = [self.strLenTbl objectAtIndex:i];
        CGFloat orgLen = [len doubleValue];
        len = @(orgLen + charW);
    }
    
    return [[self.strLenTbl objectAtIndex:idx + 1] doubleValue];
}

-(CGFloat) delNumCharAt:(int)idx {
    if (self.charCnt <= 1) {
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
    self.charCnt--;
    
    for (int i = idx; i < self.strLenTbl.count; i++) {
        NSNumber *len = [self.strLenTbl objectAtIndex:i];
        CGFloat orgLen = [len doubleValue];
        len = @(orgLen - charW);
    }
    
    return [[self.strLenTbl objectAtIndex:idx - 1] doubleValue];
}

-(int) getTxtInsIdx: (CGPoint) p {
    NSMutableArray *arr = self.strLenTbl;
    int target = (int)(p.x - self.frame.origin.x);
    int mid, left = 0, right = arr.count - 1;
    
    while(left <= right) {
        mid = (left + right) / 2;
        int value = [[arr objectAtIndex:mid] intValue];
        if(value == target)
            return mid;
        if(value > target)
            right = mid - 1;
        else
            left = mid + 1;
    }
    
    if (left == arr.count) {
        return right;
    } else if(right < 0) {
        return left;
    } else {
        int leftV = [[arr objectAtIndex:right] intValue];
        int rightV = [[arr objectAtIndex:left] intValue];
        if (abs(leftV - target) < abs(target - rightV)) {
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

-(void) destroy {
    if (self.expo != nil) {
        [self.expo destroy];
    }
    [self.strLenTbl removeAllObjects];
    self.strLenTbl = nil;
    [self removeFromSuperlayer];
}

@end
