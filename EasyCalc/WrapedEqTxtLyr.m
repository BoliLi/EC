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

@implementation WrapedEqTxtLyr
@synthesize guid;
@synthesize c_idx;
@synthesize parent;
@synthesize ancestor;
@synthesize is_base_expo;
@synthesize mainFrame;
@synthesize roll;
@synthesize title;
@synthesize content;
@synthesize left_parenth;
@synthesize right_parenth;
@synthesize fontLvl;
@synthesize isCopy;

-(id) init :(NSString *)pfx :(CGPoint)inputPos :(Equation *)E :(ViewController *)vc {
    self = [super init];
    if (self) {
        CalcBoard *calcB = E.par;
        self.ancestor = E;
        self.guid = E.guid_cnt++;
        self.roll = calcB.curRoll;
        self.is_base_expo = calcB.base_or_expo;
        self.fontLvl = calcB.curFontLvl;
        
        CGPoint org = inputPos;
        CGFloat w = 0.0;
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: pfx];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)calcB.curFont.fontName, calcB.curFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, pfx.length)];
        CGSize strSize = [attStr size];
        
        self.title = [[CATextLayer alloc] init];
        self.title.contentsScale = [UIScreen mainScreen].scale;
        self.title.backgroundColor = [UIColor clearColor].CGColor;
        self.title.frame = CGRectMake(org.x, org.y, strSize.width, strSize.height);
        self.title.string = attStr;
        [calcB.view.layer addSublayer:self.title];
        
        org.x += strSize.width;
        w += strSize.width;
        
        self.left_parenth = [[Parentheses alloc] init:org :E :LEFT_PARENTH :vc];
        self.left_parenth.parent = self;
        [calcB.view.layer addSublayer:self.left_parenth];
        [self.left_parenth setNeedsDisplay];
        
        org.x += self.left_parenth.frame.size.width;
        w += self.left_parenth.frame.size.width;
        
        self.content = [[EquationBlock alloc] init:org :E];
        self.content.roll = ROLL_WRAP_ROOT;
        self.content.parent = self;
        NSLog(@"%s%i>~%.1f~%.1f~~~~~~~~~", __FUNCTION__, __LINE__, org.x, org.y);
        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :org :E :TEXTLAYER_EMPTY];
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
        
        self.right_parenth = [[Parentheses alloc] init:org :E :RIGHT_PARENTH :vc];
        self.right_parenth.parent = self;
        [calcB.view.layer addSublayer:self.right_parenth];
        [self.right_parenth setNeedsDisplay];
        
        w += self.right_parenth.frame.size.width;
        
        self.mainFrame = CGRectMake(inputPos.x, inputPos.y, w, self.content.mainFrame.size.height);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.roll = [coder decodeIntForKey:@"roll"];
        self.guid = [coder decodeIntForKey:@"guid"];
        self.mainFrame = [coder decodeCGRectForKey:@"mainFrame"];
        self.is_base_expo = [coder decodeIntForKey:@"is_base_expo"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.content = [coder decodeObjectForKey:@"content"];
        self.left_parenth = [coder decodeObjectForKey:@"left_parenth"];
        self.right_parenth = [coder decodeObjectForKey:@"right_parenth"];
        self.fontLvl = [coder decodeIntForKey:@"fontLvl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.roll forKey:@"roll"];
    [coder encodeInt:self.guid forKey:@"guid"];
    [coder encodeCGRect:self.mainFrame forKey:@"mainFrame"];
    [coder encodeInt:self.is_base_expo forKey:@"is_base_expo"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeObject:self.left_parenth forKey:@"left_parenth"];
    [coder encodeObject:self.right_parenth forKey:@"right_parenth"];
    [coder encodeInt:self.fontLvl forKey:@"fontLvl"];
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
    copy.is_base_expo = self.is_base_expo;
    copy.fontLvl = self.fontLvl;
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
    if (self.fontLvl == lvl) {
        return;
    }
    
    UIFont *font = [UIFont systemFontOfSize:getFontSize(lvl)];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[self.title.string string]];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, attStr.length)];
    CFRelease(ctFont);
    
    CGRect f = self.title.frame;
    f.size = [attStr size];
    self.title.frame = f;
    
    self.title.string = attStr;
    
    [self.content updateSize:lvl];
    
    [self updateFrame:YES];
    
    self.fontLvl = lvl;
}

-(void) destroy {
    [self.content destroy];
    [self.title removeFromSuperlayer];
    [self.left_parenth destroy];
    [self.right_parenth destroy];
}
@end
