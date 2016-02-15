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

@implementation WrapedEqTxtLyr
@synthesize guid;
@synthesize c_idx;
@synthesize parent;
@synthesize ancestor;
@synthesize is_base_expo;
@synthesize mainFrame;
@synthesize roll;
@synthesize prefix;
@synthesize content;
@synthesize suffix;

-(id) init : (NSString *)pfx : (CGPoint)inputPos : (Equation *)E {
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
        
        self.prefix = [[CATextLayer alloc] init];
        self.prefix.contentsScale = [UIScreen mainScreen].scale;
        self.prefix.backgroundColor = [UIColor clearColor].CGColor;
        self.prefix.frame = CGRectMake(org.x, org.y, strSize.width, strSize.height);
        self.prefix.string = attStr;
        [E.view.layer addSublayer:self.prefix];
        
        org.x += strSize.width;
        w += strSize.width;
        
        self.content = [[EquationBlock alloc] init:org :E];
        self.content.roll = ROLL_WRAP_ROOT;
        self.content.parent = self;
        self.content.ancestor = E;
        
        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :org :E :TEXTLAYER_EMPTY];
        layer.parent = self.content;
        self.content.numerFrame = layer.frame;
        self.content.mainFrame = layer.frame;
        
        layer.c_idx = 0;
        [self.content.children addObject:layer];
        [E.view.layer addSublayer:layer];
        E.curTxtLyr = layer;
        E.curBlk = layer;
        
        self.parent = E.curParent;
        E.curParent = self.content;
        
        org.x += layer.mainFrame.size.width;
        w += layer.mainFrame.size.width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString: @")"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        CFRelease(ctFont);
        strSize = [attStr size];
        
        self.suffix = [[CATextLayer alloc] init];
        self.suffix.contentsScale = [UIScreen mainScreen].scale;
        self.suffix.backgroundColor = [UIColor clearColor].CGColor;
        self.suffix.frame = CGRectMake(org.x, org.y, strSize.width, strSize.height);
        self.suffix.string = attStr;
        [E.view.layer addSublayer:self.suffix];
        
        w += strSize.width;
        
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
        self.prefix = [coder decodeObjectForKey:@"prefix"];
        self.content = [coder decodeObjectForKey:@"content"];
        self.suffix = [coder decodeObjectForKey:@"suffix"];
    }
    return self;
}



- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.roll forKey:@"roll"];
    [coder encodeInt:self.guid forKey:@"guid"];
    [coder encodeCGRect:self.mainFrame forKey:@"mainFrame"];
    [coder encodeInt:self.is_base_expo forKey:@"is_base_expo"];
    [coder encodeObject:self.prefix forKey:@"prefix"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeObject:self.suffix forKey:@"suffix"];
}

-(void) destroy {
    [self.content destroy];
    [self.prefix removeFromSuperlayer];
    [self.suffix removeFromSuperlayer];
}
@end
