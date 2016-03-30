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

-(id) init :(NSString *)pfx :(CGPoint)inputPos :(Equation *)E :(ViewController *)vc {
    self = [super init];
    if (self) {
        self.ancestor = E;
        self.guid = E.guid_cnt++;
        self.roll = E.curRoll;
        
        if (E.curFont == E.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
        
        CGPoint org = inputPos;
        CGFloat w = 0.0;
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: pfx];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)E.curFont.fontName, E.curFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, pfx.length)];
        CGSize strSize = [attStr size];
        
        self.title = [[CATextLayer alloc] init];
        self.title.contentsScale = [UIScreen mainScreen].scale;
        self.title.backgroundColor = [UIColor clearColor].CGColor;
        self.title.frame = CGRectMake(org.x, org.y, strSize.width, strSize.height);
        self.title.string = attStr;
        [E.view.layer addSublayer:self.title];
        
        org.x += strSize.width;
        w += strSize.width;
        
        self.left_parenth = [[Parentheses alloc] init:org :E :LEFT_PARENTH :vc];
        self.left_parenth.parent = self;
        [E.view.layer addSublayer:self.left_parenth];
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
        [E.view.layer addSublayer:layer];
        E.curTxtLyr = layer;
        E.curBlk = layer;
        
        self.parent = E.curParent;
        
        org.x += layer.mainFrame.size.width;
        w += layer.mainFrame.size.width;
        
        self.right_parenth = [[Parentheses alloc] init:org :E :RIGHT_PARENTH :vc];
        self.right_parenth.parent = self;
        [E.view.layer addSublayer:self.right_parenth];
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

-(void) destroy {
    [self.content destroy];
    [self.title removeFromSuperlayer];
    [self.left_parenth destroy];
    [self.right_parenth destroy];
}
@end
