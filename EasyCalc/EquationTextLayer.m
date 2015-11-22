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

-(id) init : (Equation *)e {
    self = [super init];
    if (self) {
        self.ancestor = e;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.guid = ++e.guid_cnt;
        self.roll = e.curRoll;
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
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: str];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)e.curFont.fontName, e.curFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, str.length)];
        if (t == TEXTLAYER_NUM || t == TEXTLAYER_PARENTH) {
            
        } else if (t == TEXTLAYER_OP) {
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)e.curFont.fontName, e.curFont.pointSize / 4.0, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(2, 1)];
        } else if (t == TEXTLAYER_EMPTY) {
            [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,str.length)];
        } else {
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        CGSize newStrSize = [attStr size];
        self.frame = CGRectMake(org.x, org.y, newStrSize.width, newStrSize.height);
        self.mainFrame = self.frame;
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.string = attStr;
        
        if (e.curFont == e.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
    }
    return self;
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
    
    [self removeFromSuperlayer];
}

@end
